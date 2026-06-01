import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 're_login_selection_page.dart';
import 'home_page.dart';
import 'user_service.dart';
import 'theme/theme_provider.dart';
import 'app_lock_service.dart';
import 'app_lock_page.dart';
import 'app_security_service.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // APP SECURITY CHECK
  bool isValid = await AppSecurityService.checkApp();

  // BLOCK APP IF INVALID
  if (!isValid) {
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SecurityBlockedPage(),
      ),
    );
    return;
  }

  final UserService userService = UserService();
  final AppLockService appLockService = AppLockService();
  final AuthService authService = AuthService();

  // CHECK TOKEN VALIDITY
  final String authResult = await authService.checkAuthOnStartup();

  final bool isLoggedIn =
      authResult == AuthService.resultDashboard &&
          await userService.isUserLoggedIn();

  final bool isAppLockEnabled = await appLockService.isAppLockEnabled();
  final userData = await userService.getUserData();

  Widget home;

  if (!isLoggedIn) {
    final bool hasLoggedOut = await userService.hasLoggedOut();
    home = hasLoggedOut ? const ReLoginSelectionPage() : const LoginPage();
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(initialHome: home),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialHome;

  const MyApp({
    super.key,
    required this.initialHome,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UserPortal',
          themeMode: themeProvider.themeMode,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          home: initialHome,
          routes: {
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}

class SecurityBlockedPage extends StatelessWidget {
  const SecurityBlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "❌ INVALID APPLICATION",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}