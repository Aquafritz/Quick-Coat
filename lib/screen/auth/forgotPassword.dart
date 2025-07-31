import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickcoat/animations/animatedTextField.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/features/hover_extensions.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isObscure = true;
  Icon icon = Icon(Icons.visibility_off);

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
            SizedBox(
              height: MediaQuery.of(context).size.height / 30
              ),
            Text(
              'Reset your Password',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 45, 
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 90
              ),
            Text(
              "Enter your email address and we'll send you a link to reset your password. ",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 90, 
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height / 2,
              child: Card(
                color: Colors.white,
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 90,
                        ),
                        ),
                      AnimatedTextField(
                        label: null, 
                        suffix: null, 
                        readOnly: false,
                        prefix: Icon(Icons.email_outlined),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 40,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.height / 16,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)
                            ),
                            backgroundColor: AppColors.color9,
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 10,
                              vertical: MediaQuery.of(context).size.height / 90,
                            ),
                          ),
                          onPressed: () {
                            // Handle sign in logic
                          },
                          child: Text('Send reset link', 
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 90,
                            color: AppColors.color1,
                            ),
                          ).showCursorOnHover.moveUpOnHover
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 40,),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed('/signIn');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_left,
                              size: MediaQuery.of(context).size.width / 60,
                              color: AppColors.color9,
                              ),
                            Text('Back to Sign In',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 90,
                              color: AppColors.color9
                            ),),
                          ],
                        ).moveUpOnHover.showCursorOnHover,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
