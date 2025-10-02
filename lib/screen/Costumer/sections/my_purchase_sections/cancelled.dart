import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

Widget buildCancelled() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please sign in to see your orders"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: user.uid)
              .where("status", isEqualTo: "Cancelled")
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No pending orders"));
        }

        final orders = snapshot.data!.docs;

        return Column(
          children:
              orders.map((doc) {
                final order = doc.data() as Map<String, dynamic>;
                final cartItems = List<Map<String, dynamic>>.from(
                  order["cartItems"] ?? [],
                );

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order: ${doc.id}",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 80,
                            ),
                          ),
                          Text(
                            order['status'] ?? "Pending",
                            style: GoogleFonts.roboto(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children:
                            cartItems.map((item) {
                              final imageUrl =
                                  item["productImages"] is String
                                      ? item["productImages"]
                                      : (item["productImages"] as List?)
                                              ?.isNotEmpty ==
                                          true
                                      ? item["productImages"][0]
                                      : "https://via.placeholder.com/100";
                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["productName"] ?? "No name",
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  90,
                                            ),
                                          ),
                                          Text(
                                            "Size: ${item["selectedSize"] ?? "-"} | Color: ${item["selectedColor"] ?? "-"}",
                                            style: GoogleFonts.roboto(
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  110,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("x${item["quantity"] ?? 1}"),
                                              Text(
                                                "₱${item["productPrice"]}",
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width /
                                                      90,
                                                ),
                                              ),
                                            ],
                                          ),
                                           Text(
                            order['timestamp'] != null
                                ? DateFormat(
                                  "MMMM dd, yyyy 'at' hh:mm:ss a",
                                ).format(
                                  (order['timestamp'] as Timestamp)
                                      .toDate()
                                      .toLocal(),
                                )
                                : "",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 110,
                              color: Colors.grey,
                            ),
                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ₱${order['total']}",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 85,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 5,
                            child: Text(
                              "Cancellation Reason: ${order['cancelReason']}",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width / 85,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }