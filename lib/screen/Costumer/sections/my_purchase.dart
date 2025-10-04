import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/all.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/cancelled.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/delivered.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/pending.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/processing.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/return&refund.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase_sections/shipped.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';
import 'dart:ui' as ui;

class MyPurchase extends StatefulWidget {
  const MyPurchase({super.key});

  @override
  State<MyPurchase> createState() => _MyPurchaseState();
}

class _MyPurchaseState extends State<MyPurchase> {
  int selectedIndex = 0;

  Widget _buildSelectedWidget() {
    switch (selectedIndex) {
      case 0:
        return buildAll();
      case 1:
        return buildPending();
      case 2:
        return buildProcessing();
      case 3:
        return buildShipped();
      case 4:
        return buildDelivered();
      case 5:
        return buildCancelled();
      case 6:
        return buildReturnRefund();
      default:
        return buildAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const HeaderWithout(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/costumerHome');
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios),
                    Text(
                      'My Purchase',
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                        ]
                      )
                    ).showCursorOnHover.moveUpOnHover,
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      // Remove fixed height and let content decide
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          // ✅ prevent overflow
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildNavBar(context),
                              const SizedBox(height: 20),
                              _buildSelectedWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final tabs = [
      "All",
      "Pending",
      "Processing",
      "Shipped",
      "Delivered",
      "Cancelled",
      "Return & Refund",
    ];

    final List<double> textWidths =
        tabs.map((title) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: title,
              style: GoogleFonts.roboto(
                fontSize: MediaQuery.of(context).size.width / 90,
              ),
            ),
            textDirection: ui.TextDirection.ltr,
          )..layout();

          return textPainter.width;
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / tabs.length;

        return SizedBox(
          height: MediaQuery.of(context).size.width / 50,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  tabs.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: SizedBox(
                      width: tabWidth,
                      child: Center(
                        child: Text(
                          tabs[index],
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 90,
                            fontWeight:
                                selectedIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                selectedIndex == index
                                    ? AppColors.color8
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left:
                    tabWidth * selectedIndex +
                    (tabWidth - textWidths[selectedIndex]) / 2,
                bottom: -5,
                child: Container(
                  height: 2,
                  width: textWidths[selectedIndex],
                  color: AppColors.color8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
