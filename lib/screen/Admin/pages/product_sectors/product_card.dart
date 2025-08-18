import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  // Track which button is selected
  List<bool> isSelected = [true, false]; // Default: Grid is active

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            /// View Toggle (Grid/View)
            ToggleButtons(
              borderRadius: BorderRadius.circular(6),
              isSelected: isSelected,
              onPressed: (index) {
                setState(() {
                  // Make only the clicked button true
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

            /// Filter Dropdown
            SizedBox(
              width: 150,
              height: 36,
              child: DropdownButtonFormField<String>(
                value: "All Products",
                items: const [
                  DropdownMenuItem(
                    value: "All Products",
                    child: Text("All Products", style: TextStyle(fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: "Inventory",
                    child: Text("Inventory", style: TextStyle(fontSize: 14)),
                  ),
                ],
                onChanged: (value) {
                  // Handle filter change
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
