import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getNextProductId() async {
    final snapshot = await _firestore.collection('products').get();
    if (snapshot.docs.isEmpty) return 1;

    final List<int> ids =
        snapshot.docs
            .map((doc) => (doc['productId'] as int?) ?? 0)
            .where((id) => id > 0)
            .toList();
    ids.sort();

    for (int i = 1; i <= ids.last; i++) {
      if (!ids.contains(i)) return i;
    }

    return ids.last + 1;
  }

  Future<List<String>> uploadImages(
    int productId,
    List<Uint8List> images,
  ) async {
    List<String> uploadedUrls = [];
    try {
      for (int i = 0; i < images.length; i++) {
        final filePath = "products/product_${productId}_$i.png";

        await _supabase.storage
            .from('QuickCoat')
            .uploadBinary(
              filePath,
              images[i],
              fileOptions: const FileOptions(upsert: true),
            );

        final publicUrl = _supabase.storage
            .from('QuickCoat')
            .getPublicUrl(filePath);
        uploadedUrls.add(publicUrl);
      }
    } catch (e) {
      throw Exception("Failed to upload images: $e");
    }

    return uploadedUrls;
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String price,
    required List<Map<String, dynamic>> variants,
    required List<String> imageUrls,
  }) async {
    final nextId = await getNextProductId();

    await _firestore.collection("products").add({
      "productId": nextId,
      "productName": name,
      "productDescription": description,
      "productPrice": price,
      "productVariants": variants,
      "productImages": imageUrls,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required int productId,
    required String name,
    required String description,
    required String price,
    required List<Map<String, dynamic>> variants,
  }) async {
    final query =
        await _firestore
            .collection("products")
            .where("productId", isEqualTo: productId)
            .limit(1)
            .get();

    if (query.docs.isEmpty) throw Exception("Product not found");

    final docId = query.docs.first.id;

    await _firestore.collection("products").doc(docId).update({
      "productName": name,
      "productDescription": description,
      "productPrice": price,
      "productVariants": variants,
    });
  }

  Future<void> deleteProduct({required int productId}) async {
    final query =
        await _firestore
            .collection('products')
            .where('productId', isEqualTo: productId)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      throw Exception("Product not found");
    }

    final doc = query.docs.first;
    final docId = doc.id;

    final List<dynamic> imageUrls = doc['productImages'] ?? [];
    for (String url in imageUrls) {
      try {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        final filePathIndex = pathSegments.indexOf('public') + 2;
        if (filePathIndex < pathSegments.length) {
          final filePath = pathSegments.sublist(filePathIndex).join('/');
          await _supabase.storage.from('QuickCoat').remove([filePath]);
        }
      } catch (e) {
        print("Failed to delete image $url: $e");
      }
    }

    await _firestore.collection('products').doc(docId).delete();
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> addToCart({
    required Map<String, dynamic> product,
    required int quantity,
    required String? selectedSize,
    required String? selectedColor,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final cartsRef = _firestore.collection("carts");

      final productImages = (product["productImages"] as List?) ?? [];
      final String productImage =
          productImages.isNotEmpty ? productImages.first : "";

      final existing =
          await cartsRef
              .where("userId", isEqualTo: user.uid)
              .where("productId", isEqualTo: product["productId"])
              .where("selectedSize", isEqualTo: selectedSize)
              .where("selectedColor", isEqualTo: selectedColor)
              .limit(1)
              .get();

      if (existing.docs.isNotEmpty) {
        final docId = existing.docs.first.id;
        await cartsRef.doc(docId).update({
          "quantity": FieldValue.increment(quantity),
          "updatedAt": FieldValue.serverTimestamp(),
        });
      } else {
        final cartItem = {
          "userId": user.uid,
          "productId": product["productId"],
          "productName": product["productName"],
          "productPrice":
              double.tryParse(product["productPrice"].toString()) ?? 0,
          "quantity": quantity,
          "selectedSize": selectedSize,
          "selectedColor": selectedColor,
          "productImages": productImage,
          "createdAt": FieldValue.serverTimestamp(),
        };

        await cartsRef.add(cartItem);
      }
    } catch (e) {
      throw Exception("Failed to add to cart: $e");
    }
  }
}
