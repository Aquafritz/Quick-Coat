import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickcoat/core/colors/app_colors.dart';

class DeliveryProfile extends StatefulWidget {
  const DeliveryProfile({super.key});

  @override
  State<DeliveryProfile> createState() => _DeliveryProfileState();
}

class _DeliveryProfileState extends State<DeliveryProfile> {

  Map<String,dynamic>? userData;
  bool isLoading = true;

   @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection("users").doc(uid).get();

        if (doc.exists) {
          setState(() {
            userData = doc.data();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
       ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 20,
          vertical: MediaQuery.of(context).size.width / 20,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [dashboardCard(context), settings(context)],
          ),
        ),
      ),
    );
  }

  Widget dashboardCard(BuildContext context) {
    final profilePic = userData?["profile_picture"];
    final fullName = userData?["full_name"] ?? "No Name";

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
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
        children: [
          Container(
            height: MediaQuery.of(context).size.width / 4,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: AppColors.color8,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 15,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      profilePic != null ? NetworkImage(profilePic) : null,
                  child: profilePic == null
                      ? Icon(
                          Icons.person,
                          size: MediaQuery.of(context).size.width / 15,
                          color: Colors.white,
                        )
                      : null,
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 50),
                Text(
                  fullName,
                  style: GoogleFonts.roboto(
                    fontSize: MediaQuery.of(context).size.width / 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.width / 2.1,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 15,
                vertical: MediaQuery.of(context).size.width / 30,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.color4,
                        child: Icon(Icons.star_outline, color: Colors.yellow),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 40),
                      Text(
                        "4.8",
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 35,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 60),
                      Text(
                        "Rider Rating",
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 35,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width / 90),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.color2.withOpacity(1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "158",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                                color: AppColors.color8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Deliveries",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 35,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.color2.withOpacity(1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "98%",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                                color: AppColors.color8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Completion",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 35,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.color2.withOpacity(1),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "95%",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                                color: AppColors.color8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "On Time",
                              style: GoogleFonts.roboto(
                                fontSize:
                                    MediaQuery.of(context).size.width / 35,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
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

  Widget settings(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      height: MediaQuery.of(context).size.width / 2.1,
      margin: const EdgeInsets.only(top: 20),
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
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 15,
          vertical: MediaQuery.of(context).size.width / 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/deliveryHistory');
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: MediaQuery.of(context).size.width / 20,
                        color: AppColors.color8,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 50),
                      Text(
                        'Delivery History',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: MediaQuery.of(context).size.width / 30,
                ),
              ],
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                Get.toNamed('/vehicleInformation');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: MediaQuery.of(context).size.width / 20,
                        color: AppColors.color8,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 50),
                      Text(
                        'Vehicle Information',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: MediaQuery.of(context).size.width / 30,
                  ),
                ],
              ),
            ),
            
            Divider(),
            GestureDetector(
              onTap: () {
                Get.toNamed('/profileSettings');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: MediaQuery.of(context).size.width / 20,
                        color: AppColors.color8,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width / 50),
                      Text(
                        'Profile Settings',
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: MediaQuery.of(context).size.width / 30,
                  ),
                ],
              ),
            ),

            Divider(),
            GestureDetector(
                    onTap: () => _showSignOutDialog(context),

              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: MediaQuery.of(context).size.width / 20,
                    color: Colors.red,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 50),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.roboto(
                      fontSize: MediaQuery.of(context).size.width / 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text("Confirm Sign Out",
        style: GoogleFonts.roboto(
          fontSize: MediaQuery.of(context).size.width / 20,
          color: Colors.black,
          fontWeight: FontWeight.w600
        ),
        ),
        content: Text("Are you sure you want to Sign Out?",
        style: GoogleFonts.roboto(
          fontSize: MediaQuery.of(context).size.width / 25,
          color: Colors.black,
          fontWeight: FontWeight.w400
        ),),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.color8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  )
                ),
                onPressed: () {
                  Get.back(); // close dialog
                },
                child: Text(
                  "No",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 30,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Get.back(); // close dialog
                  Get.offAllNamed("/driverSignIn"); // navigate to login page
                },
                child: Text("Yes", style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 30,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
