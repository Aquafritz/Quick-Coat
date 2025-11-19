import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickcoat/app/router.dart';
import 'package:quickcoat/screen/landing/landing_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  static bool isOrdersExpanded = false;
  static bool isDeliveryExpanded = false;
  static bool isSettingsExpanded = false;

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Get.offAll(() => const LandingPage());
    } catch (e) {
      debugPrint("Error signing out: $e");
      Get.snackbar(
        "Error",
        "Failed to sign out. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1F2937),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              /// Main Scrollable Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      _buildHeader(),

                      const SizedBox(height: 25),

                      // ✅ Menu items
                      menuItem(
                        Icons.dashboard,
                        'Dashboard',
                        AppRoutes.adminDashboard,
                      ),
                      menuItem(
                        Icons.inventory,
                        'Products',
                        AppRoutes.adminProducts,
                      ),

                      _buildOrdersSection(),
                      _buildDeliveryDrivers(),
                      
                      menuItem(
                        Icons.outlined_flag,
                        'Red Flags',
                        AppRoutes.redflag,
                      ),
                      menuItem(
                        Icons.bar_chart,
                        'Analytics',
                        AppRoutes.adminAnalytics,
                      ),
                      _buildSettings(),
                    ],
                  ),
                ),
              ),

              /// Fixed Bottom Section
              const Divider(color: Colors.white30, thickness: 0.5),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                  size: 20,
                ),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
                onTap: _signOut,
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/qclogo.png',
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Admin Panel",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Quick Coat",
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Quality Kapote for Everyone",
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Colors.white70,
        colorScheme: const ColorScheme.dark(),
      ),
      child: ExpansionTile(
        initiallyExpanded: isOrdersExpanded,
        onExpansionChanged: (expanded) {
          setState(() => isOrdersExpanded = expanded);
        },
        leading: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
        title: const Text(
          "Orders",
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        childrenPadding: const EdgeInsets.only(left: 20),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: [
          Column(
            children: [
              subMenuItem("All Orders", AppRoutes.allOrders),
              subMenuItem("Pending Orders", AppRoutes.pendingOrders),
              subMenuItem("Processing Orders", AppRoutes.processingOrders),
              subMenuItem("Shipped Orders", AppRoutes.shippedOrders),
              subMenuItem("Delivered Orders", AppRoutes.deliveredOrders),
              subMenuItem("Cancelled Orders", AppRoutes.cancelledOrders),
              subMenuItem("Return & Refund Orders", AppRoutes.returnandrefundOrders),
            ],
          ),
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      onTap: () {
        setState(() => isOrdersExpanded = false);
        Get.offNamed(route);
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget subMenuItem(String title, String route) {
    return ListTile(
      leading: const Icon(Icons.arrow_right, color: Colors.white54, size: 18),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      onTap: () {
        setState(() => isOrdersExpanded = true);
        Get.toNamed(route);
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildSettings() {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Colors.white70,
        colorScheme: const ColorScheme.dark(),
      ),
      child: ExpansionTile(
        initiallyExpanded: isSettingsExpanded,
        onExpansionChanged: (expanded) {
          setState(() => isSettingsExpanded = expanded);
        },
        leading: const Icon(Icons.settings, color: Colors.white, size: 20),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        childrenPadding: const EdgeInsets.only(left: 20),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: [
          Column(
            children: [
              settingsSubMenu("Active Customers", AppRoutes.manageUsers),
              settingsSubMenu("Inactive Customers", AppRoutes.deletedUsers),
            ],
          ),
        ],
      ),
    );
  }

  Widget settingsSubMenu(String title, String route) {
    return ListTile(
      leading: const Icon(Icons.arrow_right, color: Colors.white54, size: 18),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      onTap: () {
        setState(() => isSettingsExpanded = true);
        Get.toNamed(route);
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDeliveryDrivers() {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: Colors.white70,
        colorScheme: const ColorScheme.dark(),
      ),
      child: ExpansionTile(
        initiallyExpanded: isDeliveryExpanded,
        onExpansionChanged: (expanded) {
          setState(() => isDeliveryExpanded = expanded);
        },
        leading: const Icon(
          Icons.local_shipping_rounded,
          color: Colors.white,
          size: 20,
        ),
        title: const Text(
          "Delivery Driver",
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        childrenPadding: const EdgeInsets.only(left: 20),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: [
          Column(
            children: [
              deliverysubMenuItem("Driver List", AppRoutes.driverList),
              deliverysubMenuItem(
                "Driver Assignment",
                AppRoutes.driverAssignment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget deliverysubMenuItem(String title, String route) {
    return ListTile(
      leading: const Icon(Icons.arrow_right, color: Colors.white54, size: 18),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      onTap: () {
        setState(() => isDeliveryExpanded = true);
        Get.toNamed(route);
      },
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
