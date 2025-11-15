import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PurchaseCountPieChart extends StatefulWidget {
  const PurchaseCountPieChart({
    super.key,
    this.collectionName = 'orders',
    this.timestampField = 'timestamp',
    this.cartItemsField = 'cartItems',
    this.quantityField = 'quantity',
  });

  final String collectionName;
  final String timestampField;
  final String cartItemsField;
  final String quantityField;

  @override
  State<PurchaseCountPieChart> createState() => _PurchaseCountPieChartState();
}

class _PurchaseCountPieChartState extends State<PurchaseCountPieChart> {
  late Future<_Counts> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchCounts();
  }

  Future<_Counts> _fetchCounts() async {
    final now = DateTime.now();

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart =
        (now.month == 12)
            ? DateTime(now.year + 1, 1, 1)
            : DateTime(now.year, now.month + 1, 1);
    final yearStart = DateTime(now.year, 1, 1);
    final nextYearStart = DateTime(now.year + 1, 1, 1);

    // Time-only query for the year (avoid composite index)
    final snap =
        await FirebaseFirestore.instance
            .collection(widget.collectionName)
            .where(
              widget.timestampField,
              isGreaterThanOrEqualTo: Timestamp.fromDate(yearStart),
            )
            .where(
              widget.timestampField,
              isLessThan: Timestamp.fromDate(nextYearStart),
            )
            .get();

    int dayCount = 0;
    int monthCount = 0;
    int yearCount = 0;

    for (final doc in snap.docs) {
      final data = doc.data();
      // filter status in-memory
      final status = (data['status'] ?? '').toString();
      if (status != 'Delivered') continue;

      final ts = data[widget.timestampField];
      if (ts is! Timestamp) continue;
      final dt = ts.toDate();

      // sum quantity for this order (cartItems array)
      int orderQty = 0;
      final items = (data[widget.cartItemsField] as List?) ?? const [];
      for (final it in items) {
        if (it is Map && it[widget.quantityField] != null) {
          final q = it[widget.quantityField];
          if (q is num) orderQty += q.toInt();
        }
      }

      // Year (already within year window)
      yearCount += orderQty;

      // Month
      if (!dt.isBefore(monthStart) && dt.isBefore(nextMonthStart)) {
        monthCount += orderQty;
      }

      // Day (today)
      if (!dt.isBefore(todayStart) && dt.isBefore(tomorrowStart)) {
        dayCount += orderQty;
      }
    }

    return _Counts(day: dayCount, month: monthCount, year: yearCount);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Counts>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 260,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final c = snap.data ?? const _Counts(day: 0, month: 0, year: 0);
        final total = c.day + c.month + c.year;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Purchase Count (Day / Month / Year)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Pie with total in center
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      centerSpaceRadius: 60,
                      sectionsSpace: 2,
                      sections: [
                        PieChartSectionData(
                          value: c.day.toDouble(),
                          color: Colors.blue,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: c.month.toDouble(),
                          color: Colors.green,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: c.year.toDouble(),
                          color: Colors.orange,
                          title: '',
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Legend
            Row(
              children: [
                _LegendDot(color: Colors.blue, label: 'Day', value: c.day),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.green, label: 'Month', value: c.month),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.orange, label: 'Year', value: c.year),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Counts {
  final int day;
  final int month;
  final int year;
  const _Counts({required this.day, required this.month, required this.year});
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.value,
    super.key,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: color),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }
}
