import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Sidebar.dart';
import 'pages/DashboardPage.dart';
import 'pages/ProductsPage.dart';
import 'pages/OrdersPage.dart';
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
      case AppRoutes.adminOrders:
        page = OrdersPage();
        break;
      case AppRoutes.adminAnalytics:
        page = AnalyticsPage();
        break;
      case AppRoutes.adminSettings:
        page = SettingsPage();
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
