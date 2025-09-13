import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dashboardCard(context),
            SizedBox(
              height: MediaQuery.of(context).size.width / 20,
            ),
            Text("Today's Deliveries", style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500
                    ),),
                     SizedBox(
              height: MediaQuery.of(context).size.width / 70,
            ),
            deliveries(context)
          ]
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context) {
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
              'Welcome Back, Full Name!',
              style: GoogleFonts.roboto(
                fontSize: MediaQuery.of(context).size.width / 20,
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
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 3,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.color6.withOpacity(1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.color8,
                        child: Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "2",
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
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 3,
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.color6.withOpacity(1),
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
                      CircleAvatar(
                        backgroundColor: AppColors.color8,
                        child: Icon(Icons.check_circle, color: Colors.white),
                      ),
                      Text(
                        "12",
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
  }

 Widget deliveries(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width / 1.15,
    height: MediaQuery.of(context).size.width / 1.6,
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
        horizontal: MediaQuery.of(context).size.width / 30
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order # 124512', style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width / 20,      
                fontWeight: FontWeight.w600        
                ),
                ),
              Container(
                 decoration: BoxDecoration(
            color: AppColors.color5,
            borderRadius: BorderRadius.circular(12)
          ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('In Progress', style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width / 30,      
                fontWeight: FontWeight.w400        
                ),),
                ),
              )
            ],
          ),  SizedBox(
            height: MediaQuery.of(context).size.width / 30
          ),
             Row(
            children: [
              Icon(Icons.timer_outlined),
              Text('Today, 10:30 AM', style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width / 35,      
                fontWeight: FontWeight.w400        
                ),),
            ],
          ),  SizedBox(
            height: MediaQuery.of(context).size.width / 30
          ),
             Row(
            children: [
              Icon(Icons.check_box_outlined),
              Text('5 Items •', style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width / 35,      
                fontWeight: FontWeight.w400        
                ),),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width / 30
          ),
             Row(
            children: [
             Icon(Icons.location_city_outlined),
              Text('123 Makati City', style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width / 35,      
                fontWeight: FontWeight.w400        
                ),),
            ],
          ),
          Spacer(),
          Divider(),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₱ 12,124.00', style: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.width / 22,      
                fontWeight: FontWeight.w600        
                ),
                ),
              Container(
                      decoration: BoxDecoration(
            color: AppColors.color8,
            borderRadius: BorderRadius.circular(12)
          ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Details', style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width / 32,      
                  fontWeight: FontWeight.w400        
                  ),),
                ),
              )
            ],
          )
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
