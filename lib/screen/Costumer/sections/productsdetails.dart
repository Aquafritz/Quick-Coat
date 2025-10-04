import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/product_services.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';

class ProductsDetails extends StatefulWidget {
  const ProductsDetails({super.key});

  @override
  State<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends State<ProductsDetails> {
  final ProductService _productService = ProductService();
  int quantity = 10;
  late String selectedImage;
  Color? selectedColor;
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    final product = Get.arguments;

    final images = (product["productImages"] as List?) ?? [];
    selectedImage =
        images.isNotEmpty ? images[0] : "https://via.placeholder.com/150";
  }

  @override
  Widget build(BuildContext context) {
    final product = Get.arguments;
    final productVariants = product["productVariants"] as List? ?? [];
    final sizes =
        productVariants.map((v) => v["productSize"] as String).toSet().toList();
    final colors =
        productVariants
            .map((v) => _mapColorNameToColor(v["productColor"] ?? ""))
            .toSet()
            .toList();
    final productImages = (product["productImages"] as List?) ?? [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithout(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 29,
              ),
              child:  GestureDetector(
                      onTap: () {
                        Get.toNamed('/costumerHome');
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios),
                    Text(
                      'Product Details',
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                        ]
                      )
                    ).showCursorOnHover.moveUpOnHover,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(50),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  selectedImage,
                                  height: MediaQuery.of(context).size.width / 4,
                                  width: MediaQuery.of(context).size.width / 4,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 80,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  productImages.map((image) {
                                    final bool isSelected =
                                        image == selectedImage;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedImage = image;
                                        });
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          0,
                                          10,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          padding: EdgeInsets.all(
                                            isSelected ? 3 : 0,
                                          ),
                                          decoration: BoxDecoration(
                                            border:
                                                isSelected
                                                    ? Border.all(
                                                      color: AppColors.color8,
                                                      width: 2,
                                                    )
                                                    : null,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              image,
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product["productName"] ?? "",
                              style: GoogleFonts.roboto(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 110,
                            ),
                            Text(
                              "₱${product["productPrice"]}",
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 110,
                            ),
                            Text(
                              product["productDescription"] ?? "",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 110,
                            ),
                            Text(
                              'Colors',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 120,
                            ),
                            Row(
                              children:
                                  colors.map((color) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedColor == color) {
                                            selectedColor = null;
                                          } else {
                                            selectedColor = color;
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                selectedColor == color
                                                    ? AppColors.color8
                                                    : Colors.grey.shade300,
                                            width:
                                                selectedColor == color ? 3 : 1,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 110,
                            ),
                            Text(
                              'Sizes',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 120,
                            ),
                            Wrap(
                              spacing: 10,
                              children:
                                  sizes.map((size) {
                                    final bool isSelected =
                                        selectedSize == size;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (selectedSize == size) {
                                            selectedSize = null;
                                          } else {
                                            selectedSize = size;
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppColors.color8
                                                    : Colors.grey,
                                            width: 2,
                                          ),
                                          color:
                                              isSelected
                                                  ? AppColors.color8
                                                      .withOpacity(0.1)
                                                  : Colors.white,
                                        ),
                                        child: Text(
                                          size,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                isSelected
                                                    ? AppColors.color8
                                                    : Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 110,
                            ),
                            Text(
                              'Quantity',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 120,
                            ),
                            Row(
                              children: [
                                _buildQtyButton(Icons.remove, () {
                                  if (quantity > 10) {
                                    setState(() {
                                      quantity--;
                                    });
                                  }
                                }),
                                Container(
                                  width: MediaQuery.of(context).size.width / 30,
                                  height:
                                      MediaQuery.of(context).size.width / 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _buildQtyButton(Icons.add, () {
                                  setState(() {
                                    quantity++;
                                  });
                                }),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 110,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 10,
                                  height:
                                      MediaQuery.of(context).size.width / 25,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          (selectedSize == null ||
                                                  selectedColor == null ||
                                                  quantity < 1)
                                              ? Colors.grey
                                              : AppColors.color8,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed:
                                        (selectedSize == null ||
                                                selectedColor == null ||
                                                quantity < 1)
                                            ? null
                                            : () async {
                                              try {
                                                await _productService.addToCart(
                                                  product: product,
                                                  quantity: quantity,
                                                  selectedSize: selectedSize,
                                                  selectedColor: _colorToName(
                                                    selectedColor,
                                                  ),
                                                );

                                                setState(() {
                                                  selectedSize = null;
                                                  selectedColor = null;
                                                  quantity = 0;
                                                });

                                                Toastify.show(
                                                  context,
                                                  message: 'Success',
                                                  description: 'Added to cart',
                                                  type: ToastType.success,
                                                );
                                              } catch (e) {
                                                Toastify.show(
                                                  context,
                                                  message: 'Error',
                                                  type: ToastType.error,
                                                );
                                              }
                                            },

                                    icon: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      "Add to Cart",
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                      ),
                                    ),
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

  String _colorToName(Color? color) {
    if (color == null) return "";
    if (color == Colors.black) return "Black";
    if (color == Colors.blue) return "Blue";
    if (color == Colors.red) return "Red";
    if (color == Colors.green) return "Green";
    if (color == Colors.white) return "White";
    if (color == Colors.brown) return "Brown";
    if (color == Colors.grey) return "Grey";
    if (color == Colors.yellow) return "Yellow";
    if (color == Colors.orange) return "Orange";
    if (color == Colors.purple) return "Purple";
    if (color == Colors.teal) return "Teal";
    if (color == Colors.pink) return "Pink";
    return "Unknown";
  }
}
