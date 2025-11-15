import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlySalesLineChart extends StatefulWidget {
  const MonthlySalesLineChart({super.key, this.year, this.capAt100k = true});

  final int? year;
  final bool capAt100k;

  @override
  State<MonthlySalesLineChart> createState() => _MonthlySalesLineChartState();
}

class _MonthlySalesLineChartState extends State<MonthlySalesLineChart> {
  late Future<List<double>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchMonthlySalesTotals();
  }

  Future<List<double>> _fetchMonthlySalesTotals() async {
    final now = DateTime.now();
    final y = widget.year ?? now.year;
    final startOfYear = DateTime(y, 1, 1);
    final startNextYear = DateTime(y + 1, 1, 1);

    // Query by time only -> no composite index needed
    final snap =
        await FirebaseFirestore.instance
            .collection('orders')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear),
            )
            .where('timestamp', isLessThan: Timestamp.fromDate(startNextYear))
            .get();

    // 12 months initialized to 0
    final totals = List<double>.filled(12, 0.0);

    for (final doc in snap.docs) {
      final data = doc.data();
      // filter status in-memory
      final status = (data['status'] ?? '').toString();
      if (status != 'Delivered') continue;

      final ts = data['timestamp'];
      final total = (data['total'] as num?)?.toDouble() ?? 0.0;
      if (ts is Timestamp) {
        final dt = ts.toDate();
        final idx = dt.month - 1; // 0..11
        if (idx >= 0 && idx < 12) totals[idx] += total;
      }
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final totals = snap.data ?? List<double>.filled(12, 0.0);
        final spots = [
          for (int i = 0; i < 12; i++) FlSpot(i.toDouble(), totals[i]),
        ];

        return LineChart(
          LineChartData(
            minY: 0,
            gridData: const FlGridData(show: true),
            borderData: FlBorderData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: 20000,
                  getTitlesWidget: (value, meta) {
                    if (!widget.capAt100k) {
                      final v = value.toInt();
                      return Text(v == 0 ? '0' : '${v ~/ 1000}K');
                    }
                    switch (value.toInt()) {
                      case 0:
                        return const Text('0');
                      case 20000:
                        return const Text('20K');
                      case 40000:
                        return const Text('40K');
                      case 60000:
                        return const Text('60K');
                      case 80000:
                        return const Text('80K');
                      case 100000:
                        return const Text('100K');
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const m = [
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec',
                    ];
                    if (value < 0 || value > 11) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        m[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                spots: spots,
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems:
                    (touchedSpots) =>
                        touchedSpots
                            .map(
                              (s) => LineTooltipItem(
                                '₱${s.y.toStringAsFixed(0)}',
                                const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                            .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
