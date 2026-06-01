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
      'https://user.jobes24x7.com/api/login/authenticate';

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
  }) async {
    final Map<String, dynamic> body = {'password': password};
    if (identifier.contains('@')) {
      body['email'] = identifier;
    } else {
      body['phone_number'] = identifier;
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
      final bool success = data['data']?['code'] == 200 || data['code'] == 200;

      if (success) {
        // ── Extract token ──────────────────────────────────────────────────
        final String? token =
            data['data']?['token']?.toString() ??
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
        throw AuthException(data['message']?.toString() ?? 'Login failed.');
      }
    } else {
      throw AuthException('Server error: ${response.statusCode}');
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
