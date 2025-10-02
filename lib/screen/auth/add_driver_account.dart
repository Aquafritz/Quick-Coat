import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverSignUpDialog {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Register Driver",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill in all fields")),
                  );
                  return;
                }

                try {
                  // 🔹 Create FirebaseAuth user
                  UserCredential userCredential =
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  String uid = userCredential.user!.uid;

                  // 🔹 Save user info into Firestore
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .set({
                    "uid": uid,
                    "email": email,
                    "accountType": "Driver", // default role
                    "createdAt": FieldValue.serverTimestamp(),
                  });

                  Navigator.of(ctx).pop(); // close dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Driver registered successfully!")),
                  );
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.message}")),
                  );
                }
              },
              child: const Text("Sign Up"),
            ),
          ],
        );
      },
    );
  }
}
