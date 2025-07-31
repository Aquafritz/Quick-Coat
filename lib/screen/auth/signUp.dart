import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickcoat/animations/animatedTextField.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/features/hover_extensions.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController fullName = TextEditingController();
  TextEditingController emailAdd = TextEditingController();
  TextEditingController pwd = TextEditingController();
  TextEditingController confirmPwd = TextEditingController();

  bool isObscure = true;
  bool isAgreed = false; // for Terms and Conditions checkbox
  bool isConfirmObscure = true;
  Icon icon = Icon(Icons.visibility_off_outlined);
  Icon iconConfirm = Icon(Icons.visibility_off_outlined);

  bool validatePassword(String password) {
    String pattern =
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[_!@#$%^&*(),.?":{}|<>]).{8,16}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }

  void _clearFields() {
    fullName.clear();
    emailAdd.clear();
    pwd.clear();
    confirmPwd.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.color1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 30),

            Image.asset(
              "assets/images/qclogo.png",
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.width / 10,
              width: MediaQuery.of(context).size.width / 10,
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 30),
            Text(
              'Create your account',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 45,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 90),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 90,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 100),
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/signIn');
                  },
                  child:
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 90,
                          color: AppColors.color9,
                          fontWeight: FontWeight.bold,
                        ),
                      ).showCursorOnHover.moveUpOnHover,
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height / 1.7,
              child: Card(
                color: Colors.white,
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 110,
                        ),
                      ),
                      AnimatedTextField(
                        controller: fullName,
                        label: null,
                        suffix: null,
                        readOnly: false,
                        prefix: Icon(Icons.person_outline),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 90),
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 110,
                        ),
                      ),
                      AnimatedTextField(
                        controller: emailAdd,
                        label: null,
                        suffix: null,
                        readOnly: false,
                        prefix: Icon(Icons.email_outlined),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 90),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 6,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start, // <-- Aligns children to the start (left)
                              children: [
                                Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 110,
                                  ),
                                ),
                                AnimatedTextField(
                                  controller: pwd,
                                  label: null,
                                  prefix: Icon(Icons.lock_outline),
                                  suffix:
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isObscure = !isObscure;
                                            icon =
                                                isObscure
                                                    ? Icon(
                                                      Icons
                                                          .visibility_off_outlined,
                                                    )
                                                    : Icon(
                                                      Icons.visibility_outlined,
                                                    );
                                          });
                                        },
                                        child: icon,
                                      ).showCursorOnHover.moveUpOnHover,
                                  readOnly: false,
                                  obscureText: isObscure,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 6,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start, // <-- Make sure this is added
                              children: [
                                Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 110,
                                  ),
                                ),
                                AnimatedTextField(
                                  controller: confirmPwd,
                                  label: null,
                                  prefix: Icon(Icons.lock_outline),

                                  suffix:
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isConfirmObscure =
                                                !isConfirmObscure;
                                            iconConfirm =
                                                isConfirmObscure
                                                    ? Icon(
                                                      Icons
                                                          .visibility_off_outlined,
                                                    )
                                                    : Icon(
                                                      Icons.visibility_outlined,
                                                    );
                                          });
                                        },
                                        child: iconConfirm,
                                      ).showCursorOnHover.moveUpOnHover,
                                  readOnly: false,
                                  obscureText: isConfirmObscure,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 110,
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isAgreed,
                                onChanged: (value) {
                                  setState(() {
                                    isAgreed = value ?? false;
                                  });
                                },
                              ),
                              Text(
                                'I agree to the',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 110,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/terms&condition');
                            },
                            child: Text(
                              'Terms and Conditions',
                              style: TextStyle(
                                color: AppColors.color9,
                                fontSize:
                                    MediaQuery.of(context).size.width / 110,
                              ),
                            ),
                          ).moveUpOnHover.showCursorOnHover,
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 11022,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 17,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            backgroundColor: AppColors.color9,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width / 10,
                              vertical: MediaQuery.of(context).size.height / 90,
                            ),
                          ),
                          onPressed: _validator,
                          child:
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 90,
                                  color: AppColors.color1,
                                ),
                              ).showCursorOnHover.moveUpOnHover,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 40),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('/landPage');
                        },
                        child:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.keyboard_arrow_left,
                                  size: MediaQuery.of(context).size.width / 60,
                                  color: AppColors.color9,
                                ),
                                Text(
                                  'Back to Land Page',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width / 90,
                                    color: AppColors.color9,
                                  ),
                                ),
                              ],
                            ).moveUpOnHover.showCursorOnHover,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validator() async {
    if (!mounted) return;

    String name = fullName.text.trim();
    String email = emailAdd.text.trim();
    String password = pwd.text.trim();
    String confirmPassword = confirmPwd.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showDialog('Empty Fields', 'Please fill in all required fields.');
      return;
    }

    if (!validatePassword(password)) {
      _showDialog(
        'Invalid Password',
        'Password must contain at least one uppercase, one lowercase letter, one number, one special character, and be 8-16 characters long.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showDialog('Password Mismatch', 'Passwords do not match.');
      return;
    }

    if (!isAgreed) {
      _showDialog(
        'Terms & Conditions',
        'Please Read Terms & Conditions.',
      );
      return;
    }

    await _registerUser(name, email, password);
  }

  Future<void> _registerUser(String name, String email, String password) async {
    try {
      // Step 1: Check if email already exists in Firestore
      QuerySnapshot existingUser =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email_Address', isEqualTo: email)
              .get();

      if (existingUser.docs.isNotEmpty) {
        _showDialog('Email Already Exists', 'Please use a different email.');
        _clearFields();
        return;
      }

      // Step 2: Create user in Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 3: Get the current max user_id
      QuerySnapshot userIdSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .orderBy('id', descending: true)
              .limit(1)
              .get();

      int nextUserId = 1;
      if (userIdSnapshot.docs.isNotEmpty) {
        final lastUserData =
            userIdSnapshot.docs.first.data() as Map<String, dynamic>;
        if (lastUserData.containsKey('id')) {
          nextUserId = (lastUserData['id'] as int) + 1;
        }
      }

      // Step 4: Save user to Firestore with new user_id
      await FirebaseFirestore.instance.collection('users').add({
        'id': nextUserId,
        'full_name': name,
        'email_Address': email,
        'accountType': 'Customer',
        'status': 'pending',
        'created_at': Timestamp.now(),
      });

      _showDialog(
        'Registration Successful',
        'Your account has been created and is pending approval.',
      );
      _clearFields();
    } catch (e) {
      String errorMessage;

      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? 'An unknown authentication error occurred.';
      } else {
        errorMessage = e.toString();
      }

      _showDialog('Registration Error', errorMessage);
    }
  }

  // This is will show the dialog
  void _showDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8.0,
          child: Container(
            width: MediaQuery.of(context).size.width / 3,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF5F9FF)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF0e2643),
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: "SB",
                        color: Color(0xFF0e2643),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 7,
                      height: MediaQuery.of(context).size.width / 35,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width / 170,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "OK",
                          style: TextStyle(
                            fontFamily: "R",
                            fontSize: MediaQuery.of(context).size.width / 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
