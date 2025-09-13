import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickcoat/screen/Drivers/DriverHome.dart';
import 'package:quickcoat/screen/auth/delivery_rider_signIn.dart';
import 'package:quickcoat/screen/landing/landing_page.dart';
import 'router.dart';
import 'package:get/get.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
    bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 600; // you can tweak breakpoint
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _setImmersiveMode();

    // 👇 make sure overlays are reapplied right after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setImmersiveMode();
    });
  }

  void _setImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setImmersiveMode(); // 👈 keep hiding bars after app resumes
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

