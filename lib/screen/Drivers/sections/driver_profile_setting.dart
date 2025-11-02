import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/Drivers/sections/services/profile_settings_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

class DriverProfileSettings extends StatefulWidget {
  const DriverProfileSettings({super.key});

  @override
  State<DriverProfileSettings> createState() => _DriverProfileSettingsState();
}

class _DriverProfileSettingsState extends State<DriverProfileSettings> {
  bool isExpanded = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _barangayController = TextEditingController();
  final _provinceController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _genderController = TextEditingController();
  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  final ProfileSettingsService _profileService =
      ProfileSettingsService(); // 👈 instance
  File? _profileImage;
  Uint8List? _webImage; // 👈 for web
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    // Prevent null access for Flutter Web
    _nameController.text = '';
    _phoneController.text = '';
    _houseNumberController.text = '';
    _barangayController.text = '';
    _cityController.text = '';
    _provinceController.text = '';
    _birthdayController.text = '';
    _genderController.text = '';
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await _profileService.fetchUserProfile();
      if (data != null) {
        setState(() {
          userData = data;
          _nameController.text = data["full_name"] ?? "";
          _phoneController.text = data["phone_number"] ?? "";
          _houseNumberController.text = data["house_number"] ?? "";
          _cityController.text = data["city"] ?? "";
          _provinceController.text = data["province"] ?? "";
          if (data["birthday"] is Timestamp) {
            final date = (data["birthday"] as Timestamp).toDate();
            _birthdayController.text =
                "${_monthName(date.month)} ${date.day}, ${date.year}";
          }

          _genderController.text = data["gender"] ?? "";
          _barangayController.text = data["barangay"] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      if (kIsWeb) {
        // ✅ Use FilePicker only on web
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true, // <-- important on web to get bytes
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _webImage = result.files.single.bytes!;
          });
        }
      } else {
        // ✅ Use ImagePicker on mobile
        final picker = ImagePicker();
        final picked = await picker.pickImage(source: ImageSource.gallery);

        if (picked != null) {
          setState(() {
            _profileImage = File(picked.path);
          });
        }
      }
    } catch (e, st) {
      debugPrint("Error picking image: $e\n$st");
    }
  }

  Future<void> _saveUserData() async {
    try {
      String? profileUrl;

      // ✅ Upload different depending on platform
      if (kIsWeb && _webImage != null) {
        profileUrl = await _profileService.uploadWebProfilePicture(_webImage!);
      } else if (_profileImage != null) {
        profileUrl = await _profileService.uploadProfilePicture(_profileImage!);
      }

      // 👇 Only upload if user picked a new image
      if (_profileImage != null) {
        profileUrl = await _profileService.uploadProfilePicture(_profileImage!);
      }

      await _profileService.saveUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        profileUrl: profileUrl,
        houseNumber: _houseNumberController.text.trim(),
        barangay: _barangayController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        birthday: _birthdayController.text.trim(),
        gender: _genderController.text.trim(),
      );
      if (!mounted) return; // prevent setState after dispose

      setState(() {
        isExpanded = false;
        _profileImage = null; // clear temp image after saving
      });

      await _loadUserData();
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _houseNumberController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _birthdayController.dispose();
    _genderController.dispose();
    _barangayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: screenWidth,
                    height: isExpanded ? 860 : 400,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth / 20,
                      vertical: screenWidth / 40,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.color9,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
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
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 28,
                                color: Colors.white,
                              ),
                              onPressed: () => Get.back(),
                            ),
                            Text(
                              "Profile Settings",
                              style: GoogleFonts.roboto(
                                fontSize: screenWidth / 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth / 15),
                        isExpanded
                            ? Center(
                              child: GestureDetector(
                                onTap: _pickAndUploadImage,
                                child: CircleAvatar(
                                  radius: screenWidth / 3,
                                  backgroundColor: AppColors.color8,
                                  backgroundImage:
                                      _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : _webImage != null
                                          ? MemoryImage(
                                            _webImage!,
                                          ) // 👈 Show web image
                                          : (userData?["profile_picture"] !=
                                                  null
                                              ? NetworkImage(
                                                userData!["profile_picture"],
                                              )
                                              : null),
                                  child:
                                      (_profileImage == null &&
                                              _webImage == null &&
                                              userData?["profile_picture"] ==
                                                  null)
                                          ? const Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                              ),
                            )
                            : Center(
                              child: CircleAvatar(
                                radius: screenWidth / 3,
                                backgroundColor:
                                    (_profileImage == null &&
                                            userData?["profile_picture"] ==
                                                null)
                                        ? AppColors
                                            .color8 // 👈 Use color8 only when no image
                                        : Colors
                                            .transparent, // 👈 Keep transparent if there's an image
                                backgroundImage:
                                    _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : (userData?["profile_picture"] != null
                                            ? NetworkImage(
                                                  userData!["profile_picture"],
                                                )
                                                as ImageProvider
                                            : null),
                                child:
                                    (_profileImage == null &&
                                            userData?["profile_picture"] ==
                                                null)
                                        ? const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            ),

                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            child:
                                isExpanded
                                    ? SingleChildScrollView(
                                      key: const ValueKey("form"),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Full Name",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _nameController,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  "Enter full name", // 👈 optional hint
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          Text(
                                            "Phone Number",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _phoneController,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                              hintText: "Enter phone number",
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            "House Number",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _houseNumberController,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                              hintText: "Enter house number",
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            "Barangay",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _barangayController,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                              hintText: "Enter barangay",
                                            ),
                                          ),

                                          const SizedBox(height: 20),
                                          Text(
                                            "City / Municipality",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _cityController,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                              hintText:
                                                  "Enter city or municipality",
                                            ),
                                          ),

                                          const SizedBox(height: 20),
                                          Text(
                                            "Province",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _provinceController,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                              hintText: "Enter province",
                                            ),
                                          ),

                                          const SizedBox(height: 20),
                                          Text(
                                            "Birthday",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          TextFormField(
                                            controller: _birthdayController,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                              hintText: "Select birthday",
                                              suffixIcon: Icon(
                                                Icons.calendar_today,
                                              ),
                                            ),
                                            onTap: () async {
                                              final picked =
                                                  await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime(1990),
                                                    firstDate: DateTime(1950),
                                                    lastDate: DateTime.now(),
                                                  );
                                              if (picked != null) {
                                                // Show only readable date in UI
                                                _birthdayController.text =
                                                    "${_monthName(picked.month)} ${picked.day}, ${picked.year}";
                                              }
                                            },
                                          ),

                                          const SizedBox(height: 20),
                                          Text(
                                            "Gender",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          DropdownButtonFormField<String>(
                                            value:
                                                (_genderController.text != '' &&
                                                        _genderController
                                                            .text
                                                            .isNotEmpty)
                                                    ? _genderController.text
                                                    : null,

                                            items:
                                                ["Male", "Female", "Other"]
                                                    .map(
                                                      (g) => DropdownMenuItem(
                                                        value: g,
                                                        child: Text(g),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged:
                                                (value) => setState(
                                                  () =>
                                                      _genderController.text =
                                                          value!,
                                                ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(),
                                            ),
                                          ),

                                          const SizedBox(height: 30),

                                          ElevatedButton(
                                            onPressed: _saveUserData,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              "Save Changes",
                                              style: GoogleFonts.roboto(
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width /
                                                    25,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isExpanded)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth / 20,
                    vertical: screenWidth / 40,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Basic Information',
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 15,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(thickness: 2, color: AppColors.color8),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 30,
                        ),
                        Text(
                          "Name:",
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userData?["full_name"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 20,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "Email:",
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userData?["email"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 20,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "Number:",
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userData?["phone_number"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: MediaQuery.of(context).size.width / 20,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "House Number:",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          userData?["house_number"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.color8,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "Barangay:",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          userData?["barangay"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.color8,
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "City:",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          userData?["city"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.color8,
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "Province:",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          userData?["province"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.color8,
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "Birthday:",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          userData?["birthday"] is Timestamp
                              ? (() {
                                final date =
                                    (userData?["birthday"] as Timestamp)
                                        .toDate();
                                return "${_monthName(date.month)} ${date.day}, ${date.year}";
                              })()
                              : (userData?["birthday"]?.toString() ?? "N/A"),
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.color8,
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.width / 40,
                        ),
                        Text(
                          "Gender:",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          userData?["gender"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.color8,
                          ),
                        ),
                      ],
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
