import 'package:get/get.dart';
import 'package:quickcoat/features/landing/home/landing_page.dart';
import 'package:quickcoat/screen/Admin/AdminHome.dart';
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
  static const String adminHome = '/adminHome';
  static const String costumerHome = '/costumerHome';
  static const String driverHome = '/driverHome';


  static final routes = [
    GetPage(name: '/', page: () => LandingPage()),
    GetPage(name: '/contact', page: () => ContactPage()),
    GetPage(name: '/signIn', page: () => SignIn()),
    GetPage(name: '/signUp', page: () => SignUp()),
    GetPage(name: '/forgotPassword', page: () => ForgotPassword()),
    GetPage(name: '/terms&condition', page: () => TermsandCondition()),
    GetPage(name: '/aboutUs', page: () => AboutUs()),
    GetPage(name: '/privacyPolicy', page: () => PrivacyPolicy()),
    GetPage(name: '/adminHome', page: () => AdminHome()),
    GetPage(name: '/costumerHome', page: () => CostumerHome()),
    GetPage(name: '/driverHome', page: () => DriverHome()),
  ];
}