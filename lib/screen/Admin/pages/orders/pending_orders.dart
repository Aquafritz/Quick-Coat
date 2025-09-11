import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';

class PendingOrders extends StatelessWidget {
  const PendingOrders({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
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
                  'Pending Orders',
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
    );
  }

  Widget sortingCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
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
          DropdownButton(items: null, onChanged: null),
          Text('Date'),
          DropdownButton(items: null, onChanged: null),
        ],
      ),
    );
  }

  Widget contextCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 3.1,
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

          // Define fixed widths for each column
          final wOrderId = totalWidth * 0.12;
          final wProduct = totalWidth * 0.20;
          final wCustomer = totalWidth * 0.16;
          final wDate = totalWidth * 0.16;
          final wTotal = totalWidth * 0.10;
          final wStatus = totalWidth * 0.08;
          final wActions = totalWidth * 0.06;

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

          Widget rowCell(
            String text,
            double width, {
            Color? color,
            bool bold = false,
          }) {
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
              // Header row
              Row(
                children: [
                  headerCell("Order ID", wOrderId),
                  headerCell("Product Details", wProduct),
                  headerCell("Customer Name", wCustomer),
                  headerCell("Date", wDate),
                  headerCell("Total", wTotal),
                  headerCell("Status", wStatus),
                  headerCell("Actions", wActions),
                ],
              ),
              const Divider(),
              // Orders list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection("orders")
                          .where("status", isEqualTo: "Pending") 
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
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final doc = orders[index];
                        final order = doc.data() as Map<String, dynamic>;
                        final cartItems = List<Map<String, dynamic>>.from(
                          order["cartItems"] ?? [],
                        );
                        final userDetails =
                            order["userDetails"] as Map<String, dynamic>? ?? {};
                        final orderDate =
                            (order["timestamp"] is Timestamp)
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
                              // Order ID
                              rowCell(doc.id, wOrderId),
                              // Product Details
                              // Product Details column
                              SizedBox(
                                width: wProduct,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      cartItems.map((item) {
                                        final imageUrl =
                                            item["productImage"] is String
                                                ? item["productImage"]
                                                : (item["productImage"]
                                                            as List?)
                                                        ?.isNotEmpty ==
                                                    true
                                                ? item["productImage"][0]
                                                : "https://via.placeholder.com/80";

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              // ❌ remove Expanded, use SizedBox with max width
                                              SizedBox(
                                                width:
                                                    wProduct -
                                                    50, // make room for image & spacing
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item["productName"] ??
                                                          "No name",
                                                      style: GoogleFonts.roboto(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      "x${item["quantity"] ?? 1} • ₱${item["productPrice"] ?? 0}",
                                                      style: GoogleFonts.roboto(
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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

                              // Customer
                              rowCell(
                                userDetails["full_name"] ?? "N/A",
                                wCustomer,
                              ),
                              // Date
                              rowCell(orderDate, wDate),
                              // Total
                              rowCell(
                                "₱${order["total"] ?? 0}",
                                wTotal,
                                bold: true,
                              ),
                              // Status
                              rowCell(
                                order["status"] ?? "Pending",
                                wStatus,
                                color: Colors.orange.shade700,
                                bold: true,
                              ),
                              // Actions
                              SizedBox(
                                width: wActions,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.remove_red_eye, color: AppColors.color8,),
                                      onPressed: () {},
                                    ),
                                     IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.check, color: AppColors.color8),
        onPressed: () async {
          try {
            await FirebaseFirestore.instance
                .collection("orders")
                .doc(doc.id)
                .update({"status": "Process"});

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Order status updated to Process ✅"),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to update: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
      IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.cancel, color: Colors.red),
        onPressed: () async {
          try {
            await FirebaseFirestore.instance
                .collection("orders")
                .doc(doc.id)
                .update({"status": "Cancelled"});

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Order status updated to Cancelled ❌"),
                backgroundColor: Colors.red,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to update: $e"),
                backgroundColor: Colors.red,
              ),
            );
          }
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
              ),
            ],
          );
        },
      ),
    );
  }
}
