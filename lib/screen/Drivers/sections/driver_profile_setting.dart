import 'dart:io';
import 'dart:typed_data';

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

  final ProfileSettingsService _profileService =
      ProfileSettingsService(); // 👈 instance
  File? _profileImage;
  Uint8List? _webImage; // 👈 for web
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
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
        name: _nameController.text,
        phone: _phoneController.text,
        profileUrl: profileUrl,
      );

      setState(() {
        isExpanded = false;
        _profileImage = null; // clear temp image after saving
      });

      _loadUserData(); // refresh UI
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                              child:  GestureDetector(
                onTap: _pickAndUploadImage,
                child: CircleAvatar(
                  radius: screenWidth / 3,
                  backgroundColor: AppColors.color8,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : _webImage != null
                          ? MemoryImage(_webImage!) // 👈 Show web image
                          : (userData?["profile_picture"] != null
                              ? NetworkImage(userData!["profile_picture"])
                              : null),
                  child: (_profileImage == null &&
                          _webImage == null &&
                          userData?["profile_picture"] == null)
                      ? const Icon(Icons.person, size: 80, color: Colors.white)
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
