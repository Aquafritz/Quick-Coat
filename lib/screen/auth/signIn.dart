import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickcoat/animations/animatedTextField.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/animations/hover_extensions.dart';
import 'package:quickcoat/screen/landing/product_list_view.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailAdd = TextEditingController();
  TextEditingController pwd = TextEditingController();
  bool isObscure = true;
  Icon icon = Icon(Icons.visibility_off_outlined);

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
              'Sign In to your account',
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
                  'Or',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 90,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width / 100),
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/signUp');
                  },
                  child:
                      Text(
                        'Create a new account',
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
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 90,
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
                      Text(
                        'Password',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 90,
                        ),
                      ),
                      AnimatedTextField(
                        controller: pwd,
                        label: null,
                        suffix:
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isObscure = !isObscure;
                                  icon =
                                      isObscure
                                          ? Icon(Icons.visibility_off_outlined)
                                          : Icon(Icons.visibility_outlined);
                                });
                              },
                              child: icon,
                            ).showCursorOnHover.moveUpOnHover,
                        readOnly: false,
                        obscureText: isObscure,
                        prefix: Icon(Icons.lock_outline),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 90),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(value: false, onChanged: null),
                              Text('Remember Me'),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/forgotPassword');
                            },
                            child: Text(
                              'Forgot Password?',
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
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 16,
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
                          onPressed: _checkEmailandPasswords,
                          child:
                              Text(
                                'Sign In',
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

  void _checkEmailandPasswords() {
  String input = emailAdd.text.trim();
  String password = pwd.text.trim();

  if (password.isEmpty || input.isEmpty) {
    _showDialog('Empty Fields', 'Please fill in both fields.');
    return;
  }

  RegExp passwordRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_-]).{8,}$',
  );

  if (!passwordRegex.hasMatch(password)) {
    _showDialog('Weak Password',
        'Password must contain at least 8 characters, including uppercase letters, lowercase letters, numbers, and symbols.');
    return;
  }

  RegExp emailRegex = RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]");

  if (emailRegex.hasMatch(input)) {
    _signInWithEmail(input, password);
  } else {
    _showDialog('Invalid Input', 'Please enter a valid email address.');
  }
}

Future<void> _signInWithEmail(String email, String password) async {
  try {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      final QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email_Address', isEqualTo: email)
          .get();

      if (userDocs.docs.isNotEmpty) {
        final userData = userDocs.docs.first.data() as Map<String, dynamic>?;

        final accountType = userData?['accountType'];

        switch (accountType) {
          case 'Admin':
            Get.toNamed('/adminHome');
            break;

          case 'Driver':
            Get.toNamed('/driverHome');
            break;

          case 'Customer':
           Get.toNamed('/costumerHome');
            break;

          default:
            _showDialog('Login Failed', 'Unrecognized account type.');
        }
      } else {
        _showDialog('User Not Found', 'User document not found.');
      }

    }
  } catch (error) {
    String errorMessage = 'An error occurred. Please try again later.';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid password.';
          break;
        default:
          errorMessage = 'Authentication error: ${error.message}';
      }
    } else {
      errorMessage = 'Unexpected error: ${error.toString()}';
    }
    _showDialog('Login Failed', errorMessage);
  }
}

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void _loadRememberMe() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _rememberMe = prefs.getBool('rememberMe') ?? false;
  //   });
  //   if (_rememberMe) {
  //     List<String>? rememberedEmails = prefs.getStringList('rememberedEmails');
  //     if (rememberedEmails != null && rememberedEmails.isNotEmpty) {
  //       _emailController.text = rememberedEmails.last;
  //     }
  //   }
  // }

  // void _saveRememberMe(bool value, [String? email]) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   _rememberMe = value;
  //   if (_rememberMe) {
  //     List<String> rememberedEmails =
  //         prefs.getStringList('rememberedEmails') ?? [];
  //     if (!rememberedEmails.contains(email)) {
  //       rememberedEmails.add(email!);
  //       prefs.setStringList('rememberedEmails', rememberedEmails);
  //     }
  //   } else {
  //     prefs.remove('rememberedEmails');
  //   }
  //   prefs.setBool('rememberMe', _rememberMe);
  // }
}
