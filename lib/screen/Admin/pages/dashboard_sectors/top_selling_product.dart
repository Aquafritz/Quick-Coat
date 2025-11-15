import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TopSellingProducts extends StatelessWidget {
  const TopSellingProducts({super.key});

  @override
  Widget build(BuildContext context) {
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
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Selling Products',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),

          /// Firestore Stream
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('orders')
                    .where('status', isEqualTo: 'Delivered')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              /// Map store → {productName: totalSold}
              Map<String, dynamic> salesMap = {};

              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;

                if (data['cartItems'] != null) {
                  for (var item in data['cartItems']) {
                    final name = item['productName'] ?? 'Unknown Product';
                    final qty = item['quantity'] ?? 0;
                    final price = item['productPrice'] ?? 0;

                    if (!salesMap.containsKey(name)) {
                      salesMap[name] = {
                        'name': name,
                        'price': price,
                        'sold': qty,
                      };
                    } else {
                      salesMap[name]['sold'] += qty;
                    }
                  }
                }
              }

              /// Sort by sold count DESC
              final topProducts =
                  salesMap.values.toList()
                    ..sort((a, b) => b['sold'].compareTo(a['sold']));

              /// Assign ranks
              for (int i = 0; i < topProducts.length; i++) {
                topProducts[i]['rank'] = i + 1;
              }

              return Column(
                children:
                    topProducts.map((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            /// Rank Badge
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${product['rank']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            /// Name (productName)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "Sold items",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Price & Sold
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₱${product['price']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${product['sold']} sold',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
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
