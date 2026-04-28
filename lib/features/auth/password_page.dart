import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:circuit/features/home/home_page.dart';
import 'package:circuit/core/services/user_service.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _strength = 0;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String val) {
    setState(() {
      _strength = (val.length / 10).clamp(0, 1);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      // Set session as logged in
      await UserService().saveUserData(isLoggedIn: true);

      // Use UserService to fetch final session data
      final data = await UserService().getUserData();
      final String name = data['name']!;
      final String email = data['email']!;

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userName: name,
              email: email,
            ),
          ),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _buildBlob(themeColor.withOpacity(0.12), 300)),
          Positioned(bottom: -50, left: -100, child: _buildBlob(const Color(0xFFEC4899).withOpacity(0.08), 350)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _progressDot(true, color: const Color(0xFF6366F1)),
                      _progressLine(true, const Color(0xFF6366F1)),
                      _progressDot(true, color: const Color(0xFF6366F1)),
                      _progressLine(true, const Color(0xFF10B981)),
                      _progressDot(true, color: const Color(0xFF10B981)),
                      _progressLine(true, themeColor),
                      _progressDot(true, color: themeColor),
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
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [themeColor.withOpacity(0.05), themeColor.withOpacity(0.01)],
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
                                        gradient: const LinearGradient(colors: [themeColor, Color(0xFF7C3AED)]),
                                        boxShadow: [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                                      ),
                                      child: const Icon(Icons.lock_person_rounded, color: Colors.white, size: 36),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text('Secure Vault', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                                    const SizedBox(height: 8),
                                    const Text('Choose a master password for your account', style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
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
                                      const Text('New Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: _obscurePassword,
                                        onChanged: _onPasswordChanged,
                                        decoration: _inputDecoration(
                                          'Create a strong password',
                                          Icons.lock_outline_rounded,
                                          themeColor,
                                          suffix: IconButton(
                                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                          ),
                                        ),
                                        validator: (val) => (val == null || val.length < 6) ? 'Min 6 characters required' : null,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: _strength,
                                              backgroundColor: Colors.black12,
                                              valueColor: AlwaysStoppedAnimation<Color>(_strength < 0.4 ? Colors.red : (_strength < 0.7 ? Colors.orange : themeColor)),
                                              minHeight: 4,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _strength < 0.4 ? 'Weak' : (_strength < 0.7 ? 'Fair' : 'Strong'),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _strength < 0.4 ? Colors.red : (_strength < 0.7 ? Colors.orange : themeColor)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      const Text('Confirm Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: confirmPasswordController,
                                        obscureText: _obscureConfirmPassword,
                                        decoration: _inputDecoration(
                                          'Repeat your password',
                                          Icons.lock_reset_rounded,
                                          themeColor,
                                          suffix: IconButton(
                                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                          ),
                                        ),
                                        validator: (val) => val != passwordController.text ? 'Passwords do not match' : null,
                                      ),
                                      const SizedBox(height: 40),
                                      _buildGradientButton(text: 'Finalize Account', colors: [themeColor, const Color(0xFF7C3AED)], onPressed: _submit),
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

  InputDecoration _inputDecoration(String hint, IconData icon, Color color, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: color, width: 1.5)),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }

  Widget _buildGradientButton({required String text, required List<Color> colors, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: colors),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _progressDot(bool active, {required Color color}) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? color : Colors.black12));
  }

  Widget _progressLine(bool active, Color color) {
    return Container(width: 20, height: 2, color: active ? color.withOpacity(0.3) : Colors.black12);
  }
}