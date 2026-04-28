import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'http://192.168.1.35/smt_mail';
  static const String messageCentralBaseUrl = 'https://cpaas.messagecentral.com/verification/v3';
  static const String authToken = 'YOUR_AUTH_TOKEN'; // Replace with actual token
  static const String customerId = 'YOUR_CUSTOMER_ID'; // Replace with actual ID

  // --- Session Management (from UserService) ---

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  Future<void> saveUserData(String name, String email, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'phone': prefs.getString('phone') ?? '',
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> setRegistrationIncomplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('registrationIncomplete', value);
  }

  Future<bool> isRegistrationIncomplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('registrationIncomplete') ?? false;
  }

  Future<void> clearRegistrationIncomplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('registrationIncomplete');
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Check all possible keys used across the app for consistency
    return prefs.getString('auth_token') ?? 
           prefs.getString('token') ?? 
           prefs.getString('authToken') ?? 
           prefs.getString('access_token');
  }

  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('token', token);
    await prefs.setString('authToken', token);
    await prefs.setString('access_token', token);
  }

  // --- Phone OTP Service (from OtpService) ---

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    final url = Uri.parse('$messageCentralBaseUrl/sendOtp?countryCode=91&mobileNumber=$mobileNumber&customerId=$customerId');
    try {
      final response = await http.post(url, headers: {'authToken': authToken});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> validateOtp(String mobileNumber, String otpCode, String verificationId) async {
    final url = Uri.parse('$messageCentralBaseUrl/validateOtp?countryCode=91&mobileNumber=$mobileNumber&verificationId=$verificationId&code=$otpCode&customerId=$customerId');
    try {
      final response = await http.get(url, headers: {'authToken': authToken});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Email OTP Service (from EmailService) ---

  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    final url = Uri.parse('$baseUrl/send_otp.php');
    try {
      final response = await http.post(url, body: {'email': email});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> validateEmailOtp(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verify_otp.php');
    try {
      final response = await http.post(url, body: {'email': email, 'otp': otp});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  // --- Backend User Registration (Secondary API) ---

  Future<Map<String, dynamic>> loginBackend(String phone) async {
    final url = Uri.parse('$baseUrl/login.php');
    try {
      final response = await http.post(url, body: {'phone': phone});
      return json.decode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
