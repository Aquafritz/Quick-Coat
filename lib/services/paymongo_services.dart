import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PayMongoService {
  final String backendUrl = "http://localhost:4242"; // change when deployed
  final String publicKey = "pk_test_M7ZvDMreAqunfphwWYctVYUe";

  Future<void> payWithPayMongo({
    required double amount,
    required String paymentType,
    required String name,
    required String email,
    required String phone,
    String? cardNumber,
    String? expMonth,
    String? expYear,
    String? cvc,
  }) async {
    try {
      // 1️⃣ Create PaymentIntent
      final intentResponse = await http.post(
        Uri.parse("$backendUrl/create-payment-intent"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "amount": amount.toInt(),
          "description": "QuickCoat Raincoat Order",
        }),
      );

      if (intentResponse.statusCode != 200) {
        throw Exception(
          "Failed to create PaymentIntent: ${intentResponse.body}",
        );
      }

      final intentData = jsonDecode(intentResponse.body);
      final paymentIntentId = intentData["data"]["id"];

      // 2️⃣ Build method attributes
      final paymentTypeMap = {
        "Credit/Debit Card": "card",
        "GCash": "gcash",
        "PayMaya": "paymaya",
        "GrabPay": "grab_pay",
      };
      final resolvedType = paymentTypeMap[paymentType] ?? paymentType;

      Map<String, dynamic> methodAttributes = {
        "type": resolvedType,
        "billing": {"name": name, "email": email, "phone": phone},
      };

      // 3️⃣ Add card details if it's a card payment
      if (resolvedType == "card") {
        methodAttributes["details"] = {
          "card_number": cardNumber?.trim().replaceAll(' ', '') ?? '',
          "exp_month": int.tryParse(expMonth?.trim() ?? '') ?? 0,
          "exp_year": _normalizeYear(expYear?.trim() ?? ''),
          "cvc": cvc?.trim() ?? '',
        };
      }

      // 4️⃣ Create PaymentMethod
      final methodResponse = await http.post(
        Uri.parse("https://api.paymongo.com/v1/payment_methods"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic ${base64Encode(utf8.encode('$publicKey:'))}",
        },
        body: jsonEncode({
          "data": {"attributes": methodAttributes},
        }),
      );

      if (methodResponse.statusCode != 200) {
        throw Exception(
          "Failed to create PaymentMethod: ${methodResponse.body}",
        );
      }

      final methodData = jsonDecode(methodResponse.body);
      final paymentMethodId = methodData["data"]["id"];

      // 5️⃣ Attach method to intent
      final attachResponse = await http.post(
        Uri.parse("$backendUrl/attach-payment"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "paymentIntentId": paymentIntentId,
          "paymentMethodId": paymentMethodId,
        }),
      );

      if (attachResponse.statusCode != 200) {
        throw Exception(
          "Failed to attach PaymentMethod: ${attachResponse.body}",
        );
      }

      final attachData = jsonDecode(attachResponse.body);

      // 6️⃣ Handle redirects or success
      if (resolvedType == "card") {
        final status = attachData["data"]["attributes"]["status"];
        if (status == "succeeded") {
          print("✅ Card Payment Successful!");
        } else {
          final redirectUrl =
              attachData["data"]["attributes"]["next_action"]?["redirect"]?["url"];
          if (redirectUrl != null) {
            await launchUrl(
              Uri.parse(redirectUrl),
              mode: LaunchMode.externalApplication,
            );
          }
        }
      } else {
        final checkoutUrl =
            attachData["data"]["attributes"]["next_action"]["redirect"]["url"];
        await launchUrl(
          Uri.parse(checkoutUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print("❌ PayMongo Error: $e");
      rethrow;
    }
  }

  int _normalizeYear(String yearInput) {
    if (yearInput.length == 2) {
      final now = DateTime.now();
      final century = now.year ~/ 100;
      final twoDigit = int.tryParse(yearInput) ?? (now.year % 100);
      return (twoDigit < (now.year % 100))
          ? (century + 1) * 100 + twoDigit
          : century * 100 + twoDigit;
    }
    return int.tryParse(yearInput) ?? DateTime.now().year;
  }
}
