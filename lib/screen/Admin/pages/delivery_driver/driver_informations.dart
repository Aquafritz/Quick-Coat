import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';

class DriverInformations extends StatelessWidget {
  final Map<String, dynamic> driver;

  const DriverInformations({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    final filteredDriver =
        Map<String, dynamic>.from(driver)
          ..remove('accountType')
          ..remove('uid')
          ..remove('updatedAt')
          ..remove('createdAt');

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back_ios),
                        ).showCursorOnHover.moveUpOnHover,
                        Text(
                          'Driver Info',
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
    width: MediaQuery.of(context).size.width / 1.5,
    height: MediaQuery.of(context).size.width / 2,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width / 80,
        horizontal: MediaQuery.of(context).size.width / 80,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width / 20,
            backgroundImage: driver['profile_picture'] != null
                ? NetworkImage(driver['profile_picture'])
                : null,
            child: driver['profile_picture'] == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 80),
          Text(
            driver['full_name'] ?? 'N/A',
            style: GoogleFonts.roboto(
              fontSize: MediaQuery.of(context).size.width / 25,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 3.5,
                height: MediaQuery.of(context).size.width / 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width / 80,
                    horizontal: MediaQuery.of(context).size.width / 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 70,
                          color: AppColors.color8,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Divider(color: AppColors.color8),
                      Text(
                        'Account Type',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        driver['accountType'] ?? 'N/A',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 90),
                      Text(
                        'Email Address',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        driver['email'] ?? 'N/A',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 90),
                      Text(
                        'Phone Number',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        driver['phone_number'] ?? 'N/A',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 3.5,
                height: MediaQuery.of(context).size.width / 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width / 80,
                    horizontal: MediaQuery.of(context).size.width / 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Information',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 70,
                          color: AppColors.color8,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Divider(color: AppColors.color8),
                      Text(
                        'Vehicle Type',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        driver['vehicle_type'] ?? 'N/A',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 90),
                      Text(
                        'Vehicle Model',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        driver['vehicle_model'] ?? 'N/A',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 90),
                      Text(
                        'Vehicle Color',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        driver['vehicle_color'] ?? 'N/A',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 90),
                      Text(
                        'Plate Number',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        driver['plate_number'] ?? 'N/A',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 100,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
  );
}

}
