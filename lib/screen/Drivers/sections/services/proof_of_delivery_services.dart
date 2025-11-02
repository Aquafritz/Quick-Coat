import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProofOfDeliveryService {
  final ImagePicker _picker = ImagePicker();
  final supabase = Supabase.instance.client;

  Future<void> uploadProof({
    required String orderId,
    required List<Map<String, dynamic>> cartItems,
    required BuildContext context,
  }) async {
    try {
      Uint8List? webImageBytes;
      File? mobileFile;
      String filename;

      if (kIsWeb) {
        // ✅ Web: use FilePicker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true, // important for web
        );

        if (result == null || result.files.single.bytes == null) return;

        webImageBytes = result.files.single.bytes!;
        filename = result.files.single.name;
      } else {
        // ✅ Mobile: use ImagePicker
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (picked == null) return;

        mobileFile = File(picked.path);
        filename = path.basename(picked.path);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final driverId =
          FirebaseAuth.instance.currentUser?.uid ?? 'unknown_driver';

      final supabasePath =
          'proof_of_delivery/$orderId/${driverId}_$timestamp\_$filename';

      // ✅ Upload to Supabase
      if (kIsWeb && webImageBytes != null) {
        await supabase.storage.from('QuickCoat').uploadBinary(
              supabasePath,
              webImageBytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else if (mobileFile != null) {
        await supabase.storage.from('QuickCoat').upload(
              supabasePath,
              mobileFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );
      }

      // ✅ Get public URL
      final downloadUrl =
          supabase.storage.from('QuickCoat').getPublicUrl(supabasePath);

      // ✅ Firestore batch update
      final ordersRef =
          FirebaseFirestore.instance.collection('orders').doc(orderId);
      final driverParcelRef =
          FirebaseFirestore.instance.collection('assigned_driver_parcel').doc(driverId);

      final batch = FirebaseFirestore.instance.batch();

      // Update `orders`
      batch.set(ordersRef, {
        "proofOfDelivery": FieldValue.arrayUnion([downloadUrl]),
      }, SetOptions(merge: true));

      // Update `assigned_driver_parcel`
      final driverParcelSnapshot = await driverParcelRef.get();
      if (driverParcelSnapshot.exists) {
        final data = driverParcelSnapshot.data() as Map<String, dynamic>;
        final orders = (data['orders'] as Map<String, dynamic>?) ?? {};

        if (orders.containsKey(orderId)) {
          final orderMap = Map<String, dynamic>.from(orders[orderId]);
          final existingProofs = List.from(orderMap['proofOfDelivery'] ?? []);
          existingProofs.add(downloadUrl);
          orderMap['proofOfDelivery'] = existingProofs;

          batch.set(driverParcelRef, {
            'orders': {orderId: orderMap},
          }, SetOptions(merge: true));
        } else {
          batch.set(driverParcelRef, {
            'orders': {
              orderId: {
                'orderId': orderId,
                'proofOfDelivery': [downloadUrl],
                'cartItems': cartItems,
              },
            },
          }, SetOptions(merge: true));
        }
      } else {
        batch.set(driverParcelRef, {
          'driverId': driverId,
          'assignedAt': FieldValue.serverTimestamp(),
          'orders': {
            orderId: {
              'orderId': orderId,
              'proofOfDelivery': [downloadUrl],
              'cartItems': cartItems,
            },
          },
        }, SetOptions(merge: true));
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proof of delivery uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload proof: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Optional: mark order as delivered
  Future<void> markOrderDelivered(String orderId, BuildContext context) async {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    try {
      final batch = FirebaseFirestore.instance.batch();

      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);
      batch.update(orderRef, {
        'status': 'Delivered',
        'deliveredAt': FieldValue.serverTimestamp(),
      });

      final driverParcelRef = FirebaseFirestore.instance
          .collection('assigned_driver_parcel')
          .doc(driverId);
      final driverParcelSnapshot = await driverParcelRef.get();

      if (driverParcelSnapshot.exists) {
        final data = driverParcelSnapshot.data() as Map<String, dynamic>;
        final orders = (data['orders'] as Map<String, dynamic>?) ?? {};

        if (orders.containsKey(orderId)) {
          final orderMap = Map<String, dynamic>.from(orders[orderId]);
          orderMap['status'] = 'Delivered';
          orderMap['deliveredAt'] = FieldValue.serverTimestamp();
          batch.set(driverParcelRef, {
            'orders': {orderId: orderMap},
          }, SetOptions(merge: true));
        }
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order marked Delivered'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark Delivered: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> markDeliveryFailed(BuildContext context, String orderId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final driverId = FirebaseAuth.instance.currentUser?.uid ?? "unknown_driver";

  String? selectedReason;
  final TextEditingController otherReasonController = TextEditingController();

  final List<String> reasons = [
    "Customer not answering phone calls",
    "Customer not at the delivery address",
    "No one available to receive the parcel",
    "Customer requested to reschedule delivery",
    "Delivery address is incomplete or incorrect",
    "Bad weather or inaccessible location",
    "Other",
  ];

  // 🪟 Show dialog (responsive)
  await showDialog(
    context: context,
    builder: (context) {
      final isMobile = MediaQuery.of(context).size.width < 600;
      final dialogWidth =
          isMobile ? MediaQuery.of(context).size.width * 0.9 : 400.0;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              "Failed to Deliver",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: dialogWidth,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      hint: const Text("Select reason"),
                      isExpanded: true,
                      items: reasons.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      onChanged: (v) {
                        setState(() => selectedReason = v);
                      },
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedReason == "Other")
                      TextField(
                        controller: otherReasonController,
                        decoration: InputDecoration(
                          labelText: "Enter other reason",
                          hintText: "Please describe the issue",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                      ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (selectedReason == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select a reason.")),
                    );
                    return;
                  }

                  if (selectedReason == "Other" &&
                      otherReasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please enter your reason for 'Other'.")),
                    );
                    return;
                  }

                  final reason = selectedReason == "Other"
                      ? otherReasonController.text.trim()
                      : selectedReason!;

                  Navigator.pop(context);
                  await _recordDeliveryAttempt(context, orderId, reason, driverId);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  child: Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _recordDeliveryAttempt(
    BuildContext context, String orderId, String reason, String driverId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final orderRef = firestore.collection('orders').doc(orderId);
  final driverParcelRef =
      firestore.collection('assigned_driver_parcel').doc(driverId);

  try {
    final snapshot = await orderRef.get();
    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order not found.")),
      );
      return;
    }

    final data = snapshot.data()!;
    int attempts = (data['deliveryAttempts'] ?? 0) + 1;

    // 📝 Save attempt in subcollection
    await orderRef.collection('delivery_attempts').add({
      'attemptNumber': attempts,
      'reason': reason,
      'driverId': driverId,
      'status': 'Failed',
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (attempts >= 3) {
      // 🚫 3rd failed attempt — mark as Cancelled
      await orderRef.update({
        'status': 'Cancelled',
        'deliveryAttempts': attempts,
        'cancelledReason': '3 failed delivery attempts',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // 🧹 Remove this order from assigned_driver_parcel
      final driverDoc = await driverParcelRef.get();
      if (driverDoc.exists) {
        final data = driverDoc.data() as Map<String, dynamic>;
        final orders = (data['orders'] ?? {}) as Map<String, dynamic>;

        if (orders.containsKey(orderId)) {
          orders.remove(orderId); // Remove this order

          // If no more orders, delete the whole document
          if (orders.isEmpty) {
            await driverParcelRef.delete();
          } else {
            await driverParcelRef.update({'orders': orders});
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "3rd failed attempt — order cancelled and removed from driver parcel.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // 🟠 For 1st or 2nd attempt
      await orderRef.update({
        'status': "Attempt $attempts Failed",
        'deliveryAttempts': attempts,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Attempt $attempts recorded: $reason"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    debugPrint("Error saving delivery attempt: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

}
