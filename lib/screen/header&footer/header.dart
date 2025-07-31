import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/features/hover_extensions.dart';

class Header extends StatelessWidget {
  const Header({super.key});

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
                  //Home
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 15.5,
                      height: MediaQuery.of(context).size.width / 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 120,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Home",
                          style: TextStyle(
                            color: AppColors.color11,
                            fontSize: MediaQuery.of(context).size.width / 90,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ).fontFamily,
                          ),
                        ),
                      ),
                    ).showCursorOnHover.moveUpOnHover,
                  ),
                  //Products
                  Container(
                    width: MediaQuery.of(context).size.width / 15.5,
                    height: MediaQuery.of(context).size.width / 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width / 120,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Products",
                        style: TextStyle(
                          color: AppColors.color11,
                          fontSize: MediaQuery.of(context).size.width / 90,
                          fontFamily:
                              GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ).fontFamily,
                        ),
                      ),
                    ),
                  ).showCursorOnHover.moveUpOnHover,
                  //About
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/aboutUs');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 15.5,
                      height: MediaQuery.of(context).size.width / 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 120,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "About",
                          style: TextStyle(
                            color: AppColors.color11,
                            fontSize: MediaQuery.of(context).size.width / 90,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ).fontFamily,
                          ),
                        ),
                      ),
                    ).showCursorOnHover.moveUpOnHover,
                  ),
                  //Contact Us
                  GestureDetector(
                    onTap: () {
                     Get.toNamed('/contact'); // Assuming you have a route named '/contact'
                    },
                    child:
                        Container(
                          width: MediaQuery.of(context).size.width / 15.5,
                          height: MediaQuery.of(context).size.width / 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width / 120,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Contact",
                              style: TextStyle(
                                color: AppColors.color11,
                                fontSize:
                                    MediaQuery.of(context).size.width / 90,
                                fontFamily:
                                    GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ).fontFamily,
                              ),
                            ),
                          ),
                        ).showCursorOnHover.moveUpOnHover,
                  ),
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
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.color11,
                    size: MediaQuery.of(context).size.width / 50,
                  ).showCursorOnHover.moveUpOnHover,
                  SizedBox(width: MediaQuery.of(context).size.width / 80),
                  //Sign In
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/signIn');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 15.5,
                      height: MediaQuery.of(context).size.width / 35,
                      decoration: BoxDecoration(
                        color: AppColors.color10,
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 120,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: AppColors.color1,
                            fontSize: MediaQuery.of(context).size.width / 90,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ).fontFamily,
                          ),
                        ),
                      ),
                    ).showCursorOnHover.moveUpOnHover,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 80),
                  //Sign Up
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/signUp');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 15.5,
                      height: MediaQuery.of(context).size.width / 35,
                      decoration: BoxDecoration(
                        color: Color(0xFFfff200),
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 120,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: AppColors.color11,
                            fontSize: MediaQuery.of(context).size.width / 90,
                            fontFamily:
                                GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ).fontFamily,
                          ),
                        ),
                      ),
                    ).showCursorOnHover.moveUpOnHover,
                  ),
                ],
              ),
            ],
          ),
        );
  }
}