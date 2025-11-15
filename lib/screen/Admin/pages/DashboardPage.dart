import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/dashboard_card.dart';
import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/recent_orders_table.dart';
import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/receny_activity.dart';
import 'package:quickcoat/screen/Admin/pages/dashboard_sectors/top_selling_product.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // Helper to format money like ₱4,000
  String _formatCurrency(num value) {
    final formatter = NumberFormat('#,##0', 'en_PH');
    return '₱${formatter.format(value)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TopBar(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;
                  int cardsPerRow =
                      maxWidth > 900
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

                      Text(
                        "Admin Dashboard",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// DASHBOARD CARDS
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          /// TOTAL SALES (sum of total where status == Delivered)
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .where('status', isEqualTo: 'Delivered')
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Total Sales',
                                  value: 'Loading...',
                                  // trend: 'from last month',
                                  color: Colors.blue,
                                  icon: Icons.attach_money,
                                );
                              }

                              if (snapshot.hasError) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Total Sales',
                                  value: 'Error',
                                  // percentage: '+0%',
                                  // trend: 'from last month',
                                  color: Colors.blue,
                                  icon: Icons.attach_money,
                                );
                              }

                              num totalSales = 0;
                              for (var doc in snapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                final total = data['total'];
                                if (total is int || total is double) {
                                  totalSales += total;
                                } else if (total is String) {
                                  totalSales += num.tryParse(total) ?? 0;
                                }
                              }

                              return DashboardCard(
                                width: cardWidth,
                                title: 'Total Sales',
                                value: _formatCurrency(totalSales),
                                // percentages are static placeholders for now
                                // percentage: '+12.5%',
                                // trend: 'from last month',
                                color: Colors.blue,
                                icon: Icons.attach_money,
                              );
                            },
                          ),

                          /// ALL ORDERS (count of orders collection)
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Orders',
                                  value: 'Loading...',
                                  // // percentage: '+0%',
                                  // trend: 'from last month',
                                  color: Colors.green,
                                  icon: Icons.shopping_bag,
                                );
                              }

                              if (snapshot.hasError) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Orders',
                                  value: 'Error',
                                  // percentage: '+0%',
                                  // trend: 'from last month',
                                  color: Colors.green,
                                  icon: Icons.shopping_bag,
                                );
                              }

                              final ordersCount =
                                  snapshot.data?.docs.length ?? 0;

                              return DashboardCard(
                                width: cardWidth,
                                title: 'Orders',
                                value: ordersCount.toString(),
                                // percentage: '+8.2%',
                                // trend: 'from last month',
                                color: Colors.green,
                                icon: Icons.shopping_bag,
                              );
                            },
                          ),

                          /// ALL PRODUCTS (count of products collection)
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('products')
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Products',
                                  value: 'Loading...',
                                  // percentage: '+0%',
                                  // trend: 'from last month',
                                  color: Colors.purple,
                                  icon: Icons.inventory_2,
                                );
                              }

                              if (snapshot.hasError) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Products',
                                  value: 'Error',
                                  // percentage: '+0%',
                                  // trend: 'from last month',
                                  color: Colors.purple,
                                  icon: Icons.inventory_2,
                                );
                              }

                              final productsCount =
                                  snapshot.data?.docs.length ?? 0;

                              return DashboardCard(
                                width: cardWidth,
                                title: 'Products',
                                value: productsCount.toString(),
                                // percentage: '+3.7%',
                                // trend: 'from last month',
                                color: Colors.purple,
                                icon: Icons.inventory_2,
                              );
                            },
                          ),

                          /// PENDING DELIVERIES (orders where status == Pending)
                          StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .where('status', isEqualTo: 'Pending')
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Pending Deliveries',
                                  value: 'Loading...',
                                  // percentage: '-0%',
                                  // trend: 'from last month',
                                  color: Colors.orange,
                                  icon: Icons.local_shipping,
                                );
                              }

                              if (snapshot.hasError) {
                                return DashboardCard(
                                  width: cardWidth,
                                  title: 'Pending Deliveries',
                                  value: 'Error',
                                  // percentage: '-0%',
                                  // trend: 'from last month',
                                  color: Colors.orange,
                                  icon: Icons.local_shipping,
                                );
                              }

                              final pendingCount =
                                  snapshot.data?.docs.length ?? 0;

                              return DashboardCard(
                                width: cardWidth,
                                title: 'Pending Deliveries',
                                value: pendingCount.toString(),
                                // percentage: '-3.8%',
                                // trend: 'from last month',
                                color: Colors.orange,
                                icon: Icons.local_shipping,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// You said ignore Recent Orders table logic,
                      /// so we leave these widgets as they are.
                      const RecentOrdersTable(),
                      // const RecentActivity(),
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
