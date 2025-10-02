import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/app/router.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/pages/orders/view_orders.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';

class ReturnandRefundOrders extends StatelessWidget {
  const ReturnandRefundOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width / 80,
                  horizontal: MediaQuery.of(context).size.width / 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Return & Refund Orders',
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    sortingCard(context),
                    contextCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sortingCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 30,
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
        children: [
          Text('Status'),
          const SizedBox(width: 8),
          DropdownButton(items: null, onChanged: null),
          const SizedBox(width: 16),
          Text('Date'),
          const SizedBox(width: 8),
          DropdownButton(items: null, onChanged: null),
        ],
      ),
    );
  }

  Widget contextCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;

          // Define consistent column widths
          final wOrderId = totalWidth * 0.15;
          final wProduct = totalWidth * 0.16;
          final wCustomer = totalWidth * 0.15;
          final wDate = totalWidth * 0.15;
          final wTotal = totalWidth * 0.08;
          final wStatus = totalWidth * 0.10;
          final wRequest = totalWidth * 0.10;
          final wActions = totalWidth * 0.07;

          Widget headerCell(String text, double width) {
            return SizedBox(
              width: width,
              child: Text(
                text,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          }

          Widget rowCell(String text, double width,
              {Color? color, bool bold = false}) {
            return SizedBox(
              width: width,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black,
                  fontSize: 12,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  headerCell("Order ID", wOrderId),
                  headerCell("Product Details", wProduct),
                  headerCell("Customer Name", wCustomer),
                  headerCell("Date", wDate),
                  headerCell("Total", wTotal),
                  headerCell("Order Status", wStatus),
                  headerCell("Request Status", wRequest),
                  headerCell("Actions", wActions),
                ],
              ),
              const Divider(),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where("status", isEqualTo: "Return&Refund")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No orders available"));
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final doc = orders[index];
                      final order = doc.data() as Map<String, dynamic>;
                      final cartItems =
                          List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
                      final userDetails =
                          order["userDetails"] as Map<String, dynamic>? ?? {};
                      final orderDate = (order["timestamp"] is Timestamp)
                          ? DateFormat('MMM dd, yyyy – hh:mm a').format(
                              (order["timestamp"] as Timestamp).toDate(),
                            )
                          : "-";

                      return Container(
                        key: ValueKey(doc.id),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            rowCell(doc.id, wOrderId),
                            SizedBox(
                              width: wProduct,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: cartItems.map((item) {
                                  final imageUrl = item["productImages"] is String
                                      ? item["productImages"]
                                      : (item["productImages"] as List?)?.isNotEmpty == true
                                          ? item["productImages"][0]
                                          : "https://via.placeholder.com/80";

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            imageUrl,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item["productName"] ?? "No name",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                "x${item["quantity"] ?? 1} • ₱${item["productPrice"] ?? 0}",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 11,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            rowCell(userDetails["full_name"] ?? "N/A", wCustomer),
                            rowCell(orderDate, wDate),
                            rowCell("₱${order["total"] ?? 0}", wTotal, bold: true),
                            rowCell(order["status"] ?? "Return & Refund", wStatus,
                                color: Colors.orange.shade800, bold: true),
                            rowCell(order["status1"] ?? "Pending", wRequest,
                                color: Colors.blue.shade800, bold: true),
                            SizedBox(
                              width: wActions,
                              child: Row(
                                children: [
                                    IconButton(
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(),
    icon: const Icon(Icons.check, color: AppColors.color8),
    onPressed: () async {
      try {
        await FirebaseFirestore.instance
            .collection("orders")
            .doc(doc.id)
            .update({"status1": "approved"});

        Get.snackbar(
          "Success",
          "Order has been approved",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        Get.snackbar(
        "Error",
        "Failed to approve: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 2),
      );
    }
  },
),

                                  SizedBox(
                                    width: wActions / 8,
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.remove_red_eye,
                                        color: AppColors.color8),
                                    onPressed: () {
                                       Get.to(() => ViewOrders(
    orderData: order,
    orderId: doc.id,
    orderType: "Return&Refund",
  ));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
