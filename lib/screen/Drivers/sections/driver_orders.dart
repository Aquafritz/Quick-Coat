import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_delivery.dart';

class DriverOrders extends StatefulWidget {
  const DriverOrders({super.key});

  @override
  State<DriverOrders> createState() => _DriverOrdersState();
}

class _DriverOrdersState extends State<DriverOrders> {
  String selected = "assigned"; // default view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 20,
          vertical: MediaQuery.of(context).size.width / 20,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Orders",
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width / 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              dashboardCard(context),
              SizedBox(height: MediaQuery.of(context).size.width / 20),
              if (selected == 'assigned') assigned(context),
              if (selected == 'completed') completed(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context) {
    final tabWidth = MediaQuery.of(context).size.width / 2; // half width
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 7,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.color8,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 🔹 Sliding Highlight
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment:
                selected == "assigned"
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
            child: Container(
              width: tabWidth - 8,
              height: MediaQuery.of(context).size.width / 9,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Row with equal slots
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selected = "assigned"),
                  child: Center(
                    child: Text(
                      "Assigned",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            selected == "assigned"
                                ? Colors.black
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selected = "completed"),
                  child: Center(
                    child: Text(
                      "Completed",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            selected == "completed"
                                ? Colors.black
                                : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget assigned(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("assigned_driver_parcel")
              .doc(driverId) // fetch only the current driver’s assigned orders
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No deliveries assigned yet"));
        }

        final driverData = snapshot.data!.data() as Map<String, dynamic>;
        final assignedOrders =
            driverData["orders"] as Map<String, dynamic>? ?? {};

        final shippedOrders =
            assignedOrders.entries
                .where((entry) => entry.value["status"] == "Shipped")
                .toList();

        if (shippedOrders.isEmpty) {
          return const Center(child: Text("No deliveries today"));
        }

        return Column(
          children:
              shippedOrders.map((entry) {
                final order = entry.value as Map<String, dynamic>;
                final orderId = order["orderId"] ?? entry.key;
                final status = order["status"] ?? "In Progress";
                final total = order["total"] ?? 0;
                final cartItems = List<Map<String, dynamic>>.from(
                  order["cartItems"] ?? [],
                );
                final address = order["selectedAddress"] ?? {};
                final userDetails = order["userDetails"] ?? {}; // ✅ fix here

                return Container(
                  width: MediaQuery.of(context).size.width / 1.15,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: AppColors.color8,
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
                      // 🔵 Blue left bar
                      Container(
                        width: 8.5,
                        decoration: const BoxDecoration(
                          color: AppColors.color8,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width / 20,
                              horizontal:
                                  MediaQuery.of(context).size.width / 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 Order Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order # $orderId',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                            30,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.color5,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                30,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 30,
                                ),

                                // 🔹 Show all cart items
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      cartItems.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 🖼 Product Image
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  item["productImages"] ?? "",
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // 📦 Product Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item["productName"] ??
                                                          "Unknown",
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            30,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Qty: ${item["quantity"]} • ₱${item["productPrice"]}",
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            35,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Size: ${item["selectedSize"] ?? "-"} • Color: ${item["selectedColor"] ?? "-"}",
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            35,
                                                        fontWeight:
                                                            FontWeight.w400,
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

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 30,
                                ),

                                // 🔹 Address
                                Row(
                                  children: [
                                    const Icon(Icons.location_city_outlined),
                                    Expanded(
                                      child: Text(
                                        '${address["house_number"] ?? ""} ${address["barangay"] ?? ""}, ${address["city_municipality"] ?? ""}',
                                        style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width /
                                              35,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 90,
                                ),

                                const Divider(),

                                // 🔹 Footer (Total + Details button)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₱ ${total.toStringAsFixed(2)}',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                            22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(
                                          () => DriverDelivery(
                                            order: {
                                              "orderId": orderId,
                                              "status": status,
                                              "total": total,
                                              "cartItems": cartItems,
                                              "address": address,
                                              "userDetails":
                                                  userDetails, // ✅ fixed
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.color8,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width /
                                                40,
                                          ),
                                          child: Text(
                                            'Details',
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width /
                                                  32,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Widget completed(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("assigned_driver_parcel")
              .doc(driverId) // fetch only the current driver’s assigned orders
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("No deliveries assigned yet"));
        }

        final driverData = snapshot.data!.data() as Map<String, dynamic>;
        final assignedOrders =
            driverData["orders"] as Map<String, dynamic>? ?? {};

        final shippedOrders =
            assignedOrders.entries
                .where((entry) => entry.value["status"] == "Delivered")
                .toList();

        if (shippedOrders.isEmpty) {
          return const Center(child: Text("No Delivered Items"));
        }

        return Column(
          children:
              shippedOrders.map((entry) {
                final order = entry.value as Map<String, dynamic>;
                final orderId = order["orderId"] ?? entry.key;
                final status = order["status"] ?? "In Progress";
                final total = (order["total"] ?? 0).toDouble();
                final cartItems = List<Map<String, dynamic>>.from(
                  order["cartItems"] ?? [],
                );
                final address = order["selectedAddress"] ?? {};
                final userDetails = order["userDetails"] ?? {}; // ✅ fix here

                return Container(
                  width: MediaQuery.of(context).size.width / 1.15,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: AppColors.color8,
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
                      // 🔵 Blue left bar
                      Container(
                        width: 8.5,
                        decoration: const BoxDecoration(
                          color: AppColors.color8,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width / 20,
                              horizontal:
                                  MediaQuery.of(context).size.width / 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🔹 Order Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order # $orderId',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                            30,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.color5,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                30,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 30,
                                ),

                                // 🔹 Show all cart items
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      cartItems.map((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 🖼 Product Image
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  item["productImages"] ?? "",
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(width: 8),

                                              // 📦 Product Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item["productName"] ??
                                                          "Unknown",
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            30,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Qty: ${item["quantity"]} • ₱${item["productPrice"]}",
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            35,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Size: ${item["selectedSize"] ?? "-"} • Color: ${item["selectedColor"] ?? "-"}",
                                                      style: GoogleFonts.roboto(
                                                        fontSize:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width /
                                                            35,
                                                        fontWeight:
                                                            FontWeight.w400,
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

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 30,
                                ),

                                // 🔹 Address
                                Row(
                                  children: [
                                    const Icon(Icons.location_city_outlined),
                                    Expanded(
                                      child: Text(
                                        '${address["house_number"] ?? ""} ${address["barangay"] ?? ""}, ${address["city_municipality"] ?? ""}',
                                        style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width /
                                              35,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width / 90,
                                ),

                                const Divider(),

                                // 🔹 Footer (Total + Details button)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₱ ${total.toStringAsFixed(2)}',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                            22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    //                             GestureDetector(
                                    // onTap: () {
                                    //   Get.to(
                                    //     () => DriverDelivery(
                                    //       order: {
                                    //         "orderId": orderId,
                                    //         "status": status,
                                    //         "total": total,
                                    //         "cartItems": cartItems,
                                    //         "address": address,
                                    //         "userDetails": userDetails, // ✅ fixed
                                    //       },
                                    //     ),
                                    //   );
                                    // },
                                    //                               child: Container(
                                    //                                 decoration: BoxDecoration(
                                    //                                   color: AppColors.color8,
                                    //                                   borderRadius: BorderRadius.circular(12),
                                    //                                 ),
                                    //                                 child: Padding(
                                    //                                   padding: EdgeInsets.all(
                                    //                                     MediaQuery.of(context).size.width / 40,
                                    //                                   ),
                                    //                                   child: Text(
                                    //                                     'Details',
                                    //                                     style: GoogleFonts.roboto(
                                    //                                       color: Colors.white,
                                    //                                       fontSize:
                                    //                                           MediaQuery.of(context).size.width /
                                    //                                               32,
                                    //                                       fontWeight: FontWeight.w400,
                                    //                                     ),
                                    //                                   ),
                                    //                                 ),
                                    //                               ),
                                    //                             ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
