import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/legacy_login_page.dart';
import 'login_page.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String keyName = 'user_name';
  static const String keyEmail = 'user_email';
  static const String keyPhone = 'user_phone';
  static const String keyAddress = 'user_address';
  static const String keyAccountType = 'user_account_type';
  static const String keyUserId = 'user_id';
  static const String keyProfilePhoto = 'user_profile_photo_base64';
  static const String keyIsLoggedIn = 'is_logged_in';

  // 🔥 Change this to your XAMPP server IP if testing on a real device
  static const String backendBaseUrl = 'http://192.168.1.35/smt_mail';

  Uint8List? _profilePhotoBytes;
  Uint8List? get profilePhotoBytes => _profilePhotoBytes;

  Future<void> saveUserData({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? accountType,
    String? userId,
    bool? isLoggedIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (name != null) await prefs.setString(keyName, name);
    if (email != null) await prefs.setString(keyEmail, email);
    if (phone != null) await prefs.setString(keyPhone, phone);
    if (address != null) await prefs.setString(keyAddress, address);
    if (accountType != null) await prefs.setString(keyAccountType, accountType);
    if (userId != null) await prefs.setString(keyUserId, userId);
    if (isLoggedIn != null) await prefs.setBool(keyIsLoggedIn, isLoggedIn);

    notifyListeners();
  }

  Future<void> saveFromApiUser(Map<String, dynamic> user) async {
    String name =
        user['name']?.toString() ??
            user['fullName']?.toString() ??
            user['username']?.toString() ??
            user['user_name']?.toString() ??
            'User';

    String email =
        user['email']?.toString() ??
            user['emailId']?.toString() ??
            user['mail']?.toString() ??
            'user@example.com';

    String phone =
        user['phone']?.toString() ??
            user['mobile']?.toString() ??
            user['mobileNumber']?.toString() ??
            user['phoneNumber']?.toString() ??
            'Not provided';

    String address =
        user['address']?.toString() ??
            user['location']?.toString() ??
            user['city']?.toString() ??
            'Not provided';

    String accountType =
        user['accountType']?.toString() ??
            user['userType']?.toString() ??
            user['role']?.toString() ??
            'GUEST';

    String userId =
        user['id']?.toString() ??
            user['userId']?.toString() ??
            user['userid']?.toString() ??
            '9508383027';

    await saveUserData(
      name: name,
      email: email,
      phone: phone,
      address: address,
      accountType: accountType,
      userId: userId,
    );
  }

  Future<void> updateProfilePhoto(Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    _profilePhotoBytes = bytes;

    final String base64String = base64Encode(bytes);
    await prefs.setString(keyProfilePhoto, base64String);

    notifyListeners();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? base64String = prefs.getString(keyProfilePhoto);

    if (base64String != null && base64String.isNotEmpty) {
      _profilePhotoBytes = base64Decode(base64String);
    }

    notifyListeners();
  }

  Future<bool> checkPhoneRegistration(String phone) async {
    try {
      final response = await http.get(
        Uri.parse('$backendBaseUrl/check_user.php?phone=$phone'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['registered'] == true;
      }
      return false;
    } catch (e) {
      debugPrint("Check Registration Error: $e");
      return false;
    }
  }

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString(keyName) ?? 'User',
      'email': prefs.getString(keyEmail) ?? 'user@example.com',
      'phone': prefs.getString(keyPhone) ?? 'Not provided',
      'address': prefs.getString(keyAddress) ?? 'Not provided',
      'accountType': prefs.getString(keyAccountType) ?? 'GUEST',
      'userId': prefs.getString(keyUserId) ?? '9508383027',
    };
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
    _profilePhotoBytes = null;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }
}