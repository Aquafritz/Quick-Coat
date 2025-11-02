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
    required String barangay,
    required String houseNumber,
    required String city,
    required String province,
    required String birthday,
    required String gender,
    String? profileUrl, // optional
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    // 🔹 Convert readable string (like "October 5, 2025") to DateTime → Timestamp
   Timestamp? birthdayTimestamp;
if (birthday.isNotEmpty) {
  try {
    // Parse "Month Day, Year" like "October 5, 2025"
    final parts = birthday.split(' ');
    if (parts.length == 3) {
      final monthMap = {
        "January": 1,
        "February": 2,
        "March": 3,
        "April": 4,
        "May": 5,
        "June": 6,
        "July": 7,
        "August": 8,
        "September": 9,
        "October": 10,
        "November": 11,
        "December": 12,
      };
      final month = monthMap[parts[0]];
      final day = int.parse(parts[1].replaceAll(',', ''));
      final year = int.parse(parts[2]);

      // ✅ Create a date-only timestamp (midnight UTC)
      final parsedDate = DateTime.utc(year, month!, day);
      birthdayTimestamp = Timestamp.fromDate(parsedDate);
    }
  } catch (e) {
    print("❌ Error parsing birthday: $e");
  }
}


    await _firestore.collection("users").doc(user.uid).set({
      "full_name": name,
      "phone_number": phone,
      "house_number": houseNumber,
      "city": city,
      "province": province,
      if (birthdayTimestamp != null) "birthday": birthdayTimestamp,
      "gender": gender,
      "barangay": barangay,
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

    final res = await _supabase.storage
        .from("QuickCoat")
        .upload(fileName, file);

    if (res.isEmpty) {
      throw Exception("Failed to upload profile picture");
    }

    // Get public URL from Supabase
    final publicUrl = _supabase.storage
        .from("QuickCoat")
        .getPublicUrl(fileName);

    return publicUrl;
  }

  Future<String> uploadWebProfilePicture(Uint8List fileBytes) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No user logged in");

    final fileName =
        "profile_pictures/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final res = await _supabase.storage
        .from("QuickCoat")
        .uploadBinary(
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
