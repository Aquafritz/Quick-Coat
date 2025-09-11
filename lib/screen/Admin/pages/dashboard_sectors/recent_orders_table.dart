import 'package:flutter/material.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'id': 'ORD-7829',
        'customer': 'Juana Cruz',
        'amount': '₱1,240',
        'status': 'Completed',
        'date': 'Jul 12, 2023',
      },
      {
        'id': 'ORD-7830',
        'customer': 'Miguel Santos',
        'amount': '₱860',
        'status': 'Processing',
        'date': 'Jul 12, 2023',
      },
      {
        'id': 'ORD-7831',
        'customer': 'Sofia Reyes',
        'amount': '₱2,100',
        'status': 'Pending',
        'date': 'Jul 11, 2023',
      },
      {
        'id': 'ORD-7832',
        'customer': 'Diego Mendoza',
        'amount': '₱780',
        'status': 'Completed',
        'date': 'Jul 11, 2023',
      },
      {
        'id': 'ORD-7833',
        'customer': 'Isabella Garcia',
        'amount': '₱1,500',
        'status': 'Cancelled',
        'date': 'Jul 10, 2023',
      },
    ];

    Color statusColor(String status) {
      switch (status) {
        case 'Completed':
          return Colors.green;
        case 'Processing':
          return Colors.blue;
        case 'Pending':
          return Colors.orange;
        case 'Cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

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
                'Recent Orders',
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
          const SizedBox(height: 16),

          /// Table Headers
          Row(
            children: const [
              Expanded(flex: 2, child: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 3, child: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(flex: 2, child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),

          const Divider(),

          /// Table Rows
          Column(
            children: orders.map((order) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(order['id']!)),
                    Expanded(flex: 3, child: Text(order['customer']!)),
                    Expanded(flex: 2, child: Text(order['amount']!)),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 100, // Set your preferred fixed width
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor(order['status']!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            order['status']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: statusColor(order['status']!),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(flex: 2, child: Text(order['date']!)),
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
