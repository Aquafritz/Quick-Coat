import 'package:flutter/material.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/header&footer/footer.dart';
import 'package:quickcoat/screen/header&footer/header.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});
  
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: MediaQuery.of(context).size.width / 90, color: Colors.black87);
    final headingStyle = TextStyle(fontSize: MediaQuery.of(context).size.width / 70, fontWeight: FontWeight.bold,);

    return Scaffold(
      backgroundColor: AppColors.color1,
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
          child: Center(
            child: Column(
              children: [
                Header(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padded content
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width / 10,
                            MediaQuery.of(context).size.width / 60,
                            MediaQuery.of(context).size.width / 10,
                            MediaQuery.of(context).size.width / 60
                            ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Privacy Policy", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,)),
SizedBox(height: MediaQuery.of(context).size.height / 90,),
Center(
  child: SizedBox(
    width: MediaQuery.of(context).size.width / 1.1,
    child: Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
           MediaQuery.of(context).size.width / 25,
           MediaQuery.of(context).size.width / 40,
           MediaQuery.of(context).size.width / 4,
           MediaQuery.of(context).size.width / 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("1. Introduction", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text(
              "Welcome to Quick Coat. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile app or website.",
              style: textStyle,
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("2. Information We Collect", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("• Contact information (e.g., name, email) if provided via forms or communication.", style: textStyle),
            Text("• Device information such as model, OS version, and usage behavior.", style: textStyle),
            Text("• Optional location data, with your permission.", style: textStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("3. How We Use Your Information", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("• To respond to inquiries and provide customer support.", style: textStyle),
            Text("• To improve our app functionality and user experience.", style: textStyle),
            Text("• To send updates or promotional content (only with your consent).", style: textStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("4. Third-Party Services", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("We may use trusted third-party services for analytics and customer interaction. These include:", style: textStyle),
            Text("• Google Firebase (for analytics)", style: textStyle),
            Text("• Social media platforms (when accessing external links)", style: textStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("5. Data Security", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("We implement reasonable security measures to protect your information, but cannot guarantee absolute security over the internet.", style: textStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("6. Your Choices", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("• You may disable location services in your device settings.", style: textStyle),
            Text("• You can uninstall the app to stop all data collection.", style: textStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("7. Children’s Privacy", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("Our app is not intended for children under the age of 13. We do not knowingly collect information from children.", style: textStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("8. Changes to This Policy", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("We may update this Privacy Policy periodically. Users will be notified through in-app notices or app store updates.", style: textStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("9. Contact Us", style: headingStyle),
            SizedBox(height: MediaQuery.of(context).size.height / 90,),
            Text("If you have questions about this Privacy Policy, you may contact us at:", style: textStyle),
            Text("📧 info@quickcoat.com", style: textStyle),
            Text("📍 123 Quick Coat Street, Metro Manila, Philippines", style: textStyle),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
        
                        // Footer with no padding
                        Footer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
