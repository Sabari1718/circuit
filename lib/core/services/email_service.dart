import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // ✅ WORKING LIVE API
  static const String sendOtpUrl = 'https://user.jobes24x7.com/api/send-otp';
  static const String verifyOtpUrl = 'https://user.jobes24x7.com/api/verify-otp';

  // ✅ Resend can use same send OTP API
  static const String resendOtpUrl = 'https://user.jobes24x7.com/api/send-otp';

  Future<Map<String, dynamic>> sendEmailOtp({
    required String email,
  }) async {
    try {
      final uri = Uri.parse(sendOtpUrl);

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
      );

      print("====================================");
      print("EMAIL SEND OTP URL: $uri");
      print("EMAIL SEND OTP STATUS: ${response.statusCode}");
      print("EMAIL SEND OTP BODY: ${response.body}");
      print("====================================");

      if (response.body.trim().isEmpty) {
        return {
          "success": false,
          "message": "Empty response from email server",
        };
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return {
        "success": (data["success"] == true || data["status"] == true),
        "message": data["message"] ?? "Failed to send email OTP",
      };
    } catch (e) {
      print("EMAIL SEND OTP ERROR: $e");
      return {
        "success": false,
        "message": "Send email OTP error: $e",
      };
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final uri = Uri.parse(verifyOtpUrl);

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email.trim(),
          'otp': otp.trim(),
        }),
      );

      print("====================================");
      print("EMAIL VERIFY OTP URL: $uri");
      print("EMAIL VERIFY OTP STATUS: ${response.statusCode}");
      print("EMAIL VERIFY OTP BODY: ${response.body}");
      print("====================================");

      if (response.body.trim().isEmpty) {
        return {
          "success": false,
          "message": "Empty response from email server",
        };
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return {
        "success": (data["success"] == true || data["status"] == true),
        "message": data["message"] ?? "Invalid Email OTP",
      };
    } catch (e) {
      print("EMAIL VERIFY OTP ERROR: $e");
      return {
        "success": false,
        "message": "Verify email OTP error: $e",
      };
    }
  }

  Future<Map<String, dynamic>> resendEmailOtp({
    required String email,
  }) async {
    try {
      final uri = Uri.parse(resendOtpUrl);

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
      );

      print("====================================");
      print("EMAIL RESEND OTP URL: $uri");
      print("EMAIL RESEND OTP STATUS: ${response.statusCode}");
      print("EMAIL RESEND OTP BODY: ${response.body}");
      print("====================================");

if (response.body.trim().isEmpty) {
return {
"success": false,
"message": "Empty response from email server",
};
}

final data = jsonDecode(response.body) as Map<String, dynamic>;

return {
"success": (data["success"] == true || data["status"] == true),
"message": data["message"] ?? "Failed to resend email OTP",
};
} catch (e) {
print("EMAIL RESEND OTP ERROR: $e");
return {
"success": false,
"message": "Resend email OTP error: $e",
};
}
}
}


