import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/features/hover_extensions.dart';

class FirstSection extends StatefulWidget {
  const FirstSection({super.key});

  @override
  State<FirstSection> createState() => _FirstSectionState();
}

class _FirstSectionState extends State<FirstSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(border: Border(bottom: BorderSide.none)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset("assets/images/bgqc.png", fit: BoxFit.cover),
          // Gradient overlay - Modified to blend better with second section
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide.none),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.color10.withOpacity(0.15), // little color at top
                  AppColors.color10, // match second section start
                ],
                stops: [0.0, 0.8],
              ),
            ),
          ),
          // Content
          Container(
            margin: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.width / 15,
              horizontal: MediaQuery.of(context).size.width / 8.5,
            ),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.width / 30),
                Center(
                  child: Text(
                    "Premium Quality Coats",
                    style: TextStyle(
                      color: AppColors.color1,
                      fontSize: MediaQuery.of(context).size.width / 15,
                      fontFamily:
                          GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                          ).fontFamily,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Discover our wide range of coats with different designs, colors, and sizes.",
                    style: TextStyle(
                      color: AppColors.color1,
                      fontSize: MediaQuery.of(context).size.width / 50,
                      fontFamily:
                          GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ).fontFamily,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 7,
                      height: MediaQuery.of(context).size.width / 20,
                      decoration: BoxDecoration(
                        color: Color(0xFFfff200),
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 120,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Shop Now",
                          style: TextStyle(
                            color: AppColors.color11,
                            fontSize: MediaQuery.of(context).size.width / 50,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                ).fontFamily,
                          ),
                        ),
                      ),
                    ).showCursorOnHover.moveUpOnHover,
                    SizedBox(width: MediaQuery.of(context).size.width / 40),
                    Text(
                      "Learn More",
                      style: TextStyle(
                        color: AppColors.color1,
                        fontSize: MediaQuery.of(context).size.width / 50,
                        fontFamily:
                            GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                            ).fontFamily,
                      ),
                    ).moveUpOnHover.showCursorOnHover,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
