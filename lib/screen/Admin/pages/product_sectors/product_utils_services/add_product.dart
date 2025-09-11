// ignore_for_file: prefer_final_fields

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
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController productName = TextEditingController();
  final TextEditingController productPrice = TextEditingController();
  final TextEditingController productDescription = TextEditingController();
  final ProductService _productService = ProductService();

  List<Map<String, dynamic>> _variants = [];
  final TextEditingController variantSize = TextEditingController();
  final TextEditingController variantColor = TextEditingController();
  final TextEditingController variantQuantity = TextEditingController();

  List<Uint8List> _webImages = [];

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      final List<Uint8List> bytesList = await Future.wait(
        pickedFiles.map((file) => file.readAsBytes()),
      );
      setState(() {
        _webImages.addAll(bytesList);
      });
    }
  }

  Future<void> saveProduct() async {
    try {
      final imageUrls = await _productService.uploadImages(
        await _productService.getNextProductId(),
        _webImages,
      );

      await _productService.addProduct(
        name: productName.text.trim(),
        description: productDescription.text.trim(),
        price: productPrice.text.trim(),
        variants: _variants,
        imageUrls: imageUrls,
      );

      Get.back();
      Toastify.show(
        context,
        message: 'Success',
        description: 'Product added successfully',
        type: ToastType.success,
      );

       productName.clear();
      productDescription.clear();
      productPrice.clear();
      variantSize.clear();
      variantColor.clear();
      variantQuantity.clear();
      setState(() {
        _webImages.clear();
        _variants.clear();
      });
    } catch (e) {
      Toastify.show(context, message: "Error", type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width / 3.5,
      ),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child:
                      Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.color9,
                      ).showCursorOnHover.moveUpOnHover,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.width / 90),
              GestureDetector(
  onTap: pickImages,
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
              Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 30,
                    width: MediaQuery.of(context).size.width / 4,
                    child: AnimatedTextField(
                      controller: productName,
                      label: 'Product Name',
                      suffix: null,
                      readOnly: false,
                      prefix: Icon(Icons.production_quantity_limits),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 130),
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 30,
                    width: MediaQuery.of(context).size.width / 4,
                    child: AnimatedTextField(
                      controller: productDescription,
                      label: 'Product Description',
                      suffix: null,
                      readOnly: false,
                      prefix: Icon(Icons.production_quantity_limits),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 130),
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 30,
                    width: MediaQuery.of(context).size.width / 4,
                    child: AnimatedTextField(
                      controller: productPrice,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      label: 'Product Price',
                      suffix: null,
                      readOnly: false,
                      prefix: Icon(Icons.price_check),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 130),
                  Row(
                      children: [
                        Expanded(
                          child: AnimatedTextField(
                            controller: variantSize,
                            label: 'Size',
                            suffix: null,
                      readOnly: false,
                            prefix: Icon(Icons.straighten),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedTextField(
                            controller: variantColor,
                            label: 'Color',
                            suffix: null,
                      readOnly: false,
                            prefix: Icon(Icons.color_lens),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedTextField(
                            controller: variantQuantity,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            label: 'Quantity',
                            suffix: null,
                      readOnly: false,
                            prefix: Icon(Icons.production_quantity_limits),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: AppColors.color9),
                          onPressed: () {
                            if (variantSize.text.isNotEmpty &&
                                variantColor.text.isNotEmpty &&
                                variantQuantity.text.isNotEmpty) {
                              setState(() {
                                _variants.add({
                                  "productSize": variantSize.text.trim(),
                                  "productColor": variantColor.text.trim(),
                                  "productQuantity": int.parse(variantQuantity.text.trim())
                                });
                                variantSize.clear();
                                variantColor.clear();
                                variantQuantity.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  
                    // Display Variants
                    Column(
                      children: _variants.map((variant) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column( 
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Size: ${variant['productSize']}", style: GoogleFonts.roboto(
                                                fontSize:  MediaQuery.of(context).size.width / 100,
                                                
                                              ),),
                                              Text("Color: ${variant['productColor']}", style: GoogleFonts.roboto(
                                                fontSize:  MediaQuery.of(context).size.width / 100,)),
                                              Text("Quantity: ${variant['productQuantity']}", style: GoogleFonts.roboto(
                                                fontSize:  MediaQuery.of(context).size.width / 100,)),
                                            ],
                                          ),
                                            IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            _variants.remove(variant);
                                          });
                                        },
                                      ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
          
              SizedBox(height: MediaQuery.of(context).size.width / 130),
              SizedBox(
                height: MediaQuery.of(context).size.width / 30,
                width: MediaQuery.of(context).size.width / 4,
                child: ElevatedButton(
                  onPressed: () {
                    AlertDialogHelper(
                      title: 'Add Product',
                      content: 'Are you sure you want to add this product?',
                      confirmText: 'Yes',
                      cancelText: 'No',
                      onConfirm: () {
                        Get.back();
                        saveProduct();
                      },
                      onCancel: () {
                        Get.back();
                      },
                    ).show(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color9,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Add Product",
                    style: GoogleFonts.roboto(
                      color: AppColors.color1,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
