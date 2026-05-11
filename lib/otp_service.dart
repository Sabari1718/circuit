import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {

  static const String authToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLTgzNkRCNzBCNTU4NzQ5MyIsImlhdCI6MTc3MzA0NzU5OSwiZXhwIjoxOTMwNzI3NTk5fQ.pgnC_7IQgwfh3QGRuu4APflRX9VCpt_RQNR-QX1SP425KXn4PUmAohdQTWtEWhDx7Z9lOVfAevCVHCed4uemew";


  static const String customerId = "C-836DB70B5587493";
  static const String baseUrl =
      "https://cpaas.messagecentral.com/verification/v3";

  Future<Map<String, dynamic>> sendOtp({
    required String mobileNumber,
    String countryCode = "91",
    String flowType = "SMS",
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/send"
            "?countryCode=$countryCode"
            "&customerId=$customerId"
            "&flowType=$flowType"
            "&mobileNumber=$mobileNumber",
      );

      final response = await http.post(
        uri,
        headers: {
          "authToken": authToken,
          "accept": "application/json",
        },
      );

      print("====================================");
      print("SEND OTP URL: $uri");
      print("SEND OTP STATUS: ${response.statusCode}");
      print("SEND OTP BODY: ${response.body}");
      print("====================================");

      if (response.statusCode == 401) {
        return {
          "success": false,
          "message":
          "401 Unauthorized - authToken invalid/expired or customerId mismatch",
        };
      }

      if (response.body.trim().isEmpty) {
        return {
          "success": false,
          "message": "Empty response from OTP server",
        };
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final isSuccess = response.statusCode == 200 &&
          (data["responseCode"] == 200 ||
              data["responseCode"]?.toString() == "200" ||
              data["message"]?.toString().toUpperCase() == "SUCCESS");

      if (isSuccess) {
        return {
          "success": true,
          "message": data["message"] ?? "OTP sent successfully",
          "verificationId": data["data"]?["verificationId"]?.toString() ?? "",
          "timeout": data["data"]?["timeout"]?.toString() ?? "60",
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to send OTP",
          "data": data,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Send OTP error: $e",
      };
    }
  }

  Future<Map<String, dynamic>> validateOtp({
    required String mobileNumber,
    required String verificationId,
    required String otp,
    String countryCode = "91",
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/validateOtp"
            "?countryCode=$countryCode"
            "&mobileNumber=$mobileNumber"
            "&verificationId=$verificationId"
            "&customerId=$customerId"
            "&code=$otp",
      );

      final response = await http.get(
        uri,
        headers: {
          "authToken": authToken,
          "accept": "application/json",
        },
      );

      print("====================================");
      print("VALIDATE OTP URL: $uri");
      print("VALIDATE OTP STATUS: ${response.statusCode}");
      print("VALIDATE OTP BODY: ${response.body}");
      print("====================================");

      if (response.statusCode == 401) {
        return {
          "success": false,
          "message":
          "401 Unauthorized - authToken invalid/expired or customerId mismatch",
        };
      }

      if (response.body.trim().isEmpty) {
        return {
          "success": false,
          "message": "Empty response from OTP server",
        };
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final isSuccess = response.statusCode == 200 &&
          (data["responseCode"] == 200 ||
              data["responseCode"]?.toString() == "200" ||
              data["message"]?.toString().toUpperCase() == "SUCCESS");

      if (isSuccess) {
        return {
          "success": true,
          "message": data["message"] ?? "OTP verified successfully",
          "data": data,
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Invalid OTP",
          "data": data,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Validate OTP error: $e",
      };
    }
  }
}