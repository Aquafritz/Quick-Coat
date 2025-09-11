import 'package:get/get.dart';
import 'package:quickcoat/screen/Admin/pages/orders/all_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/cancelled_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/delivered_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/pending_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/processing_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/returnandrefund_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/shipped_orders.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/add_product.dart';
import 'package:quickcoat/screen/Costumer/sections/costumer_setting.dart';
import 'package:quickcoat/screen/Costumer/sections/check_out.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase.dart';
import 'package:quickcoat/screen/landing/landing_page.dart';
import 'package:quickcoat/screen/Admin/AdminLayout.dart'; // <-- new
import 'package:quickcoat/screen/Costumer/costumerHome.dart';
import 'package:quickcoat/screen/Costumer/sections/productsdetails.dart';
import 'package:quickcoat/screen/Costumer/sections/shoppingcart.dart';
import 'package:quickcoat/screen/Drivers/DriverHome.dart';
import 'package:quickcoat/screen/auth/forgotPassword.dart';
import 'package:quickcoat/screen/auth/signIn.dart';
import 'package:quickcoat/screen/auth/signUp.dart';
import 'package:quickcoat/screen/others/aboutUs.dart';
import 'package:quickcoat/screen/others/contact.dart';
import 'package:quickcoat/screen/others/privacyPolicy.dart';
import 'package:quickcoat/screen/others/terms&condition.dart';

class AppRoutes {
  static const String landpage = '/';

  // Auth
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';
  static const String forgotpassword = '/forgotPassword';

  // Admin Layout
  static const String adminDashboard = '/adminDashboard';
  static const String adminProducts = '/adminProducts';
  
  static const String allOrders = '/allOrders';
    static const String pendingOrders = '/pendingOrders';
    static const String processingOrders = '/processingOrders';
  static const String shippedOrders = '/shippedOrders';
  static const String deliveredOrders = '/deliveredOrders';
  static const String cancelledOrders = '/cancelledOrders';
  static const String returnandrefundOrders = '/returnandrefundOrders';

  static const String adminAnalytics = '/adminAnalytics';
  static const String adminSettings = '/adminSettings';

  // Customer
  static const String costumerHome = '/costumerHome';
  static const String costumerSetting = '/costumerSetting';
  static const String checkOut = '/checkOut';
  static const String costumerPurchase = '/myPurchase';

  // Driver
  static const String driverHome = '/driverHome';

  // Products
  static const String productDetails = '/productDetails';
  static const String shoppingCart = '/shoppingCart';
  static const String addProduct = '/addProduct';

    // Others
  static const String contact = '/contact';
  static const String termsandcondition = '/terms&condition';
  static const String aboutus = '/aboutUs';
  static const String privacypolicy = '/privacyPolicy';

  static final routes = [
    GetPage(name: landpage, page: () => LandingPage()),

    // Auth
    GetPage(name: signIn, page: () => SignIn()),
    GetPage(name: signUp, page: () => SignUp()),
    GetPage(name: forgotpassword, page: () => ForgotPassword()),

    // Others
    GetPage(name: termsandcondition, page: () => TermsandCondition()),
    GetPage(name: aboutus, page: () => AboutUs()),
    GetPage(name: privacypolicy, page: () => PrivacyPolicy()),
    GetPage(name: contact, page: () => ContactPage()),

    // Costumer
    GetPage(name: costumerHome, page: () => CostumerHome()),
    GetPage(name: costumerSetting, page: () => CostumerSetting()),
    GetPage(name: checkOut, page: () => CheckOut()),
    GetPage(name: costumerPurchase, page: () => MyPurchase()),

    // Driver
    GetPage(name: driverHome, page: () => DriverHome()),

    // ✅ All admin routes use same layout
    GetPage(name: adminDashboard, page: () => const AdminLayout()),
    GetPage(name: adminProducts, page: () => const AdminLayout()),

    GetPage(name: allOrders, page: () => const AdminLayout()),
    GetPage(name: pendingOrders, page: () => const AdminLayout()),
    GetPage(name: processingOrders, page: () => const AdminLayout()),
    GetPage(name: shippedOrders, page: () => const AdminLayout()),
    GetPage(name: deliveredOrders, page: () => const AdminLayout()),
    GetPage(name: cancelledOrders, page: () => const AdminLayout()),
    GetPage(name: returnandrefundOrders, page: () => const AdminLayout()),

    GetPage(name: adminAnalytics, page: () => const AdminLayout()),
    GetPage(name: adminSettings, page: () => const AdminLayout()),

    // Products
    GetPage(name: productDetails, page: () => ProductsDetails()),
    GetPage(name: shoppingCart, page: () => ShoppingCart()),
    GetPage(name: addProduct, page: () => AddProduct()),
  ];
}
