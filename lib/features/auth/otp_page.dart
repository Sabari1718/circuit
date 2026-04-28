import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:circuit/features/profile/profile_details_page.dart';
import 'package:circuit/features/auth/login_page.dart';
import 'package:circuit/core/services/otp_service.dart';
import 'package:circuit/features/auth/email_page.dart';
import 'package:circuit/core/services/user_service.dart';
import 'package:circuit/features/home/home_page.dart';

enum VerificationMode { sms, whatsapp, email }

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String? email;
  final VerificationMode? initialMode;

  const OtpPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.email,
    this.initialMode,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  final OtpService _otpService = OtpService();
  final UserService _userService = UserService();

  int _secondsRemaining = 60;
  Timer? _timer;
  late VerificationMode _currentMode;
  int _attempts = 1;
  final int _maxAttempts = 3;

  bool _isVerifying = false;
  bool _isResending = false;

  String _currentVerificationId = "";

  @override
  void initState() {
    super.initState();

    _currentVerificationId = widget.verificationId;

    // 🔥 Always start with SMS unless explicitly passed
    _currentMode = widget.initialMode ?? VerificationMode.sms;

    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    if (mounted) {
      setState(() {
        _secondsRemaining = 60;
      });
    } else {
      _secondsRemaining = 60;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() => _secondsRemaining--);
        } else {
          _secondsRemaining--;
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  void _handleTimeout() {
    _consumeAttempt(reason: "Time expired");
  }

  void _consumeAttempt({String? reason}) {
    if (_attempts < _maxAttempts) {
      if (mounted) {
        setState(() => _attempts++);
      } else {
        _attempts++;
      }

      _startTimer();
      _showSnackBar("${reason ?? 'Attempt consumed'}. Attempt $_attempts of 3");
    } else {
      _handleModeFailure();
    }
  }

  Future<void> _handleModeFailure() async {
    if (_currentMode == VerificationMode.sms) {
      if (mounted) {
        setState(() {
          _currentMode = VerificationMode.whatsapp;
          _attempts = 1;
        });
      } else {
        _currentMode = VerificationMode.whatsapp;
        _attempts = 1;
      }

      _clearOtpFields();
      _showSnackBar("SMS failed. Sending OTP via WhatsApp...");

      await _resendOtp(forceMode: VerificationMode.whatsapp);
    } else if (_currentMode == VerificationMode.whatsapp) {
      _timer?.cancel();

      if (!mounted) return;

      _showSnackBar("WhatsApp failed. Please enter your email.");

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EmailPage()),
      );
    } else {
      _timer?.cancel();
      _showFinalFailureDialog();
    }
  }

  void _showFinalFailureDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Verification Failed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "All verification attempts failed. Please try again later.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
            child: const Text(
              "Ok",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ OTP success na check registration and navigate accordingly
  Future<void> _handleSuccess() async {
    _timer?.cancel();

    setState(() {
      _isVerifying = true; // Show loading while checking
    });

    // Check if user is registered in backend
    final bool isRegistered = await _userService.checkPhoneRegistration(widget.phoneNumber);

    if (!mounted) return;

    if (isRegistered) {
      // Existing User: Save session and go directly to Home
      await _userService.saveUserData(
        phone: widget.phoneNumber,
        isLoggedIn: true,
      );

      final userData = await _userService.getUserData();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: userData['name']!,
            email: userData['email']!,
          ),
        ),
            (route) => false,
      );
    } else {
      // New User: Proceed to registration flow (Email -> Details -> Password)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const EmailPage(),
        ),
            (route) => false,
      );
    }
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }

    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;

    final String otp = _controllers.map((c) => c.text.trim()).join();

    if (otp.length != 4) {
      _showSnackBar("Please enter full 4-digit code");
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // 🔥 EMAIL MODE TEMP VERIFY (only if opened intentionally in email mode)
      if (_currentMode == VerificationMode.email) {
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // TEMP TEST EMAIL OTP
        if (otp == "1234") {
          _showSnackBar("Email OTP verified successfully");
          await _handleSuccess();
        } else {
          _consumeAttempt(reason: "Incorrect Email OTP");
          _clearOtpFields();
        }

        return;
      }

      // 🔥 SMS / WHATSAPP REAL VERIFY
      final result = await _otpService.validateOtp(
        mobileNumber: widget.phoneNumber,
        verificationId: _currentVerificationId,
        otp: otp,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        _showSnackBar("OTP verified successfully");
        await _handleSuccess();
      } else {
        _consumeAttempt(reason: "Incorrect OTP");
        _clearOtpFields();
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Verification failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp({VerificationMode? forceMode}) async {
    if (_isResending) return;

    final modeToUse = forceMode ?? _currentMode;

    setState(() {
      _isResending = true;
    });

    try {
      // 🔥 EMAIL MODE TEMP PLACEHOLDER
      if (modeToUse == VerificationMode.email) {
        await Future.delayed(const Duration(milliseconds: 700));

        if (!mounted) return;

        _currentVerificationId = "EMAIL_TEMP_1234";
        _clearOtpFields();
        _startTimer();
        _showSnackBar(
          "Email OTP sent successfully to ${widget.email ?? 'your email'}",
        );
        return;
      }

      // 🔥 SMS / WHATSAPP REAL API
      final result = await _otpService.sendOtp(
        mobileNumber: widget.phoneNumber,
        flowType: modeToUse == VerificationMode.whatsapp ? "WHATSAPP" : "SMS",
      );

      if (!mounted) return;

      if (result["success"] == true) {
        final String newVerificationId =
            result["verificationId"]?.toString() ?? "";

        if (newVerificationId.isNotEmpty) {
          _currentVerificationId = newVerificationId;
        }

        _clearOtpFields();
        _startTimer();
        _showSnackBar("OTP resent successfully via ${_modeLabel(modeToUse)}");
      } else {
        _showSnackBar(result["message"] ?? "Failed to resend OTP");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Resend failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  String _modeLabel(VerificationMode mode) {
    switch (mode) {
      case VerificationMode.sms:
        return "SMS";
      case VerificationMode.whatsapp:
        return "WhatsApp";
      case VerificationMode.email:
        return "Email";
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_secondsRemaining == 0 && !_isVerifying && !_isResending) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _secondsRemaining == 0) {
          _handleTimeout();
        }
      });
    }

    Color modeColor;
    String modeTitle;
    String modeSubtitle;
    IconData modeIcon;

    switch (_currentMode) {
      case VerificationMode.sms:
        modeColor = const Color(0xFF6366F1);
        modeTitle = "Verify Identity";
        modeSubtitle = "Code sent to +91 ${widget.phoneNumber}";
        modeIcon = Icons.sms_outlined;
        break;
      case VerificationMode.whatsapp:
        modeColor = const Color(0xFF22C55E);
        modeTitle = "WhatsApp Verification";
        modeSubtitle = "OTP sent via WhatsApp to +91 ${widget.phoneNumber}";
        modeIcon = Icons.chat_bubble_outline;
        break;
      case VerificationMode.email:
        modeColor = const Color(0xFFF59E0B);
        modeTitle = "Email Verification";
        modeSubtitle = "OTP sent to ${widget.email ?? 'your email'}";
        modeIcon = Icons.mail_outline;
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: _buildBlob(modeColor.withOpacity(0.08), 200),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBlob(
              const Color(0xFFA855F7).withOpacity(0.05),
              250,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      _buildProgressIndicator(modeColor),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: modeColor.withOpacity(0.1),
                              ),
                              child: Icon(
                                modeIcon,
                                color: modeColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              modeTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              modeSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildChip(
                                  Icons.refresh,
                                  "$modeName Attempt $_attempts/3",
                                  modeColor,
                                ),
                                _buildChip(
                                  Icons.timer_outlined,
                                  "${_secondsRemaining}s",
                                  _secondsRemaining < 10
                                      ? Colors.red
                                      : modeColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildOtpInputRow(modeColor),
                            const SizedBox(height: 32),
                            _buildGradientButton(
                              text: _isVerifying ? 'Verifying...' : 'Verify Code',
                              color: modeColor,
                              onPressed: _isVerifying ? null : _verifyOtp,
                              isLoading: _isVerifying,
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: (_secondsRemaining == 0 && !_isResending)
                                  ? () => _resendOtp()
                                  : null,
                              child: Text(
                                _isResending ? "Resending..." : "Resend Code",
                                style: TextStyle(
                                  color: (_secondsRemaining == 0 && !_isResending)
                                      ? modeColor
                                      : Colors.grey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildOtpInputRow(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (index) => _buildOtpField(index, color),
      ),
    );
  }

  Widget _buildOtpField(int index, Color color) {
    return Container(
      width: 55,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_controllers[index].text.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
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
      ),
    );
  }

  Widget _buildProgressIndicator(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(true, color),
        _line(true, color),
        _dot(true, color),
        _line(false, color),
        _dot(false, color),
      ],
    );
  }

  Widget _dot(bool active, Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : Colors.black12,
      ),
    );
  }

  Widget _line(bool active, Color color) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: active ? color.withOpacity(0.3) : Colors.black12,
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String get modeName {
    switch (_currentMode) {
      case VerificationMode.sms:
        return "SMS";
      case VerificationMode.whatsapp:
        return "WhatsApp";
      case VerificationMode.email:
        return "Email";
    }
  }
}