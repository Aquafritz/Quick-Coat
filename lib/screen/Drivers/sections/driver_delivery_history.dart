import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

class DriverDeliveryHistory extends StatefulWidget {
  const DriverDeliveryHistory({super.key});

  @override
  State<DriverDeliveryHistory> createState() => _DriverDeliveryHistoryState();
}

class _DriverDeliveryHistoryState extends State<DriverDeliveryHistory> {
  String selected = "all_time";

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
                if (selected == 'all_time') allTime(context),
                if (selected == 'this_week') thisWeek(context),
                if (selected == 'this_month') thisMonth(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context) {
    final tabCount = 3;
    final tabWidth = MediaQuery.of(context).size.width / tabCount;

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
                  "Total: 4 Deliveries",
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 35,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: MediaQuery.of(context).size.width / 30,
                    color: AppColors.color8,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 40),
                  Text(
                    "Filter",
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 35,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
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
