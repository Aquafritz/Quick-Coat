import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_delivery.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

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
              dashboardCard(context),
              SizedBox(height: MediaQuery.of(context).size.width / 20),
              Text(
                "Today's Deliveries",
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width / 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width / 70),
              deliveries(context),
              SizedBox(height: MediaQuery.of(context).size.width / 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("assigned_driver_parcel")
              .doc(driverId)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        int assignedCount = 0;
        int completedCount = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final orders = data["orders"] as Map<String, dynamic>? ?? {};

          assignedCount =
              orders.values
                  .where(
                    (order) =>
                        (order as Map<String, dynamic>)["status"] == "Shipped",
                  )
                  .length;

          completedCount =
              orders.values
                  .where(
                    (order) =>
                        (order as Map<String, dynamic>)["status"] ==
                        "Delivered",
                  )
                  .length;
        }

        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 1.6,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(12),
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back, Full Name!',
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Ready for today's delivery?",
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // ✅ Assigned count
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.color6.withOpacity(1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.color8,
                            child: const Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "$assignedCount",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Assigned",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ Completed count
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: MediaQuery.of(context).size.width / 3,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.color6.withOpacity(1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.color8,
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "$completedCount",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            "Completed",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget deliveries(BuildContext context) {
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
          return const Center(child: Text("No Delivered Items"));
        }

        return Column(
          children:
              shippedOrders.map((entry) {
                final order = entry.value as Map<String, dynamic>;
                final orderId = order["orderId"] ?? entry.key;
                final status = order["status"] ?? "";
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
}
