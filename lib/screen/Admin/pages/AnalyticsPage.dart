import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quickcoat/screen/Admin/pages/day_status_bar_chart.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';
import 'package:quickcoat/screen/Admin/pages/monthly_sales_line_chart.dart';
import 'package:quickcoat/screen/Admin/pages/purchase_count_pie_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            const Text(
              "Monthly Sales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 300, child: MonthlySalesLineChart()),

            const SizedBox(height: 40),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT 50% — Firestore-backed Purchase Count Pie
                const Expanded(child: PurchaseCountPieChart()),

                const SizedBox(width: 20),

                // RIGHT 50% — Day Status Level Bar (UI-only for now)
                // RIGHT 50% — Day Status Level Bar (Firestore-backed)
                // RIGHT 50% — Day Status Level Bar (Firestore-backed)
                const Expanded(
                  child: DayStatusLevelBar(
                    collectionPath: 'orders', // <-- change to your collection
                    statusField: 'status', // <-- status field name
                    // dateField defaults to 'timestamp', so you can omit it
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
