import 'package:flutter/material.dart';
import 'Sidebar.dart'; // make sure path is correct

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.black,
      ),
      body: const Center(child: Text("Welcome to Admin Home")),
    );
  }
}
