import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/product_services.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  final ProductService _productService = ProductService();

  String? _selectedSize;
  String? _selectedColor;

  // Map backend color names to Flutter Colors
  Color _mapColorNameToColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case "black":
        return Colors.black;
      case "blue":
        return Colors.blue;
      case "red":
        return Colors.red;
      case "green":
        return Colors.green;
      case "white":
        return Colors.white;
      case "brown":
        return Colors.brown;
      case "grey":
        return Colors.grey;
      case "yellow":
        return Colors.yellow;
      case "orange":
        return Colors.orange;
      case "purple":
        return Colors.purple;
      case "teal":
        return Colors.teal;
      case "pink":
        return Colors.pink;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.width / 80,
        horizontal: MediaQuery.of(context).size.width / 15,
      ),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Our Products',
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width / 65,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 150),
          Text(
            'Discover our wide range of high-quality kapote products',
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width / 90,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 90),

          // Main Row: Sidebar + Product Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar filter
              // Sidebar filter
SizedBox(
  width: MediaQuery.of(context).size.width / 5,
  child: Card(
    elevation: 8,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Filters",
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
              Icon(Icons.filter_list),
            ],
          ),
          const SizedBox(height: 20),

          // Size Filter
          const Text("Size"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _selectedSize,
              hint: const Text("All Sizes"),
              items: ["All", "S", "M", "L", "XL"].map((size) {
                return DropdownMenuItem(
                  value: size == "All" ? null : size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSize = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Color Filter
          const Text("Color"),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: const SizedBox(),
              value: _selectedColor,
              hint: const Text("All Colors"),
              items: [
                "All", 
                "Black", 
                "Blue", 
                "Red", 
                "Green", 
                "White", 
                "Brown", 
                "Grey", 
                "Yellow", 
                "Orange", 
                "Purple", 
                "Teal", 
                "Pink"]
                  .map((color) {
                return DropdownMenuItem(
                  value: color == "All" ? null : color,
                  child: Text(color),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedColor = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Clear Filters Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _selectedSize = null;
                  _selectedColor = null;
                });
              },
              child: const Text("Clear Filters"),
            ),
          ),
        ],
      ),
    ),
  ),
),


              SizedBox(width: MediaQuery.of(context).size.width / 100),

              // Product Grid → dynamic
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                              future: _productService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No products found"));
                    }

                    final products = snapshot.data!;

                    // ✅ Apply filtering
                    final filteredProducts = products.where((product) {
                      final variants =
                          product["productVariants"] as List<dynamic>? ?? [];

                      final matchesSize = _selectedSize == null ||
                          variants.any(
                              (v) => v["productSize"] == _selectedSize);

                      final matchesColor = _selectedColor == null ||
                          variants.any((v) =>
                              (v["productColor"] ?? "").toLowerCase() ==
                              _selectedColor!.toLowerCase());

                      return matchesSize && matchesColor;
                    }).toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 3 / 4,
                      ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final variants =
                            product["productVariants"] as List<dynamic>? ?? [];

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               // Product Image
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      (product["productImages"] as List).isNotEmpty
                                          ? product["productImages"][0]
                                          : "https://via.placeholder.com/150",
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.width /
                                        80),

                                // Product Title
                                Text(
                                  product["productName"] ?? "",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // Description
                                Text(
                                  product["productDescription"] ?? "",
                                  style: GoogleFonts.roboto(
                                      fontSize: 12, color: Colors.black54),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.width /
                                        80),

                                // Sizes & quantities
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: variants.map((variant) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                            "${variant["productSize"]} (${variant["productQuantity"]})"),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.width /
                                        80),

                                // Colors Row
                                Row(
                                  children: variants
                                      .map((variant) => _mapColorNameToColor(
                                              variant["productColor"] ?? "")
                                          )
                                      .toSet()
                                      .take(4)
                                      .map((color) => Container(
                                            margin: const EdgeInsets.only(
                                                right: 4),
                                            width: 15,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color:
                                                      Colors.grey.shade300),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.width /
                                        80),

                                // Price
                                Text(
                                  "₱${product["productPrice"]}",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.color11,
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.width /
                                        80),

                                // View Details Button
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1,
                                  height:
                                      MediaQuery.of(context).size.width / 35,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.color8,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.toNamed('/productDetails',
                                          arguments: product);
                                    },
                                    child: Text(
                                      'View Details',
                                      style: GoogleFonts.roboto(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
