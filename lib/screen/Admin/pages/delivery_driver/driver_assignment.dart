import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';
import 'package:quickcoat/screen/auth/add_driver_account.dart';

class DriverAssignment extends StatelessWidget {
  const DriverAssignment({super.key});

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
                      'Driver Assignment',
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Status'),
              const SizedBox(width: 8),
              DropdownButton(items: null, onChanged: null),
              const SizedBox(width: 16),
              const Text('Date'),
              const SizedBox(width: 8),
              DropdownButton(items: null, onChanged: null),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: AppColors.color8,
            ),
            onPressed: () {
              DriverSignUpDialog().show(context);
            },
            child: Text(
              'New Driver',
              style: GoogleFonts.roboto(
                fontSize: MediaQuery.of(context).size.width / 90,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
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

          final wProfile = totalWidth * 0.12;
          final wName = totalWidth * 0.20;
          final wNumber = totalWidth * 0.16;
          final wStatus = totalWidth * 0.16;
          final wDeliveries = totalWidth * 0.10;
          final wVehicle = totalWidth * 0.12;
          final wActions = totalWidth * 0.10;

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
              Row(
                children: [
                  headerCell("Driver Profile", wProfile),
                  headerCell("Driver Name", wName),
                  headerCell("Driver Number", wNumber),
                  headerCell("Driver Status", wStatus),
                  headerCell("Current Deliveries", wDeliveries),
                  headerCell("Vehicle Type", wVehicle),
                  headerCell("Actions", wActions),
                ],
              ),
              const Divider(),

              /// 🔹 Fetch drivers from Firestore
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("users")
                        .where("accountType", isEqualTo: "Driver")
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("No drivers found"),
                    );
                  }

                  final drivers = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final doc = drivers[index];
                      final driver = doc.data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                                    SizedBox(
  width: MediaQuery.of(context).size.width / 25,
  height: MediaQuery.of(context).size.width / 25, // make sure height equals width
  child: ClipOval(
    child: driver["profile_picture"] != null
        ? Image.network(
            driver["profile_picture"],
            fit: BoxFit.cover, // fill the circle
            width: MediaQuery.of(context).size.width / 25,
            height: MediaQuery.of(context).size.width / 25,
          )
        : Icon(
            Icons.person,
            size: MediaQuery.of(context).size.width / 25,
            color: Colors.grey,
          ),
  ),
),

SizedBox(
  width: MediaQuery.of(context).size.width / 20,
),
                            rowCell(driver["full_name"] ?? "N/A", wName),
                            rowCell(driver["phone_number"] ?? "N/A", wNumber),
                            rowCell(
                              driver["status"] ?? "Active",
                              wStatus,
                              color: Colors.green,
                              bold: true,
                            ),
                             StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection("assigned_driver_parcel")
      .where("driverId", isEqualTo: doc.id)
      .snapshots(),
  builder: (context, snapshotDeliveries) {
    if (snapshotDeliveries.connectionState == ConnectionState.waiting) {
      return rowCell('...', wDeliveries, bold: true);
    }
    int activeDeliveries = 0;

    if (snapshotDeliveries.hasData) {
      for (var docParcel in snapshotDeliveries.data!.docs) {
        final ordersMap = docParcel['orders'] as Map<String, dynamic>? ?? {};
        ordersMap.forEach((key, order) {
          if (order['status'] != 'Delivered') {
            activeDeliveries++;
          }
        });
      }
    }

    return rowCell(activeDeliveries.toString(), wDeliveries, bold: true);
  },
),
                            rowCell(driver["vehicle_type"] ?? "N/A", wVehicle),

                            Row(
                              children: [
                                 SizedBox(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.remove_red_eye,
                                  color: AppColors.color8,
                                ),
                                onPressed: () {
                                  // Navigate to driver informations page
                                  Get.toNamed(
                                    '/driverInformations',
                                    arguments:
                                        driver, // pass the whole driver map
                                  );
                                },
                              ),
                            ),
                                SizedBox(
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.assignment_ind,
                                      color: AppColors.color8,
                                    ),
                                    onPressed: () {
                                      _showAssignDialog(context, doc.id, driver);
                                    },
                                  ),
                                ),
                              ],
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

  /// 🔹 Dialog to show products with status == "Process"
  void _showAssignDialog(
    BuildContext context,
    String driverId,
    Map<String, dynamic> driver,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final selectedOrders = <String, Map<String, dynamic>>{};
              final estimatedDates = <String, DateTimeRange>{}; // 🗓 store for each order

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Assign Orders to ${driver['name'] ?? 'Driver'}"),
              content: SizedBox(
                width: 400,
                height: 400,
                child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("orders")
        .where("status", isEqualTo: "Process")
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("No orders to assign"));
      }

      final orders = snapshot.data!.docs;

      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final orderDoc = orders[index];
          final order = orderDoc.data() as Map<String, dynamic>;
          final isSelected = selectedOrders.containsKey(orderDoc.id);
                      final range = estimatedDates[orderDoc.id];

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                value: isSelected,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedOrders[orderDoc.id] = order;
                    } else {
                      selectedOrders.remove(orderDoc.id);
                    }
                  });
                },
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order: ${order["orderId"] ?? orderDoc.id}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Customer: ${order["userDetails"]?["full_name"] ?? "Unknown"}",
                    ),
                    const SizedBox(height: 8),

                    // 🛍 Items
                    ...List<Widget>.from(
                      (order["cartItems"] as List<dynamic>? ?? []).map((item) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item["productImages"] ?? "",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["productName"] ?? "Unknown",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                          "₱${item["productPrice"]} x ${item["quantity"]}"),
                                      Text("Color: ${item["selectedColor"]}"),
                                      Text("Size: ${item["selectedSize"]}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 6),

                    // 📦 Address
                    if (order["selectedAddress"] != null) ...[
                      Text(
                        "Ship to: ${order["selectedAddress"]["house_number"]} "
                        "${order["selectedAddress"]["street"]}, "
                        "${order["selectedAddress"]["barangay"]}, "
                        "${order["selectedAddress"]["city_municipality"]}, "
                        "${order["selectedAddress"]["province"]}, "
                        "${order["selectedAddress"]["country"]} "
                        "(${order["selectedAddress"]["postal_code"]})",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],

                    const SizedBox(height: 6),

                    // 💰 Totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Status: ${order["status"] ?? "N/A"}",
                          style: const TextStyle(color: Colors.blue),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Subtotal: ₱${order["subtotal"] ?? 0}"),
                            Text(
                              "Total: ₱${order["total"] ?? 0}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🗓 Estimated Date (under each order)
             GestureDetector(
  onTap: () async {
    DateTime? startDate = range?.start ?? DateTime.now();
    DateTime? endDate = range?.end ?? DateTime.now().add(const Duration(days: 3));

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Select Estimated Delivery Date",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 300,
                height: 250,
                child: Column(
                  children: [
                    // 🔹 Start Date Picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Start Date",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                     subtitle: Text(
  startDate != null
      ? "${startDate!.month}/${startDate!.day}/${startDate!.year}"
      : "Select date",
  style: const TextStyle(fontSize: 12),
),


                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate!,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.color8,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setLocalState(() => startDate = picked);
                          }
                        },
                      ),
                    ),

                    // 🔹 End Date Picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "End Date",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                      subtitle: Text(
  endDate != null
      ? "${endDate!.month}/${endDate!.day}/${endDate!.year}"
      : "Select date",
  style: const TextStyle(fontSize: 12),
),

                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate!,
                            firstDate: startDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.color8,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setLocalState(() => endDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      estimatedDates[orderDoc.id] = DateTimeRange(
                        start: startDate!,
                        end: endDate!,
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  },
  child: Container(
    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.color8,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      range == null
          ? "Estimated Date"
          : "Estimated: ${range.start.month}/${range.start.day}/${range.start.year} - ${range.end.month}/${range.end.day}/${range.end.year}",
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.white,
      ),
    ),
  ),
)

                        ],
                      );
                    },
                  );
                },
              ),
            ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
  if (selectedOrders.isEmpty) return;

    // 🔹 Check if all selected orders have estimated dates
    final hasMissingDates = selectedOrders.keys.any(
      (id) => estimatedDates[id] == null,
    );

    if (hasMissingDates) {
      Toastify.show(
        context,
        message: 'Missing Estimated Date',
        description: 'Please select estimated delivery dates for all selected orders before assigning.',
        type: ToastType.warning,
      );
      return;
    }

  try {
    final batch = FirebaseFirestore.instance.batch();

    final driverParcelRef = FirebaseFirestore.instance
        .collection("assigned_driver_parcel")
        .doc(driverId);

    // 🔹 Prepare orders with status = "Shipped"
    final shippedOrders = <String, Map<String, dynamic>>{};
    selectedOrders.forEach((orderId, order) {
               final selectedRange = estimatedDates[orderId];

      shippedOrders[orderId] = {
        ...order,
        "status": "Shipped",
if (selectedRange != null) ...{
  "estimated_start": Timestamp.fromDate(selectedRange.start),
  "estimated_end": Timestamp.fromDate(selectedRange.end),
},

      };
    });

    // 🔹 Save to assigned_driver_parcel
    batch.set(driverParcelRef, {
      "driverId": driverId,
      "driver_email": driver["email"],
      "driverName": driver["full_name"],
      "driverNumber": driver["phone_number"],
      "vehicle_type": driver["vehicle_type"],
      "vehicle_model": driver["vehicle_model"],
      "vehicle_color": driver["vehicle_color"],
      "plate_number": driver["plate_number"],
      "assignedAt": FieldValue.serverTimestamp(),
      "orders": shippedOrders,
    }, SetOptions(merge: true));

    // 🔹 Update status in orders collection
    for (var orderId in selectedOrders.keys) {
      final orderRef = FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId);final selectedRange = estimatedDates[orderId]; // ✅ get range for this order

  batch.update(orderRef, {
    "status": "Shipped",
    if (selectedRange != null) ...{
      "estimated_start": Timestamp.fromDate(selectedRange.start),
      "estimated_end": Timestamp.fromDate(selectedRange.end),
    },
  });
}

    await batch.commit();

    Navigator.pop(context);
    Toastify.show(
      context,
      message: 'Success',
      description: 'Orders assigned to driver successfully!',
      type: ToastType.success,
    );
  } catch (e) {
    Toastify.show(
      context,
      message: 'Error',
      description: 'Failed to assign orders: $e',
      type: ToastType.error,
    );
  }
},

                  child: const Text("Assign to Driver"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
