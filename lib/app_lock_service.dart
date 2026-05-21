import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService {
  static final AppLockService _instance = AppLockService._internal();
  factory AppLockService() => _instance;
  AppLockService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyAppLockPin = 'app_lock_pin';
  static const String _keyAppLockPassword = 'app_lock_password';

  // ── Enable / Disable ────────────────────────────────────────────────────────

  Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAppLockEnabled) ?? false;
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAppLockEnabled, enabled);
  }

  // ── PIN ─────────────────────────────────────────────────────────────────────

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppLockPin, pin);
  }

  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppLockPin);
  }

  Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> verifyPin(String enteredPin) async {
    final savedPin = await getPin();
    if (savedPin == null || savedPin.isEmpty) return false;
    return savedPin == enteredPin;
  }

  // ── Password ────────────────────────────────────────────────────────────────

  Future<void> setPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppLockPassword, password);
  }

  Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAppLockPassword);
  }

  Future<bool> verifyPassword(String enteredPassword) async {
    final savedPassword = await getPassword();
    if (savedPassword == null || savedPassword.isEmpty) return false;
    return savedPassword == enteredPassword;
  }

  // ── Biométric ───────────────────────────────────────────────────────────────

  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometric() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to unlock the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (_) {
      return false;
    }
  }

  // ── Setup convenience ────────────────────────────────────────────────────────

  Future<void> enableAppLock({
    required String pin,
    required String password,
  }) async {
    await setPin(pin);
    await setPassword(password);
    await setAppLockEnabled(true);
  }
}
