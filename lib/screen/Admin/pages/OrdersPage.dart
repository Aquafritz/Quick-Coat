import 'package:flutter/material.dart';
import 'package:quickcoat/screen/Admin/top_bar.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TopBar(),
          ],
        ),
      ),
      );
  }
}
