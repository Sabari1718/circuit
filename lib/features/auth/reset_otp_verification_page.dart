import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth_service.dart';
import 'reset_new_password_page.dart';
import 'reset_new_captcha_page.dart';

class ResetOtpVerificationPage extends StatefulWidget {
  final String sentTo;
  final String method;
  final String identifier;
  final bool isPasswordSelected;
  final bool isCaptchaSelected;

  const ResetOtpVerificationPage({
    super.key,
    required this.sentTo,
    required this.method,
    required this.identifier,
    required this.isPasswordSelected,
    required this.isCaptchaSelected,
  });

  @override
  State<ResetOtpVerificationPage> createState() => _ResetOtpVerificationPageState();
}

class _ResetOtpVerificationPageState extends State<ResetOtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimeout = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _resendTimeout = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout > 0) {
        setState(() {
          _resendTimeout--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onVerify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().verifyResetOtp(
        widget.identifier,
        otp,
        isCaptchaOnly: widget.isCaptchaSelected && !widget.isPasswordSelected,
      );

      if (!mounted) return;

      if (widget.isPasswordSelected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetNewPasswordPage(
              identifier: widget.identifier,
              otp: otp,
              isCaptchaSelected: widget.isCaptchaSelected,
            ),
          ),
        );
      } else if (widget.isCaptchaSelected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetNewCaptchaPage(
              identifier: widget.identifier,
              otp: otp,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('AuthException: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onResend() async {
    if (_resendTimeout > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().requestResetOtp(
        widget.identifier,
        isCaptchaOnly: widget.isCaptchaSelected && !widget.isPasswordSelected,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent successfully!')),
      );
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('AuthException: ', '')),
          backgroundColor: Colors.redAccent,
        ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                // Header
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
                                    Icons.lock_clock_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.6),
                                      letterSpacing: 0.2,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Enter the OTP sent to '),
                                      TextSpan(
                                        text: widget.sentTo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // OTP Input
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "••••••",
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), letterSpacing: 8),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Verify Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00E5FF), Color(0xFF7000FF)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00E5FF).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _onVerify,
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
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                            )
                                          : const Text(
                                              'Verify',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Resend & Back Links
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Text(
                                        'Back',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _resendTimeout == 0 ? _onResend : null,
                                      child: Text(
                                        _resendTimeout > 0 ? 'Resend in $_resendTimeout s' : 'Resend OTP',
                                        style: TextStyle(
                                          color: _resendTimeout > 0 ? Colors.white.withOpacity(0.4) : const Color(0xFF00E5FF),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
