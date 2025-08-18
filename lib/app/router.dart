import 'package:get/get.dart';
import 'package:quickcoat/features/landing/home/landing_page.dart';
import 'package:quickcoat/screen/Admin/AdminLayout.dart'; // <-- new
import 'package:quickcoat/screen/Costumer/CostumerHome.dart';
import 'package:quickcoat/screen/Drivers/DriverHome.dart';
import 'package:quickcoat/screen/auth/forgotPassword.dart';
import 'package:quickcoat/screen/auth/signIn.dart';
import 'package:quickcoat/screen/auth/signUp.dart';
import 'package:quickcoat/screen/sections/aboutUs.dart';
import 'package:quickcoat/screen/sections/contact.dart';
import 'package:quickcoat/screen/sections/privacyPolicy.dart';
import 'package:quickcoat/screen/sections/terms&condition.dart';

class AppRoutes {
  static const String landpage = '/';
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';
  static const String contact = '/contact';
  static const String forgotpassword = '/forgotPassword';
  static const String termsandcondition = '/terms&condition';
  static const String aboutus = '/aboutUs';
  static const String privacypolicy = '/privacyPolicy';
  

  // Admin Layout
  static const String adminDashboard = '/adminDashboard';
  static const String adminProducts = '/adminProducts';
  static const String adminOrders = '/adminOrders';
  static const String adminAnalytics = '/adminAnalytics';
  static const String adminSettings = '/adminSettings';

  static const String costumerHome = '/costumerHome';
  static const String driverHome = '/driverHome';

  static final routes = [
    GetPage(name: landpage, page: () => LandingPage()),
    GetPage(name: signIn, page: () => SignIn()),
    GetPage(name: signUp, page: () => SignUp()),
    GetPage(name: forgotpassword, page: () => ForgotPassword()),
    GetPage(name: termsandcondition, page: () => TermsandCondition()),
    GetPage(name: aboutus, page: () => AboutUs()),
    GetPage(name: privacypolicy, page: () => PrivacyPolicy()),
    GetPage(name: contact, page: () => ContactPage()),
    GetPage(name: costumerHome, page: () => CostumerHome()),
    GetPage(name: driverHome, page: () => DriverHome()),

    // ✅ All admin routes use same layout
    GetPage(name: adminDashboard, page: () => const AdminLayout()),
    GetPage(name: adminProducts, page: () => const AdminLayout()),
    GetPage(name: adminOrders, page: () => const AdminLayout()),
    GetPage(name: adminAnalytics, page: () => const AdminLayout()),
    GetPage(name: adminSettings, page: () => const AdminLayout()),
  ];
}
