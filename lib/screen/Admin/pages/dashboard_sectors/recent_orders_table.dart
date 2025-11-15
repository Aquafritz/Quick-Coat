import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({super.key});

  /// Map Firestore status → color
  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'processing':
      case 'process':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'shipped':
        return Colors.purple;
      case 'return&refund':
      case 'return & refund':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  /// Generate an order ID based on the **document ID**
  /// Example:  docId = "5ZPqGxAxJZkINVLIPc..."
  /// Shown as: "ORD-ZKINVLI" (last 6 chars, uppercased)
  String generateOrderId(String docId) {
    if (docId.isEmpty) return 'ORD-UNKNOWN';
    final cleaned = docId.replaceAll('-', '').replaceAll('_', '');
    final int take = 6;
    final short =
        cleaned.length <= take
            ? cleaned
            : cleaned.substring(cleaned.length - take);
    return 'ORD-${short.toUpperCase()}';
  }

  /// Format Firestore Timestamp / DateTime → "Oct 25, 2025"
  String formatDate(dynamic ts) {
    DateTime date;

    if (ts is Timestamp) {
      date = ts.toDate();
    } else if (ts is DateTime) {
      date = ts;
    } else {
      return '';
    }

    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format amount → ₱4,000
  String formatAmount(dynamic value) {
    num numValue;
    if (value is num) {
      numValue = value;
    } else {
      numValue = num.tryParse(value.toString()) ?? 0;
    }

    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    );
    return formatter.format(numValue);
  }

  @override
  Widget build(BuildContext context) {
    // LAST 7 DAYS = "weekly recent orders"
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    final Timestamp oneWeekAgoTs = Timestamp.fromDate(oneWeekAgo);

    final weeklyOrdersQuery = FirebaseFirestore.instance
        .collection('orders')
        // "timestamp" field in your screenshot
        .where('timestamp', isGreaterThanOrEqualTo: oneWeekAgoTs)
        .orderBy('timestamp', descending: true)
        .limit(10); // adjust how many you want to show

    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // TODO: navigate to All Orders page if you have one
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Table Headers
          Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'Order ID',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Customer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Amount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(),

          /// Firestore data
          StreamBuilder<QuerySnapshot>(
            stream: weeklyOrdersQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Failed to load orders.',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No orders for this week yet.'),
                );
              }

              return Column(
                children:
                    docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final status = (data['status'] ?? 'Unknown').toString();
                      final timestamp = data['timestamp'];
                      final amount =
                          data['total'] ??
                          data['subtotal'] ??
                          0; // from screenshot

                      // 👇 adjust this if your customer name is stored differently
                      final customerName =
                          (data['userDetails']?['full_name'] ??
                                  'Unknown Customer')
                              .toString();

                      final orderId = generateOrderId(doc.id);
                      final amountText = formatAmount(amount);
                      final dateText = formatDate(timestamp);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(orderId)),
                            Expanded(flex: 3, child: Text(customerName)),
                            Expanded(flex: 2, child: Text(amountText)),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 100,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: statusColor(status),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 2, child: Text(dateText)),
                          ],
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
