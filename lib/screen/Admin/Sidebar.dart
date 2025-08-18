import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickcoat/app/router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF1F2937),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Padding(
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
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
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
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// ✅ Menu items
          menuItem(Icons.dashboard, 'Dashboard', AppRoutes.adminDashboard),
          menuItem(Icons.inventory, 'Products', AppRoutes.adminProducts),
          menuItem(Icons.shopping_cart, 'Orders', AppRoutes.adminOrders),
          menuItem(Icons.bar_chart, 'Analytics', AppRoutes.adminAnalytics),
          menuItem(Icons.settings, 'Settings', AppRoutes.adminSettings),
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
      onTap: () => Get.offNamed(route),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
