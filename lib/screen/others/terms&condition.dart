import 'package:flutter/material.dart';
import 'package:quickcoat/core/colors/app_colors.dart';
import 'package:quickcoat/screen/header&footer/footer.dart';
import 'package:quickcoat/screen/header&footer/header.dart';

class TermsandCondition extends StatelessWidget {
  const TermsandCondition({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: MediaQuery.of(context).size.width / 90, color: Colors.black87);
    final headingStyle = TextStyle(fontSize: MediaQuery.of(context).size.width / 70, fontWeight: FontWeight.bold,);

    return Scaffold(
      backgroundColor: AppColors.color1,
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white, 
            AppColors.color6, // little color at top
            AppColors.color11, // match second section start
          ],
          stops: [0.0, 0.4, 0.8],
        ),
      ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Header(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padded content
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width / 10,
                            MediaQuery.of(context).size.width / 60,
                            MediaQuery.of(context).size.width / 10,
                            MediaQuery.of(context).size.width / 60
                            ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Terms and Conditions", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,)),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.1,
                                  child: Card(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                         MediaQuery.of(context).size.width / 25,
                            MediaQuery.of(context).size.width / 40,
                            MediaQuery.of(context).size.width / 4,
                            MediaQuery.of(context).size.width / 40),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "1. Introduction",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "Welcome to Quick Coat, By accessing and using our website, you accept and agree to be bound by these terms and conditions. Please read them carefully before using our services",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "2. Definitions",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            '• "Website" refers to Quick Coat, accessible at www.quickcoat.web.app',
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            '• "User", "You", and "Your", refers to you, the person accessing this website',
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            '• "Company", "We", "Our", and "Us" refers to Quick Coat',
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            '• "Products" refers to the item available for purchase on our website',
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "3. Account Terms",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "To access certain feature of the website, you must register/signup for an account, You agree to:",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "• Provide accurate and complete information",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "• Maintain the security of your account and password",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                            Text(
                                            "• Accept responsibility for all activities under your account",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "• Notify us immediately of any security breaches",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          
                                          Text(
                                            "4. Products Terms",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "All products are subject to availability. We serve the right to:",
                                            style: textStyle,
                                          ),Text(
                                            "• Limit the quantity of products sold",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "• Discontinue any product at any time",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "• Change products prices without notices",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "• Refuse services to anyone",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text("5. Lorem Ipsum", style: headingStyle),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "6. Lorem Ipsum",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "7. Lorem Ipsum",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "8. Lorem Ipsum",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "9. Lorem Ipsum",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum",
                                            style: textStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "10. Lorem Ipsum",
                                            style: headingStyle,
                                          ),
                              SizedBox(height: MediaQuery.of(context).size.height / 90,),
                                          Text(
                                            "Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum Lorem Ipsum",
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
        
                        // Footer with no padding
                        Footer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
