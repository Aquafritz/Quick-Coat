import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/screen/header&footer/footer.dart';
import 'package:quickcoat/screen/header&footer/header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

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
                          "Contact Us",
                          style: TextStyle(
                            color: AppColors.color1,
                            fontSize: MediaQuery.of(context).size.width / 25,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ).fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 90),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 5,
                          vertical: MediaQuery.of(context).size.width / 100,
                        ),
                        child: Text(
                          "We'd love to hear from you. Get in touch with us for any inquiries or support.",
                          style: TextStyle(
                            color: AppColors.color1,
                            fontSize: MediaQuery.of(context).size.width / 55,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ).fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.width / 80),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildValueCard(
                                context,
                                FontAwesomeIcons.locationDot, // 📍 Visit Us
                                'Visit Us',
                                '123 Quick Coat Street, Metro Manila, Philippines',
                              ),
                              const SizedBox(width: 16),
                              buildValueCard(
                                context,
                                FontAwesomeIcons.phone, // ☎️ Call Us
                                'Call Us',
                                '+63 123 456 7890',
                              ),
                              const SizedBox(width: 16),
                              buildValueCard(
                                context,
                                FontAwesomeIcons.envelope, // 📧 Email Us
                                'Email Us',
                                "info@QuickCoat.com",
                              ),
                              const SizedBox(width: 16),
                              buildValueCard(
                                context,
                                FontAwesomeIcons.clock, // 🕒 Business Hours
                                'Business Hours',
                                'Mon–Fri: 9:00 AM – 6:00 PM\nSat: 9:00 AM – 3:00 PM\nSun: Closed',
                              ),
                            ],
                          ),
                        ),
                      ),

                      Center(
                        child: Text(
                          "Follow Us",
                          style: TextStyle(
                            color: AppColors.color1,
                            fontSize: MediaQuery.of(context).size.width / 25,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ).fontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width / 80),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildSocialCard(
                                context,
                                FontAwesomeIcons.facebook,
                                'Facebook',
                                'https://www.facebook.com',
                              ),
                              const SizedBox(width: 16),
                              buildSocialCard(
                                context,
                                FontAwesomeIcons.instagram,
                                'Instagram',
                                'https://www.instagram.com',
                              ),
                              const SizedBox(width: 16),
                              buildSocialCard(
                                context,
                                FontAwesomeIcons.xTwitter,
                                'X',
                                'https://twitter.com',
                              ),
                              const SizedBox(width: 16),
                              buildSocialCard(
                                context,
                                FontAwesomeIcons.youtube,
                                'YouTube',
                                'https://www.youtube.com',
                              ),
                            ],
                          ),
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

  Widget buildSocialCard(
    BuildContext context,
    IconData icon,
    String title,
    String url,
  ) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        try {
          if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
            throw 'Could not launch $url';
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to open link: $url')));
        }
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width /  7,
        height: MediaQuery.of(context).size.height / 4,
        child: Card(
          elevation: 8,
          shadowColor: AppColors.color11.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: AppColors.color11, size:  MediaQuery.of(context).size.width /  15,),
                SizedBox(height:  MediaQuery.of(context).size.height / 90,),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.color11,
                    fontSize: MediaQuery.of(context).size.width /  70,
                    fontFamily:
                        GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ).fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ).showCursorOnHover.moveUpOnHover,
      ),
    );
  }

 Widget buildValueCard(
  BuildContext context,
  IconData icon,
  String title,
  String description,
) {
  Future<void> handleTap() async {
    if (title == 'Visit Us') {
      final Uri url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=123+Quick+Coat+Street+Metro+Manila+Philippines");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else if (title == 'Call Us') {
      await Clipboard.setData(ClipboardData(text: description));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number copied to clipboard")),
      );
    } else if (title == 'Email Us') {
      await Clipboard.setData(ClipboardData(text: description));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email address copied to clipboard")),
      );
    }
  }

  return GestureDetector(
    onTap: handleTap,
    child: SizedBox(
      width: MediaQuery.of(context).size.width / 5.5,
      height: MediaQuery.of(context).size.height / 3,
      child: Card(
        elevation: 10,
        shadowColor: AppColors.color11.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              FaIcon(icon, color: AppColors.color11, size: MediaQuery.of(context).size.width / 25),
              SizedBox(height: MediaQuery.of(context).size.height / 90),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.color11,
                  fontSize: MediaQuery.of(context).size.width / 70,
                  fontFamily: GoogleFonts.inter(fontWeight: FontWeight.bold).fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 90),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 90,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ).showCursorOnHover.moveUpOnHover,
    ),
  );
}
}
