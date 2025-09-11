import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/header&footer/footer.dart';
import 'package:quickcoat/screen/header&footer/header.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white, 
            AppColors.color6, // little color at top
            AppColors.color11, // match second section start
          ],
          stops: [0.0, 0.4, 0.8],
        ),
      ),
        child: SafeArea(
          child: Column(
            children: [
              Header(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "About Us",
                          style: TextStyle(
                            color: AppColors.color1,
                            fontSize:
                                MediaQuery.of(context).size.width / 25,
                            fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold)
                                .fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                          height:
                              MediaQuery.of(context).size.width / 90),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.width / 5,
                          vertical:
                              MediaQuery.of(context).size.width / 100,
                        ),
                        child: Text(
                          "Quick Coat started with a simple mission: to provide high-quality, stylish, and affordable rain protection for everyone.",
                          style: TextStyle(
                            color: AppColors.color1,
                            fontSize:
                                MediaQuery.of(context).size.width / 55,
                            fontFamily: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold)
                                .fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildInfoCard(
                              context,
                              "Our Mission",
                              "To provide innovative and high-quality rain protection solutions that enhance people's daily lives, while maintaining affordability and style."),
                          buildInfoCard(
                              context,
                              "Our Vision",
                              "To become the leading provider of rain protection gear in the Philippines, known for quality, innovation, and customer satisfaction."),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 80),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              "Our Values",
                              style: TextStyle(
                                color: AppColors.color1,
                                fontSize:
                                    MediaQuery.of(context).size.width / 50,
                                fontFamily: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold)
                                    .fontFamily,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildValueCard(
                                  context,
                                  Icons.verified,
                                  'Quality',
                                  'We never compromise on the quality of our products and services.',
                                ),
                                buildValueCard(
                                  context,
                                  Icons.support_agent,
                                  'Customer First',
                                  "Our customer's satisfaction is our top priority.",
                                ),
                                buildValueCard(
                                  context,
                                  Icons.lightbulb,
                                  'Innovation',
                                  'We constantly innovate to improve our products and services.',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Footer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(
      BuildContext context, String title, String description) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      height: MediaQuery.of(context).size.height / 3,
      child: Card(
        elevation: 10,
        shadowColor: AppColors.color11.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.color11,
                  fontSize: MediaQuery.of(context).size.width / 50,
                  fontFamily:
                      GoogleFonts.inter(fontWeight: FontWeight.bold).fontFamily,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 80,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildValueCard(BuildContext context, IconData icon, String title,
      String description) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      child: Card(
        elevation: 10,
        shadowColor: AppColors.color11.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.color11,
                size: MediaQuery.of(context).size.width / 25,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.color11,
                  fontSize: MediaQuery.of(context).size.width / 50,
                  fontFamily:
                      GoogleFonts.inter(fontWeight: FontWeight.bold).fontFamily,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 80,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
