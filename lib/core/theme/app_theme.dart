import 'package:flutter/material.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;
}

final themeManager = ThemeManager();