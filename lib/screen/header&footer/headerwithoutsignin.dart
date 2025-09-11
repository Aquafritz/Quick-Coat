import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeaderWithout extends StatelessWidget {
  const HeaderWithout({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text("Not signed in");
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;

        final fullName = userData?["full_name"] ?? "Guest User";
        final email = userData?["email_Address"] ?? user.email ?? "";
        final profilePic = userData?["profile_picture"];

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 40,
            vertical: MediaQuery.of(context).size.width / 80,
          ),
          child: Row(
            children: [
              // ✅ Logo
              Image.asset(
                "assets/images/qclogo.png",
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.width / 30,
                width: MediaQuery.of(context).size.width / 30,
              ).showCursorOnHover,

              SizedBox(width: MediaQuery.of(context).size.width / 90),

              // ✅ QuickCoat Logo Text
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
                        fontFamily: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ).fontFamily,
                      ),
                    ),
                    TextSpan(
                      text: "Coat",
                      style: TextStyle(
                        color: const Color(0xFFfff200),
                        fontSize: MediaQuery.of(context).size.width / 50,
                        fontFamily: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                        ).fontFamily,
                      ),
                    ),
                  ],
                ),
              ).showCursorOnHover,

              const Spacer(),

              // ✅ Search bar
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 6,
                    height: MediaQuery.of(context).size.width / 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width / 120,
                      ),
                      boxShadow: const [
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
                            width: MediaQuery.of(context).size.width / 120),
                        Expanded(
                          child: Text(
                            "Search products...",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize:
                                  MediaQuery.of(context).size.width / 90,
                              fontFamily: GoogleFonts.inter().fontFamily,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ).showCursorOnHover,

                  SizedBox(width: MediaQuery.of(context).size.width / 80),

                  // ✅ Cart Icon
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

                  // ✅ Profile Menu
                  PopupMenuButton<int>(
                    offset:
                        Offset(0, MediaQuery.of(context).size.width / 35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 0) {
                        Get.toNamed("/myPurchase");
                      } else if (value == 1) {
                        Get.toNamed('/costumerSetting');
                      } else if (value == 2) {
                        Get.toNamed('/logout');
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 0,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.black54),
                            SizedBox(width: 8),
                            Text("My Purchase"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.settings, color: Colors.black54),
                            SizedBox(width: 8),
                            Text("Settings"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 70,
                          backgroundImage: profilePic != null
                              ? NetworkImage(profilePic)
                              : null,
                          backgroundColor: Colors.grey.shade300,
                          child: profilePic == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                         Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fullName,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(email,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                      ],
                    ).showCursorOnHover.moveUpOnHover,
                  ),

                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
