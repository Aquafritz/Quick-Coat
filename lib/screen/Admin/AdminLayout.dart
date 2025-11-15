import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickcoat/screen/Admin/pages/DeletedUsers.dart';
import 'package:quickcoat/screen/Admin/pages/ManageUsers.dart';
import 'package:quickcoat/screen/Admin/pages/delivery_driver/driver_assignment.dart';
import 'package:quickcoat/screen/Admin/pages/delivery_driver/driver_informations.dart';
import 'package:quickcoat/screen/Admin/pages/delivery_driver/driver_list.dart';
import 'package:quickcoat/screen/Admin/pages/orders/cancelled_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/delivered_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/pending_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/processing_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/returnandrefund_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/shipped_orders.dart';
import 'package:quickcoat/screen/Admin/pages/orders/view_orders.dart';
import 'Sidebar.dart';
import 'pages/DashboardPage.dart';
import 'pages/product_sectors/ProductsPage.dart';
import 'pages/orders/all_orders.dart';
import 'pages/AnalyticsPage.dart';
import 'pages/SettingsPage.dart';
import 'package:quickcoat/app/router.dart';

class AdminLayout extends StatelessWidget {
  const AdminLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current route to decide which page to show
    final currentRoute = Get.currentRoute;

    Widget page;
    switch (currentRoute) {
      case AppRoutes.adminProducts:
        page = ProductsPage();
        break;
      case AppRoutes.allOrders:
        page = AllOrders();
        break;
      case AppRoutes.pendingOrders:
        page = PendingOrders();
        break;
      case AppRoutes.processingOrders:
        page = ProcessingOrders();
        break;
      case AppRoutes.shippedOrders:
        page = ShippedOrders();
        break;
      case AppRoutes.deliveredOrders:
        page = DeliveredOrders();
        break;
      case AppRoutes.cancelledOrders:
        page = CancelledOrders();
        break;
      case AppRoutes.returnandrefundOrders:
        page = ReturnandRefundOrders();
        break;
      case AppRoutes.viewOrders:
        final args = Get.arguments as Map<String, dynamic>;
        page = ViewOrders(
          orderData: args["orderData"],
          orderId: args["orderId"],
          orderType:
              args["orderType"] ?? "General", // optional: default fallback
        );
        break;
      case AppRoutes.driverList:
        page = DriverList();
        break;
      case AppRoutes.driverInformation:
        page = DriverInformations(driver: Get.arguments);
        break;
      case AppRoutes.driverAssignment:
        page = DriverAssignment();
        break;
      case AppRoutes.adminAnalytics:
        page = AnalyticsPage();
        break;
      case AppRoutes.adminSettings:
        page = SettingsPage();
        break;
      case AppRoutes.manageUsers:
        page = ManageUsers();
        break;
      case AppRoutes.deletedUsers:
        page = DeletedUsers();
        break;
      case AppRoutes.adminDashboard:
      default:
        page = DashboardPage();
        break;
    }

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(), // Always visible sidebar
          Expanded(child: page), // Dynamic page content
        ],
      ),
    );
  }
}
