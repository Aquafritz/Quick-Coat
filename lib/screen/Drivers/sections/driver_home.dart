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
    stream: FirebaseFirestore.instance
        .collection("users") // 👈 fetch from users collection
        .doc(driverId)
        .snapshots(),
    builder: (context, userSnapshot) {
      String driverName = "Driver";
      if (userSnapshot.hasData && userSnapshot.data!.exists) {
        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        driverName = userData["full_name"] ?? "Driver";
      }

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
                  'Welcome Back, $driverName!',
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 25,
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
    );
  }

 Widget deliveries(BuildContext context) {
  final driverId = FirebaseAuth.instance.currentUser?.uid;

  // Reactive filter state
  final Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);

  // mode: "main" = show [All, Colors, Sizes]
  // "colors" = show [All Colors, <color list>]
  // "sizes" = show [All Sizes, <size list>]
  final RxString filterMode = "main".obs;
  final RxString filterValue = "All".obs; // actual selected value (e.g. "Red", "M", "All Colors", "All Sizes")

  // dynamic lists loaded once
  final RxList<String> availableColors = <String>[].obs;
  final RxList<String> availableSizes = <String>[].obs;

  // Load colors & sizes once (non-blocking). This won't change your UI.
  FirebaseFirestore.instance
      .collection("assigned_driver_parcel")
      .doc(driverId)
      .get()
      .then((doc) {
    if (doc.exists) {
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

      // sort for stable order
      final colorsList = colorSet.toList()..sort();
      final sizesList = sizeSet.toList()..sort();

      availableColors.assignAll(colorsList);
      availableSizes.assignAll(sizesList);
    }
  });

  // UI — unchanged layout. We only change the dropdown behavior & filtering logic under the hood.
  return Obx(() {
    // build menu items depending on mode
    List<String> menuItems;
    if (filterMode.value == "main") {
      menuItems = ["All", "Colors", "Sizes"];
    } else if (filterMode.value == "colors") {
      // show "All Colors" + dynamic colors (or "All Colors" only if none)
      menuItems = ["All Colors", ...availableColors];
      if (menuItems.isEmpty) menuItems = ["All Colors"]; // safety
    } else {
      // sizes
      menuItems = ["All Sizes", ...availableSizes];
      if (menuItems.isEmpty) menuItems = ["All Sizes"];
    }

    // Ensure dropdown's currently selected item is valid inside menuItems; fallback to first
    String dropdownValue =
        menuItems.contains(filterValue.value) ? filterValue.value : menuItems.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FILTER BAR (UI kept exactly as in your original)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Date range picker (unchanged)
            GestureDetector(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(now.year - 1),
                  lastDate: DateTime(now.year + 1),
                  initialDateRange: selectedDateRange.value ??
                      DateTimeRange(start: now, end: now),
                );
                if (picked != null) selectedDateRange.value = picked;
              },
              child: Container(
                 width: MediaQuery.of(context).size.width / 2.5, // 👈 same width
        height: 45, // 👈 unified height
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
                      selectedDateRange.value == null
                          ? "Select Date"
                          : "${selectedDateRange.value!.start.month}/${selectedDateRange.value!.start.day} - ${selectedDateRange.value!.end.month}/${selectedDateRange.value!.end.day}",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (selectedDateRange.value != null)
                      GestureDetector(
                        onTap: () => selectedDateRange.value = null,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.clear, color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Item Type Dropdown + Clear icon (keeps same layout)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
          height: 45, // 👈 unified height
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

                      // When in main menu and user selects "Colors" or "Sizes", switch mode
                      if (filterMode.value == "main") {
                        if (value == "Colors") {
                          filterMode.value = "colors";
                          // default subfilter to "All Colors"
                          filterValue.value = "All Colors";
                          return;
                        }
                        if (value == "Sizes") {
                          filterMode.value = "sizes";
                          filterValue.value = "All Sizes";
                          return;
                        }
                        // value == "All"
                        filterMode.value = "main";
                        filterValue.value = "All";
                        return;
                      }

                      // When in colors mode:
                      if (filterMode.value == "colors") {
                        // if user picks "All Colors", reset to main menu with no subfilter OR keep in colors mode but All Colors selected
                        if (value == "All Colors") {
                          // keep colors mode but treat All Colors as no filter
                          filterValue.value = "All Colors";
                          return;
                        }
                        // selecting a specific color applies filter
                        filterValue.value = value;
                        return;
                      }

                      // When in sizes mode:
                      if (filterMode.value == "sizes") {
                        if (value == "All Sizes") {
                          filterValue.value = "All Sizes";
                          return;
                        }
                        filterValue.value = value;
                        return;
                      }
                    },
                  ),
                ),

                // clear X icon — appears only when a real filter is active
                if (!(
                    (filterMode.value == "main" && filterValue.value == "All") ||
                    (filterMode.value == "colors" && (filterValue.value == "All Colors")) ||
                    (filterMode.value == "sizes" && (filterValue.value == "All Sizes"))
                )) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      // reset to main "All"
                      filterMode.value = "main";
                      filterValue.value = "All";
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
        ),

        const SizedBox(height: 15),

        // Deliveries Stream — UI unchanged, only filtering logic below
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
            final assignedOrders =
                driverData["orders"] as Map<String, dynamic>? ?? {};

            final shippedOrders = assignedOrders.entries
                .where((entry) => entry.value["status"] == "Shipped")
                .map((entry) => {
                      "id": entry.key,
                      "data": entry.value as Map<String, dynamic>,
                    })
                .toList();

            // Apply filters (date + variant)
            final filtered = shippedOrders.where((entry) {
              final order = entry["data"] as Map<String, dynamic>;
              final timestamp = (order["timestamp"] as Timestamp?)?.toDate();

              // date filter
              final matchesDate = selectedDateRange.value == null ||
                  (timestamp != null &&
                      timestamp.isAfter(selectedDateRange.value!.start
                          .subtract(const Duration(days: 1))) &&
                      timestamp.isBefore(selectedDateRange.value!.end
                          .add(const Duration(days: 1))));

              // variant filter
              final cartItems =
                  List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
              bool matchesVariant = true;
              final sel = filterValue.value.toLowerCase();

              if (filterMode.value == "colors") {
                // if "All Colors" selected => matchesVariant stays true (no filtering)
                if (filterValue.value != "All Colors") {
                  matchesVariant = cartItems.any((item) =>
                      (item["selectedColor"] ?? "").toString().toLowerCase() ==
                      sel);
                }
              } else if (filterMode.value == "sizes") {
                if (filterValue.value != "All Sizes") {
                  matchesVariant = cartItems.any((item) =>
                      (item["selectedSize"] ?? "").toString().toLowerCase() ==
                      sel);
                }
              } else {
                // filterMode == main -> no variant filtering
                matchesVariant = true;
              }

              return matchesDate && matchesVariant;
            }).toList();

            if (filtered.isEmpty) {
              return const Center(child: Text("No deliveries match your filter."));
            }

            // Keep your original UI for displaying orders (unchanged)
            return Column(
              children: filtered.map((entry) {
                final order = entry["data"] as Map<String, dynamic>;
                final orderId = order["orderId"] ?? entry["id"];
                final status = order["status"] ?? "";
                final total = order["total"] ?? 0;
                final cartItems =
                    List<Map<String, dynamic>>.from(order["cartItems"] ?? []);
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
                                // Order Header
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
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize:
                                                MediaQuery.of(context).size.width /
                                                    30,
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
                                                    fontSize: MediaQuery.of(context).size.width / 30,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  "Qty: ${item["quantity"]} • ₱${item["productPrice"]}",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: MediaQuery.of(context).size.width / 35,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  "Size: ${item["selectedSize"] ?? "-"} • Color: ${item["selectedColor"] ?? "-"}",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: MediaQuery.of(context).size.width / 35,
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
                                // Footer: total + details
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
                                          () => DriverDelivery(order: {
                                            "orderId": orderId,
                                            "status": status,
                                            "total": total,
                                            "cartItems": cartItems,
                                            "address": address,
                                            "userDetails": userDetails,
                                          }),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.color8,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(MediaQuery.of(context).size.width / 40),
                                          child: Text(
                                            'Details',
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context).size.width / 32,
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
  });
}

}
