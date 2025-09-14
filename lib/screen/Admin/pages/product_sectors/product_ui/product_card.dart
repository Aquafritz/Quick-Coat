import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/product_card_utils.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<bool> isSelected = [true, false];
  String filter = "All Products";
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          /// Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                // Toggle (Grid / List)
                ToggleButtons(
                  borderRadius: BorderRadius.circular(6),
                  isSelected: isSelected,
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = i == index;
                      }
                    });
                  },
                  constraints: const BoxConstraints(
                    minHeight: 36,
                    minWidth: 50,
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Grid", style: TextStyle(fontSize: 14)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("View", style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Filter Dropdown
                SizedBox(
                  width: 150,
                  height: 36,
                  child: DropdownButtonFormField<String>(
                    initialValue: filter, // old code
                    // value: filter, // new code
                    items: const [
                      DropdownMenuItem(
                        value: "All Products",
                        child: Text(
                          "All Products",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Inventory",
                        child: Text(
                          "Inventory",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        filter = value ?? "All Products";
                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                /// Search Bar
                SizedBox(
                  width: 200,
                  height: 36,
                  child: TextField(
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Search products...",
                      prefixIcon: const Icon(Icons.search, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 500,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection("products").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                final products =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name =
                          (data['productName'] ?? "").toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                if (isSelected[0]) {
                  return MasonryGridView.count(
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return buildGridProductCard(context, product);
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 50,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: buildListProductCard(context, product),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
