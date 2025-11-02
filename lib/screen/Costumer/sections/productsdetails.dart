import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/product_services.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';
import 'package:video_player/video_player.dart';

class ProductsDetails extends StatefulWidget {
  const ProductsDetails({super.key});

  @override
  State<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends State<ProductsDetails> {
  final ProductService _productService = ProductService();
  int quantity = 10;
  late String selectedImage;
  Map<String, dynamic>? selectedVariant;
  List<Map<String, dynamic>> _productRatings = [];


 @override
void initState() {
  super.initState();
  final product = Get.arguments;
  final images = (product["productImages"] as List?) ?? [];
  selectedImage =
      images.isNotEmpty ? images[0] : "https://via.placeholder.com/150";

  // 🟩 Fetch product ratings
  fetchProductRatings(product["productId"]).then((ratings) {
    setState(() {
      _productRatings = ratings;
    });
  });
}


Future<List<Map<String, dynamic>>> fetchProductRatings(dynamic productId) async {
  try {
    // 🔹 ensure correct type for Firestore query
    final dynamic queryId = (productId is String)
        ? int.tryParse(productId) ?? productId
        : productId;

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('productId', isEqualTo: queryId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      debugPrint('❌ No product found with productId: $productId');
      return [];
    }

    final productDocId = snapshot.docs.first.id;

    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productDocId)
        .collection('ratings')
        .orderBy('createdAt', descending: true)
        .get();

    final List<Map<String, dynamic>> ratings = ratingsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'comment': data['comment'] ?? '',
        'createdAt': data['createdAt'],
        'media': (data['media'] as List?) ?? [],
        'orderId': data['orderId'] ?? '',
        'rating': data['rating'] ?? 0,
        'userId': data['userId'] ?? '',
            'customerName': data['customerName'] ?? 'Anonymous User', // 🆕 include name

      };
    }).toList();

    debugPrint('✅ Retrieved ${ratings.length} ratings for product: $productId');
    return ratings;
  } catch (e) {
    debugPrint('🔥 Error fetching product ratings: $e');
    return [];
  }
}


  @override
  Widget build(BuildContext context) {
    final product = Get.arguments;
    final productVariants = (product["productVariants"] as List?) ?? [];
    final productImages = (product["productImages"] as List?) ?? [];

    final int availableStock =
        selectedVariant != null
            ? (selectedVariant!['productQuantity'] ?? 0)
            : 0;

    final bool canAddToCart =
        selectedVariant != null && quantity > 0 && quantity <= availableStock;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderWithout(),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 29,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(context),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductPictures(productImages),

                          // Divider
                          Container(
                            width: 1,
                            height: MediaQuery.of(context).size.width / 3,
                            color: Colors.grey.shade200,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                          ),

                          _buildProductInformation(
                            context,
                            product,
                            productVariants,
                            productImages,
                            canAddToCart,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDesription(product),
                        SizedBox(width: MediaQuery.of(context).size.width / 50,),
                        _buildReviews(product)
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────
  // SECTION 1: Header + Back Button
  // ──────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width / 29,
      ),
      child:
          GestureDetector(
            onTap: () => Get.toNamed('/costumerHome'),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios),
                Text(
                  'Product Details',
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).showCursorOnHover.moveUpOnHover,
    );
  }

  // ──────────────────────────────
  // SECTION 2: Product Images
  // ──────────────────────────────
  Widget _buildProductPictures(List productImages) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.5,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  productImages.map((image) {
                    final bool isSelected = image == selectedImage;
                    return GestureDetector(
                      onTap: () => setState(() => selectedImage = image),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: EdgeInsets.all(isSelected ? 3 : 0),
                        decoration: BoxDecoration(
                          border:
                              isSelected
                                  ? Border.all(
                                    color: AppColors.color8,
                                    width: 2,
                                  )
                                  : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image,
                            height: 60,
                            width: 60,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────
  // SECTION 3: Product Info + Variants
  // ──────────────────────────────
  Widget _buildProductInformation(
    BuildContext context,
    Map<String, dynamic> product,
    List productVariants,
    List productImages,
    bool canAddToCart,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Product name + price + description
          Text(
            product["productName"] ?? "",
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₱${product["productPrice"]}",
            style: GoogleFonts.roboto(
              fontSize: 20,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // --- Variants ---
          Text(
            'Variants',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          // ✅ Responsive grid: 3 per row, scrolls if > 2 rows
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const int itemsPerRow = 3; // force exactly 3 per row
                const double itemSpacing = 10;

                // Calculate each item width dynamically based on total width
                final double totalSpacing = itemSpacing * (itemsPerRow - 1);
                final double itemWidth =
                    (constraints.maxWidth - totalSpacing) / itemsPerRow;

                // Calculate how many rows we’ll have
                final int rows = (productVariants.length / itemsPerRow).ceil();

                // Dynamically adjust height
                double containerHeight;
                if (rows <= 1) {
                  containerHeight = 80;
                } else if (rows == 2) {
                  containerHeight = 150;
                } else {
                  containerHeight = 200; // scrolls after 2 rows
                }

                return SizedBox(
                  height: containerHeight,
                  child: SingleChildScrollView(
                    physics:
                        rows > 2
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                    child: Wrap(
                      spacing: itemSpacing,
                      runSpacing: itemSpacing,
                      children:
                          productVariants.map((variant) {
                            final color = variant['productColor'] ?? '';
                            final size = variant['productSize'] ?? '';
                            final bool isSelected = selectedVariant == variant;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedVariant = variant;
                                  selectedImage =
                                      productImages.isNotEmpty
                                          ? productImages.first
                                          : selectedImage;
                                  quantity = 10;
                                });
                              },
                              child: Container(
                                width:
                                    itemWidth, // ✅ fixed: now exactly 3 per row
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.color8
                                            : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      isSelected
                                          ? AppColors.color8.withOpacity(0.1)
                                          : Colors.white,
                                ),
                                child: Text(
                                  "$color - $size",
                                  textAlign: TextAlign.center,
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
                  ),
                );
              },
            ),
          ),


          // --- Quantity ---
          Text(
            'Quantity',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildQtyButton(Icons.remove, () {
                if (quantity > 10) {
                  setState(() => quantity--);
                } else {
                  Toastify.show(
                    context,
                    message: 'Minimum order is 10',
                    type: ToastType.warning,
                  );
                }
              }),
              Container(
                width: 50,
                height: 40,
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
                if (selectedVariant != null &&
                    quantity < (selectedVariant!['productQuantity'] ?? 0)) {
                  setState(() => quantity++);
                } else {
                  Toastify.show(
                    context,
                    message: 'Stock limit reached',
                    type: ToastType.warning,
                  );
                }
              }),
            ],
          ),
          const SizedBox(height: 20),

          // --- Add to Cart Button ---
          SizedBox(
            width: MediaQuery.of(context).size.width / 10,
            height: MediaQuery.of(context).size.width / 25,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: canAddToCart ? AppColors.color8 : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed:
                  canAddToCart
                      ? () async {
                        try {
                          await _productService.addToCart(
                            product: product,
                            quantity: quantity,
                            selectedSize: selectedVariant!['productSize'],
                            selectedColor: selectedVariant!['productColor'],
                          );

                          setState(() {
                            selectedVariant = null;
                            quantity = 10;
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
                      }
                      : null,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                "Add to Cart",
                style: GoogleFonts.roboto(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────
  // SECTION 4: Reusable Qty Button
  // ──────────────────────────────
  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

 // ──────────────────────────────
// SECTION 5: Product Description + Reviews
// ──────────────────────────────
Widget _buildDesription(Map<String, dynamic> product) {
  final productVariants = (product["productVariants"] as List?) ?? [];

      return Container(
        width: MediaQuery.of(context).size.width / 2.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Description:',
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, fontSize: 24)),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Text(
                    product["productDescription"] ?? "",
                    style: GoogleFonts.roboto(fontSize: 18, height: 1.4),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text('Sized Descriptions:',
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(height: 10),

              ...productVariants.map((variant) {
                final desc = variant['productSizedDescription'] ??
                    'No description available.';
                return Padding(
                  padding: const EdgeInsets.only(left: 20.0, bottom: 12),
                  child: Text(
                    desc,
                    style: GoogleFonts.roboto(
                        fontSize: 16, color: Colors.black87, height: 1.4),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
            ]
          )
        )
      );
        
}

Widget _buildReviews(Map<String, dynamic> product) {
  final productVariants = (product["productVariants"] as List?) ?? [];
  int? selectedStar; // null = All

  return StatefulBuilder(
    builder: (context, setState) {
      final screenWidth = MediaQuery.of(context).size.width;

      // ✅ Responsive scaling (for desktop/laptop)
      final containerWidth = screenWidth / 2.2;
      final titleFontSize = screenWidth / 60; // ~24 on 1440px
      final textFontSize = screenWidth / 90; // ~16 on 1440px
      final smallFontSize = screenWidth / 110; // ~13 on 1440px
      final padding = screenWidth / 80; // consistent scaling
      final iconSize = screenWidth / 70;

      // filter reviews dynamically
      final filteredRatings = selectedStar == null
          ? _productRatings
          : _productRatings
              .where((r) => r['rating'] == selectedStar)
              .toList();

      return Container(
        width: containerWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Product Reviews',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                ),
              ),
              SizedBox(height: screenWidth / 120),

              // ⭐ All + Star Filter Row
              Row(
                children: [
                  _buildFilterButton(
                    label: 'All',
                    selected: selectedStar == null,
                    onTap: () => setState(() => selectedStar = null),
                    textFontSize: textFontSize,
                    iconSize: iconSize,
                  ),
                  ...List.generate(5, (index) {
                    final star = index + 1;
                    final isSelected = selectedStar == star;
                    return _buildFilterButton(
                      label: '$star Star',
                      icon: Icons.star,
                      selected: isSelected,
                      onTap: () => setState(() => selectedStar = star),
                      textFontSize: textFontSize,
                      iconSize: iconSize,
                    );
                  }),
                ],
              ),
              SizedBox(height: screenWidth / 80),

              // 🔸 No reviews message or review list
              if (filteredRatings.isEmpty)
                Text(
                  'No reviews found.',
                  style: GoogleFonts.roboto(
                    fontSize: textFontSize,
                    color: Colors.black54,
                  ),
                )
              else
                Column(
                  children: filteredRatings.map((rating) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenWidth / 200),
                      child: Card(
                        color: Colors.grey.shade50,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth / 120),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🧍 Customer name
Text(
  rating['customerName'] ?? 'Anonymous User',
  style: GoogleFonts.roboto(
    fontSize: textFontSize,
    fontWeight: FontWeight.bold,
    color: AppColors.color8,
  ),
),
SizedBox(height: screenWidth / 250),
                              // Rating stars row
                              Row(
                                children: List.generate(
                                  rating['rating'],
                                  (index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: iconSize,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenWidth / 200),

                              // Comment
                              Text(
                                rating['comment'],
                                style: GoogleFonts.roboto(
                                  fontSize: textFontSize,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: screenWidth / 200),

                              // Media preview
                              if (rating['media'].isNotEmpty)
                                SizedBox(
                                  height: screenWidth / 20,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        (rating['media'] as List).map<Widget>((url) {
                                      final isVideo =
                                          url.toString().toLowerCase().endsWith('.mp4');
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth / 200),
                                        child: GestureDetector(
                                          onTap: () =>
                                              _showMediaViewer(context, url),
                                          child: isVideo
                                              ? Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      width: screenWidth / 15,
                                                      height: screenWidth / 25,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black12,
                                                        borderRadius:
                                                            BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(
                                                        Icons.videocam,
                                                        color: Colors.grey,
                                                        size: iconSize * 1.5,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.play_circle_fill,
                                                      color: Colors.white70,
                                                      size: iconSize * 2,
                                                    )
                                                  ],
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    url,
                                                    width: screenWidth / 15,
                                                    height: screenWidth / 25,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                              SizedBox(height: screenWidth / 200),

                              // Created at timestamp
                              Text(
  rating['createdAt'] != null
      ? DateFormat("MMMM d, yyyy 'at' h:mm a").format(
          (rating['createdAt'] as Timestamp).toDate(),
        )
      : '',
  style: GoogleFonts.roboto(
    fontSize: smallFontSize,
    color: Colors.grey,
  ),
),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildFilterButton({
  required String label,
  IconData? icon,
  required bool selected,
  required VoidCallback onTap,
  required double textFontSize,
  required double iconSize,
  Color iconColor = Colors.amber,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.color8 : Colors.white,
          border: Border.all(
            color: selected ? AppColors.color8 : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: selected ? Colors.white : iconColor,
              ),
            if (icon != null) const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: textFontSize,
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



// 🆕 Media viewer function
void _showMediaViewer(BuildContext context, String url) {
  final bool isVideo = url.toLowerCase().endsWith('.mp4');
  showDialog(
    context: context,
    barrierDismissible: true, // ✅ allows tapping outside to close
    builder: (_) {
      return Stack(
        children: [
          Dialog(
            backgroundColor: Colors.black,
            insetPadding: const EdgeInsets.all(10),
            child: Center(
              child: isVideo
                  ? _VideoPlayerViewer(url: url)
                  : InteractiveViewer(
                      child: Image.network(url, fit: BoxFit.contain),
                    ),
            ),
          ),
          // ✅ Keep single close button here only
          Positioned(
            top: 30,
            right: 30,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      );
    },
  );
}

}

class _VideoPlayerViewer extends StatefulWidget {
  final String url;
  const _VideoPlayerViewer({required this.url});

  @override
  State<_VideoPlayerViewer> createState() => _VideoPlayerViewerState();
}

class _VideoPlayerViewerState extends State<_VideoPlayerViewer> {
  late VideoPlayerController _controller;
  bool _isControlsVisible = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _isPlaying = true;
          _controller.play();
        });
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration position) {
    final minutes = position.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = position.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
    } else {
      _controller.play();
      _isPlaying = true;
    }
    setState(() {});
  }

  void _seekToRelativePosition(double relative) {
    final Duration newPosition = _controller.value.duration * relative;
    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final duration = _controller.value.duration;
    final position = _controller.value.position;
    final progress =
        duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;

    return GestureDetector(
      // ✅ toggles overlay visibility on tap
      onTap: () => setState(() => _isControlsVisible = !_isControlsVisible),
      behavior: HitTestBehavior.opaque, // ✅ ensures taps always reach this
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // --- Controls overlay ---
          if (_isControlsVisible)
            Container(
              color: Colors.black54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Progress bar + time
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                              thumbColor: Colors.redAccent,
                              activeTrackColor: Colors.redAccent,
                              inactiveTrackColor: Colors.white30,
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (value) => _seekToRelativePosition(value),
                            ),
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Play / Pause / Skip controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.replay_10,
                              color: Colors.white, size: 36),
                          onPressed: () {
                            final newPos = position - const Duration(seconds: 10);
                            _controller.seekTo(newPos > Duration.zero ? newPos : Duration.zero);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: Colors.white,
                            size: 60,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: const Icon(Icons.forward_10,
                              color: Colors.white, size: 36),
                          onPressed: () {
                            final newPos = position + const Duration(seconds: 10);
                            if (newPos < duration) {
                              _controller.seekTo(newPos);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
