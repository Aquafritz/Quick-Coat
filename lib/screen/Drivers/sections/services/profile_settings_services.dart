import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileSettingsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 🔹 Save user profile data to Firestore
  Future<void> saveUserProfile({
    required String name,
    required String phone,
    String? profileUrl, // optional
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    await _firestore.collection("users").doc(user.uid).set({
      "full_name": name,
      "phone_number": phone,
      if (profileUrl != null) "profile_picture": profileUrl,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Fetch user profile data from Firestore
  /// 🔹 Fetch user profile data from Firestore
Future<Map<String, dynamic>?> fetchUserProfile() async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("No user logged in");

  final doc = await _firestore.collection("users").doc(user.uid).get();
  final data = doc.data() ?? {};

  // Always include email from FirebaseAuth (not editable)
  data["email"] = user.email;

  return data;
}


  /// 🔹 Upload profile picture to Supabase (QuickCoat/profile_pictures)
  Future<String> uploadProfilePicture(File file) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final fileName =
        "profile_pictures/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final res = await _supabase.storage.from("QuickCoat").upload(fileName, file);

    if (res.isEmpty) {
      throw Exception("Failed to upload profile picture");
    }

    // Get public URL from Supabase
    final publicUrl = _supabase.storage.from("QuickCoat").getPublicUrl(fileName);

    return publicUrl;
  }

  Future<String> uploadWebProfilePicture(Uint8List fileBytes) async {
  final user = _auth.currentUser;
  if (user == null) throw Exception("No user logged in");

  final fileName =
      "profile_pictures/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

  final res = await _supabase.storage.from("QuickCoat").uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(contentType: "image/jpeg"),
      );

  if (res.isEmpty) {
    throw Exception("Failed to upload profile picture");
  }

  // Get public URL
  return _supabase.storage.from("QuickCoat").getPublicUrl(fileName);
}

}