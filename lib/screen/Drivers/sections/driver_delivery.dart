import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Drivers/sections/services/proof_of_delivery_services.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDelivery extends StatefulWidget {
  final Map<String, dynamic> order;

  const DriverDelivery({super.key, required this.order});

  @override
  State<DriverDelivery> createState() => _DriverDeliveryState();
}

class _DriverDeliveryState extends State<DriverDelivery> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final orderId = order["orderId"] ?? "";
    final status = order["status"] ?? "In Progress";
    final total = (order["total"] ?? 0).toDouble();
    final cartItems = List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
    final address = order["address"] ?? {};
    final user = order["userDetails"] ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 20,
            vertical: MediaQuery.of(context).size.width / 20,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 28,
                        color: Colors.black,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Delivery Details",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                dashboardCard(
                  context,
                  orderId,
                  status,
                  total,
                  cartItems,
                  address,
                  user,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    String orderId,
    String status,
    double total,
    List<Map<String, dynamic>> cartItems,
    Map<String, dynamic> address,
    Map<String, dynamic> user,
  ) {
    final proofService = ProofOfDeliveryService();

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
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
        children: [
          // 🔹 Header
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: AppColors.color8,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order #$orderId - $status",
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Estimated delivery: Today",
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 30,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Body
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 15,
                vertical: MediaQuery.of(context).size.width / 30,
              ),
              child: Column(
                children: [
                  // User
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.color4,
                        child: const Icon(
                          Icons.person_outline,
                          color: AppColors.color8,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user["full_name"] ?? "Unknown",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 35,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            user["phone_number"] ?? "",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 35,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                           final phone = user["phone_number"] ?? "";
      if (phone.isNotEmpty) {
        final Uri launchUri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not launch dialer")),
          );
        }
      }
    },
                        
                        child: CircleAvatar(
                          backgroundColor: Colors.green.shade200,
                          child: const Icon(
                            Icons.call_outlined,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 50),

                  // Address
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.color4,
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.color8,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Address",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 35,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${address["house_number"] ?? ""} ${address["barangay"] ?? ""}, ${address["city_municipality"] ?? ""}",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 35,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.of(context).size.width / 30),

                  // Cart Items
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 20,
                        vertical: MediaQuery.of(context).size.width / 60,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Items',
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...cartItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item["quantity"]}x ${item["productName"]}',
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          35,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '₱ ${(item["productPrice"] * item["quantity"]).toStringAsFixed(2)}',
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                          35,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total"),
                              Text(
                                '₱ ${total.toStringAsFixed(2)}',
                                style: GoogleFonts.roboto(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 30,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.color8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.width / 30),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.7,
                        height: MediaQuery.of(context).size.width / 12,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // Proof of Delivery button
                          onPressed: () async {
                            await proofService.uploadProof(
                              orderId: orderId,
                              cartItems: cartItems,
                              context: context,
                            );
                          },
                          child: Text(
                            "Proof of Delivery",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 35,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.7,
                        height: MediaQuery.of(context).size.width / 12,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
               await proofService.markOrderDelivered(orderId, context);
                          },
                          child: Text(
                            "Delivered",
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 35,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
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
        ],
      ),
    );
  }
}
