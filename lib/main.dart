import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'user_service.dart';
import 'theme/app_theme.dart';
import 'app_lock_service.dart';
import 'app_lock_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final UserService userService = UserService();
  final AppLockService appLockService = AppLockService();

  final bool isLoggedIn = await userService.isUserLoggedIn();
  final bool isAppLockEnabled = await appLockService.isAppLockEnabled();
  final userData = await userService.getUserData();

  Widget home;

  if (!isLoggedIn) {
    home = const LoginPage();
  } else if (isAppLockEnabled) {
    home = AppLockPage(
      userName: userData['name'] ?? '',
      email: userData['email'] ?? '',
    );
  } else {
    home = HomePage(
      userName: userData['name'] ?? '',
      email: userData['email'] ?? '',
    );
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => userService,
      child: MyApp(initialHome: home),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialHome;
  const MyApp({super.key, required this.initialHome});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Secure Login',
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xFFE11D48),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xFFE11D48),
          ),
          home: initialHome,
          routes: {
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}