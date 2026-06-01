import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'user_service.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'app_lock_page.dart';
import 'app_lock_service.dart';

/// SplashScreen — first widget shown on every app launch.
///
/// Flow:
///   1. Branded splash visible while work runs in background.
///   2. [AuthService.checkAuthOnStartup] runs (local 24-h expiry check, no network).
///      • Token absent          → LoginPage
///      • Token age < 24 h      → HomePage / AppLockPage
///      • Token age ≥ 24 h      → token cleared → LoginPage
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // Status text shown under the spinner
  String _statusText = 'Checking session…';

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );

    _animCtrl.forward();

    // Small delay so splash logo animates in before we route away
    Future.delayed(const Duration(milliseconds: 1200), _runAuthCheck);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Core auth check (pure local — no network call)
  // ──────────────────────────────────────────────

  Future<void> _runAuthCheck() async {
    if (!mounted) return;

    final authService = AuthService();
    final userService = UserService();
    final appLockService = AppLockService();

    // ── Local 24-hour expiry check ────────────────────────────────────────
    final String route = await authService.checkAuthOnStartup();

    if (!mounted) return;

    if (route == AuthService.resultDashboard) {
      // ── Token is valid ── ─────────────────────────────────────────────────
      // Show remaining time on splash for a moment
      final Duration remaining = await authService.tokenTimeRemaining();
      final int hoursLeft = remaining.inHours;
      final int minsLeft = remaining.inMinutes % 60;

      if (mounted) {
        setState(() {
          _statusText = 'Session valid · ${hoursLeft}h ${minsLeft}m left';
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      // Load user data + check app-lock
      final bool isAppLockEnabled = await appLockService.isAppLockEnabled();
      final userData = await userService.getUserData();

      if (!mounted) return;

      Widget destination;
      if (isAppLockEnabled) {
        destination = AppLockPage(
          userName: userData['name'] ?? '',
          email: userData['email'] ?? '',
        );
      } else {
        destination = HomePage(
          userName: userData['name'] ?? '',
          email: userData['email'] ?? '',
        );
      }

      _navigate(destination);
    } else {
      // ── No token or expired ────────────────────────────────────────────────
      if (mounted) {
        setState(() {
          _statusText = 'Session expired. Please login.';
        });
      }

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      _navigate(const LoginPage());
    }
  }

  void _navigate(Widget page) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── App icon ──────────────────────────────────────────────
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 28),

                // ── App name ──────────────────────────────────────────────
                const Text(
                  'UserPortal',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure · Fast · Reliable',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 56),

                // ── Spinner ───────────────────────────────────────────────
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Dynamic status text ───────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    _statusText,
                    key: ValueKey(_statusText),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.50),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
