import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'profile_details_page.dart';
import 'email_service.dart';
import 'login_page.dart';

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
    const Color themeColor = Color(0xFF00E5FF);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F24), Color(0xFF10193E), Color(0xFF0A0F24)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              left: -50,
              child: _buildBlob(themeColor.withOpacity(0.15), 200),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _buildBlob(
                const Color(0xFF7000FF).withOpacity(0.15),
                250,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        _buildProgressIndicator(themeColor),
                        const SizedBox(height: 40),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(32),
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
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: themeColor.withOpacity(0.15),
                                      border: Border.all(
                                        color: themeColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.mark_email_read_outlined,
                                      color: themeColor,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Enter Email OTP',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'We sent a 4-digit OTP to\n${widget.email}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.6),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildChip(
                                        Icons.refresh,
                                        "Attempts Left: $attemptsLeft / 3",
                                        themeColor,
                                      ),
                                      _buildChip(
                                        Icons.timer_outlined,
                                        _secondsRemaining > 0 ? "${_secondsRemaining}s" : "Ready",
                                        _secondsRemaining < 10 && _secondsRemaining > 0
                                            ? const Color(0xFFFF4B4B)
                                            : themeColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  TextField(
                                    controller: otpController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    onChanged: (value) {
                                      if (value.length == 4) {
                                        FocusScope.of(context).unfocus();
                                        _verifyOtp();
                                      }
                                    },
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 12,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '----',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      counterText: '',
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.2),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: themeColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildGradientButton(
                                    text: _isVerifying ? 'Verifying...' : 'Verify Email OTP',
                                    colors: const [
                                      Color(0xFF00E5FF),
                                      Color(0xFF7000FF),
                                    ],
                                    onPressed: _isVerifying ? null : _verifyOtp,
                                    isLoading: _isVerifying,
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: canResend ? _resendOtp : null,
                                    child: _isResending
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: themeColor),
                                          )
                                        : Text(
                                            _secondsRemaining > 0
                                                ? 'Resend in $_secondsRemaining s'
                                                : 'Resend Email OTP',
                                            style: TextStyle(
                                              color: canResend
                                                  ? themeColor
                                                  : Colors.white.withOpacity(0.3),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ],
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
          ],
        ),
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
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 20,
          )
        ]
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required List<Color> colors,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressIndicator(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
        ),
      ],
    );
  }
}