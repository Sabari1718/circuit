import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// ============================================================
/// AuthService  –  centralised JWT token lifecycle manager
/// ============================================================
///
/// Token lifecycle:
///   1. Login  → backend returns { token, expires_in, expiry }
///   2. Token + expiry timestamp saved to SharedPreferences
///   3. On every app launch / resume:
///        a. No token → Login page
///        b. Token exists → check saved expiry locally
///           • Age < 24 h  → Dashboard (no network call)
///           • Age ≥ 24 h  → clear token → Login page
///              (next login generates a fresh token)
/// ============================================================
class AuthService {
  // ──────────────────────────────────────────────
  // Singleton
  // ──────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ──────────────────────────────────────────────
  // SharedPreferences keys
  // ──────────────────────────────────────────────

  /// The JWT string itself.
  static const String keyAuthToken = 'auth_token';

  /// Unix-millisecond timestamp of when the token was issued (saved at login).
  static const String keyTokenIssuedAt = 'auth_token_issued_at';

  /// Raw expiry string returned by the server (e.g. "2026-05-26 10:30:00").
  /// Stored for debugging / display purposes only.
  static const String keyTokenExpiry = 'auth_token_expiry';

  // ──────────────────────────────────────────────
  // Endpoints
  // ──────────────────────────────────────────────

  /// Login endpoint.
  static const String loginUrl =
      'https://managelogin.jobes24x7.com/api/login/authenticate';

  // ──────────────────────────────────────────────
  // Token validity window
  // ──────────────────────────────────────────────

  /// Maximum age of a token before it is considered expired locally.
  static const Duration tokenValidity = Duration(hours: 24);

  // ──────────────────────────────────────────────
  // Route constants
  // ──────────────────────────────────────────────

  static const String resultDashboard = 'dashboard';
  static const String resultLogin = 'login';

  // ──────────────────────────────────────────────
  // Low-level storage helpers
  // ──────────────────────────────────────────────

  /// Save token + issue-time + optional server expiry string.
  Future<void> saveToken(String token, {String? serverExpiry}) async {
    final prefs = await SharedPreferences.getInstance();
    final int issuedAt = DateTime.now().millisecondsSinceEpoch;

    await prefs.setString(keyAuthToken, token);
    await prefs.setInt(keyTokenIssuedAt, issuedAt);
    if (serverExpiry != null && serverExpiry.isNotEmpty) {
      await prefs.setString(keyTokenExpiry, serverExpiry);
    }

    debugPrint(
      '[AuthService] Token saved. IssuedAt=$issuedAt'
      '  ServerExpiry=${serverExpiry ?? "N/A"}',
    );
  }

  /// Returns the stored token string, or null.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAuthToken);
  }

  /// Returns the DateTime when the token was issued, or null.
  Future<DateTime?> getTokenIssuedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final int? ms = prefs.getInt(keyTokenIssuedAt);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Wipe token + all related metadata from local storage.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyAuthToken);
    await prefs.remove(keyTokenIssuedAt);
    await prefs.remove(keyTokenExpiry);
    debugPrint('[AuthService] Token cleared.');
  }

  // ──────────────────────────────────────────────
  // Core: local 24-hour expiry check
  // ──────────────────────────────────────────────

  /// Called on every app launch / resume.
  ///
  /// Returns [resultDashboard] when a valid (< 24 h old) token exists.
  /// Returns [resultLogin] when there is no token or it has expired.
  ///
  /// ✅ NO network call is made here — expiry is checked entirely locally.
  ///    A new token is only generated when the user logs in again after expiry.
  Future<String> checkAuthOnStartup() async {
    final token = await getToken();

    // 1. No token stored at all
    if (token == null || token.trim().isEmpty) {
      debugPrint('[AuthService] No token → Login');
      return resultLogin;
    }

    // 2. Token exists — check local age
    final DateTime? issuedAt = await getTokenIssuedAt();

    if (issuedAt == null) {
      // Token exists but no issue-time (legacy / corrupted) → force re-login
      debugPrint('[AuthService] Token has no issue-time → clear + Login');
      await clearToken();
      return resultLogin;
    }

    final Duration age = DateTime.now().difference(issuedAt);
    debugPrint(
      '[AuthService] Token age: ${age.inHours}h ${age.inMinutes % 60}m',
    );

    if (age < tokenValidity) {
      // ✅ Still valid — go directly to Dashboard
      final int remaining = (tokenValidity - age).inMinutes;
      debugPrint(
        '[AuthService] Token valid ($remaining min remaining) → Dashboard',
      );
      return resultDashboard;
    } else {
      // ❌ Expired (≥ 24 h) — clear and force login
      debugPrint(
        '[AuthService] Token expired (${age.inHours}h old) → clear + Login',
      );
      await clearToken();
      return resultLogin;
    }
  }

  /// Returns true if the currently stored token is still within the 24-hour window.
  /// Useful for in-app guards (e.g. before making an API call).
  Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) return false;

    final DateTime? issuedAt = await getTokenIssuedAt();
    if (issuedAt == null) return false;

    return DateTime.now().difference(issuedAt) < tokenValidity;
  }

  /// How much time remains before the token expires.
  /// Returns Duration.zero if the token is already expired or absent.
  Future<Duration> tokenTimeRemaining() async {
    final DateTime? issuedAt = await getTokenIssuedAt();
    if (issuedAt == null) return Duration.zero;
    final Duration age = DateTime.now().difference(issuedAt);
    if (age >= tokenValidity) return Duration.zero;
    return tokenValidity - age;
  }

  // ──────────────────────────────────────────────
  // Login  (called from PasswordPage)
  // ──────────────────────────────────────────────

  /// Calls the login API, saves the returned token with issue-time,
  /// and returns the full decoded response.
  ///
  /// Expected successful response shape:
  /// ```json
  /// {
  ///   "token": "xxxxx",
  ///   "expires_in": 86400,
  ///   "expiry": "2026-05-26 10:30:00"
  /// }
  /// ```
  ///
  /// Throws [AuthException] on API or credential failure.
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    bool isPin = false,
    int? captchaImageId,
  }) async {
    final Map<String, dynamic> body = isPin ? {'pin': password} : {'password': password};
    if (identifier.contains('@')) {
      body['email'] = identifier;
    } else {
      body['phone_number'] = identifier;
    }
    if (captchaImageId != null) {
      body['captcha_image_id'] = captchaImageId;
    }

    debugPrint('[AuthService] LOGIN → $loginUrl  body: $body');

    final response = await http
        .post(
          Uri.parse(loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    debugPrint('[AuthService] Login status : ${response.statusCode}');
    debugPrint('[AuthService] Login body   : ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      bool success = false;

      if (data['code'] == 200 || data['result'] == 'Success' || data['result'] == 'success') {
        success = true;
      }
      if (data['data'] != null && data['data'] is Map) {
        if (data['data']['code'] == 200 || 
            data['data']['result'] == 'Success' || 
            data['data']['result'] == 'success') {
          success = true;
        }
      }

      if (success) {
        // ── Extract token ──────────────────────────────────────────────────
        final String? token =
            (data['data'] is Map ? data['data']['token']?.toString() : null) ??
            data['token']?.toString() ??
            data['access_token']?.toString() ??
            data['jwt']?.toString();

        // ── Extract server-provided expiry (optional, for logging) ─────────
        final String? serverExpiry =
            data['data']?['expires_at']?.toString() ??
            data['expires_at']?.toString() ??
            data['expiry']?.toString();

        if (token != null && token.isNotEmpty) {
          debugPrint('TOKEN => $token');

          // ✅ Save token + current timestamp as "issued at"
          await saveToken(token, serverExpiry: serverExpiry);

          debugPrint(
            '[AuthService] New token saved after login. '
            'Expiry: ${serverExpiry ?? "N/A"}',
          );
        } else {
          debugPrint(
            '[AuthService] ⚠️ Login success but no token in response.',
          );
        }

        return data;
      } else {
        throw AuthException(
          _extractErrorMessage(response.body, 'Login failed.'),
        );
      }
    } else {
      throw AuthException(
        _extractErrorMessage(
          response.body,
          'Server error: ${response.statusCode}',
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  // Check User Exists (Phone Only)
  // ──────────────────────────────────────────────

  Future<bool?> checkUserExists(String identifier) async {
    final bool isEmail = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(identifier);
    final String endpoint = isEmail ? 'check-email' : 'check-phone';
    final String url =
        'https://user.jobes24x7.com/api/login/$endpoint/$identifier';
    debugPrint('[AuthService] CHECK USER → $url');
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['exists'] == true) {
          return true;
        }
        return false;
      }
      return null; // Return null if API fails so we can fallback
    } catch (e) {
      debugPrint('[AuthService] checkUserExists error: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // Register (New User)
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String email,
    required String password,
    required String address,
    required String userName,
    required String pin,
    required String captchaImage,
    required int captchaImageId,
  }) async {
    const String registerUrl = 'https://managelogin.jobes24x7.com/api/login/create';

    final Map<String, dynamic> body = {
      'phone_number': phoneNumber.isNotEmpty ? phoneNumber : '',
      'email': email.isNotEmpty ? email : '',
      'password': password,
      'address': address.isNotEmpty ? address : 'N/A',
      'user_name': userName.isNotEmpty ? userName : 'User',
      'created_by': userName.isNotEmpty ? userName : 'User',
      'attempt_count': 2,
      'email_otp': email.isNotEmpty ? true : false,
      'mobile_otp': phoneNumber.isNotEmpty ? true : false,
      'is_verified': 1,
      'last_attempt': 9,
      'otp': 4449,
      'status': 1,
      'user_main_id': null,
      'user_type': 'guest',
      'pin': pin,
      'captcha_image': captchaImage,
      'captcha_image_id': captchaImageId,
    };

    debugPrint('[AuthService] REGISTER → $registerUrl  body: $body');

    final response = await http
        .post(
          Uri.parse(registerUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    debugPrint('[AuthService] Register status : ${response.statusCode}');
    debugPrint('[AuthService] Register body   : ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          data = {'message': response.body};
        }
      } catch (_) {
        data = {'message': response.body};
      }
      return data;
    } else {
      throw AuthException(
        _extractErrorMessage(
          response.body,
          'Server error: ${response.statusCode}',
        ),
      );
    }
  }

  // ──────────────────────────────────────────────
  // Reset Access Flow (OTP & Password/Captcha)
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> requestResetOtp(String identifier, {bool isCaptchaOnly = false}) async {
    final String url = isCaptchaOnly 
        ? 'https://managelogin.jobes24x7.com/api/forgot-captcha/request-otp'
        : 'https://managelogin.jobes24x7.com/api/forgot-password/request-otp';
    final bool isEmail = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(identifier);
    final Map<String, dynamic> body = isEmail ? {'email': identifier} : {'phone_number': identifier};

    debugPrint('[AuthService] REQUEST RESET OTP → $url  body: $body');

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    debugPrint('[AuthService] Request OTP status : ${response.statusCode}');
    debugPrint('[AuthService] Request OTP body   : ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw AuthException(_extractErrorMessage(response.body, 'Failed to request OTP'));
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp(String identifier, String otp, {bool isCaptchaOnly = false}) async {
    final String url = isCaptchaOnly
        ? 'https://managelogin.jobes24x7.com/api/forgot-captcha/verify-otp'
        : 'https://managelogin.jobes24x7.com/api/forgot-password/verify-otp';
    final bool isEmail = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(identifier);
    final Map<String, dynamic> body = {
      if (isEmail) 'email': identifier else 'phone_number': identifier,
      'otp': otp,
    };

    debugPrint('[AuthService] VERIFY RESET OTP → $url  body: $body');

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    debugPrint('[AuthService] Verify OTP status : ${response.statusCode}');
    debugPrint('[AuthService] Verify OTP body   : ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded['code'] != 200 && decoded['result']?.toString().toLowerCase() != 'success') {
         throw AuthException(_extractErrorMessage(response.body, 'Invalid OTP'));
      }
      return decoded;
    } else {
      throw AuthException(_extractErrorMessage(response.body, 'Failed to verify OTP'));
    }
  }

  Future<Map<String, dynamic>> resetAccess({
    required String identifier,
    required String otp,
    String? newPassword,
    int? captchaImageId,
  }) async {
    final String url = (newPassword == null || newPassword.isEmpty)
        ? 'https://managelogin.jobes24x7.com/api/forgot-captcha/reset'
        : 'https://managelogin.jobes24x7.com/api/forgot-password/reset';
    final bool isEmail = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(identifier);
    final Map<String, dynamic> body = {
      if (isEmail) 'email': identifier else 'phone_number': identifier,
      'otp': otp,
    };

    if (newPassword != null && newPassword.isNotEmpty) {
      body['password'] = newPassword;
      body['new_password'] = newPassword;
    }
    if (captchaImageId != null) {
      body['captcha_image_id'] = captchaImageId;
    }

    debugPrint('[AuthService] RESET ACCESS → $url  body: $body');

    final response = await http
        .post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));

    debugPrint('[AuthService] Reset status : ${response.statusCode}');
    debugPrint('[AuthService] Reset body   : ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw AuthException(_extractErrorMessage(response.body, 'Failed to reset access'));
    }
  }

  // ──────────────────────────────────────────────
  // Logout
  // ──────────────────────────────────────────────

  Future<String?> getValidToken() async {
    final bool valid = await isTokenValid();

    if (!valid) {
      await clearToken();
      return null;
    }

    return await getToken();
  }

  /// Clears token + metadata. Call alongside UserService.logout().
  Future<void> logout() async {
    await clearToken();
  }

  /// Extracts the error message from the response body if present.
  String _extractErrorMessage(String responseBody, String defaultMsg) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final dataPart = decoded['data'];
        if (dataPart is Map<String, dynamic>) {
          final msg = dataPart['message']?.toString();
          if (msg != null && msg.trim().isNotEmpty) return msg;
        }
        final msg = decoded['message']?.toString();
        if (msg != null && msg.trim().isNotEmpty) return msg;
      }
    } catch (_) {}
    return defaultMsg;
  }
}

// ──────────────────────────────────────────────
// Helper exception
// ──────────────────────────────────────────────
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

// ──────────────────────────────────────────────
// Helper exception
// ──────────────────────────────────────────────
