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
}
