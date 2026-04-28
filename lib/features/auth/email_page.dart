import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit/features/auth/email_otp_page.dart';
import 'package:circuit/core/services/email_service.dart';

class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSending = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _continueAction() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final String enteredEmail = emailController.text.trim();

      print("ENTERED EMAIL: $enteredEmail");

      // Save email locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', enteredEmail);

      // Send email OTP
      final result = await EmailService().sendEmailOtp(email: enteredEmail);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Verification code sent successfully',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailOtpPage(
              email: enteredEmail,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to send verification code',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to send OTP: $e",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlob(themeColor.withOpacity(0.12), 300),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: _buildBlob(
              const Color(0xFF6366F1).withOpacity(0.08),
              350,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _progressDot(true, color: const Color(0xFF6366F1)),
                      _progressLine(true, const Color(0xFF6366F1)),
                      _progressDot(true, color: const Color(0xFF6366F1)),
                      _progressLine(true, themeColor),
                      _progressDot(true, color: themeColor),
                      _progressLine(false, themeColor),
                      _progressDot(false),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      themeColor.withOpacity(0.05),
                                      themeColor.withOpacity(0.01),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [themeColor, Color(0xFFD97706)],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: themeColor.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.alternate_email_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Enter Email',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Enter your email to receive verification code',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Email Address',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'example@gmail.com',
                                          prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            size: 20,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFFF1F5F9),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 20,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(
                                              color: themeColor,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Email required';
                                          }
                                          if (!RegExp(
                                            r'^[\w\.-]+@[\w\.-]+\.\w+$',
                                          ).hasMatch(value.trim())) {
                                            return 'Invalid email format';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 40),
                                      _buildGradientButton(
                                        text: _isSending
                                            ? 'Sending...'
                                            : 'Send Verification Code',
                                        colors: const [
                                          themeColor,
                                          Color(0xFFD97706),
                                        ],
                                        onPressed: _isSending ? null : _continueAction,
                                      ),
                                      const SizedBox(height: 24),
                                      const Center(
                                        child: Text(
                                          'We value your privacy',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required List<Color> colors,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isSending
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _progressDot(
      bool active, {
        Color color = const Color(0xFF6366F1),
      }) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : Colors.black12,
      ),
    );
  }

  Widget _progressLine(bool active, Color color) {
    return Container(
      width: 30,
      height: 2,
      color: active ? color.withOpacity(0.3) : Colors.black12,
    );
  }
}