import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  static const String _themeKey = "theme_mode";

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() async {
    _themeMode =
    _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_themeKey, _themeMode.toString());
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final themeStr = prefs.getString(_themeKey);

    if (themeStr != null) {
      _themeMode =
      themeStr == ThemeMode.dark.toString()
          ? ThemeMode.dark
          : ThemeMode.light;

      notifyListeners();
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      primaryColor: const Color(0xFF6366F1),

      scaffoldBackgroundColor: const Color(0xFFF8FAFC),

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
        surface: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        elevation: 2,

        shadowColor: Colors.black.withValues(alpha: 0.1),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        color: Colors.white,
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),

        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),

        bodyMedium: TextStyle(
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      primaryColor: const Color(0xFF818CF8),

      scaffoldBackgroundColor: const Color(0xFF0F172A),

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
        surface: const Color(0xFF1E293B),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        elevation: 4,

        shadowColor: Colors.black.withValues(alpha: 0.3),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        color: const Color(0xFF1E293B),
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        bodyMedium: TextStyle(
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}