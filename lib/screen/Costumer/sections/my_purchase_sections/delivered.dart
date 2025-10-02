import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

Widget buildDelivered() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Center(child: Text("Please sign in to see your orders"));
  }

  return StreamBuilder<QuerySnapshot>(
    stream:
        FirebaseFirestore.instance
            .collection("orders")
            .where("userId", isEqualTo: user.uid)
            .where("status", isEqualTo: "Delivered")
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
                                                (order['timestamp']
                                                        as Timestamp)
                                                    .toDate()
                                                    .toLocal(),
                                              )
                                              : "",
                                          style: GoogleFonts.roboto(
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                110,
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
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                          ),
                          onPressed: () {
                            showReturnRefundDialog(
                              context,
                              doc.id,
                            ); // Pass order ID
                          },
                          child: Text(
                            'Request Reutrn&Refund',
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 90,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
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

void showReturnRefundDialog(BuildContext context, String orderId) {
  final TextEditingController reasonController = TextEditingController();
  String? selectedReason; // Dropdown selection for reason type

  final List<String> reasons = [
    'Damaged Item',
    'Wrong Item Delivered',
    'Item Not as Described',
    'Other',
  ];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Return & Refund',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          height: MediaQuery.of(context).size.width / 5,
          width: MediaQuery.of(context).size.width / 4,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select reason for return & refund:',
                  style: GoogleFonts.roboto(),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  items:
                      reasons
                          .map(
                            (reason) => DropdownMenuItem<String>(
                              value: reason,
                              child: Text(reason, style: GoogleFonts.roboto()),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedReason = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: reasonController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Add more details (optional)...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (selectedReason == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a reason')),
                    );
                    return;
                  }

                  final details = reasonController.text.trim();

                  // Update Firestore order with return/refund info
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderId)
                      .update({
                        'status1': 'pending',
                        'status': 'Return&Refund',
                        'returnReason': selectedReason,
                        'returnDetails': details,
                        'returnRequestedAt': Timestamp.now(),
                      });

                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Return & refund requested successfully'),
                    ),
                  );
                },
                child: Text(
                  'Submit',
                  style: GoogleFonts.roboto(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
