import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/product_services.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

@override
void initState() {
  super.initState();
  fetchProducts();

  /// Wait until the widget tree finishes mounting
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _waitForControllerReady();
  });
}

/// 🕒 Wait until ScrollController is attached to its position
Future<void> _waitForControllerReady() async {
  int attempts = 0;
  while (!_scrollController.hasClients && attempts < 10) {
    await Future.delayed(const Duration(milliseconds: 300));
    attempts++;
  }

  if (_scrollController.hasClients && mounted) {
    _startAutoScroll();
  } else {
    debugPrint("⚠️ ScrollController not ready after retries");
  }
}

void _startAutoScroll() {
  _autoScrollTimer?.cancel(); // prevent multiple timers

  _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
    if (!mounted) return;
    if (!_scrollController.hasClients || _products.isEmpty) return;

    try {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      double nextOffset = current + 200;

      if (nextOffset >= maxScroll) nextOffset = 0;

      _scrollController.animateTo(
        nextOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint("⚠️ Scroll attempt failed: $e");
    }
  });
}


  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _mapColorNameToColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case "black":
        return Colors.black;
      case "white":
        return Colors.white;
      case "red":
        return Colors.red;
      case "blue":
        return Colors.blue;
      case "green":
        return Colors.green;
      case "yellow":
        return Colors.yellow;
      case "orange":
        return Colors.orange;
      case "brown":
        return Colors.brown;
      case "purple":
        return Colors.purple;
      case "grey":
      case "gray":
        return Colors.grey;
      case "transparent":
        return Colors.transparent;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return Center(
        child: Text(
          "No products available",
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.width / 2.7,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 80,
        ),
        itemCount: _products.length,
        separatorBuilder: (_, __) =>
            SizedBox(width: MediaQuery.of(context).size.width / 40),
        itemBuilder: (context, index) {
          final product = _products[index];
          final List<dynamic> variants = product["productVariants"] ?? [];
          final List<Color> colors = variants.map((variant) {
            final String colorName = variant["productColor"] ?? "";
            return _mapColorNameToColor(colorName);
          }).toList();

          final bool hasMoreColors = colors.length > 5;

          return Container(
            width: MediaQuery.of(context).size.width / 5,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 100),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(MediaQuery.of(context).size.width / 100),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width / 100),
                    child: product["productImages"] != null &&
                            product["productImages"].isNotEmpty
                        ? Image.network(product["productImages"][0],
                            fit: BoxFit.contain)
                        : Container(color: Colors.grey.shade300),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 150),
                Text(
                  product["productName"] ?? "",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width / 60,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 150),
                Row(
                  children: [
                    ...List.generate(
                      hasMoreColors ? 5 : colors.length,
                      (colorIndex) => Padding(
                        padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width / 180),
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 120,
                          backgroundColor: colors[colorIndex],
                        ),
                      ),
                    ),
                    if (hasMoreColors)
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width / 250),
                        child: Text(
                          "+ more",
                          style: GoogleFonts.inter(
                            fontSize: MediaQuery.of(context).size.width / 90,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 150),
                Text(
                  product["productDescription"] ?? "",
                  style: GoogleFonts.inter(
                    fontSize: MediaQuery.of(context).size.width / 90,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₱${product["productPrice"] ?? ""}",
                      style: GoogleFonts.inter(
                        color: AppColors.color11,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 65,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/signIn');
                      },
                      child: Text(
                        "View Details",
                        style: GoogleFonts.inter(
                          color: AppColors.color10,
                          fontSize: MediaQuery.of(context).size.width / 80,
                          decoration: TextDecoration.underline,
                        ),
                      ).showCursorOnHover.moveUpOnHover,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
