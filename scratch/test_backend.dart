import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final now = DateTime.now().millisecondsSinceEpoch;
  final email = 'test$now@test.com';
  final phone = '9999$now'.substring(0, 10);
  
  final registerUrl = 'https://user.jobes24x7.com/api/login/create';
  final registerBody = {
    'phone_number': phone,
    'email': email,
    'password': 'Password@123',
    'address': 'Test Address',
    'user_name': 'Test User',
    'created_by': 'Test User',
    'attempt_count': 2,
    'email_otp': true,
    'mobile_otp': true,
    'is_verified': 1,
    'last_attempt': 9,
    'otp': 4449,
    'status': 1,
    'user_main_id': null,
    'user_type': 'guest',
    'pin': '123456',
    'captcha': 'assets/captcha/dog.jpg',
  };

  print("Registering $email");
  final regRes = await http.post(Uri.parse(registerUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode(registerBody));
  print("Register response: ${regRes.body}");

  final loginUrl = 'https://user.jobes24x7.com/api/login/authenticate';
  final loginBody = {
    'email': email,
    'password': 'Password@123'
  };
  print("Logging in $email");
  final loginRes = await http.post(Uri.parse(loginUrl), headers: {'Content-Type': 'application/json'}, body: jsonEncode(loginBody));
  print("Login response: ${loginRes.body}");
}
