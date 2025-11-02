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
  String selected = "assigned";

  DateTimeRange? assignedDateRange;
  String assignedFilterMode = "main";
  String assignedFilterValue = "All";
  List<String> assignedAvailableColors = [];
  List<String> assignedAvailableSizes = [];

  DateTimeRange? completedDateRange;
  String completedFilterMode = "main"; 
  String completedFilterValue = "All";
  List<String> completedAvailableColors = [];
  List<String> completedAvailableSizes = [];

  @override
  void initState() {
    super.initState();
    _loadVariantsForBothTabs();
  }

  Future<void> _loadVariantsForBothTabs() async {
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("assigned_driver_parcel")
          .doc(driverId)
          .get();

      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>;
      final orders = data["orders"] as Map<String, dynamic>? ?? {};

      final Set<String> colorSet = {};
      final Set<String> sizeSet = {};

      for (var entry in orders.entries) {
        final order = entry.value as Map<String, dynamic>;
        final cartItems =
            List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
        for (var item in cartItems) {
          final color = (item["selectedColor"] ?? "").toString().trim();
          final size = (item["selectedSize"] ?? "").toString().trim();
          if (color.isNotEmpty) colorSet.add(color);
          if (size.isNotEmpty) sizeSet.add(size);
        }
      }

      setState(() {
        assignedAvailableColors = colorSet.toList()..sort();
        assignedAvailableSizes = sizeSet.toList()..sort();
        completedAvailableColors = List.from(assignedAvailableColors);
        completedAvailableSizes = List.from(assignedAvailableSizes);
      });
    } catch (e) {
    }
  }

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
    final tabWidth = MediaQuery.of(context).size.width / 2; 
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
          AnimatedAlign(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment:
                selected == "assigned" ? Alignment.centerLeft : Alignment.centerRight,
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
                        color: selected == "assigned" ? Colors.black : Colors.white,
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
                        color: selected == "completed" ? Colors.black : Colors.white,
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

    Widget filterBarAssigned() {
      // menu items dependent on mode
      List<String> menuItems;
      if (assignedFilterMode == "main") {
        menuItems = ["All", "Colors", "Sizes"];
      } else if (assignedFilterMode == "colors") {
        menuItems = ["All Colors", ...assignedAvailableColors];
        if (menuItems.isEmpty) menuItems = ["All Colors"];
      } else {
        menuItems = ["All Sizes", ...assignedAvailableSizes];
        if (menuItems.isEmpty) menuItems = ["All Sizes"];
      }

      final String dropdownValue =
          menuItems.contains(assignedFilterValue) ? assignedFilterValue : menuItems.first;

      bool isDefault = (assignedFilterMode == "main" && assignedFilterValue == "All" && assignedDateRange == null) ||
          (assignedFilterMode == "colors" && assignedFilterValue == "All Colors" && assignedDateRange == null) ||
          (assignedFilterMode == "sizes" && assignedFilterValue == "All Sizes" && assignedDateRange == null);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 1),
                initialDateRange: assignedDateRange ?? DateTimeRange(start: now, end: now),
              );
              if (picked != null) setState(() => assignedDateRange = picked);
            },
            child: Container(
                 width: MediaQuery.of(context).size.width / 2.5, // 👈 same width
        height: 45,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.color8,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    assignedDateRange == null
                        ? "Select Date"
                        : "${assignedDateRange!.start.month}/${assignedDateRange!.start.day} - ${assignedDateRange!.end.month}/${assignedDateRange!.end.day}",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (assignedDateRange != null)
                    GestureDetector(
                      onTap: () => setState(() => assignedDateRange = null),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.clear, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Row(
            children: [
              Container(
        height: 45, 
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.color8,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: dropdownValue,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.color8,
                  iconEnabledColor: Colors.white,
                  style: GoogleFonts.roboto(color: Colors.white),
                  items: menuItems
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (assignedFilterMode == "main") {
                        if (value == "Colors") {
                          assignedFilterMode = "colors";
                          assignedFilterValue = "All Colors";
                          return;
                        }
                        if (value == "Sizes") {
                          assignedFilterMode = "sizes";
                          assignedFilterValue = "All Sizes";
                          return;
                        }
                        assignedFilterMode = "main";
                        assignedFilterValue = "All";
                        return;
                      }
                      if (assignedFilterMode == "colors") {
                        assignedFilterValue = value;
                        return;
                      }
                      if (assignedFilterMode == "sizes") {
                        assignedFilterValue = value;
                        return;
                      }
                    });
                  },
                ),
              ),

              if (!isDefault) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      assignedFilterMode = "main";
                      assignedFilterValue = "All";
                      assignedDateRange = null;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.color5,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: filterBarAssigned(),
        ),

        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("assigned_driver_parcel")
              .doc(driverId) 
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("No deliveries assigned yet"));
            }

            final driverData = snapshot.data!.data() as Map<String, dynamic>;
            final assignedOrders = driverData["orders"] as Map<String, dynamic>? ?? {};

            final shippedOrders = assignedOrders.entries
                .where((entry) => entry.value["status"] == "Shipped")
                .toList();

            if (shippedOrders.isEmpty) {
              return const Center(child: Text("No deliveries today"));
            }

            final filtered = shippedOrders.where((entry) {
              final order = entry.value as Map<String, dynamic>;
              final timestamp = (order["timestamp"] as Timestamp?)?.toDate();
              final cartItems = List<Map<String, dynamic>>.from(order["cartItems"] ?? []);

              final matchesDate = assignedDateRange == null ||
                  (timestamp != null &&
                      timestamp.isAfter(assignedDateRange!.start.subtract(const Duration(days: 1))) &&
                      timestamp.isBefore(assignedDateRange!.end.add(const Duration(days: 1))));

              bool matchesVariant = true;
              final sel = assignedFilterValue.toLowerCase();

              if (assignedFilterMode == "colors" && assignedFilterValue != "All Colors") {
                matchesVariant = cartItems.any((item) =>
                    (item["selectedColor"] ?? "").toString().toLowerCase() == sel);
              } else if (assignedFilterMode == "sizes" && assignedFilterValue != "All Sizes") {
                matchesVariant = cartItems.any((item) =>
                    (item["selectedSize"] ?? "").toString().toLowerCase() == sel);
              }

              return matchesDate && matchesVariant;
            }).toList();

            if (filtered.isEmpty) {
              return const Center(child: Text("No deliveries match your filter."));
            }

            return Column(
              children: filtered.map((entry) {
                final order = entry.value as Map<String, dynamic>;
                final orderId = order["orderId"] ?? entry.key;
                final status = order["status"] ?? "In Progress";
                final total = order["total"] ?? 0;
                final cartItems = List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
                final address = order["selectedAddress"] ?? {};
                final userDetails = order["userDetails"] ?? {}; 

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
                              horizontal: MediaQuery.of(context).size.width / 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order # $orderId',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width / 30,
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
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item["productName"] ?? "Unknown",
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
                                Row(
                                  children: [
                                    const Icon(Icons.location_city_outlined),
                                    Expanded(
                                      child: Text(
                                        '${address["house_number"] ?? ""} ${address["barangay"] ?? ""}, ${address["city_municipality"] ?? ""}',
                                        style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context).size.width / 35,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.width / 90),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₱ ${total.toStringAsFixed(2)}',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width / 22,
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
                                              "userDetails": userDetails, 
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.color8,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context).size.width / 40),
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
        ),
      ],
    );
  }

  Widget completed(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser?.uid;

    Widget filterBarCompleted() {
      List<String> menuItems;
      if (completedFilterMode == "main") {
        menuItems = ["All", "Colors", "Sizes"];
      } else if (completedFilterMode == "colors") {
        menuItems = ["All Colors", ...completedAvailableColors];
        if (menuItems.isEmpty) menuItems = ["All Colors"];
      } else {
        menuItems = ["All Sizes", ...completedAvailableSizes];
        if (menuItems.isEmpty) menuItems = ["All Sizes"];
      }

      final String dropdownValue =
          menuItems.contains(completedFilterValue) ? completedFilterValue : menuItems.first;

      bool isDefault = (completedFilterMode == "main" && completedFilterValue == "All" && completedDateRange == null) ||
          (completedFilterMode == "colors" && completedFilterValue == "All Colors" && completedDateRange == null) ||
          (completedFilterMode == "sizes" && completedFilterValue == "All Sizes" && completedDateRange == null);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 1),
                initialDateRange: completedDateRange ?? DateTimeRange(start: now, end: now),
              );
              if (picked != null) setState(() => completedDateRange = picked);
            },
            child: Container(
                 width: MediaQuery.of(context).size.width / 2.5, // 👈 same width
        height: 45, 
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.color8,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    completedDateRange == null
                        ? "Select Date"
                        : "${completedDateRange!.start.month}/${completedDateRange!.start.day} - ${completedDateRange!.end.month}/${completedDateRange!.end.day}",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (completedDateRange != null)
                    GestureDetector(
                      onTap: () => setState(() => completedDateRange = null),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.clear, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Container(
        height: 45, 
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.color8,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: dropdownValue,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.color8,
                  iconEnabledColor: Colors.white,
                  style: GoogleFonts.roboto(color: Colors.white),
                  items: menuItems
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      if (completedFilterMode == "main") {
                        if (value == "Colors") {
                          completedFilterMode = "colors";
                          completedFilterValue = "All Colors";
                          return;
                        }
                        if (value == "Sizes") {
                          completedFilterMode = "sizes";
                          completedFilterValue = "All Sizes";
                          return;
                        }
                        completedFilterMode = "main";
                        completedFilterValue = "All";
                        return;
                      }
                      if (completedFilterMode == "colors") {
                        completedFilterValue = value;
                        return;
                      }
                      if (completedFilterMode == "sizes") {
                        completedFilterValue = value;
                        return;
                      }
                    });
                  },
                ),
              ),

              if (!isDefault) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      completedFilterMode = "main";
                      completedFilterValue = "All";
                      completedDateRange = null;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.color5,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: filterBarCompleted(),
        ),

        StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance.collection("assigned_driver_parcel").doc(driverId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("No deliveries assigned yet"));
            }

            final driverData = snapshot.data!.data() as Map<String, dynamic>;
            final assignedOrders = driverData["orders"] as Map<String, dynamic>? ?? {};

            final shippedOrders = assignedOrders.entries
                .where((entry) => entry.value["status"] == "Delivered")
                .toList();

            if (shippedOrders.isEmpty) {
              return const Center(child: Text("No Delivered Items"));
            }

            final filtered = shippedOrders.where((entry) {
              final order = entry.value as Map<String, dynamic>;
              final timestamp = (order["timestamp"] as Timestamp?)?.toDate();
              final cartItems = List<Map<String, dynamic>>.from(order["cartItems"] ?? []);

              final matchesDate = completedDateRange == null ||
                  (timestamp != null &&
                      timestamp.isAfter(completedDateRange!.start.subtract(const Duration(days: 1))) &&
                      timestamp.isBefore(completedDateRange!.end.add(const Duration(days: 1))));

              bool matchesVariant = true;
              final sel = completedFilterValue.toLowerCase();

              if (completedFilterMode == "colors" && completedFilterValue != "All Colors") {
                matchesVariant = cartItems.any((item) =>
                    (item["selectedColor"] ?? "").toString().toLowerCase() == sel);
              } else if (completedFilterMode == "sizes" && completedFilterValue != "All Sizes") {
                matchesVariant = cartItems.any((item) =>
                    (item["selectedSize"] ?? "").toString().toLowerCase() == sel);
              }

              return matchesDate && matchesVariant;
            }).toList();

            if (filtered.isEmpty) {
              return const Center(child: Text("No Delivered Items match filter."));
            }
            return Column(
              children: filtered.map((entry) {
                final order = entry.value as Map<String, dynamic>;
                final orderId = order["orderId"] ?? entry.key;
                final status = order["status"] ?? "In Progress";
                final total = (order["total"] ?? 0).toDouble();
                final cartItems = List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
                final address = order["selectedAddress"] ?? {};
                final userDetails = order["userDetails"] ?? {};

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
                              horizontal: MediaQuery.of(context).size.width / 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order # $orderId',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width / 30,
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
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item["productName"] ?? "Unknown",
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
                                Row(
                                  children: [
                                    const Icon(Icons.location_city_outlined),
                                    Expanded(
                                      child: Text(
                                        '${address["house_number"] ?? ""} ${address["barangay"] ?? ""}, ${address["city_municipality"] ?? ""}',
                                        style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context).size.width / 35,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: MediaQuery.of(context).size.width / 90),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₱ ${total.toStringAsFixed(2)}',
                                      style: GoogleFonts.roboto(
                                        color: Colors.black,
                                        fontSize: MediaQuery.of(context).size.width / 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     Get.to(
                                    //       () => DriverDelivery(
                                    //         order: {
                                    //           "orderId": orderId,
                                    //           "status": status,
                                    //           "total": total,
                                    //           "cartItems": cartItems,
                                    //           "address": address,
                                    //           "userDetails": userDetails,
                                    //         },
                                    //       ),
                                    //     );
                                    //   },
                                    //   child: Container(
                                    //     decoration: BoxDecoration(
                                    //       color: AppColors.color8,
                                    //       borderRadius: BorderRadius.circular(12),
                                    //     ),
                                    //     child: Padding(
                                    //       padding: EdgeInsets.all(
                                    //           MediaQuery.of(context).size.width / 40),
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
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
