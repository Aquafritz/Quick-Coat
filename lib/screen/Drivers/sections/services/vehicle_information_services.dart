import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleInformationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> fetchVehicleInformation() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection("users").doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null &&
            (data.containsKey("vehicle_type") ||
             data.containsKey("vehicle_model") ||
             data.containsKey("vehicle_color") ||
             data.containsKey("plate_number"))) {
          return {
            "vehicle_type": data["vehicle_type"],
            "vehicle_model": data["vehicle_model"],
            "vehicle_color": data["vehicle_color"],
            "plate_number": data["plate_number"],
          };
        }
      }
      return null;
    } catch (e) {
      print("Error fetching vehicle information: $e");
      return null;
    }
  }

  Future<void> saveVehicleInformation({
    required String vehicleType,
    required String vehicleModel,
    required String vehicleColor,
    required String plateNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection("users").doc(user.uid).set({
        "vehicle_type": vehicleType,
        "vehicle_model": vehicleModel,
        "vehicle_color": vehicleColor,
        "plate_number": plateNumber,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving vehicle information: $e");
    }
  }
}