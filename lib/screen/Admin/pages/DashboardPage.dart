import 'package:flutter/material.dart';
import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/dashboard_card.dart';
import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/recent_orders_table.dart';
import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/receny_activity.dart';
import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/top_selling_product.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔹 Replaced old top bar with TopBar widget
            const TopBar(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;
                  int cardsPerRow = maxWidth > 900
                      ? 4
                      : maxWidth > 700
                          ? 2
                          : 1;

                  double spacing = 16;
                  double totalSpacing = spacing * (cardsPerRow - 1);
                  double cardWidth = (maxWidth - totalSpacing) / cardsPerRow;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      /// Admin Dashboard Title
                      Text(
                        "Admin Dashboard",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),

                      const SizedBox(height: 16),

                      /// Dashboard Cards
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          DashboardCard(
                            width: cardWidth,
                            title: 'Total Sales',
                            value: '₱158,432',
                            percentage: '+12.5%',
                            trend: 'from last month',
                            color: Colors.blue,
                            icon: Icons.attach_money,
                            isPositive: true,
                          ),
                          DashboardCard(
                            width: cardWidth,
                            title: 'Orders',
                            value: '243',
                            percentage: '+8.2%',
                            trend: 'from last month',
                            color: Colors.green,
                            icon: Icons.shopping_bag,
                            isPositive: true,
                          ),
                          DashboardCard(
                            width: cardWidth,
                            title: 'Products',
                            value: '78',
                            percentage: '+3.7%',
                            trend: 'from last month',
                            color: Colors.purple,
                            icon: Icons.inventory_2,
                            isPositive: true,
                          ),
                          DashboardCard(
                            width: cardWidth,
                            title: 'Pending Deliveries',
                            value: '56',
                            percentage: '-3.8%',
                            trend: 'from last month',
                            color: Colors.orange,
                            icon: Icons.local_shipping,
                            isPositive: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// Recent Orders Table
                      const RecentOrdersTable(),
                      const RecentActivity(),
                      const TopSellingProducts(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
