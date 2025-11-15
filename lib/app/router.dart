import 'package:get/get.dart';
import 'package:quickcoat/screen/Admin/pages/delivery_driver/driver_informations.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/add_product.dart';
import 'package:quickcoat/screen/Costumer/sections/costumer_setting.dart';
import 'package:quickcoat/screen/Costumer/sections/check_out.dart';
import 'package:quickcoat/screen/Costumer/sections/my_purchase.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_delivery_history.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_profile_setting.dart';
import 'package:quickcoat/screen/Drivers/sections/driver_vehicle_information.dart';
import 'package:quickcoat/screen/auth/delivery_rider_signIn.dart';
import 'package:quickcoat/screen/landing/landing_page.dart';
import 'package:quickcoat/screen/Admin/AdminLayout.dart'; // <-- new
import 'package:quickcoat/screen/Costumer/costumerHome.dart';
import 'package:quickcoat/screen/Costumer/sections/productsdetails.dart';
import 'package:quickcoat/screen/Costumer/sections/shoppingcart.dart';
import 'package:quickcoat/screen/Drivers/driver_layout.dart';
import 'package:quickcoat/screen/auth/forgotPassword.dart';
import 'package:quickcoat/screen/auth/signIn.dart';
import 'package:quickcoat/screen/auth/signUp.dart';
import 'package:quickcoat/screen/others/aboutUs.dart';
import 'package:quickcoat/screen/others/contact.dart';
import 'package:quickcoat/screen/others/privacyPolicy.dart';
import 'package:quickcoat/screen/others/terms&condition.dart';
import 'package:quickcoat/services/success_payment.dart';

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
  static const String viewOrders = '/viewOrders';

  static const String driverList = '/driverList';
  static const String driverAssignment = '/driverAssignment';

  static const String adminAnalytics = '/adminAnalytics';
  static const String adminSettings = '/adminSettings';

  static const String manageUsers = '/manageUsers';
  static const String deletedUsers = '/deletedUsers';

  // Customer
  static const String costumerHome = '/costumerHome';
  static const String costumerSetting = '/costumerSetting';
  static const String checkOut = '/checkOut';
  static const String costumerPurchase = '/myPurchase';

  // Driver
  static const String driverHome = '/driverHome';
  static const String driverDeliveryHistory = '/deliveryHistory';
  static const String driverProfileSettings = '/profileSettings';
  static const String driverVehicleInformation = '/vehicleInformation';
  static const String driverSignIn = '/driverSignIn';
  static const String driverInformation = '/driverInformations';

  // Products
  static const String productDetails = '/productDetails';
  static const String shoppingCart = '/shoppingCart';
  static const String addProduct = '/addProduct';

  // Others
  static const String contact = '/contact';
  static const String termsandcondition = '/terms&condition';
  static const String aboutus = '/aboutUs';
  static const String privacypolicy = '/privacyPolicy';
  static const String successpayment = '/successPayment';

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
    GetPage(name: successpayment, page: () => SuccessPayment()),

    // Costumer
    GetPage(name: costumerHome, page: () => CostumerHome()),
    GetPage(name: costumerSetting, page: () => CostumerSetting()),
    GetPage(name: checkOut, page: () => CheckOut()),
    GetPage(name: costumerPurchase, page: () => MyPurchase()),

    // Driver
    GetPage(name: driverHome, page: () => DriverLayout()),
    GetPage(name: driverDeliveryHistory, page: () => DriverDeliveryHistory()),
    GetPage(name: driverProfileSettings, page: () => DriverProfileSettings()),
    GetPage(
      name: driverVehicleInformation,
      page: () => DriverVehicleInformation(),
    ),
    GetPage(name: driverSignIn, page: () => RiderLogin()),
    GetPage(name: driverInformation, page: () => AdminLayout()),

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
    GetPage(name: viewOrders, page: () => AdminLayout()),

    GetPage(name: adminAnalytics, page: () => const AdminLayout()),
    GetPage(name: adminSettings, page: () => const AdminLayout()),

    GetPage(name: productDetails, page: () => ProductsDetails()),
    GetPage(name: shoppingCart, page: () => ShoppingCart()),
    GetPage(name: addProduct, page: () => AddProduct()),

    GetPage(name: driverList, page: () => AdminLayout()),
    GetPage(name: driverAssignment, page: () => AdminLayout()),

    GetPage(name: manageUsers, page: () => AdminLayout()),
    GetPage(name: deletedUsers, page: () => AdminLayout()),
  ];
}
