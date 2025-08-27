import 'package:flutter/material.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';

class ProductsDetails extends StatefulWidget {
  const ProductsDetails({super.key});

  @override
  State<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends State<ProductsDetails> {
  final List<Map<String, dynamic>> products = [
    {
      "colors": [
        Colors.black,
        Colors.brown,
        Colors.grey,
        Colors.blue,
        Colors.red,
        Colors.green,
      ],
    },
  ];

  int quantity = 1;

  final List<String> productImages = [
    'assets/images/product1.png',
    'assets/images/product2.png',
    'assets/images/product3.png',
  ];

  late String selectedImage;
  Color? selectedColor;

  final List<String> sizes = ["S", "M", "L", "XL"];
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    selectedImage = productImages[0];
  }

  @override
  Widget build(BuildContext context) {
    final product = products[0];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderWithout(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Left: Product Images
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                selectedImage,
                                height:  MediaQuery.of(context).size.width / 4,
                                width:  MediaQuery.of(context).size.width / 4,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 80,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: productImages.map((image) {
                                final bool isSelected = image == selectedImage;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImage = image;
                                    });
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 6),
                                    padding:
                                        EdgeInsets.all(isSelected ? 3 : 0),
                                    decoration: BoxDecoration(
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.blue, width: 2)
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        image,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                           SizedBox(height:  MediaQuery.of(context).size.width / 80),
                          ],
                        ),
                      ),
                    ),

                    // ✅ Right: Product Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Text(
                              'Premium Kapote Design 1',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 100),

                            // Price
                            const Text(
                              '₱1299.00',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 110),

                            // Description
                            const Text(
                              'Our premium kapote is made with high-quality materials that provide excellent protection \nagainst rain and harsh weather conditions. This design features enhanced \ndurability and comfort, perfect for everyday use.',
                              style: TextStyle(fontSize: 14, height: 1.4),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 110),

                            // Colors
                            const Text(
                              'Colors',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 120),
                            Row(
                              children: (product["colors"] as List<Color>)
                                  .map(
                                    (color) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedColor = color;
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(right: 8),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selectedColor == color
                                                ? Colors.blue
                                                : Colors.grey.shade300,
                                            width: selectedColor == color ? 3 : 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 110),

                            // Sizes
                            const Text(
                              'Sizes',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 120),
                            Wrap(
                              spacing: 10,
                              children: sizes.map((size) {
                                final bool isSelected = selectedSize == size;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSize = size;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.white,
                                    ),
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 110),

                            // Quantity
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 120),
                            Row(
                              children: [
                                _buildQtyButton(Icons.remove, () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                }),
                                Container(
                                  width: MediaQuery.of(context).size.width / 30,
                                  height: MediaQuery.of(context).size.width / 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _buildQtyButton(Icons.add, () {
                                  setState(() {
                                    quantity++;
                                  });
                                }),
                              ],
                            ),
                            SizedBox(height:  MediaQuery.of(context).size.width / 110),

                            // Add to Cart + Favorite
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 10,
                                  height: MediaQuery.of(context).size.width / 25,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      backgroundColor: AppColors.color8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      
                                    ),
                                    icon: const Icon(Icons.shopping_cart, color: Colors.white,),
                                    label: const Text(
                                      'Add to Cart',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Features
                            const Text(
                              'Features',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('• Waterproof Material'),
                                Text('• Adjustable Hood'),
                                Text('• Multiple Pockets'),
                                Text('• Lightweight and Comfortable'),
                                Text('• Easy to Fold and Store'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper for rounded quantity buttons
  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: MediaQuery.of(context).size.width / 60,
        height: MediaQuery.of(context).size.width / 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
