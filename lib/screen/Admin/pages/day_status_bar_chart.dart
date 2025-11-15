import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DayStatusLevelBar extends StatelessWidget {
  const DayStatusLevelBar({
    super.key,
    required this.collectionPath,
    this.statusField = 'status',
    this.dateField = 'timestamp', // <-- uses your Timestamp field
  });

  final String collectionPath;
  final String statusField;
  final String dateField;

  static const List<String> _labels = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Return & Refund',
  ];

  String _normalizeStatus(String raw) {
    final v = raw.trim().toLowerCase();
    if (v == 'process' || v == 'processing') return 'Processing';
    if (v == 'pending') return 'Pending';
    if (v == 'shipped') return 'Shipped';
    if (v == 'delivered') return 'Delivered';
    if (v == 'cancelled' || v == 'canceled') return 'Cancelled';
    if (v.replaceAll(' ', '') == 'return&refund' ||
        v == 'return & refund' ||
        v == 'return and refund')
      return 'Return & Refund';
    return ''; // ignore unknowns
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now(); // local time (e.g., Asia/Manila)
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = FirebaseFirestore.instance
        .collection(collectionPath)
        .where(
          dateField,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(dateField, isLessThan: Timestamp.fromDate(endOfDay));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Day Status Level",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                query
                    .withConverter<Map<String, dynamic>>(
                      fromFirestore:
                          (snap, _) => snap.data() ?? <String, dynamic>{},
                      toFirestore: (data, _) => data,
                    )
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              final counts = {for (final k in _labels) k: 0};
              for (final doc in (snapshot.data?.docs ?? const [])) {
                final data = doc.data();
                final raw = (data[statusField] ?? '').toString();
                final normalized = _normalizeStatus(raw);
                if (counts.containsKey(normalized))
                  counts[normalized] = counts[normalized]! + 1;
              }

              final maxCount = counts.values.fold<int>(
                0,
                (m, v) => v > m ? v : m,
              );
              final maxY =
                  (maxCount == 0)
                      ? 5.0
                      : (maxCount + (maxCount * 0.25)).ceilToDouble();

              final groups = <BarChartGroupData>[];
              for (var i = 0; i < _labels.length; i++) {
                final label = _labels[i];
                final y = counts[label]!.toDouble();
                groups.add(
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: y,
                        width: 17,
                        borderRadius: BorderRadius.circular(4),
                        color: switch (label) {
                          'Pending' => Colors.orange,
                          'Processing' => Colors.blue,
                          'Shipped' => Colors.purple,
                          'Delivered' => Colors.green,
                          'Cancelled' => Colors.red,
                          'Return & Refund' => Colors.brown,
                          _ => Colors.grey,
                        },
                      ),
                    ],
                  ),
                );
              }

              final noData = maxCount == 0;

              return Stack(
                children: [
                  BarChart(
                    BarChartData(
                      maxY: maxY,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: groups,
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget:
                                (v, m) => Text(
                                  v.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= _labels.length)
                                return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _labels[i],
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = _labels[group.x.toInt()];
                            final count = counts[label]!;
                            return BarTooltipItem(
                              '$label: $count',
                              const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (noData)
                    const Center(
                      child: Text(
                        'No data for today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
