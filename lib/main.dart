import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

import 'login_page.dart';
import 're_login_selection_page.dart';
import 'user_service.dart';
import 'theme/theme_provider.dart';

import 'auth_service.dart';
import 'biometric_pin_gate_page.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(initialHome: SplashScreen()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final Widget initialHome;

  const MyApp({
    super.key,
    required this.initialHome,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeProviderState);
    
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
  }
}

