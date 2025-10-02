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

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Assign Orders to ${driver['name'] ?? 'Driver'}"),
              content: SizedBox(
                width: 400,
                height: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
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

                        final isSelected = selectedOrders.containsKey(
                          orderDoc.id,
                        );

                        return CheckboxListTile(
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
                              // 🔹 Customer name + Order ID
                              Text(
                                "Order: ${order["orderId"] ?? orderDoc.id}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Customer: ${order["userDetails"]?["full_name"] ?? "Unknown"}",
                              ),

                              const SizedBox(height: 8),

                              // 🔹 Loop cartItems array
                              ...List<Widget>.from(
                                (order["cartItems"] as List<dynamic>? ?? []).map((
                                  item,
                                ) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              item["productImages"] ?? "",
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 10),

                                          // Product details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item["productName"] ??
                                                      "Unknown",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  "₱${item["productPrice"]} x ${item["quantity"]}",
                                                ),
                                                Text(
                                                  "Color: ${item["selectedColor"]}",
                                                ),
                                                Text(
                                                  "Size: ${item["selectedSize"]}",
                                                ),
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

                              // 🔹 Address
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

                              // 🔹 Status + Totals
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Status: ${order["status"] ?? "N/A"}",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Subtotal: ₱${order["subtotal"] ?? 0}",
                                      ),
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

                    try {
                      final batch = FirebaseFirestore.instance.batch();

                      final driverParcelRef = FirebaseFirestore.instance
                          .collection("assigned_driver_parcel")
                          .doc(driverId);

                      // 🔹 Prepare orders with status = "Shipped"
                      final shippedOrders = <String, Map<String, dynamic>>{};
                      selectedOrders.forEach((orderId, order) {
                        shippedOrders[orderId] = {
                          ...order, // copy existing fields
                          "status": "Shipped", // force status
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
                            .doc(orderId);
                        batch.update(orderRef, {"status": "Shipped"});
                      }

                      // 🔹 Commit batch
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
