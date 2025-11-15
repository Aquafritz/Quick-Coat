import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  // final String percentage; // ex: "+12.5%", "-3.2%", "0%"
  // final String trend;
  final Color color;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    // required this.percentage,
    // required this.trend,
    required this.color,
    required this.icon,
  });

  /// Extract numeric value from percentage string
  // double get _percentageValue {
  //   String cleaned = percentage.replaceAll('%', '').trim();
  //   return double.tryParse(cleaned) ?? 0;
  // }

  // bool get _isPositive => _percentageValue > 0;
  // bool get _isNegative => _percentageValue < 0;
  // bool get _isNeutral => _percentageValue == 0;

  // Color get _arrowColor =>
  //     _isPositive
  //         ? Colors.green
  //         : _isNegative
  //         ? Colors.red
  //         : Colors.grey;

  // IconData get _arrowIcon =>
  //     _isPositive
  //         ? Icons.arrow_upward
  //         : _isNegative
  //         ? Icons.arrow_downward
  //         : Icons.remove; // dash icon for neutral

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          /// Circle Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),

          /// Text Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Row(
                //   children: [
                //     Icon(_arrowIcon, size: 12, color: _arrowColor),
                //     const SizedBox(width: 4),

                //     // Text(
                //     //   "$percentage $trend",
                //     //   style: TextStyle(fontSize: 8.5, color: _arrowColor),
                //     // ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
