import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:quickcoat/animations/animatedTextField.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/animations/toastification.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Costumer/costumer_services.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;

class CostumerSetting extends StatefulWidget {
  const CostumerSetting({super.key});

  @override
  State<CostumerSetting> createState() => _CostumerSettingState();
}

class _CostumerSettingState extends State<CostumerSetting> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController houseNumberController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController cityMunicipalityController =
      TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  Timestamp? dobTimestamp;
  String? profilePictureUrl;
  Uint8List? pickedImageBytes;

  /// ✅ PSGC local data cache
  Map<String, dynamic>? psgcData;
  List<dynamic> provinces = [];
  List<dynamic> cities = [];
  List<dynamic> barangays = [];

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
      print(
        "Sample provinces: ${psgcData!['provinces'].take(10).map((p) => p['name']).toList()}",
      );

      print("✅ PSGC offline data loaded: ${psgcData!.keys}");
      print("Provinces loaded: ${psgcData!['provinces'].length}");
      print("Cities loaded: ${psgcData!['cities_municipalities'].length}");
      print("Barangays loaded: ${psgcData!['barangays'].length}");
    } catch (e) {
      print("⚠️ Failed to load PSGC data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadPSGCOffline(); // ✅ Load PSGC local file
  }

  Future<void> loadUserData() async {
    final data = await CustomerServices.loadUserData();
    if (data != null) {
      fullNameController.text = data['full_name'] ?? '';
      emailController.text = data['email_Address'] ?? '';
      phoneNumberController.text = data['phone_number'] ?? '';
      genderController.text = data['gender'] ?? '';
      profilePictureUrl = data['profile_picture'];

      if (data['date_of_birth'] != null) {
  if (data['date_of_birth'] is Timestamp) {
    dobTimestamp = data['date_of_birth'];
  } else if (data['date_of_birth'] is String) {
    try {
      final parsed = DateFormat("MM/dd/yyyy").parse(data['date_of_birth']);
      dobTimestamp = Timestamp.fromDate(parsed);
    } catch (e) {
      print("DOB format error: $e");
    }
  }
}

      setState(() {});
    }
  }

  Future<void> saveUserData({
    required String fullName,
    required String phoneNumber,
    required Timestamp? dob,
    required String gender,
  }) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'full_name': fullName,
      'phone_number': phoneNumber,
      'date_of_birth': dob,
      'gender': gender,
      'profile_picture': profilePicture,
    });
  }

  Future<void> saveAddress({String? addressId}) async {
    if (addressId == null) {
      await CustomerServices.addAddress(
        label: labelController.text.isEmpty ? "Other" : labelController.text,
        houseNumber: houseNumberController.text,
        street: streetController.text,
        barangay: barangayController.text,
        cityMunicipality: cityMunicipalityController.text,
        province: provinceController.text,
        postalCode: postalCodeController.text,
        country: countryController.text,
      );
      Toastify.show(
        context,
        message: "Success",
        description: "Address added successfully!",
        type: ToastType.success,
      );
    } else {
      await CustomerServices.updateAddress(
        addressId: addressId,
        label: labelController.text.isEmpty ? "Other" : labelController.text,
        houseNumber: houseNumberController.text,
        street: streetController.text,
        barangay: barangayController.text,
        cityMunicipality: cityMunicipalityController.text,
        province: provinceController.text,
        postalCode: postalCodeController.text,
        country: countryController.text,
      );
      Toastify.show(
        context,
        message: "Success",
        description: "Address updated successfully!",
        type: ToastType.success,
      );
    }
    Get.back();
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    final initialDate = dobTimestamp?.toDate() ?? DateTime(2000, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      confirmText: 'Save',
      cancelText: 'Cancel',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.color8, // header background
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.color8, // buttons color
                textStyle: TextStyle(
                  fontSize: 18, // font size
                  fontWeight: FontWeight.w300, // font weight
                  fontFamily: 'Roboto', // font family
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        dobTimestamp = Timestamp.fromDate(pickedDate);
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithout(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 20,
                  ),
                  child:
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('/costumerHome');
                        },
                        child: Row(
                          children: [
                            Icon(Icons.arrow_back_ios),
                            Text(
                              'Profile Settings',
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ).showCursorOnHover.moveUpOnHover,
                ),
                SizedBox(height: MediaQuery.of(context).size.width / 60),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profilePicture(context),
                      SizedBox(width: MediaQuery.of(context).size.width / 20),
                      Expanded(child: profileDetails(context)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget profilePicture(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);

        if (picked != null) {
          final bytes = await picked.readAsBytes();
          setState(() {
            pickedImageBytes = bytes;
          });
          Toastify.show(
            context,
            message: 'Selected',
            description: 'Profile picture is ready to upload!',
            type: ToastType.info,
          );
        }
      },
      child: Container(
        width: 300,
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              pickedImageBytes != null
                  ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                  : profilePictureUrl != null
                  ? Image.network(profilePictureUrl!, fit: BoxFit.cover)
                  : Icon(Icons.person, size: 100, color: Colors.grey),
        ),
      ),
    );
  }

  Widget profileDetails(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 5,
            height: MediaQuery.of(context).size.width / 25,
            child: AnimatedTextField(
              controller: fullNameController,
              label: 'Full Name',
              suffix: null,
              readOnly: false,
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 90),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 8,
                height: MediaQuery.of(context).size.width / 25,
                child: AnimatedTextField(
                  controller: emailController,
                  label: 'Email',
                  suffix: null,
                  readOnly: true,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 30),
              SizedBox(
                width: MediaQuery.of(context).size.width / 8,
                height: MediaQuery.of(context).size.width / 25,
                child: AnimatedTextField(
                  controller: phoneNumberController,
                  label: 'Phone Number',
                  suffix: null,
                  readOnly: false,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 30),
              SizedBox(
                width: MediaQuery.of(context).size.width / 8,
                height: MediaQuery.of(context).size.width / 25,
                child: GestureDetector(
                  onTap: () => _pickDateOfBirth(context),
                  child: AbsorbPointer(
                    child: AnimatedTextField(
                      controller: TextEditingController(
  text: dobTimestamp == null
      ? ''
      : DateFormat('MM/dd/yyyy').format(dobTimestamp!.toDate()),
)..selection = TextSelection.collapsed(offset: 0),

                      label: 'Date of Birth',
                      suffix: Icon(Icons.calendar_today),
                      readOnly: true,
                    ),
                  ),
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width / 30),
              SizedBox(
                width: MediaQuery.of(context).size.width / 8,
                height: MediaQuery.of(context).size.width / 25,
                child: AnimatedTextField(
                  controller: genderController,
                  label: 'Gender/Sex',
                  suffix: null,
                  readOnly: false,
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 90),
          Row(
            children: [
              Text(
                "Saved Addresses",
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: AppColors.color8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => showAddressDialog(context: context),

                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Add New Address",
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 110,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('addresses')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Text("No addresses saved yet.");
              }

              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.width / 7,
                  child: Column(
                    children:
                        docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Card(
                            child: ListTile(
                              title: Text("${data['label'] ?? 'Address'}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data['house_number'] ?? ''}, ${data['street'] ?? ''}",
                                  ),
                                  Text(
                                    "${data['barangay']}, ${data['city_municipality']}, ${data['province']}",
                                  ),
                                  Text(
                                    "${data['postal_code']}, ${data['country']}",
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      showAddressDialog(
                                        context: context,
                                        addressId: doc.id,
                                        label: data['label'],
                                        houseNumber: data['house_number'],
                                        street: data['street'],
                                        barangay: data['barangay'],
                                        cityMunicipality:
                                            data['city_municipality'],
                                        province: data['province'],
                                        postalCode: data['postal_code'],
                                        country: data['country'],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await CustomerServices.deleteAddress(
                                        doc.id,
                                      );
                                      Toastify.show(
                                        context,
                                        message: "Success",
                                        description: "Address deleted!",
                                        type: ToastType.success,
                                      );
                                    },
                                  ),
                                  if (data['is_default'] == true)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  else
                                    IconButton(
                                      icon: Icon(Icons.radio_button_unchecked),
                                      onPressed: () async {
                                        await CustomerServices.setDefaultAddress(
                                          doc.id,
                                        );
                                        Toastify.show(
                                          context,
                                          message: 'Success',
                                          description:
                                              'Default address updated!',
                                          type: ToastType.success,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.width / 90),
          SizedBox(
            height: MediaQuery.of(context).size.width / 25,
            width: MediaQuery.of(context).size.width / 8,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 10,
                backgroundColor: AppColors.color8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                String? uploadedUrl = profilePictureUrl;

                if (pickedImageBytes != null) {
                  uploadedUrl = await CustomerServices.uploadProfilePicture(
                    pickedImageBytes!,
                  );
                }

                await CustomerServices.saveUserData(
                  fullName: fullNameController.text,
                  phoneNumber: phoneNumberController.text,
                  dob:
                      dobTimestamp != null
                          ? DateFormat(
                            'MM/dd/yyyy',
                          ).format(dobTimestamp!.toDate())
                          : '',
                  gender: genderController.text,
                  profilePicture: uploadedUrl,
                );
                setState(() {
                  profilePictureUrl = uploadedUrl;
                });
                Toastify.show(
                  context,
                  message: "Success",
                  description: "Profile updated successfully!",
                  type: ToastType.success,
                );
              },
              child: Text(
                'Save',
                style: GoogleFonts.roboto(
                  fontSize: MediaQuery.of(context).size.width / 90,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                      onTap: () => saveAddress(addressId: addressId),
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
}
