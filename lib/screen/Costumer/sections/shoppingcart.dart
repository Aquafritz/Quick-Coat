import 'package:flutter/material.dart';
import 'package:quickcoat/screen/header&footer/headerwithoutsignin.dart';

class ShoppingCart extends StatelessWidget {
  const ShoppingCart({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeaderWithout(),
            Column(
              children: [
                Text('Shopping Cart')
              ],
            )
          ]
        )
      )
    );
  }
}