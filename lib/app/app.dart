import 'package:flutter/material.dart';
import 'package:quickcoat/screen/Drivers/DriverHome.dart';
import 'package:quickcoat/screen/auth/delivery_rider_signIn.dart';
import 'package:quickcoat/screen/landing/landing_page.dart';
import 'router.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

    bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600; // you can tweak breakpoint
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isOnMobile = constraints.maxWidth < 600;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QuickCoats',
          theme: ThemeData(primarySwatch: Colors.blue),

          // 👇 Decide initial screen
          home: isOnMobile ? DriverHome() : LandingPage(),

          getPages: AppRoutes.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}

