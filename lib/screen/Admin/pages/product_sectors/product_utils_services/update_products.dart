// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/alert_dialog.dart';
import 'package:quickcoat/animations/animatedTextField.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Admin/pages/product_sectors/product_utils_services/product_services.dart';

class UpdateProduct extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> productData;

  const UpdateProduct({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  late List<Map<String, TextEditingController>> variantControllers;
  final TextEditingController productName = TextEditingController();
  final TextEditingController productPrice = TextEditingController();
  final TextEditingController productDescription = TextEditingController();
  List<Uint8List> _webImages = [];

  @override
  void initState() {
    super.initState();
    productName.text = widget.productData['productName']?.toString() ?? '';
    productPrice.text = widget.productData['productPrice']?.toString() ?? '0';
    productDescription.text = widget.productData['productDescription']?.toString() ?? '';

    // Initialize variants
    variantControllers = (widget.productData['productVariants'] as List<dynamic>? ?? [])
        .map((variant) => {
              'productSize': TextEditingController(text: variant['productSize']),
              'productColor': TextEditingController(text: variant['productColor']),
              'productQuantity': TextEditingController(text: variant['productQuantity'].toString()),
            })
        .toList();
  }

  void _addVariant() {
    setState(() {
      variantControllers.add({
        'productSize': TextEditingController(),
        'productColor': TextEditingController(),
        'productQuantity': TextEditingController(),
      });
    });
  }

  void _removeVariant(int index) {
    setState(() {
      variantControllers.removeAt(index);
    });
  }

  List<Map<String, dynamic>> _getVariantsData() {
    return variantControllers.map((vc) {
      return {
        'productSize': vc['productSize']!.text.trim(),
        'productColor': vc['productColor']!.text.trim(),
        'productQuantity': int.tryParse(vc['productQuantity']!.text.trim()) ?? 0,
      };
    }).toList();
  }

  Future<void> _updateProduct() async {
    final ProductService _productService = ProductService();
    try {
      await _productService.updateProduct(
        productId: widget.productId,
        name: productName.text.trim(),
        description: productDescription.text.trim(),
        price: productPrice.text.trim(),
        variants: _getVariantsData(), // updated variants
      );

      Get.back();
      Toastify.show(
        context,
        message: 'Success',
        description: 'Product updated successfully',
        type: ToastType.success,
      );
    } catch (e) {
      Toastify.show(context, message: "Error", type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 3.5),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Align(
                alignment: Alignment.topLeft,
                child: Icon(Icons.arrow_back_ios, color: AppColors.color9)
                    .showCursorOnHover
                    .moveUpOnHover,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 90),

            // Images Grid
          GestureDetector(
  onTap: (){},
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width / 3.5, // optional
    ),
    child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _webImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _webImages.length) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border.all(color: AppColors.color11),
            ),
            child: Icon(
              Icons.add_a_photo,
              size: 40,
              color: AppColors.color11,
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.color11),
          ),
          child: Image.memory(
            _webImages[index],
            fit: BoxFit.contain,
          ),
        );
      },
    ),
  ),
),
            SizedBox(height: MediaQuery.of(context).size.width / 70),

            // Product Name
            SizedBox(
              height: MediaQuery.of(context).size.width / 30,
              width: MediaQuery.of(context).size.width / 3.5,
              child: AnimatedTextField(
                controller: productName,
                label: 'Product Name',
                suffix: null,
                readOnly: false,
                prefix: const Icon(Icons.production_quantity_limits),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 130),

            // Product Description
            SizedBox(
              height: MediaQuery.of(context).size.width / 30,
              width: MediaQuery.of(context).size.width / 3.5,
              child: AnimatedTextField(
                controller: productDescription,
                label: 'Product Description',
                suffix: null,
                readOnly: false,
                prefix: const Icon(Icons.description),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 130),

            // Product Price
            SizedBox(
              height: MediaQuery.of(context).size.width / 30,
              width: MediaQuery.of(context).size.width / 3.5,
              child: AnimatedTextField(
                controller: productPrice,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                label: 'Product Price',
                suffix: null,
                readOnly: false,
                prefix: const Icon(Icons.price_check),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width / 130),

            // Variants
            // Variants
Column(
  children: [
    ...variantControllers.asMap().entries.map((entry) {
      int index = entry.key;
      var controllers = entry.value;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.width / 130),
        child: Row(
          children: [
            Expanded(
              child: AnimatedTextField(
                controller: controllers['productSize'],
                label: 'Size',
                suffix: null,
                readOnly: false,
                prefix: const Icon(Icons.straighten),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedTextField(
                controller: controllers['productColor'],
                label: 'Color',
                suffix: null,
                readOnly: false,
                prefix: const Icon(Icons.color_lens),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedTextField(
                controller: controllers['productQuantity'],
                label: 'Quantity',
                suffix: null,
                readOnly: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefix: const Icon(Icons.format_list_numbered),
              ),
            ),
            IconButton(
              onPressed: () => _removeVariant(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      );
    }),
    TextButton.icon(
      onPressed: _addVariant,
      icon: const Icon(Icons.add),
      label: const Text('Add Variant'),
    ),
  ],
),


            SizedBox(height: MediaQuery.of(context).size.width / 130),

            // Update Button
            SizedBox(
              height: MediaQuery.of(context).size.width / 30,
              width: MediaQuery.of(context).size.width / 4,
              child: ElevatedButton(
                onPressed: () {
                  AlertDialogHelper(
                    title: 'Update Product',
                    content: 'Are you sure you want to update this product?',
                    confirmText: 'Yes',
                    cancelText: 'No',
                    onConfirm: () {
                      Get.back();
                      _updateProduct();
                    },
                    onCancel: () {
                      Get.back();
                    },
                  ).show(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color9,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Update Product",
                  style: GoogleFonts.roboto(color: AppColors.color1, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
