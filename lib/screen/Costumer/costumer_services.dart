import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerServices {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  final supabase = Supabase.instance.client;
  static String? get uid => _auth.currentUser?.uid;

  static Future<void> saveUserData({
    required String fullName,
    required String phoneNumber,
    required String dob,
    required String gender,
    String? profilePicture,
  }) async {
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set({
      'full_name': fullName,
      'phone_number': phoneNumber,
      'date_of_birth': dob,
      'gender': gender,
      if (profilePicture != null) 'profile_picture': profilePicture,
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> loadUserData() async {
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> addAddress({
    required String label,
    required String houseNumber,
    required String street,
    required String barangay,
    required String cityMunicipality,
    required String province,
    required String postalCode,
    required String country,
  }) async {
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('addresses').add({
      'label': label,
      'house_number': houseNumber,
      'street': street,
      'barangay': barangay,
      'city_municipality': cityMunicipality,
      'province': province,
      'postal_code': postalCode,
      'country': country,
      'is_default': false,
    });
  }

  static Future<void> deleteAddress(String addressId) async {
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  static Future<void> setDefaultAddress(String addressId) async {
    if (uid == null) return;

    final addressRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses');

    final snapshot = await addressRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.update({'is_default': false});
    }

    await addressRef.doc(addressId).update({'is_default': true});
  }

  static Stream<QuerySnapshot> streamAddresses() {
    if (uid == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots();
  }

  static Future<String?> uploadProfilePicture(Uint8List bytes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final fileName = "$uid-${DateTime.now().millisecondsSinceEpoch}.png";

      await Supabase.instance.client.storage
          .from("QuickCoat/profile_pictures")
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = Supabase.instance.client.storage
          .from("QuickCoat/profile_pictures")
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print("❌ Failed to upload: $e");
      return null;
    }
  }

  static Future<void> updateAddress({
  required String addressId,
  required String label,
  required String houseNumber,
  required String street,
  required String barangay,
  required String cityMunicipality,
  required String province,
  required String postalCode,
  required String country,
}) async {
  if (uid == null) return;

  await _firestore
      .collection('users')
      .doc(uid)
      .collection('addresses')
      .doc(addressId)
      .update({
    'label': label,
    'house_number': houseNumber,
    'street': street,
    'barangay': barangay,
    'city_municipality': cityMunicipality,
    'province': province,
    'postal_code': postalCode,
    'country': country,
  });

}

static Future<void> placeOrder({
  required Map<String, dynamic>? userDetails,
  required List<Map<String, dynamic>> cartItems,
  required Map<String, dynamic>? selectedAddress,
}) async {
  if (uid == null) return;

  try {
    double subtotal = 0;
    for (var item in cartItems) {
      final quantity = item['quantity'] ?? 1;
      final price = double.tryParse(item['productPrice'].toString()) ?? 0;
      subtotal += price * quantity;
    }

    final orderData = {
      "userId": uid,
      "userDetails": userDetails,
      "cartItems": cartItems,
      "selectedAddress": selectedAddress,
      "subtotal": subtotal,
      "shipping": "Free",
      "total": subtotal,
      "status": "Pending",
      "timestamp": FieldValue.serverTimestamp(),
    };

    await _firestore.collection("orders").add(orderData);

    for (var item in cartItems) {
      final docId = item['id']; // each map should include the Firestore doc ID
      final quantity = item['quantity'] ?? 1;
      final productId = item['productId'];
      final size = item['selectedSize'];
      final color = item['selectedColor'];

      // Delete cart item
      await _firestore.collection("carts").doc(docId).delete();

      // Update product stock
      final query = await _firestore
          .collection("products")
          .where("productId", isEqualTo: productId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final productDoc = query.docs.first;
        final variants =
            List<Map<String, dynamic>>.from(productDoc['productVariants']);

        final updatedVariants = variants.map((variant) {
          if (variant['productSize'] == size &&
              variant['productColor'].toString().toLowerCase() ==
                  color.toString().toLowerCase()) {
            final currentStock = (variant['productQuantity'] ?? 0) as int;
            variant['productQuantity'] =
                (currentStock - quantity).clamp(0, double.infinity).toInt();
          }
          return variant;
        }).toList();

        await _firestore
            .collection("products")
            .doc(productDoc.id)
            .update({"productVariants": updatedVariants});
      }
    }
  } catch (e) {
    print("Error placing order: $e");
    rethrow;
  }
}

}
