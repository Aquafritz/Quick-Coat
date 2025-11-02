import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Costumer/costumer_services.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:lottie/lottie.dart';

class SuccessPayment extends StatefulWidget {
  const SuccessPayment({super.key});

  @override
  State<SuccessPayment> createState() => _SuccessPaymentState();
}

class _SuccessPaymentState extends State<SuccessPayment> {
  bool _isPlacingOrder = false;
  final box = GetStorage();
  Map<String, dynamic>? _checkoutData;

  @override
  void initState() {
    super.initState();
    _loadCheckoutDataSafely();
  }

  /// 🕒 Retry loading GetStorage data until it's available
  Future<void> _loadCheckoutDataSafely() async {
    for (int attempt = 1; attempt <= 5; attempt++) {
      await Future.delayed(const Duration(milliseconds: 300));

      final data = box.read('checkoutData');
      print("📦 [Attempt $attempt] Read checkoutData: $data");

      if (data != null && data is Map && data.isNotEmpty) {
        setState(() => _checkoutData = Map<String, dynamic>.from(data));
        print("✅ Loaded checkoutData successfully!");
        return;
      }
    }

    print("⚠️ Failed to load checkoutData after retries.");
    Toastify.show(
      context,
      message: 'Error',
      description: 'No saved checkout data found. Please retry your payment.',
      type: ToastType.error,
    );
  }

  Future<void> _confirmPayment() async {
    try {
      setState(() => _isPlacingOrder = true);

      if (_checkoutData == null || _checkoutData!.isEmpty) {
        throw Exception("Checkout data missing — please retry payment.");
      }

      final userDetails = _checkoutData!["userDetails"];
      final cartItems = List<Map<String, dynamic>>.from(
        _checkoutData!["cartItems"] ?? [],
      );
      final selectedAddress = _checkoutData!["selectedAddress"];
      final paymentMethod = _checkoutData!["paymentMethod"];
      final proofOfPayment = _checkoutData!["proofOfPayment"];

      print("🧾 Confirming order with data:");
      print("- User: ${userDetails?['full_name']}");
      print("- Items: ${cartItems.length}");
      print("- Address: ${selectedAddress?['label']}");
      print("- Payment: $paymentMethod");

      if (userDetails == null || cartItems.isEmpty || selectedAddress == null) {
        throw Exception("Checkout data missing — please retry payment.");
      }

      // ✅ Place order now
      await CustomerServices.placeOrder(
        userDetails: userDetails,
        cartItems: cartItems,
        selectedAddress: selectedAddress,
        proofOfPayment: proofOfPayment,
        paymentMethod: paymentMethod,
      );

      // 🧹 Clear local data
      await box.remove('checkoutData');

      Toastify.show(
        context,
        message: 'Order Placed!',
        description: 'Your payment was successful and your order is confirmed.',
        type: ToastType.success,
      );

      // ✅ Close tab (modern API)
      web.window.close();

      // 👇 Notify parent tab, if it exists
    } catch (e) {
      Toastify.show(
        context,
        message: 'Error',
        description: 'Failed to confirm order: $e',
        type: ToastType.error,
      );
      setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 500,
                child: Lottie.asset(
                  'assets/animations/paymentsuccessful.json',
                  repeat: true,
                ),
              ),
              Text(
                "Thank you for your payment.\nTap confirm to finalize your order.",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isPlacingOrder ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isPlacingOrder
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          "Confirm",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
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
