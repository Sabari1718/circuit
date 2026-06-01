import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';
import 'auth_service.dart';

class StabService {
  static final StabService _instance = StabService._internal();

  factory StabService() => _instance;

  StabService._internal();

  static int savedCorrectAnswer = 0;
  static int savedAuthId = 0;
  static int savedSessionCode = 0;
  static List<int> savedOptions = [];
  static int savedSelectedNumber = 0;
  static String savedOperation = '';

  static const String _endpoint =
      "https://user.jobes24x7.com/api/generate-auth";

  static const String _saveEndpoint =
      "https://user.jobes24x7.com/api/save-auth-config";

  static const String _baseUrl =
      "https://user.jobes24x7.com/api";

  static void clearSession() {
    savedCorrectAnswer = 0;
    savedAuthId = 0;
    savedSessionCode = 0;
    savedOptions = [];
    savedSelectedNumber = 0;
    savedOperation = '';
  }



  Future<Map<String, String>> getHeaders() async {
    final token = await   AuthService().getValidToken();

    if (token == null || token.isEmpty) {
      throw Exception("No valid token found");
    }

    return {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
  }

  Future<dynamic> generateAuth() async {
    try {
      final response = await http.get(
        Uri.parse(_endpoint),
        headers: await getHeaders(),
      );

      print("Status : ${response.statusCode}");
      print("Response : ${response.body}");

      final data = jsonDecode(response.body);

      savedAuthId = data["auth_id"] ?? 0;
      savedSessionCode = data["session_code"] ?? 0;
      savedOptions = List<int>.from(data["options"] ?? []);

      return data;
    } catch (e) {
      print("Generate Error : $e");
      rethrow;
    }
  }

  Future<dynamic> saveConfiguration({
    required int authId,
    required int selectedNumber,
    required String operation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_saveEndpoint),
        headers: await getHeaders(),
        body: jsonEncode({
          "auth_id": authId,
          "selected_number": selectedNumber,
          "operation": operation,
        }),
      );

      print("Save Status : ${response.statusCode}");
      print("Save Response : ${response.body}");

      final data = jsonDecode(response.body);

      savedCorrectAnswer = data["correct_answer"] ?? 0;
      savedSelectedNumber = selectedNumber;
      savedOperation = operation;

      print("Saved Correct Answer : $savedCorrectAnswer");

      return data;
    } catch (e) {
      print("Save Error : $e");
      rethrow;
    }
  }

  Future<dynamic> getVerificationOptions(int authId) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/get-auth-options/$authId"),
        headers: await getHeaders(),
      );

      print("Verify Status : ${response.statusCode}");
      print("Verify Response : ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Verify Error : $e");
      rethrow;
    }
  }

  Future<dynamic> verifyOption({
    required int authId,
    required int clickedOption,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/verify-option"),
        headers: await getHeaders(),
        body: jsonEncode({
          "auth_id": authId,
          "clicked_option": clickedOption,
        }),
      );

      print("Verify Option Status : ${response.statusCode}");
      print("Verify Option Response : ${response.body}");

      final data = jsonDecode(response.body);
      if (data["result"] == "Failure") {
        clearSession();
      }
      return data;
    } catch (e) {
      print("Verify Option Error : $e");
      rethrow;
    }
  }

  Future<dynamic> verifyAuth({
    required int authId,
    required int selectedAnswer,
    required int selectedNumber,
    required String selectedOperation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/verify-auth"),
        headers: await getHeaders(),
        body: jsonEncode({
          "auth_id": authId,
          "selected_answer": selectedAnswer,
          "selected_number": selectedNumber,
          "selected_operation": selectedOperation,
        }),
      );

      print("Verify Auth Status : ${response.statusCode}");
      print("Verify Auth Response : ${response.body}");

      final data = jsonDecode(response.body);
      if (data["result"] == "Failure") {
        clearSession();
      }
      return data;
    } catch (e) {
      print("Verify Auth Error : $e");
      rethrow;
    }
  }
}