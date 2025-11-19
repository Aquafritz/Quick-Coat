import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

class SecondSection extends StatefulWidget {
  const SecondSection({super.key});

  @override
  State<SecondSection> createState() => _SecondSectionState();
}

class _SecondSectionState extends State<SecondSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ Colors.white, AppColors.color5, AppColors.color10,],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width / 15,
          horizontal: MediaQuery.of(context).size.width / 40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(
              child: Text(
                "What Our Customers Say",
                style: TextStyle(
                  color: AppColors.color11,
                  fontSize: MediaQuery.of(context).size.width / 25,
                  fontFamily:
                      GoogleFonts.inter(fontWeight: FontWeight.bold).fontFamily,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3.3,
                  height: MediaQuery.of(context).size.width / 5,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 60,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width / 150,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.color11,
                            radius: MediaQuery.of(context).size.width / 40,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width / 30,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width / 60),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Maria Santos", 
                                style: TextStyle(
                                  color: AppColors.color11,
                                  fontSize: MediaQuery.of(context).size.width / 60,
                                  fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ).fontFamily,
                                ),
                              ),
                              Text("Regular Customer",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: MediaQuery.of(context).size.width / 100,
                                  fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ).fontFamily,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Text(
                        '"The quality of QuickCoat products is exceptional!. I have been using their coats for years and they never disappoint!"',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: MediaQuery.of(context).size.width / 60,
                          fontFamily: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ).fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3.3,
                  height: MediaQuery.of(context).size.width / 5,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 60,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width / 150,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.color11,
                            radius: MediaQuery.of(context).size.width / 40,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width / 30,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width / 60),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Lisa Reyes", 
                                style: TextStyle(
                                  color: AppColors.color11,
                                  fontSize: MediaQuery.of(context).size.width / 60,
                                  fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ).fontFamily,
                                ),
                              ),
                              Text("New Customer",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: MediaQuery.of(context).size.width / 100,
                                  fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ).fontFamily,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Text(
                        '"I recently discovered QuickCoat and I am impressed with their selection and quality. The coats are stylish and comfortable!"',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: MediaQuery.of(context).size.width / 60,
                          fontFamily: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ).fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 3.3,
                  height: MediaQuery.of(context).size.width / 5,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 60,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width / 150,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.color11,
                            radius: MediaQuery.of(context).size.width / 40,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.width / 30,
                            ),
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width / 60),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Juan Dela Cruz", 
                                style: TextStyle(
                                  color: AppColors.color11,
                                  fontSize: MediaQuery.of(context).size.width / 60,
                                  fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ).fontFamily,
                                ),
                              ),
                              Text("Retailer",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: MediaQuery.of(context).size.width / 100,
                                  fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ).fontFamily,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Text(
                        '"As a retailer, I appreciate the variety and quality of QuickCoat products. My customers always comes back for more!"',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: MediaQuery.of(context).size.width / 60,
                          fontFamily: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ).fontFamily,
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
}
