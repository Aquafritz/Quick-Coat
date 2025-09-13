import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_home.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
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
             Container(
               alignment: Alignment.center,
               child: Icon(
                 Icons.favorite_rounded,
                 size: 56,
                 color: Colors.red[400],
               ),
             ),
             Container(
               alignment: Alignment.center,
               child: Icon(
                 Icons.email_rounded,
                 size: 56,
                 color: Colors.green[400],
               ),
             ),
             Container(
               alignment: Alignment.center,
               child: Icon(
                 Icons.folder_rounded,
                 size: 56,
                 color: Colors.brown[400],
               ),
             ),
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
              filledIcon: Icons.local_shipping_rounded, // for Delivery
              outlinedIcon: Icons.local_shipping_outlined,
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
