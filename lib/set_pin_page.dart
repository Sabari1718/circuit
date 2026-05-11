import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'user_service.dart';
import 'app_lock_service.dart';
import 'secret_image_setup_page.dart';

class SetPinPage extends StatefulWidget {
  final String password;

  const SetPinPage({
    super.key,
    required this.password,
  });

  @override
  State<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _isSaving = false;

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final String pin = pinController.text.trim();

      // Save user's own PIN + password fallback + enable app lock
      await AppLockService().enableAppLock(
        pin: pin,
        password: widget.password,
      );

      final data = await userService.getUserData();
      final String name = data['name'] ?? '';
      final String email = data['email'] ?? '';
      final String mobile = data['phone'] ?? '';

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecretImageSetupPage(
            mobile: mobile,
            email: email,
            password: widget.password,
            pin: pin,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save PIN: $e',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF6366F1);

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
              const Color(0xFFEC4899).withOpacity(0.08),
              350,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
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
                                          colors: [
                                            themeColor,
                                            Color(0xFF4F46E5),
                                          ],
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
                                        Icons.pin_outlined,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'Set App Lock PIN',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Create your own 4-digit PIN for app unlock',
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
                                        'New PIN',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: pinController,
                                        obscureText: _obscurePin,
                                        keyboardType: TextInputType.number,
                                        maxLength: 4,
                                        decoration: _inputDecoration(
                                          'Enter 4-digit PIN',
                                          Icons.pin_outlined,
                                          themeColor,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscurePin
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                                  () => _obscurePin = !_obscurePin,
                                            ),
                                          ),
                                        ),
                                        validator: (val) {
                                          final pin = val?.trim() ?? '';

                                          if (pin.length != 4) {
                                            return 'PIN must be exactly 4 digits';
                                          }

                                          if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
                                            return 'Only 4 digits allowed';
                                          }

                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Confirm PIN',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: confirmPinController,
                                        obscureText: _obscureConfirmPin,
                                        keyboardType: TextInputType.number,
                                        maxLength: 4,
                                        decoration: _inputDecoration(
                                          'Re-enter 4-digit PIN',
                                          Icons.lock_reset_rounded,
                                          themeColor,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPin
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                                  () => _obscureConfirmPin =
                                              !_obscureConfirmPin,
                                            ),
                                          ),
                                        ),
                                        validator: (val) {
                                          final confirmPin = val?.trim() ?? '';
                                          final originalPin =
                                          pinController.text.trim();

                                          if (confirmPin.length != 4) {
                                            return 'Confirm PIN must be 4 digits';
                                          }

                                          if (confirmPin != originalPin) {
                                            return 'PINs do not match';
                                          }

                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 32),
                                      _buildGradientButton(
                                        text: _isSaving
                                            ? 'Saving...'
                                            : 'Save PIN & Continue',
                                        colors: const [
                                          themeColor,
                                          Color(0xFF4F46E5),
                                        ],
                                        onPressed: _isSaving ? null : _submit,
                                        isLoading: _isSaving,
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

  InputDecoration _inputDecoration(
      String hint,
      IconData icon,
      Color color, {
        Widget? suffix,
      }) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        borderSide: BorderSide(color: color, width: 1.5),
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
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}