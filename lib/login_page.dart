import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'otp_page.dart';
import 'user_service.dart';
import 'otp_service.dart';
import 'password_page.dart';
import 'email_page.dart';
import 'auth_service.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFFA855F7);
  static const Color textLight = Color(0xFF64748B);

  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFFA855F7),
  ];

  static const List<Color> bgGradient = [
    Color(0xFF0F0C29),
    Color(0xFF302B63),
    Color(0xFF24243E),
  ];
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  final OtpService _otpService = OtpService();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }


  bool isEmailInput(String input) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(input);
  }

  bool isMobileInput(String input) {
    return RegExp(r'^[0-9]{10}$').hasMatch(input);
  }

  Future<void> _continueAction() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final String input = inputController.text.trim();
    debugPrint("ENTERED INPUT => $input");

    setState(() {
      _isLoading = true;
    });

    try {
      final userService = ref.read(userServiceProvider);

      // ======================================================
      // 🔥 1. CHECK FOR EXISTING USER (API + LOCAL FALLBACK)
      // ======================================================
      bool userExists = false;

      final apiExists = await AuthService().checkUserExists(input);
      if (apiExists != null) {
        userExists = apiExists;
      } else {
        // Fallback to local if API fails/timeouts
        userExists = await userService.checkUserExists(input);
      }

      if (userExists) {
        debugPrint("EXISTING USER DETECTED (API or Local) => Redirecting to Password Page");
        
        final userData = await userService.getUserByInput(input);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordPage(
              phoneNumber: userData?['mobile'] ?? (isMobileInput(input) ? input : ''),
              email: userData?['email'] ?? (isEmailInput(input) ? input : ''),
              isExistingUser: true,
              passedIdentifier: input, // Pass the exact input for login
            ),
          ),
        );
        return;
      }

      // ======================================================
      // 🔥 2. NEW USER FLOW
      // ======================================================
      if (isEmailInput(input)) {
        // CASE: NEW EMAIL
        debugPrint("NEW EMAIL DETECTED => Navigating to Email Registration Flow");
        
        await userService.saveUserData(email: input);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailPage(),
          ),
        );
      } else if (isMobileInput(input)) {
        // CASE: NEW MOBILE
        debugPrint("NEW MOBILE DETECTED => Navigating to Mobile OTP Flow");
        
        await userService.saveUserData(phone: input);

        final result = await _otpService.sendOtp(
          mobileNumber: input,
          flowType: "SMS",
        );

        if (!mounted) return;

        if (result["success"] == true) {
          final String verificationId = result["verificationId"]?.toString().trim() ?? "";
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent successfully")),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpPage(
                phoneNumber: input,
                verificationId: verificationId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"]?.toString() ?? "Failed to send OTP")),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F24), Color(0xFF10193E), Color(0xFF0A0F24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Progress Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 8)
                          ]
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Glassmorphism Login Card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF00E5FF), Color(0xFF7000FF)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00E5FF).withOpacity(0.4),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.shield_outlined,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Secure Login',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Enter your credentials to continue',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Form
                              Padding(
                                padding: const EdgeInsets.only(left: 32, right: 32, bottom: 40),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MOBILE OR EMAIL',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.5),
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: inputController,
                                        keyboardType: TextInputType.emailAddress,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter mobile number or email',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.3),
                                            fontSize: 15,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.person_outline_rounded,
                                            size: 22,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                          filled: true,
                                          fillColor: Colors.black.withOpacity(0.2),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2),
                                          ),
                                          errorStyle: const TextStyle(color: Color(0xFFFF4B4B)),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Required';
                                          }
                                          final val = value.trim();
                                          if (!isEmailInput(val) && !isMobileInput(val)) {
                                            return 'Enter a valid 10-digit mobile or email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 32),
                                      
                                      // Submit Button
                                      Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF00E5FF), Color(0xFF7000FF)],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF00E5FF).withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _continueAction,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : const Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Continue',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Icon(
                                                      Icons.arrow_forward_rounded,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Center(
                                        child: Text(
                                          'Standard secure login protocol active',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withOpacity(0.4),
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}