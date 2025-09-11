import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';

class ShoppingCart extends StatefulWidget {
  const ShoppingCart({super.key});

  @override
  State<ShoppingCart> createState() => _ShoppingCartState();
}

final Map<String, bool> selectedItems = {};

class _ShoppingCartState extends State<ShoppingCart> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              HeaderWithout(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopping Cart',
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection("carts")
                              .where("userId", isEqualTo: user?.uid)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("Your cart is empty"),
                          );
                        }

                        final cartItems = snapshot.data!.docs;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children:
                                    cartItems.map((doc) {
                                      final item =
                                          doc.data() as Map<String, dynamic>;
                                      return CartItemWidget(
                                        context,
                                        item,
                                        doc.id,
                                      );
                                    }).toList(),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 25,
                            ),
                            Expanded(
                              flex: 1,
                              child: OrderSummaryWidget(context, cartItems),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget CartItemWidget(
    BuildContext context,
    Map<String, dynamic> item,
    String docId,
  ) {
    selectedItems.putIfAbsent(docId, () => true);

    final imageUrl =
        item["productImage"] is String
            ? item["productImage"]
            : (item["productImage"] as List?)?.isNotEmpty == true
            ? item["productImage"][0]
            : "https://via.placeholder.com/100";

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  "https://via.placeholder.com/100",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width / 80),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["productName"] ?? "No name",
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 250),
                Text(
                  "Size: ${item["selectedSize"] ?? "-"} | Color: ${item["selectedColor"] ?? "-"}",
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 110,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 250),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if ((item["quantity"] ?? 1) > 1) {
                                FirebaseFirestore.instance
                                    .collection("carts")
                                    .doc(docId)
                                    .update({
                                      "quantity": FieldValue.increment(-1),
                                    });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              child: const Icon(Icons.remove, size: 20),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              "${item["quantity"] ?? 1}",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              FirebaseFirestore.instance
                                  .collection("carts")
                                  .doc(docId)
                                  .update({
                                    "quantity": FieldValue.increment(1),
                                  });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.grey.shade400),
                                ),
                              ),
                              child: const Icon(Icons.add, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₱${item["productPrice"]}",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 90,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("carts")
                                .doc(docId)
                                .delete();
                            setState(() {
                              selectedItems.remove(docId);
                            });
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                        Checkbox(
                          value: selectedItems[docId],
                          onChanged: (value) {
                            setState(() {
                              selectedItems[docId] = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget OrderSummaryWidget(
    BuildContext context,
    List<QueryDocumentSnapshot> cartItems,
  ) {
    double subtotal = 0;
    for (var doc in cartItems) {
      final item = doc.data() as Map<String, dynamic>;
      if (selectedItems[doc.id] == true) {
        subtotal += (item["productPrice"] ?? 0) * (item["quantity"] ?? 0);
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Summary",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal"),
              Text("₱${subtotal.toStringAsFixed(2)}"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text("Shipping"), Text("Free")],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "₱${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final selectedMaps =
                    cartItems.where((doc) => selectedItems[doc.id] == true).map(
                      (doc) {
                        final map = doc.data() as Map<String, dynamic>;
                        map['id'] = doc.id;
                        return map;
                      },
                    ).toList();
                Get.toNamed('/checkOut', arguments: selectedMaps);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color8,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Proceed to Checkout",
                style: GoogleFonts.roboto(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Get.toNamed('/costumerHome'),
              child: Text(
                "Continue Shopping",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: AppColors.color8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}