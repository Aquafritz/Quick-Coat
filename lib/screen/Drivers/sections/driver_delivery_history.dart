import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

class DriverDeliveryHistory extends StatefulWidget {
  const DriverDeliveryHistory({super.key});

  @override
  State<DriverDeliveryHistory> createState() => _DriverDeliveryHistoryState();
}

class _DriverDeliveryHistoryState extends State<DriverDeliveryHistory> {
  String selected = "all_time";

  final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

List<Map<String, dynamic>> deliveries = [];
bool isLoading = true;

  @override
void initState() {
  super.initState();
  _fetchDriverDeliveries();
}

Future<void> _fetchDriverDeliveries() async {
  try {
    final user = _auth.currentUser;
    if (user == null) return;

    // Fetch document where ID == current driver's UID
    final doc = await _firestore
        .collection('assigned_driver_parcel')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      setState(() {
        isLoading = false;
        deliveries = [];
      });
      return;
    }

    final data = doc.data();
    final orders = data?['orders'] ?? {};

    final List<Map<String, dynamic>> deliveredOrders = [];

    // ✅ Extract only "Delivered" orders
    orders.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final status = (value["status"] ?? "").toString().trim();
        if (status == "Delivered") {
          final fullOrder = Map<String, dynamic>.from(value);
          fullOrder["orderId"] = key;
          deliveredOrders.add(fullOrder);
        }
      }
    });

    // ✅ Sort by timestamp (newest first)
    deliveredOrders.sort((a, b) {
      final tsA = a["timestamp"];
      final tsB = b["timestamp"];
      if (tsA is Timestamp && tsB is Timestamp) {
        return tsB.toDate().compareTo(tsA.toDate());
      }
      return 0;
    });

    setState(() {
      deliveries = deliveredOrders;
      isLoading = false;
    });
  } catch (e) {
    debugPrint("Error fetching driver delivered: $e");
    setState(() => isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
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
                // 🔙 Back button + Title
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
                      "Delivery History",
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 🔹 Assigned / Completed Menu
                dashboardCard(context),

                const SizedBox(height: 20),

                // 🔹 Content based on selection
                _buildDeliveryList(context),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryList(BuildContext context) {
  if (isLoading) return const Center(child: CircularProgressIndicator());

  if (deliveries.isEmpty) {
    return const Center(child: Text("No Delivered found"));
  }

  final now = DateTime.now();
  List<Map<String, dynamic>> filtered = deliveries;

  // 🔹 Filter by selection
  if (selected == "this_week") {
    final weekAgo = now.subtract(const Duration(days: 7));
    filtered = deliveries.where((d) {
      final ts = d["timestamp"];
      if (ts is Timestamp) {
        final date = ts.toDate();
        return date.isAfter(weekAgo);
      }
      return false;
    }).toList();
  } else if (selected == "this_month") {
    final monthAgo = DateTime(now.year, now.month - 1, now.day);
    filtered = deliveries.where((d) {
      final ts = d["timestamp"];
      if (ts is Timestamp) {
        final date = ts.toDate();
        return date.isAfter(monthAgo);
      }
      return false;
    }).toList();
  }

  // 🔹 Display all filtered deliveries
  return Column(
    children: filtered.map((order) {
      return _buildDeliveryCard(context, order);
    }).toList(),
  );
}


Widget _buildDeliveryCard(BuildContext context, Map<String, dynamic> order) {
  final orderId = order["orderId"] ?? "Unknown ID";
  final status = order["status"] ?? "Unknown";
  final total = (order["total"] ?? 0).toDouble();
  final cartItems = List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
  final address = Map<String, dynamic>.from(order["selectedAddress"] ?? {});
  final userDetails = Map<String, dynamic>.from(order["userDetails"] ?? {});

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
        // Blue left bar
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

        // Main container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width / 20,
                horizontal: MediaQuery.of(context).size.width / 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order # $orderId',
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.width / 30,
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
                                  MediaQuery.of(context).size.width / 30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 30),

                  // Cart items
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item["productImages"] ?? "",
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                    const Icon(Icons.image_not_supported, size: 40),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["productName"] ?? "Unknown Product",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width / 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Qty: ${item["quantity"]} • ₱${item["productPrice"]}",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width / 35,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    "Size: ${item["selectedSize"] ?? "-"} • Color: ${item["selectedColor"] ?? "-"}",
                                    style: GoogleFonts.roboto(
                                      fontSize:
                                          MediaQuery.of(context).size.width / 35,
                                      fontWeight: FontWeight.w400,
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

                  SizedBox(height: MediaQuery.of(context).size.width / 30),

                  // Address
                  Row(
                    children: [
                      const Icon(Icons.location_city_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${address["house_number"] ?? ""} ${address["barangay"] ?? ""}, ${address["city_municipality"] ?? ""}',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize:
                                MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  const Divider(),

                  // Total + Details button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₱ ${total.toStringAsFixed(2)}',
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontSize:
                              MediaQuery.of(context).size.width / 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     Get.to(() => DriverDelivery(order: order));
                      //   },
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: AppColors.color8,
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Padding(
                      //       padding: EdgeInsets.all(
                      //         MediaQuery.of(context).size.width / 40,
                      //       ),
                      //       child: Text(
                      //         'Details',
                      //         style: GoogleFonts.roboto(
                      //           color: Colors.white,
                      //           fontSize:
                      //               MediaQuery.of(context).size.width / 32,
                      //           fontWeight: FontWeight.w400,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
}



String _formatDate(dynamic ts) {
  if (ts == null) return "No date";
  if (ts is Timestamp) {
    final date = ts.toDate();
    return "${date.month}/${date.day}/${date.year}";
  }
  return ts.toString();
}



  Widget dashboardCard(BuildContext context) {
    final tabCount = 3;
    final tabWidth = MediaQuery.of(context).size.width / tabCount;
     final now = DateTime.now();

  // 🧮 Calculate delivered count based on selected filter
  int deliveredCount = 0;

   if (deliveries.isNotEmpty) {
    if (selected == "this_week") {
      final weekAgo = now.subtract(const Duration(days: 7));
      deliveredCount = deliveries.where((d) {
        final ts = d["timestamp"];
        DateTime? date;

        if (ts is Timestamp) {
          date = ts.toDate();
        } else if (ts is String) {
          try {
            // Parse your Firestore date string, e.g. "October 10, 2025 at 2:56:17 PM UTC+8"
            final parsed = DateFormat("MMMM d, yyyy 'at' h:mm:ss a 'UTC'xxx")
                .parse(ts, true)
                .toLocal();
            date = parsed;
          } catch (e) {
            debugPrint("⚠️ Failed to parse date: $ts");
          }
        }

        return date != null && date.isAfter(weekAgo);
      }).length;
    } else if (selected == "this_month") {
      final monthAgo = now.subtract(const Duration(days: 30));
      deliveredCount = deliveries.where((d) {
        final ts = d["timestamp"];
        DateTime? date;

        if (ts is Timestamp) {
          date = ts.toDate();
        } else if (ts is String) {
          try {
            final parsed = DateFormat("MMMM d, yyyy 'at' h:mm:ss a 'UTC'xxx")
                .parse(ts, true)
                .toLocal();
            date = parsed;
          } catch (e) {
            debugPrint("⚠️ Failed to parse date: $ts");
          }
        }

        return date != null && date.isAfter(monthAgo);
      }).length;
    } else {
      // All time
      deliveredCount = deliveries.length;
    }
  }

    Alignment _getAlignment() {
      switch (selected) {
        case "all_time":
          return Alignment.centerLeft;
        case "this_week":
          return Alignment.center;
        case "this_month":
          return Alignment.centerRight;
        default:
          return Alignment.centerLeft;
      }
    }

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 7,
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
              // 🔹 Sliding highlight
              AnimatedAlign(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                alignment: _getAlignment(),
                child: Container(
                  width: tabWidth - 8,
                  height: MediaQuery.of(context).size.width / 9,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              // 🔹 Row with 3 tabs
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selected = "all_time"),
                      child: Center(
                        child: Text(
                          "All Time",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                selected == "all_time"
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selected = "this_week"),
                      child: Center(
                        child: Text(
                          "This Week",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                selected == "this_week"
                                    ? Colors.black
                                    : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selected = "this_month"),
                      child: Center(
                        child: Text(
                          "This Month",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                selected == "this_month"
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
        ),
        SizedBox(height: MediaQuery.of(context).size.width / 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: MediaQuery.of(context).size.width / 30,
                  color: Colors.black,
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 70),
               Text(
                "Total: $deliveredCount Delivered",
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width / 35,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.width / 40),
      ],
    );
  }

  /// 🔹 Assigned Orders View
  Widget allTime(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.15,
      height: MediaQuery.of(context).size.width / 1.5,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppColors.color8, // ~~~ main black container
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
            width: 8.5, // thickness of the blue stripe
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
                  horizontal: MediaQuery.of(context).size.width / 30,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order # 124512',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 20,
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
                              'In Progress',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined),
                        Text(
                          'Today, 10:30 AM',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.check_box_outlined),
                        Text(
                          '5 Items •',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.location_city_outlined),
                        Text(
                          '123 Makati City',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width / 90,
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱ 12,124.00',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.color8,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 40
                            ),
                            child: Text(
                              'Details',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 32,
                                fontWeight: FontWeight.w400,
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
  }

  /// 🔹 Completed Orders View
  Widget thisWeek(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.15,
      height: MediaQuery.of(context).size.width / 1.5,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppColors.color8, // ~~~ main black container
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
            width: 8.5, // thickness of the blue stripe
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
                  horizontal: MediaQuery.of(context).size.width / 30,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order # 124512',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 20,
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
                              'In Progress',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined),
                        Text(
                          'Today, 10:30 AM',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.check_box_outlined),
                        Text(
                          '5 Items •',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.location_city_outlined),
                        Text(
                          '123 Makati City',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width / 90,
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱ 12,124.00',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.color8,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 40
                            ),
                            child: Text(
                              'Details',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 32,
                                fontWeight: FontWeight.w400,
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
  }
  

  Widget thisMonth(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.15,
      height: MediaQuery.of(context).size.width / 1.5,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppColors.color8, // ~~~ main black container
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
            width: 8.5, // thickness of the blue stripe
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
                  horizontal: MediaQuery.of(context).size.width / 30,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order # 124512',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 20,
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
                              'In Progress',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined),
                        Text(
                          'Today, 10:30 AM',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.check_box_outlined),
                        Text(
                          '5 Items •',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 30),
                    Row(
                      children: [
                        Icon(Icons.location_city_outlined),
                        Text(
                          '123 Makati City',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width / 90,
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱ 12,124.00',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.color8,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              MediaQuery.of(context).size.width / 40
                            ),
                            child: Text(
                              'Details',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width / 32,
                                fontWeight: FontWeight.w400,
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
  }
}
