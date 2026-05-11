import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_service.dart';
import 'password_page.dart';
import 'login_page.dart';
import 'email_page.dart';
import 'otp_page.dart';
import 'otp_service.dart';

class ReLoginSelectionPage extends StatefulWidget {
  const ReLoginSelectionPage({super.key});

  @override
  State<ReLoginSelectionPage> createState() => _ReLoginSelectionPageState();
}

class _ReLoginSelectionPageState extends State<ReLoginSelectionPage> {
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
    final userService = Provider.of<UserService>(context, listen: false);

    try {
      // 1. Check if account already exists
      final bool exists = await userService.checkUserExists(input);

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
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // Dark background matching design
      body: Stack(
        children: [
          // Dynamic background elements
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlob(const Color(0xFF6366F1).withOpacity(0.1), 300),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: _buildBlob(const Color(0xFF8B5CF6).withOpacity(0.1), 350),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Choose your login method to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // Login Method Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Login Method',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDropdown(),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Input Field
                        _buildInputField(),
                        
                        const SizedBox(height: 40),
                        
                        // Continue Button
                        _buildButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMethod,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          items: _methods.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
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
    
    if (_selectedMethod == 'Phone Number') keyboard = TextInputType.phone;
    if (_selectedMethod == 'Email Address') keyboard = TextInputType.emailAddress;

    return TextFormField(
      controller: _inputController,
      keyboardType: keyboard,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
