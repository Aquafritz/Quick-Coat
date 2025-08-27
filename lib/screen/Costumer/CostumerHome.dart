import 'package:flutter/material.dart';
import 'package:quickcoat/screen/Costumer/sections/products.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';

class CostumerHome extends StatelessWidget {
  const CostumerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderWithout(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Products()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}