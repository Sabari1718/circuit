import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'user_service.dart';
import 'password_page.dart';
import 'login_page.dart';
import 'email_page.dart';
import 'otp_page.dart';
import 'otp_service.dart';
import 'auth_service.dart';

class ReLoginSelectionPage extends ConsumerStatefulWidget {
  const ReLoginSelectionPage({super.key});

  @override
  ConsumerState<ReLoginSelectionPage> createState() => _ReLoginSelectionPageState();
}

class _ReLoginSelectionPageState extends ConsumerState<ReLoginSelectionPage> {
  String _selectedMethod = 'Phone Number';
  final TextEditingController _inputController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<String> _methods = [
    'Phone Number',
    'Email Address',
    'PAN Number',
    'User ID (10 Digits)',
    'Username',
    'Employee ID'
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Reuse logic from login_page.dart
  bool isEmailInput(String input) => RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(input);
  bool isMobileInput(String input) => RegExp(r'^[0-9]{10}$').hasMatch(input);

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String input = _inputController.text.trim();
    final userService = ref.read(userServiceProvider);

    try {
      // 1. Check if account already exists
      bool exists = false;
      final apiExists = await AuthService().checkUserExists(input);
      if (apiExists != null) {
        exists = apiExists;
      } else {
        exists = await userService.checkUserExists(input);
      }

      if (!mounted) return;

      if (exists) {
        // FLOW: If exists, skip OTP/registration and go to Password Screen
        final userData = await userService.getUserByInput(input);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordPage(
              phoneNumber: userData?['mobile'] ?? (isMobileInput(input) ? input : ''),
              email: userData?['email'] ?? (isEmailInput(input) ? input : ''),
              isExistingUser: true,
              passedIdentifier: input,
            ),
          ),
        );
      } else {
        // FLOW: If not exists, continue existing registration/OTP flow
        if (_selectedMethod == 'Email Address' || isEmailInput(input)) {
          await userService.saveUserData(email: input);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EmailPage()));
        } else if (_selectedMethod == 'Phone Number' || isMobileInput(input)) {
          await userService.saveUserData(phone: input);
          final otpService = OtpService();
          final result = await otpService.sendOtp(mobileNumber: input, flowType: "SMS");
          
          if (!mounted) return;
          if (result["success"] == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpPage(
                  phoneNumber: input,
                  verificationId: result["verificationId"]?.toString() ?? "",
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result["message"] ?? "OTP failed")));
          }
        } else {
          // For other methods not yet implemented in registration flow, 
          // we fallback to mobile or show error
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration flow for this method coming soon. Please use Mobile or Email.")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              top: -100,
              right: -50,
              child: _buildBlob(themeColor.withOpacity(0.15), 300),
            ),
            Positioned(
              bottom: -50,
              left: -100,
              child: _buildBlob(const Color(0xFF7000FF).withOpacity(0.15), 350),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        ClipRRect(
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                      horizontal: 32,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF00E5FF),
                                                Color(0xFF7000FF),
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: themeColor.withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.login_rounded,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Choose your login method to continue',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32, right: 32, bottom: 40),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LOGIN METHOD',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.5),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildDropdown(),
                                          const SizedBox(height: 24),
                                          _buildInputField(),
                                          const SizedBox(height: 40),
                                          _buildButton(),
                                        ],
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

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMethod,
          isExpanded: true,
          dropdownColor: const Color(0xFF10193E),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.7)),
          items: _methods.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedMethod = newValue;
                _inputController.clear();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildInputField() {
    String hint = 'Enter ${_selectedMethod.toLowerCase()}';
    TextInputType keyboard = TextInputType.text;
    List<TextInputFormatter>? formatters;
    TextCapitalization textCap = TextCapitalization.none;
    IconData prefixIcon = Icons.person_outline_rounded;
    
    if (_selectedMethod == 'Phone Number') {
      keyboard = TextInputType.phone;
      formatters = [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)];
      prefixIcon = Icons.phone_android_rounded;
    } else if (_selectedMethod == 'Email Address') {
      keyboard = TextInputType.emailAddress;
      prefixIcon = Icons.email_outlined;
    } else if (_selectedMethod == 'PAN Number') {
      textCap = TextCapitalization.characters;
      formatters = [
        TextInputFormatter.withFunction((oldValue, newValue) => 
            TextEditingValue(text: newValue.text.toUpperCase(), selection: newValue.selection)),
        LengthLimitingTextInputFormatter(10)
      ];
      prefixIcon = Icons.credit_card_rounded;
    } else if (_selectedMethod == 'User ID (10 Digits)' || _selectedMethod == 'Employee ID') {
      prefixIcon = Icons.badge_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedMethod.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _inputController,
          keyboardType: keyboard,
          inputFormatters: formatters,
          textCapitalization: textCap,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
            prefixIcon: Icon(prefixIcon, size: 22, color: Colors.white.withOpacity(0.7)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2),
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF4B4B)),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF7000FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : const Text(
                'Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
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
}
