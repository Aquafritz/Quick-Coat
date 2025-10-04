import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcoat/animations/animatedTextField.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Costumer/costumer_services.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  State<CheckOut> createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
fb.User? user;
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> addresses = [];
  String? selectedAddressLabel;
  Uint8List? _paymentProofBytes;
  String? _paymentProofUrl;

  Map<String, dynamic>? userDetails;

  String? selectedPaymentMethod;
  final List<String> paymentMethods = ["Cash on Delivery", "GCash"];

  @override
  void initState() {
    super.initState();
user = fb.FirebaseAuth.instance.currentUser;
    fetchAddresses();
    fetchUserDetails();
  }

  Future<void> fetchAddresses() async {
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('addresses')
            .get();

    final tempAddresses =
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

    setState(() {
      addresses = tempAddresses;

      final defaultAddress = addresses.firstWhere(
        (address) => address['is_default'] == true,
        orElse: () => {},
      );

      if (defaultAddress.isNotEmpty) {
        selectedAddressLabel = defaultAddress['label'] ?? null;
      } else if (addresses.isNotEmpty) {
        selectedAddressLabel = addresses[0]['label'] ?? null;
      }
    });
  }

  Future<void> fetchUserDetails() async {
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

    if (doc.exists) {
      setState(() {
        userDetails = doc.data();
      });
    }
  }

  Future<void> saveAddress({
    String? addressId,
    required String label,
    required String houseNumber,
    required String street,
    required String barangay,
    required String cityMunicipality,
    required String province,
    required String postalCode,
    required String country,
  }) async {
    if (addressId != null) {
      await CustomerServices.updateAddress(
        addressId: addressId,
        label: label,
        houseNumber: houseNumber,
        street: street,
        barangay: barangay,
        cityMunicipality: cityMunicipality,
        province: province,
        postalCode: postalCode,
        country: country,
      );
    } else {
      await CustomerServices.addAddress(
        label: label,
        houseNumber: houseNumber,
        street: street,
        barangay: barangay,
        cityMunicipality: cityMunicipality,
        province: province,
        postalCode: postalCode,
        country: country,
      );
    }
    Get.back();
    fetchAddresses();
  }

  void showAddressDialog({
    required BuildContext context,
    String? addressId,
    String? label,
    String? houseNumber,
    String? street,
    String? barangay,
    String? cityMunicipality,
    String? province,
    String? postalCode,
    String? country,
  }) {
    final labelCtrl = TextEditingController(text: label ?? '');
    final houseCtrl = TextEditingController(text: houseNumber ?? '');
    final streetCtrl = TextEditingController(text: street ?? '');
    final barangayCtrl = TextEditingController(text: barangay ?? '');
    final cityCtrl = TextEditingController(text: cityMunicipality ?? '');
    final provinceCtrl = TextEditingController(text: province ?? '');
    final postalCtrl = TextEditingController(text: postalCode ?? '');
    final countryCtrl = TextEditingController(text: country ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(addressId == null ? "New Address" : "Edit Address"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: labelCtrl,
                        label: 'Address Label',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: houseCtrl,
                        label: 'House Number',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 90),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: streetCtrl,
                        label: 'Street',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: barangayCtrl,
                        label: 'Barangay',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 90),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: cityCtrl,
                        label: 'City/Municipality',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: provinceCtrl,
                        label: 'Province',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 90),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: postalCtrl,
                        label: 'Postal Code',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width / 30),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 8,
                      height: MediaQuery.of(context).size.width / 25,
                      child: AnimatedTextField(
                        controller: countryCtrl,
                        label: 'Country',
                        suffix: null,
                        readOnly: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: MediaQuery.of(context).size.width / 40,
                    width: MediaQuery.of(context).size.width / 7.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.red,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: const Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ).showCursorOnHover,
                GestureDetector(
                  onTap:
                      () => saveAddress(
                        addressId: addressId,
                        label: labelCtrl.text,
                        houseNumber: houseCtrl.text,
                        street: streetCtrl.text,
                        barangay: barangayCtrl.text,
                        cityMunicipality: cityCtrl.text,
                        province: provinceCtrl.text,
                        postalCode: postalCtrl.text,
                        country: countryCtrl.text,
                      ),
                  child: Container(
                    height: MediaQuery.of(context).size.width / 40,
                    width: MediaQuery.of(context).size.width / 7.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: const Center(
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ).showCursorOnHover,
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    if (args != null && cartItems.isEmpty) {
      cartItems = List<Map<String, dynamic>>.from(args);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const HeaderWithout(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Out',
                      style: GoogleFonts.roboto(
                        fontSize: MediaQuery.of(context).size.width / 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: buildUserAndCartSection(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(flex: 1, child: OrderSummaryWidget()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUserAndCartSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null) ...[
            userDetailsWidget(),
            const SizedBox(height: 16),
            addressSelectionWidget(),
            const SizedBox(height: 20),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                cartItems
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CartItemWidget(context, item),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget userDetailsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Order Details",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          "${userDetails?['full_name'] ?? 'No Name'}",
          style: GoogleFonts.roboto(),
        ),
        Text(
          "${userDetails?['email_Address'] ?? user?.email ?? 'No Email'}",
          style: GoogleFonts.roboto(),
        ),
        Text(
          "${userDetails?['phone_number'] ?? user?.phoneNumber ?? 'Not Provided'}",
          style: GoogleFonts.roboto(),
        ),
      ],
    );
  }

  Widget addressSelectionWidget() {
    if (addresses.isEmpty) {
      return Column(
        children: [
          const Text("No saved addresses."),
          ElevatedButton(
            onPressed: () => showAddressDialog(context: context),
            child: const Text("Add New Address"),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            const Text(
              "Saved Addresses",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 10,
                backgroundColor: AppColors.color8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => showAddressDialog(context: context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add New Address",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        ...addresses.map((address) {
          return RadioListTile<String>(
            activeColor: AppColors.color8,
            value: address['label'] ?? "Other",
            groupValue: selectedAddressLabel,
            onChanged: (value) async {
              if (user != null) {
                await CustomerServices.setDefaultAddress(address['id']);
                Toastify.show(
                  context,
                  message: 'Success',
                  description: 'Default address updated!',
                  type: ToastType.success,
                );
                fetchAddresses();
              }
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(address['label'] ?? "Address"),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.color8),
                  onPressed: () {
                    showAddressDialog(
                      context: context,
                      addressId: address['id'],
                      label: address['label'] ?? '',
                      houseNumber: address['house_number'] ?? '',
                      street: address['street'] ?? '',
                      barangay: address['barangay'] ?? '',
                      cityMunicipality: address['city_municipality'] ?? '',
                      province: address['province'] ?? '',
                      postalCode: address['postal_code'] ?? '',
                      country: address['country'] ?? '',
                    );
                  },
                ),
              ],
            ),
            subtitle: Text(
              "${address['house_number'] ?? ''}, ${address['street'] ?? ''}, ${address['barangay'] ?? ''}, "
              "${address['city_municipality'] ?? ''}, ${address['province'] ?? ''}, "
              "${address['postal_code'] ?? ''}, ${address['country'] ?? ''}",
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget CartItemWidget(BuildContext context, Map<String, dynamic> item) {
    final imageUrl =
        item['productImages'] is String
            ? item['productImages']
            : (item['productImages'] as List?)?.isNotEmpty == true
            ? item['productImages'][0]
            : "https://via.placeholder.com/100";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['productName'] ?? "No Name",
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${item['selectedSize'] ?? 'N/A'} | ${item['selectedColor'] ?? 'N/A'} | Qty: ${item['quantity'] ?? 1}",
                  style: GoogleFonts.roboto(),
                ),
                Text("₱${item['productPrice']}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget OrderSummaryWidget() {
    double subtotal = 0;
    for (var item in cartItems) {
      subtotal += (item["productPrice"] ?? 0) * (item["quantity"] ?? 0);
    }
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal"),
              Text("₱${subtotal.toStringAsFixed(2)}"),
            ],
          ),
          const SizedBox(height: 12),

          paymentMethodWidget(), // ⬅️ Added here
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text("Shipping"), Text("Free")],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "₱${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (user == null) return;

                if (addresses.isEmpty || selectedAddressLabel == null) {
                  Toastify.show(
                    context,
                    message: 'Address Required',
                    description:
                        'Please add and select a delivery address before placing an order.',
                    type: ToastType.warning,
                  );
                  return;
                }

                  // 🔸 Payment method validation
  if (selectedPaymentMethod == null || selectedPaymentMethod!.isEmpty) {
    Toastify.show(
      context,
      message: 'Payment Method Required',
      description:
          'Please select a payment method before placing your order.',
      type: ToastType.warning,
    );
    return;
  }

                try {
                  final selectedAddress = addresses.firstWhere(
                    (addr) => addr['label'] == selectedAddressLabel,
                    orElse: () => {},
                  );

                  if (selectedAddress.isEmpty) {
                    Toastify.show(
                      context,
                      message: 'No Address Selected',
                      description: 'Please choose a delivery address.',
                      type: ToastType.warning,
                    );
                    return;
                  }

           // ✅ Upload proof of payment if GCash is selected
    if (selectedPaymentMethod == "GCash" && _paymentProofBytes != null) {
      try {
        final fileName =
            "${user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

        await Supabase.instance.client.storage
            .from("QuickCoat/proof_of_payment")
            .uploadBinary(
              fileName,
              _paymentProofBytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        final uploadedUrl = Supabase.instance.client.storage
            .from("QuickCoat/proof_of_payment")
            .getPublicUrl(fileName);

        _paymentProofUrl = uploadedUrl;
      } catch (e) {
        Toastify.show(
          context,
          message: 'Upload Failed',
          description: 'Unable to upload payment proof. $e',
          type: ToastType.error,
        );
        return;
      }
    }

                  await CustomerServices.placeOrder(
                    userDetails: userDetails,
                    cartItems: cartItems,
                    selectedAddress: selectedAddress,
                      proofOfPayment: _paymentProofUrl, // 👈 added
      paymentMethod: selectedPaymentMethod!, // ⬅️ cannot be null

                  );
                  setState(() {
                    cartItems.clear();
                    _paymentProofBytes = null;
      _paymentProofUrl = null;
                  });
                  Toastify.show(
                    context,
                    message: 'Order Placed!',
                    description: 'Your order has been successfully placed.',
                    type: ToastType.success,
                  );
                  Get.toNamed('/costumerHome');
                } catch (e) {
                  Toastify.show(
                    context,
                    message: 'Error',
                    description: 'Failed to place order: $e',
                    type: ToastType.error,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.color8,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Place Order",
                style: GoogleFonts.roboto(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Get.toNamed('/shoppingCart');
              },
              child: Text(
                "Back to Cart",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                  color: AppColors.color8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentMethodWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Method",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...paymentMethods.map((method) {
          return RadioListTile<String>(
            activeColor: AppColors.color8,
            value: method,
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value;
              });
            },
            title: Text(
              method,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),

        // 👇 Only show when GCash is selected
        if (selectedPaymentMethod == "GCash") ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.color8, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  "Pay via GCash",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.color8,
                  ),
                ),
                Image.asset(
                  'assets/images/qrr.png',
                  scale: MediaQuery.of(context).size.width / 300,
                ),
                Text(
                  "GCash Number: 09163276281", // ✅ Replace with seller’s number
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 90,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Account Name: Quick Coat", // ✅ Replace with seller’s number
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 90,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 90),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (pickedFile == null) return;

                    final bytes = await pickedFile.readAsBytes();

                    setState(() {
                      _paymentProofBytes = bytes;
                    });
                  },
                  child: Text(
                    'Payment Proof', // ✅ Replace with seller’s number
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 100,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_paymentProofBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _paymentProofBytes!,
                      height: 180,
                      width: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
