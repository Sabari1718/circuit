import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_service.dart';
import 'theme/theme_provider.dart';

final themeProviderState = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider();
});

final userServiceProvider = ChangeNotifierProvider<UserService>((ref) {
  return UserService();
});
