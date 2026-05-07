import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Session Keys (Current Login State)
  static const String keyName = 'user_name';
  static const String keyEmail = 'user_email';
  static const String keyPhone = 'user_phone';
  static const String keyAddress = 'user_address';
  static const String keyAccountType = 'user_account_type';
  static const String keyUserId = 'user_id';
  static const String keyProfilePhoto = 'user_profile_photo_base64';
  static const String keyIsLoggedIn = 'is_logged_in';

  // 🔥 MULTI-USER STORAGE KEY
  static const String keyRegisteredUsers = 'registered_users';

  // XAMPP Backend URL
  static const String backendBaseUrl = 'http://192.168.1.35/smt_mail';

  Uint8List? _profilePhotoBytes;
  Uint8List? get profilePhotoBytes => _profilePhotoBytes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ===========================================================================
  // 🔥 MULTI-USER LOCAL STORAGE METHODS
  // ===========================================================================

  Future<Map<String, dynamic>> _getUsersMap() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(keyRegisteredUsers);
    if (usersJson == null || usersJson.isEmpty) return {};
    try {
      return jsonDecode(usersJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveUsersMap(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyRegisteredUsers, jsonEncode(users));
  }

  // 🔥 UPDATED: Checks both mobile and email
  Future<bool> checkUserExists(String input) async {
    final users = await _getUsersMap();
    return users.containsKey(input);
  }

  Future<bool> checkUserExistsByMobile(String mobile) async {
    final users = await _getUsersMap();
    return users.containsKey(mobile);
  }

  Future<bool> checkUserExistsByEmail(String email) async {
    final users = await _getUsersMap();
    return users.containsKey(email);
  }

  // 🔥 UPDATED: Search by generic input (mobile or email)
  Future<Map<String, dynamic>?> getUserByInput(String input) async {
    final users = await _getUsersMap();
    if (users.containsKey(input)) {
      return users[input] as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    final users = await _getUsersMap();
    if (users.containsKey(mobile)) {
      return users[mobile] as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final users = await _getUsersMap();
    if (users.containsKey(email)) {
      return users[email] as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveRegisteredUser({
    required String mobile,
    required String email,
    required String password,
    required String pin,
  }) async {
    final users = await _getUsersMap();

    final userData = {
      'mobile': mobile,
      'email': email,
      'password': password,
      'pin': pin,
      'isRegistered': true,
    };

    // Store by both mobile and email for quick lookup
    if (mobile.isNotEmpty) users[mobile] = userData;
    if (email.isNotEmpty) users[email] = userData;

    await _saveUsersMap(users);
    debugPrint("USER SAVED LOCALLY => Mobile: $mobile, Email: $email");
  }

  Future<bool> loginWithPassword({
    required String input, // mobile or email
    required String password,
  }) async {
    final users = await _getUsersMap();
    if (users.containsKey(input)) {
      final userData = users[input] as Map<String, dynamic>;
      if (userData['password'] == password) {
        // Successful login, set session
        await saveUserData(
          phone: userData['mobile'],
          email: userData['email'],
          isLoggedIn: true,
        );
        return true;
      }
    }
    return false;
  }

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

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
    String name = user['name']?.toString() ?? user['fullName']?.toString() ?? 'User';
    String email = user['email']?.toString() ?? user['emailId']?.toString() ?? '';
    String phone = user['phone']?.toString() ?? user['mobile']?.toString() ?? '';
    String address = user['address']?.toString() ?? '';
    String accountType = user['accountType']?.toString() ?? 'GUEST';
    String userId = user['id']?.toString() ?? '';

    await saveUserData(
      name: name,
      email: email,
      phone: phone,
      address: address,
      accountType: accountType,
      userId: userId,
      isLoggedIn: true,
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
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['registered'] == true;
      }
      return false;
    } catch (e) {
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
      'name': prefs.getString(keyName) ?? '',
      'email': prefs.getString(keyEmail) ?? '',
      'phone': prefs.getString(keyPhone) ?? '',
      'address': prefs.getString(keyAddress) ?? '',
      'accountType': prefs.getString(keyAccountType) ?? '',
      'userId': prefs.getString(keyUserId) ?? '',
    };
  }

  Future<void> logout(BuildContext context) async {
    debugPrint("LOGOUT CALLED => Clearing session only");
    final prefs = await SharedPreferences.getInstance();



    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyUserId);
    await prefs.remove(keyName);
    await prefs.remove(keyEmail);
    await prefs.remove(keyPhone);
    await prefs.remove(keyAddress);
    await prefs.remove(keyAccountType);
    await prefs.remove(keyProfilePhoto);

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