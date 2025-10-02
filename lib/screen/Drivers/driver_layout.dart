import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_delivery.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_home.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_orders.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_profile.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class DriverLayout extends StatefulWidget {
  const DriverLayout({super.key});

  @override
  State<DriverLayout> createState() => _DriverLayoutState();
}

class _DriverLayoutState extends State<DriverLayout> {
  final Color navigationBarColor = Colors.white;
  int selectedIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    /// [AnnotatedRegion<SystemUiOverlayStyle>] only for android black navigation bar. 3 button navigation control (legacy)

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
         extendBody: true,
    extendBodyBehindAppBar: true,
    backgroundColor: Colors.transparent, // let your container show behind
       body: SafeArea(
         top: false,   // 👈 allow drawing under status bar
         bottom: false, // 👈 allow drawing under nav bar
         child: PageView(
           physics: const NeverScrollableScrollPhysics(),
           controller: pageController,
           children: <Widget>[
              DriverHomePage(),
              DriverOrders(),
             DeliveryProfile()
           ],
         ),
       ),

        bottomNavigationBar: WaterDropNavBar(
          waterDropColor: AppColors.color8,
          backgroundColor: navigationBarColor,
          onItemSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
            pageController.animateToPage(
              selectedIndex,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
            );
          },
          selectedIndex: selectedIndex,
          bottomPadding: 10, // optional padding for spacing
          iconSize: 32, // <-- this controls all icons' size
          barItems: <BarItem>[
            BarItem(
              filledIcon: Icons.home_rounded,
              outlinedIcon: Icons.home_outlined,
            ),
            BarItem(
              filledIcon: Icons.shopping_bag_rounded, // for Orders
              outlinedIcon: Icons.shopping_bag_outlined,
            ),
            BarItem(
              filledIcon: Icons.person_rounded, // for Profile
              outlinedIcon: Icons.person_outline,
            ),
          ],
        ),
      ),
    );
  }
}
