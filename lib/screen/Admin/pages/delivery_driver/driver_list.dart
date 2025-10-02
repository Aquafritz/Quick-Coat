import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';
import 'package:quickcoat/screen/auth/add_driver_account.dart';

class DriverList extends StatelessWidget {
  const DriverList({super.key});

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
                      'Driver List',
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
                borderRadius: BorderRadiusGeometry.circular(8),
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
          final wActions = totalWidth * 0.08;

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
                  headerCell("Actions", wActions), // new column
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
                              height:
                                  MediaQuery.of(context).size.width /
                                  25, // make sure height equals width
                              child: ClipOval(
                                child:
                                    driver["profile_picture"] != null
                                        ? Image.network(
                                          driver["profile_picture"],
                                          fit: BoxFit.cover, // fill the circle
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width /
                                              25,
                                          height:
                                              MediaQuery.of(
                                                context,
                                              ).size.width /
                                              25,
                                        )
                                        : Icon(
                                          Icons.person,
                                          size:
                                              MediaQuery.of(
                                                context,
                                              ).size.width /
                                              25,
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
                              stream:
                                  FirebaseFirestore.instance
                                      .collection("assigned_driver_parcel")
                                      .where("driverId", isEqualTo: doc.id)
                                      .snapshots(),
                              builder: (context, snapshotDeliveries) {
                                if (snapshotDeliveries.connectionState ==
                                    ConnectionState.waiting) {
                                  return rowCell(
                                    '...',
                                    wDeliveries,
                                    bold: true,
                                  );
                                }
                                int activeDeliveries = 0;

                                if (snapshotDeliveries.hasData) {
                                  for (var docParcel
                                      in snapshotDeliveries.data!.docs) {
                                    final ordersMap =
                                        docParcel['orders']
                                            as Map<String, dynamic>? ??
                                        {};
                                    ordersMap.forEach((key, order) {
                                      if (order['status'] != 'Delivered') {
                                        activeDeliveries++;
                                      }
                                    });
                                  }
                                }

                                return rowCell(
                                  activeDeliveries.toString(),
                                  wDeliveries,
                                  bold: true,
                                );
                              },
                            ),

                            rowCell(driver["vehicle_type"] ?? "N/A", wVehicle),
                            SizedBox(
                              width: totalWidth * 0.08,
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
