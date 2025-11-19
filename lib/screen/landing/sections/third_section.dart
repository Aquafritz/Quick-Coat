import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/screen/landing/product_list_view.dart';

class ThirdSection extends StatefulWidget {
  const ThirdSection({super.key});

  @override
  State<ThirdSection> createState() => _ThirdSectionState();
}

class _ThirdSectionState extends State<ThirdSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.color10, // match second section start
            AppColors.color6, // little color at top
            Colors.grey.shade100, 
            
          ],
          stops: [0.0, 0.4, 0.8],
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width / 10,
          horizontal: MediaQuery.of(context).size.width / 40,
        ),
        child: Column(
          children: [
            Center(
              child: Text(
                "Explore Our Exclusive Collection",
                style: TextStyle(
                  color: AppColors.color1,
                  fontSize: MediaQuery.of(context).size.width / 25,
                  fontFamily:
                      GoogleFonts.inter(fontWeight: FontWeight.bold).fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Featured Products",
                  style: TextStyle(
                    color: AppColors.color1,
                    fontSize: MediaQuery.of(context).size.width / 50,
                    fontFamily:
                        GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ).fontFamily,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/signIn');
                  },
                  child: Row(
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                          color: AppColors.color1,
                          fontSize: MediaQuery.of(context).size.width / 50,
                          fontFamily:
                              GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ).fontFamily,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 100),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.color1,
                        size: MediaQuery.of(context).size.width / 50,
                      ),
                    ],
                  ),
                ).showCursorOnHover.moveUpOnHover,
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 80),
            ProductListView(),
            SizedBox(height: MediaQuery.of(context).size.width / 30),
          ],
        ),
      ),
    );
  }
}
