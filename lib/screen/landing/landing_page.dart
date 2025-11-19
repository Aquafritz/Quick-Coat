import 'package:flutter/material.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/landing/sections/first_section.dart';
import 'package:quickcoat/screen/header&footer/footer.dart';
import 'package:quickcoat/screen/landing/sections/second_section.dart';
import 'package:quickcoat/screen/landing/sections/third_section.dart';
import 'package:quickcoat/screen/header&footer/header.dart';
import 'package:quickcoat/screen/landing/sections/video_section.dart';
import 'package:quickcoat/screen/others/aboutUs.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color1,
      body: SafeArea(
        child: Column(
          children: [
            Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FirstSection(),
                    VideoSection(),
                    SecondSection(),
                    ThirdSection(),
                    Footer(),
                  ], // Assuming FourthSection is defined elsewhere,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
