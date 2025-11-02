// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/alert_dialog.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/product_services.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/update_products.dart';

class ExpandableImageGrid extends StatefulWidget {
  final List<String> images;
  final double itemHeight;
  final double itemWidth;
  final int minRows;

  const ExpandableImageGrid({
    required this.images,
    this.itemHeight = 70,
    this.itemWidth = 70,
    this.minRows = 1,
    super.key,
  });

  @override
  State<ExpandableImageGrid> createState() => _ExpandableImageGridState();
}

class _ExpandableImageGridState extends State<ExpandableImageGrid> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    int actualRows = (widget.images.length / 3).ceil();
    int visibleRows =
        isExpanded
            ? actualRows
            : widget.images.length > 3
            ? 1
            : widget.minRows;
    double maxHeight = visibleRows * widget.itemHeight + (visibleRows - 1) * 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.color11),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: 20,
                          color: Colors.grey,
                        ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.images.length > 3)
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isExpanded ? "See less" : "See more",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width / 110,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Widget buildGridProductCard(
  BuildContext context,
  QueryDocumentSnapshot product,
) {
  final data = product.data() as Map<String, dynamic>;
  final String productName = data['productName'] ?? '';
  final String productDescription = data['productDescription'] ?? '';
  final String productPrice = data['productPrice'] ?? '0';
  final List<String> productImages = List<String>.from(
    data['productImages'] ?? [],
  );
  final List<dynamic> productVariants = data['productVariants'] ?? [];

  return Container(
    constraints: BoxConstraints(minHeight: 220),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      border: Border.all(width: 2, color: AppColors.color10),
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (productImages.isNotEmpty)
          ExpandableImageGrid(
            images: List<String>.from(productImages),
            itemHeight: MediaQuery.of(context).size.width / 12,
            minRows: 1,
          )
        else
          Container(
            height: MediaQuery.of(context).size.width / 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 32, color: Colors.grey),
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            productName,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width / 90,
            ),
          ),
        ),
        ExpandableText(
          productDescription,
          trimLength: 20,
          style: GoogleFonts.roboto(
            fontSize: MediaQuery.of(context).size.width / 100,
          ),
        ),
        Text(
          "Price: ₱$productPrice",
          style: GoogleFonts.roboto(
            fontSize: MediaQuery.of(context).size.width / 100,
          ),
        ),
        if (productVariants.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            "Variants:",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width / 100,
            ),
          ),
          const SizedBox(height: 4),
          ExpandableText(
            productVariants
                .map((variant) {
                  final size = variant['productSize'] ?? '';
                  final desc = variant['productSizedDescription'] ?? '';
                  final color = variant['productColor'] ?? '';
                  final qty = variant['productQuantity'] ?? '';

                  return "Size: $size\n"
                      "Size Description: $desc\n"
                      "Color: $color\n"
                      "Quantity: $qty";
                })
                .join("\n\n"),
            trimLength: 50, // longer text allowed
            style: GoogleFonts.roboto(
              fontSize: MediaQuery.of(context).size.width / 110,
            ),
          ),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => UpdateProduct(
                        productId: data['productId'],
                        productData: data,
                      ),
                );
              },
              icon:
                  Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: MediaQuery.of(context).size.width / 60,
                  ).showCursorOnHover.moveUpOnHover,
            ),
            IconButton(
              onPressed: () async {
                AlertDialogHelper(
                  title: 'Delete Product',
                  content: 'Are you sure you want to delete this product?',
                  confirmText: 'Yes',
                  cancelText: 'No',
                  onConfirm: () async {
                    Get.back();
                    try {
                      final service = ProductService();
                      await service.deleteProduct(productId: data['productId']);

                      Toastify.show(
                        context,
                        message: 'Product deleted successfully',
                        type: ToastType.success,
                      );
                    } catch (e) {
                      Toastify.show(
                        context,
                        message: 'Failed to delete product',
                        type: ToastType.error,
                      );
                    }
                  },
                  onCancel: () {
                    Get.back();
                  },
                ).show(context);
              },
              icon:
                  Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: MediaQuery.of(context).size.width / 60,
                  ).showCursorOnHover.moveUpOnHover,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildListProductCard(
  BuildContext parentContext,
  QueryDocumentSnapshot product,
) {
  final data = product.data() as Map<String, dynamic>;
  final String productName = (data['productName'] ?? "").toString();
  final String productDescription =
      (data['productDescription'] ?? "").toString();
  final String productPrice = (data['productPrice'] ?? "0").toString();
  final String productQuantity = (data['productQuantity'] ?? "0").toString();
  final List<dynamic> productImages = data['productImages'] ?? [];
  final int productId =
      data['productId'] is int
          ? data['productId']
          : int.tryParse(data['productId'].toString()) ?? 0;

  return ListCardWithAutoScrollImages(
    parentContext: parentContext,
    productId: productId,
    productData: data,
    productName: productName,
    productDescription: productDescription,
    productPrice: productPrice,
    productQuantity: productQuantity,
    productImages: productImages,
  );
}

class ListCardWithAutoScrollImages extends StatefulWidget {
  final BuildContext parentContext;
  final int productId;
  final Map<String, dynamic> productData;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String productQuantity;
  final List<dynamic> productImages;

  const ListCardWithAutoScrollImages({
    required this.parentContext,
    required this.productId,
    required this.productData,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productQuantity,
    required this.productImages,
    super.key,
  });

  @override
  State<ListCardWithAutoScrollImages> createState() =>
      _ListCardWithAutoScrollImagesState();
}

class _ListCardWithAutoScrollImagesState
    extends State<ListCardWithAutoScrollImages> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.productImages.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (_pageController.hasClients) {
          double nextPage = _pageController.page! + 1;
          if (nextPage >= widget.productImages.length) nextPage = 0;
          _pageController.animateToPage(
            nextPage.toInt(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> productVariants =
        widget.productData['productVariants'] ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(width: 2, color: AppColors.color10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.productImages.isNotEmpty)
            Container(
              margin: EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width / 10,
              height: MediaQuery.of(context).size.width / 10,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.productImages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.productImages[index],
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 30),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 120,
              height: 120,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.image, size: 30, color: Colors.grey),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 90,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3.5,
                          child: ExpandableText(
                            widget.productDescription,
                            trimLength: 70,
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 100,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Price: ",
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width / 100,
                              ),
                            ),
                            Text(
                              "₱${widget.productPrice}",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 100,
                              ),
                            ),
                          ],
                        ),

                        if (productVariants.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Variants:",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 110,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ExpandableText(
                            productVariants
                                .map((variant) {
                                  return "Size: ${variant['productSize']}\n"
                                      "Color: ${variant['productColor']}\n"
                                      "Quantity: ${variant['productQuantity']}";
                                })
                                .join("\n\n"),
                            trimLength: 20,
                            style: GoogleFonts.roboto(
                              fontSize: MediaQuery.of(context).size.width / 120,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => UpdateProduct(
                                  productId: widget.productId,
                                  productData: widget.productData,
                                ),
                          );
                        },
                        icon:
                            Icon(
                              Icons.edit,
                              color: Colors.blue,
                              size: MediaQuery.of(context).size.width / 60,
                            ).showCursorOnHover.moveUpOnHover,
                      ),
                      IconButton(
                        onPressed: () {
                          AlertDialogHelper(
                            title: 'Delete Product',
                            content:
                                'Are you sure you want to delete this product?',
                            confirmText: 'Yes',
                            cancelText: 'No',
                            onConfirm: () async {
                              Get.back();

                              try {
                                final service = ProductService();
                                await service.deleteProduct(
                                  productId: widget.productId,
                                );

                                Toastify.show(
                                  widget.parentContext,
                                  message: 'Product deleted successfully',
                                  type: ToastType.success,
                                );
                              } catch (e) {
                                Toastify.show(
                                  widget.parentContext,
                                  message: 'Failed to delete product',
                                  type: ToastType.error,
                                );
                              }
                            },
                            onCancel: () {
                              Get.back();
                            },
                          ).show(context);
                        },
                        icon:
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: MediaQuery.of(context).size.width / 60,
                            ).showCursorOnHover.moveUpOnHover,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLength;
  final TextStyle? style;

  const ExpandableText(
    this.text, {
    this.trimLength = 100,
    this.style,
    super.key,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final fullText = widget.text.replaceAll("\\n", "\n");
    final showMore = fullText.length > widget.trimLength;

    String displayText =
        isExpanded || !showMore
            ? fullText
            : fullText.substring(0, widget.trimLength);

    return RichText(
      text: TextSpan(
        style: widget.style ?? DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text:
                showMore && !isExpanded ? "$displayText... " : "$displayText ",
          ),
          if (showMore)
            TextSpan(
              text: isExpanded ? "See less" : "See more",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () {
                      setState(() => isExpanded = !isExpanded);
                    },
            ),
        ],
      ),
    );
  }
}
