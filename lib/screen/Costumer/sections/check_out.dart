import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcoat/animations/animatedTextField.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Costumer/costumer_services.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';
import 'package:quickcoat/services/paymongo_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

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
  final List<String> paymentMethods = [
    "Cash on Delivery",
    "GCash",
    "Credit/Debit Card",
    "PayMaya",
    "GrabPay",
  ];

  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController expMonthCtrl = TextEditingController();
  final TextEditingController expYearCtrl = TextEditingController();
  final TextEditingController cvcCtrl = TextEditingController();

  /// ✅ PSGC local data cache
  Map<String, dynamic>? psgcData;
  List<dynamic> provinces = [];
  List<dynamic> cities = [];
  List<dynamic> barangays = [];

  // ✅ Address field controllers
  final TextEditingController labelController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController cityMunicipalityController =
      TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  Future<void> loadPSGCOffline() async {
    try {
      final jsonString = await rootBundle.loadString('assets/psgc/psgc.json');
      final data = json.decode(jsonString);
      final List<dynamic> records = data['RECORDS'];

      setState(() {
        psgcData = {
          'regions': records.where((r) => r['is_reg'] == "1").toList(),
          'provinces': records.where((r) => r['is_prov'] == "1").toList(),
          'cities_municipalities':
              records
                  .where(
                    (r) => r['is_municipality'] == "1" || r['is_city'] == "1",
                  )
                  .toList(),
          'barangays': records.where((r) => r['is_bgy'] == "1").toList(),
        };
      });

      print("✅ PSGC data loaded (provinces: ${psgcData!['provinces'].length})");
    } catch (e) {
      print("⚠️ Failed to load PSGC: $e");
    }
  }

  void loadProvinces() {
    if (psgcData == null) return;
    setState(() {
      provinces = List<Map<String, dynamic>>.from(psgcData!['provinces']);
    });
  }

  void loadCities(String provinceName) {
    if (psgcData == null) return;
    final province = (psgcData!['provinces'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (p) =>
              p['name'].toString().toLowerCase() == provinceName.toLowerCase(),
          orElse: () => {},
        );

    if (province.isEmpty) {
      setState(() {
        cities = [];
        barangays = [];
      });
      return;
    }

    setState(() {
      cities =
          (psgcData!['cities_municipalities'] as List)
              .where((c) => c['parent_id'] == province['id'])
              .toList();
      barangays = [];
    });
  }

  void loadBarangays(String cityName) {
    if (psgcData == null) return;
    final city = (psgcData!['cities_municipalities'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (c) => c['name'].toString().toLowerCase() == cityName.toLowerCase(),
          orElse: () => {},
        );

    if (city.isEmpty) {
      setState(() {
        barangays = [];
      });
      return;
    }

    setState(() {
      barangays =
          (psgcData!['barangays'] as List)
              .where((b) => b['parent_id'] == city['id'])
              .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    user = fb.FirebaseAuth.instance.currentUser;
    fetchAddresses();
    fetchUserDetails();
    loadPSGCOffline(); // ✅ Load PSGC JSON
  }

  Future<List<String>> _checkStockAvailability(
    List<Map<String, dynamic>> cartItems,
  ) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final List<String> errors = [];

    for (final item in cartItems) {
      // Accept either item['productId'] or nested item['product']['productId']
      final dynamic pidRaw = item['productId'] ?? item['product']?['productId'];
      final String productName =
          (item['productName'] ?? pidRaw ?? 'Unknown').toString();
      final int requestedQty =
          item['quantity'] is int
              ? item['quantity'] as int
              : int.tryParse((item['quantity'] ?? '').toString()) ?? 0;
      final String selSize = (item['selectedSize'] ?? '').toString();
      final String selColor = (item['selectedColor'] ?? '').toString();

      if (pidRaw == null) {
        errors.add("Missing productId for $productName.");
        continue;
      }
      if (requestedQty <= 0) {
        errors.add("Invalid quantity for $productName.");
        continue;
      }

      try {
        QuerySnapshot<Map<String, dynamic>> query;
        DocumentSnapshot<Map<String, dynamic>>? docById;
        QueryDocumentSnapshot<Map<String, dynamic>>? productDoc;

        final String pidStr = pidRaw.toString();

        // 1) Try number match (productId stored as number)
        final int? pidAsInt = int.tryParse(pidStr);
        if (pidAsInt != null) {
          query =
              await db
                  .collection('products')
                  .where('productId', isEqualTo: pidAsInt)
                  .limit(1)
                  .get();
          if (query.docs.isNotEmpty) productDoc = query.docs.first;
        }

        // 2) If not found, try matching as string (just in case)
        if (productDoc == null) {
          query =
              await db
                  .collection('products')
                  .where('productId', isEqualTo: pidStr)
                  .limit(1)
                  .get();
          if (query.docs.isNotEmpty) productDoc = query.docs.first;
        }

        // 3) If still not found, try doc ID lookup (maybe cart stored doc id)
        if (productDoc == null) {
          docById = await db.collection('products').doc(pidStr).get();
          if (!docById.exists) docById = null;
        }

        if (productDoc == null && docById == null) {
          errors.add("Product not found for id $pidStr.");
          continue;
        }

        // Extract product data from whichever we found
        final Map<String, dynamic> prodData =
            productDoc != null
                ? (productDoc.data() as Map<String, dynamic>)
                : (docById!.data() as Map<String, dynamic>);

        final List<dynamic> variantsRaw = List<dynamic>.from(
          prodData['productVariants'] ?? [],
        );
        final List<Map<String, dynamic>> variants =
            variantsRaw.map((v) {
              if (v is Map) return Map<String, dynamic>.from(v);
              return <String, dynamic>{};
            }).toList();

        // Find variant by size+color case-insensitive
        final int variantIndex = variants.indexWhere((v) {
          final String vSize =
              (v['productSize'] ?? '').toString().toLowerCase();
          final String vColor =
              (v['productColor'] ?? '').toString().toLowerCase();
          return vSize == selSize.toLowerCase() &&
              vColor == selColor.toLowerCase();
        });

        if (variantIndex == -1) {
          errors.add(
            "Variant not found for $productName — ${selColor} / ${selSize}.",
          );
          continue;
        }

        final dynamic stockRaw = variants[variantIndex]['productQuantity'] ?? 0;
        final int currentStock =
            stockRaw is int ? stockRaw : int.tryParse(stockRaw.toString()) ?? 0;

        if (currentStock <= 0) {
          errors.add("Out of stock: $productName (${selColor} / ${selSize}).");
          continue;
        }

        if (currentStock < requestedQty) {
          errors.add(
            "Insufficient stock for $productName (${selColor} / ${selSize}). "
            "Available: $currentStock, requested: $requestedQty.",
          );
        }

        // optional debug
        print(
          "Stock OK check -> product: $productName (pid=$pidStr) variant=$selColor/$selSize stock=$currentStock req=$requestedQty",
        );
      } catch (e, st) {
        print("Error checking stock for pid=${pidRaw.toString()}: $e\n$st");
        errors.add("Failed checking stock for ${productName}: ${e.toString()}");
      }
    } // for

    return errors;
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

  Future<void> showAddressDialog({
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
  }) async {
    labelController.text = label ?? '';
    houseNumberController.text = houseNumber ?? '';
    streetController.text = street ?? '';
    barangayController.text = barangay ?? '';
    cityMunicipalityController.text = cityMunicipality ?? '';
    provinceController.text = province ?? '';
    postalCodeController.text = postalCode ?? '';
    countryController.text = country ?? 'Philippines';

    if (psgcData == null) {
      Toastify.show(
        context,
        message: "PSGC data not loaded yet",
        description: "Please wait a few seconds and try again.",
        type: ToastType.warning,
      );
      return;
    }

    if (provinces.isEmpty) {
      loadProvinces();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(addressId == null ? "New Address" : "Edit Address"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1️⃣ Address Label + Province
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: TextField(
                            controller: labelController,
                            decoration: InputDecoration(
                              labelText: 'Address Label',
                              alignLabelWithHint:
                                  true, // ✅ keeps label aligned inside top-left
                              filled: true, // ✅ enable white background
                              fillColor: Colors.white, // ✅ white background
                              labelStyle: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.color9,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width / 50),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty)
                                return const Iterable<String>.empty();
                              final List<dynamic> provList =
                                  psgcData!['provinces'] ?? [];
                              final matches =
                                  provList
                                      .map((p) => p['name'])
                                      .whereType<String>() // ✅ ignore nulls
                                      .where(
                                        (n) => n.toLowerCase().contains(
                                          value.text.toLowerCase(),
                                        ),
                                      )
                                      .toList();
                              return matches;
                            },

                            onSelected: (selection) {
                              provinceController.text = selection;
                              loadCities(selection);
                              setStateDialog(() {});
                            },
                            fieldViewBuilder: (
                              context,
                              controller,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              controller.text = provinceController.text;
                              return SizedBox(
                                child: TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Province',
                                    alignLabelWithHint:
                                        true, // ✅ keeps label aligned inside top-left
                                    filled: true, // ✅ enable white background
                                    fillColor:
                                        Colors.white, // ✅ white background
                                    labelStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black26,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: Colors.black26,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.color9,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 150),

                    // 2️⃣ City/Municipality + Barangay
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty)
                                return const Iterable<String>.empty();

                              final List<dynamic> rawList =
                                  cities.isNotEmpty
                                      ? cities
                                      : (psgcData!['cities_municipalities'] ??
                                          []);

                              final List<String> matches = [];
                              for (final item in rawList) {
                                if (item is Map && item['name'] != null) {
                                  final name = item['name'].toString();
                                  if (name.toLowerCase().contains(
                                    value.text.toLowerCase(),
                                  )) {
                                    matches.add(name);
                                  }
                                }
                              }

                              print(
                                "🏙 Found ${matches.length} city matches for '${value.text}'",
                              );
                              return matches;
                            },

                            onSelected: (selection) {
                              cityMunicipalityController.text = selection;
                              loadBarangays(selection);
                              setStateDialog(() {});
                            },
                            fieldViewBuilder: (
                              context,
                              controller,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              controller.text = cityMunicipalityController.text;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'City/Municipality',
                                  alignLabelWithHint:
                                      true, // ✅ keeps label aligned inside top-left
                                  filled: true, // ✅ enable white background
                                  fillColor: Colors.white, // ✅ white background
                                  labelStyle: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.color9,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width / 50),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: Autocomplete<String>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty)
                                return const Iterable<String>.empty();

                              final List<dynamic> rawList =
                                  barangays.isNotEmpty
                                      ? barangays
                                      : (psgcData!['barangays'] ?? []);

                              final List<String> matches = [];
                              for (final item in rawList) {
                                if (item is Map && item['name'] != null) {
                                  final name = item['name'].toString();
                                  if (name.toLowerCase().contains(
                                    value.text.toLowerCase(),
                                  )) {
                                    matches.add(name);
                                  }
                                }
                              }

                              print(
                                "🏘 Found ${matches.length} barangay matches for '${value.text}'",
                              );
                              return matches;
                            },

                            onSelected: (selection) {
                              barangayController.text = selection;
                            },
                            fieldViewBuilder: (
                              context,
                              controller,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              controller.text = barangayController.text;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: 'Barangay',
                                  alignLabelWithHint:
                                      true, // ✅ keeps label aligned inside top-left
                                  filled: true, // ✅ enable white background
                                  fillColor: Colors.white, // ✅ white background
                                  labelStyle: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.black26,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: AppColors.color9,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 150),

                    // 3️⃣ Street + House Number
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: TextField(
                            controller: streetController,
                            decoration: InputDecoration(
                              labelText: 'Street',
                              alignLabelWithHint:
                                  true, // ✅ keeps label aligned inside top-left
                              filled: true, // ✅ enable white background
                              fillColor: Colors.white, // ✅ white background
                              labelStyle: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.color9,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width / 50),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: TextField(
                            controller: houseNumberController,
                            decoration: InputDecoration(
                              labelText: 'House Number',
                              alignLabelWithHint:
                                  true, // ✅ keeps label aligned inside top-left
                              filled: true, // ✅ enable white background
                              fillColor: Colors.white, // ✅ white background
                              labelStyle: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.color9,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width / 150),

                    // 4️⃣ Postal Code + Country
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: TextField(
                            controller: postalCodeController,
                            decoration: InputDecoration(
                              labelText: 'Postal Code',
                              alignLabelWithHint:
                                  true, // ✅ keeps label aligned inside top-left
                              filled: true, // ✅ enable white background
                              fillColor: Colors.white, // ✅ white background
                              labelStyle: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.color9,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width / 50),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 8,
                          height: MediaQuery.of(context).size.width / 25,
                          child: TextField(
                            controller: countryController,
                            decoration: InputDecoration(
                              labelText: 'Country',
                              alignLabelWithHint:
                                  true, // ✅ keeps label aligned inside top-left
                              filled: true, // ✅ enable white background
                              fillColor: Colors.white, // ✅ white background
                              labelStyle: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.color9,
                                  width: 2,
                                ),
                              ),
                            ),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width / 100,
                          ),
                          color: Colors.red,
                        ),
                        height: MediaQuery.of(context).size.width / 40,
                        width: MediaQuery.of(context).size.width / 7.5,
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width / 80,
                            ),
                          ),
                        ),
                      ),
                    ).showCursorOnHover,
                    SizedBox(width: MediaQuery.of(context).size.width / 80),
                    GestureDetector(
                      onTap:
                          () => saveAddress(
                            addressId: addressId,
                            label: labelController.text,
                            houseNumber: houseNumberController.text,
                            street: streetController.text,
                            barangay: barangayController.text,
                            cityMunicipality: cityMunicipalityController.text,
                            province: provinceController.text,
                            postalCode: postalCodeController.text,
                            country: countryController.text,
                          ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.width / 100,
                          ),
                          color: Colors.green,
                        ),
                        height: MediaQuery.of(context).size.width / 40,
                        width: MediaQuery.of(context).size.width / 7.5,
                        child: Center(
                          child: Text(
                            'Save',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: MediaQuery.of(context).size.width / 80,
                            ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              paymentMethodWidget(), // ⬅️ Added here
            ],
          ),

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
                print("🟢 Button clicked");

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
                if (selectedPaymentMethod == null ||
                    selectedPaymentMethod!.isEmpty) {
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

                  final stockErrors = await _checkStockAvailability(cartItems);
                  if (stockErrors.isNotEmpty) {
                    // show user the first error or all of them
                    Toastify.show(
                      context,
                      message: 'Stock issue',
                      description: stockErrors.join("\n"),
                      type: ToastType.warning,
                    );
                    return; // stop checkout — not enough stock
                  }

                  print("✅ All pre-checks passed, writing to box...");

                  final box = GetStorage();

                  dynamic _convertTimestamps(dynamic data) {
                    if (data is Map) {
                      return data.map(
                        (key, value) =>
                            MapEntry(key, _convertTimestamps(value)),
                      );
                    } else if (data is List) {
                      return data
                          .map((item) => _convertTimestamps(item))
                          .toList();
                    } else if (data is Timestamp) {
                      return data
                          .toDate()
                          .toIso8601String(); // convert Timestamp → String
                    } else {
                      return data;
                    }
                  }

                  print("🚀 Sanitizing checkout data...");

                  final sanitizedData = {
                    "userDetails": _convertTimestamps(userDetails),
                    "cartItems": _convertTimestamps(cartItems),
                    "selectedAddress": _convertTimestamps(selectedAddress),
                    "paymentMethod": selectedPaymentMethod,
                    "proofOfPayment": _paymentProofUrl,
                  };

                  print(
                    "🧼 Sanitized checkoutData ready to store: $sanitizedData",
                  );

                  await box.write('checkoutData', sanitizedData);
                  await box
                      .save(); // ✅ ensure it’s flushed to disk/localStorage

                  print("✅ Saved checkoutData successfully!");

                  print("✅ Saved checkoutData: ${box.read('checkoutData')}");

                  final payMongo =
                      PayMongoService(); // 👈 instantiate your service

                  // 🔹 Use the centralized PayMongo service
                  if (selectedPaymentMethod == "GCash" ||
                      selectedPaymentMethod == "PayMaya" ||
                      selectedPaymentMethod == "GrabPay") {
                    await payMongo.payWithPayMongo(
                      amount: subtotal,
                      paymentType: selectedPaymentMethod!,
                      name: userDetails?['full_name'] ?? "Customer",
                      email:
                          userDetails?['email_Address'] ??
                          user?.email ??
                          "customer@example.com",
                      phone: userDetails?['phone_number'] ?? "09123456789",
                    );
                  } else if (selectedPaymentMethod == "Credit/Debit Card") {
                    await payMongo.payWithPayMongo(
                      amount: subtotal,
                      paymentType: "Credit/Debit Card",
                      name: userDetails?['full_name'] ?? "Customer",
                      email:
                          userDetails?['email_Address'] ??
                          user?.email ??
                          "customer@example.com",
                      phone: userDetails?['phone_number'] ?? "09123456789",
                      cardNumber: cardNumberCtrl.text,
                      expMonth: expMonthCtrl.text,
                      expYear: expYearCtrl.text,
                      cvc: cvcCtrl.text,
                    );
                  } else {
                    // 🟩 Cash on Delivery or other non-online methods
                    await CustomerServices.placeOrder(
                      userDetails: userDetails,
                      cartItems: cartItems,
                      selectedAddress: selectedAddress,
                      proofOfPayment: _paymentProofUrl,
                      paymentMethod: selectedPaymentMethod!,
                    );
                  }

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
        ...paymentMethods.map((method) {
          return RadioListTile<String>(
            value: method,
            groupValue: selectedPaymentMethod,
            title: Text(method),
            activeColor: AppColors.color8,
            onChanged: (value) {
              setState(() => selectedPaymentMethod = value);
            },
          );
        }).toList(),

        // 👇 Show card fields only if Credit/Debit Card is selected
        if (selectedPaymentMethod == "Credit/Debit Card")
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Card Details:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),
                TextField(
                  controller: cardNumberCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Card Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expMonthCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Exp. Month (MM)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: expYearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Exp. Year (YY)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cvcCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "CVC",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
