import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/features/hover_extensions.dart';

class HeaderWithout extends StatelessWidget {
  const HeaderWithout({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 40,
            vertical: MediaQuery.of(context).size.width / 80,
          ),
          child: Row(
            children: [
              Image.asset(
                "assets/images/qclogo.png",
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.width / 30,
                width: MediaQuery.of(context).size.width / 30,
              ).showCursorOnHover,
              SizedBox(width: MediaQuery.of(context).size.width / 90),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 40,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Quick",
                      style: TextStyle(
                        color: AppColors.color11,
                        fontSize: MediaQuery.of(context).size.width / 50,
                        fontFamily:
                            GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ).fontFamily,
                      ),
                    ),
                    TextSpan(
                      text: "Coat",
                      style: TextStyle(
                        color: Color(0xFFfff200),
                        fontSize: MediaQuery.of(context).size.width / 50,
                        fontFamily:
                            GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ).fontFamily,
                      ),
                    ),
                  ],
                ),
              ).showCursorOnHover,
              Spacer(),
              Row(
                children: [
                 
                  SizedBox(width: MediaQuery.of(context).size.width / 80),
                  //Search bar
                  Container(
                    width: MediaQuery.of(context).size.width / 6,
                    height: MediaQuery.of(context).size.width / 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width / 120,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 90,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: MediaQuery.of(context).size.width / 70,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 120,
                        ),
                        Expanded(
                          child: Text(
                            "Search products...",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: MediaQuery.of(context).size.width / 90,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ).showCursorOnHover,
                  SizedBox(width: MediaQuery.of(context).size.width / 80),
                  //Cart
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/shoppingCart');
                    },
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.color11,
                      size: MediaQuery.of(context).size.width / 50,
                    ).showCursorOnHover.moveUpOnHover,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 80),
                  //Sign In
                  GestureDetector(
                    onTap: () {

                    },
                    child: // Replace the Sign Out Container with this widget
PopupMenuButton<int>(
  offset: Offset(0, MediaQuery.of(context).size.width / 35),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  onSelected: (value) {
    if (value == 0) {
      // Navigate to Profile Settings
      Get.toNamed("/profile"); // Example route
    } else if (value == 1) {
      // Handle Sign Out
      print("Sign Out Clicked");
      // Add your logout logic here
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 0,
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.black54),
          SizedBox(width: 8),
          Text("Profile"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 1,
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.black54),
          SizedBox(width: 8),
          Text("Settings"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 2,
      child: Row(
        children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 8),
          Text("Sign Out"),
        ],
      ),
    ),
  ],
  child: CircleAvatar(
    radius: MediaQuery.of(context).size.width / 70,
    // backgroundImage: AssetImage("assets/images/profile.jpg"), // replace with user image
    backgroundColor: Colors.green,
  ).showCursorOnHover.moveUpOnHover,
),

                  ),
                 
                ],
              ),
            ],
          ),
        );
  }
}