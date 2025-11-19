import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addRedFlag({
    required String userId,
    required String reason,
    BuildContext? context, // optional
    String? reportedBy,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final snapshot = await userRef.get();

      int redFlagCount = (snapshot.data()?['redFlagCount'] ?? 0) + 1;

      // 🔹 Step 1: Update the user's flag data
      await userRef.set({
        'redFlagCount': redFlagCount,
        'accountStatus': redFlagCount >= 3 ? 'Under Review' : 'Active',
        'lastFlaggedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 🔹 Step 2: Append to red flag history
      await userRef.update({
        'redFlagHistory': FieldValue.arrayUnion([
          {
            'reason': reason,
            'timestamp': Timestamp.now(),
            'reportedBy': reportedBy ?? FirebaseAuth.instance.currentUser?.uid,
          }
        ]),
      });

      // 🔹 Step 3: Show UI feedback safely
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "🚩 Red flag added "
              "(${redFlagCount >= 3 ? "Account under review" : "Level $redFlagCount"})",
            ),
            backgroundColor:
                redFlagCount >= 3 ? Colors.redAccent : Colors.orangeAccent,
          ),
        );
      } else {
        debugPrint(
          "Red flag added for $userId "
          "(${redFlagCount >= 3 ? "Account under review" : "Level $redFlagCount"})",
        );
      }
    } catch (e) {
      debugPrint("Red flag error: $e");

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding red flag: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        debugPrint("Error adding red flag (no context): $e");
      }
    }
  }
}
