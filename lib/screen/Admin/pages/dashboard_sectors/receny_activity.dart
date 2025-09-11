import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'icon': Icons.shopping_bag_outlined,
        'color': Colors.blue,
        'text': 'New order #ORD-7834 received from Carlo Aquino',
        'time': '10 minutes ago'
      },
      {
        'icon': Icons.bar_chart_outlined,
        'color': Colors.orange,
        'text': 'Product "Large Blue Kapote" is running low on stock',
        'time': '25 minutes ago'
      },
      {
        'icon': Icons.local_shipping_outlined,
        'color': Colors.green,
        'text': 'Rider Juan Dela Cruz completed delivery #DEL-4532',
        'time': '1 hour ago'
      },
      {
        'icon': Icons.receipt_long_outlined,
        'color': Colors.purple,
        'text': 'New order #ORD-7835 is ready for delivery',
        'time': '2 hours ago'
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Activity List
          Column(
            children: activities.map((activity) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    /// Icon Circle
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: (activity['color'] as Color).withOpacity(0.1),
                      child: Icon(
                        activity['icon'] as IconData,
                        color: activity['color'] as Color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// Text and Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity['text'] as String,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
