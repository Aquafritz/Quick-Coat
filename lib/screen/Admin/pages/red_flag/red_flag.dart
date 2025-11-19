import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';

class RedFlag extends StatelessWidget {
  const RedFlag({super.key});

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
                      'Red Flag List',
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

          final wProfile = totalWidth * 0.08;
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
                  headerCell("Costumer Profile", wProfile),
                  SizedBox(width: 40),
                  headerCell("Costumer Name", wName),
                  headerCell("Costumer Number", wNumber),
                  headerCell("Costumer Email", wStatus),
                  headerCell("Red Flag Count", wDeliveries),
                  SizedBox(width: 40),
                  headerCell("Red Flag History", wVehicle),

                  // headerCell("Actions", wActions), // new column
                ],
              ),
              const Divider(),

              /// 🔹 Fetch drivers from Firestore
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("users")
                        .where("accountType", isEqualTo: "Customer")
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("No costumer found"),
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
                              width: wProfile,
                              child: ClipOval(
                                child:
                                    driver["profile_picture"] != null
                                        ? Image.network(
                                          driver["profile_picture"],
                                          fit: BoxFit.cover,
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                              ),
                            ),
                            SizedBox(width: 40),
                            // NAME
                            rowCell(driver["full_name"] ?? "N/A", wName),

                            // PHONE
                            rowCell(driver["phone_number"] ?? "N/A", wNumber),

                            // EMAIL
                            rowCell(driver["email_Address"] ?? "N/A", wStatus),

                            // RED FLAG COUNT
                            rowCell(
                              (driver["redFlagCount"] ?? 0).toString(),
                              wDeliveries,
                              bold: true,
                              color: Colors.red,
                            ),

                            // RED FLAG HISTORY: OPEN POPUP DIALOG
                            SizedBox(
                              width: wVehicle,
                              child: TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text("Red Flag History"),
                                          content: SizedBox(
                                            width: 400,
                                            child:
                                                (driver["redFlagHistory"] ==
                                                            null ||
                                                        driver["redFlagHistory"]
                                                            .isEmpty)
                                                    ? const Text(
                                                      "No history available",
                                                    )
                                                    : Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children:
                                                          driver["redFlagHistory"]
                                                              .map<Widget>(
                                                                (
                                                                  item,
                                                                ) => Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        bottom:
                                                                            8,
                                                                      ),
                                                                  child: Text(
                                                                    "- ${item["reason"]}",
                                                                  ),
                                                                ),
                                                              )
                                                              .toList(),
                                                    ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text("Close"),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                child: const Text("View"),
                              ),
                            ),

                            // // ACTIONS BUTTON
                            // SizedBox(
                            //   width: wActions,
                            //   child: IconButton(
                            //     icon: const Icon(
                            //       Icons.remove_red_eye,
                            //       color: AppColors.color8,
                            //     ),
                            //     onPressed: () {
                            //       Get.toNamed(
                            //         '/customerDetails',
                            //         arguments: driver,
                            //       );
                            //     },
                            //   ),
                            // ),
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
