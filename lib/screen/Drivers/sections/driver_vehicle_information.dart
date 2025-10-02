import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:quickcoat/screen/Drivers/sections/services/vehicle_information_services.dart';

class DriverVehicleInformation extends StatefulWidget {
  const DriverVehicleInformation({super.key});

  @override
  State<DriverVehicleInformation> createState() =>
      _DriverVehicleInformationState();
}

class _DriverVehicleInformationState extends State<DriverVehicleInformation> {
  bool isExpanded = false;

  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateNumberController = TextEditingController();

  final VehicleInformationService _vehicleService =
      VehicleInformationService(); // service instance
  Map<String, dynamic>? userData;

  int _currentIndex = 0;

  final List<Map<String, dynamic>> vehicleTypes = [
    {"name": "Car", "image": "assets/images/car.png"},
    {"name": "Bicycle", "image": "assets/images/bicycle.png"},
    {"name": "Tricycle", "image": "assets/images/tricycle.png"},
    {"name": "Motorcycle", "image": "assets/images/motorcycle.png"},
  ];

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
  }

  Future<void> _loadVehicleData() async {
    final data = await _vehicleService.fetchVehicleInformation();
    if (data != null) {
      setState(() {
        userData = data;
        _modelController.text = data["vehicle_model"] ?? "";
        _colorController.text = data["vehicle_color"] ?? "";
        _plateNumberController.text = data["plate_number"] ?? "";

        _currentIndex = vehicleTypes.indexWhere(
          (v) => v["name"] == data["vehicle_type"],
        );
        if (_currentIndex == -1) _currentIndex = 0;
      });
    }
  }

  Future<void> _saveVehicleData() async {
    await _vehicleService.saveVehicleInformation(
      vehicleType: vehicleTypes[_currentIndex]["name"],
      vehicleModel: _modelController.text,
      vehicleColor: _colorController.text,
      plateNumber: _plateNumberController.text,
    );

    await _loadVehicleData();

    setState(() {
      isExpanded = false;
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
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
                              "Vehicle Information",
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
                            ? Column(
  children: [
    CarouselSlider.builder(
      itemCount: vehicleTypes.length,
      options: CarouselOptions(
        height: screenWidth * 1.0,
        enlargeCenterPage: true, // makes the active card stand out
        viewportFraction: 0.9,   // small peek of neighbors
        autoPlay: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      itemBuilder: (context, index, realIndex) {
        final vehicle = vehicleTypes[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  vehicle["image"],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              // Vehicle name overlay
              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  vehicle["name"],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 6,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  ],
)


                            : Center(
  child: Container(
    width: screenWidth, // take full width
    height: screenWidth * 0.7, // big height
  
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Image.asset(
        vehicleTypes[_currentIndex]["image"],
        fit: BoxFit.cover, // makes it feel big and immersive
      ),
    ),
  ),
),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            switchInCurve: Curves.easeIn,
                            switchOutCurve: Curves.easeOut,
                            child: isExpanded
                                ? SingleChildScrollView(
                                    key: const ValueKey("form"),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                         Text(
                                            "Vehicle Model",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        TextFormField(
                                          controller: _modelController,
                                          decoration:
                                              const InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Enter vehicle model",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                         Text(
                                            "Vehicle Color",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        TextFormField(
                                          controller: _colorController,
                                          decoration:
                                              const InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: "Enter vehicle color",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                         Text(
                                            "Vehicle Plate Number",
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        TextFormField(
                                          controller:
                                              _plateNumberController,
                                          decoration:
                                              const InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText:
                                                "Enter vehicle plate number",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: _saveVehicleData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12),
                                            ),
                                          ),
                                          child: Text(
                                            "Save Changes",
                                            style: GoogleFonts.roboto(
                                              fontSize: MediaQuery.of(
                                                        context)
                                                    .size
                                                    .width /
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
                        isExpanded
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
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
                          'Vehicle Information',
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 15,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Divider(thickness: 2, color: AppColors.color8),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 30,
                        ),
                        Text(
                          "Vehicle Type:",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userData?["vehicle_type"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Vehicle Model:",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userData?["vehicle_model"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Vehicle Color:",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userData?["vehicle_color"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
                            color: AppColors.color8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Vehicle Plate Number:",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          userData?["plate_number"] ?? "N/A",
                          style: GoogleFonts.roboto(
                            fontSize:
                                MediaQuery.of(context).size.width / 20,
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