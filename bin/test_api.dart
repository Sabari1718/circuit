import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final uid = '9508383027'; // User ID often used in logs
  print('Testing for user: $uid');

  print('\n1. Checking Register Details...');
  try {
    final regRes = await http.get(Uri.parse('https://managelogin.jobes24x7.com/api/user_register/main/$uid'));
    print('Status: ${regRes.statusCode}');
    print('Body: ${regRes.body}');
  } catch(e) {
    print('Error: $e');
  }

  print('\n2. Checking Verification Details...');
  try {
    final verRes = await http.get(Uri.parse('https://managelogin.jobes24x7.com/api/api/verified-user/$uid'));
    print('Status: ${verRes.statusCode}');
    print('Body: ${verRes.body}');
  } catch(e) {
    print('Error: $e');
  }
}
