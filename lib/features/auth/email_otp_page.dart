import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sva_business_user/features/profile/profile_details_page.dart';
import 'package:sva_business_user/core/services/email_service.dart';
import 'package:sva_business_user/features/auth/login_page.dart';

class EmailOtpPage extends StatefulWidget {
  final String email;

  const EmailOtpPage({
    super.key,
    required this.email,
  });

  @override
  State<EmailOtpPage> createState() => _EmailOtpPageState();
}

class _EmailOtpPageState extends State<EmailOtpPage> {
  final TextEditingController otpController = TextEditingController();
  final EmailService _emailService = EmailService();

  bool _isVerifying = false;
  bool _isResending = false;

  int _attempts = 1;
  final int _maxAttempts = 3;

  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showFinalFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Verification Failed"),
        content: const Text(
          "Email OTP verification failed 3 times. Please login again.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                    (route) => false,
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    final enteredOtp = otpController.text.trim();

    print("ENTERED EMAIL OTP: $enteredOtp");
    print("EMAIL: ${widget.email}");

    // ✅ CHANGED: 4-digit OTP validation
    if (enteredOtp.length != 4) {
      _showSnackBar(
        'Please enter 4-digit Email OTP',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await _emailService.verifyEmailOtp(
        email: widget.email,
        otp: enteredOtp,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        _showSnackBar(
          result["message"] ?? "Email OTP verified successfully",
          backgroundColor: Colors.green,
        );

        // ✅ Success → Next page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileDetailsPage(),
          ),
              (route) => false,
        );
      } else {
        if (_attempts < _maxAttempts) {
          setState(() {
            _attempts++;
          });

          otpController.clear();

          _showSnackBar(
            "${result["message"] ?? "Invalid Email OTP"} (Attempt $_attempts of 3)",
            backgroundColor: Colors.redAccent,
          );
        } else {
          _showFinalFailureDialog();
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        "Verification error: $e",
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    FocusScope.of(context).unfocus();

    if (_secondsRemaining > 0) {
      _showSnackBar(
        'Please wait $_secondsRemaining seconds before resending',
        backgroundColor: Colors.orange,
      );
      return;
    }

    if (_isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final result = await _emailService.resendEmailOtp(
        email: widget.email,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        otpController.clear();
        _startResendTimer();

        _showSnackBar(
          result["message"] ?? "Email OTP resent successfully",
          backgroundColor: Colors.green,
        );
      } else {
        _showSnackBar(
          result["message"] ?? "Failed to resend Email OTP",
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(
        "Resend error: $e",
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int attemptsLeft = _maxAttempts - _attempts + 1;
    final bool canResend = _secondsRemaining == 0 && !_isResending;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Verify Email OTP',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E1E1E)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFFE9EEFF),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      color: Color(0xFF5B6CF9),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Enter Email OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ CHANGED: 4-digit text
                  Text(
                    'We sent a 4-digit OTP to\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Attempts Left: $attemptsLeft / 3',
                      style: const TextStyle(
                        color: Color(0xFF5B6CF9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _secondsRemaining > 0
                          ? 'Resend available in $_secondsRemaining sec'
                          : 'You can resend OTP now',
                      style: TextStyle(
                        color: _secondsRemaining > 0
                            ? const Color(0xFFEA580C)
                            : const Color(0xFF16A34A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,

                    // ✅ CHANGED: 4 digits only
                    maxLength: 4,

                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      // ✅ CHANGED: 4 placeholders
                      hintText: '----',
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: const Color(0xFF5B6CF9).withOpacity(0.4),
                          width: 1.4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF5B6CF9),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B6CF9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Text(
                        'Verify Email OTP',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: canResend ? _resendOtp : null,
                    child: _isResending
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Text(
                      _secondsRemaining > 0
                          ? 'Resend in $_secondsRemaining s'
                          : 'Resend Email OTP',
                      style: TextStyle(
                        color: canResend
                            ? const Color(0xFF5B6CF9)
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
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
