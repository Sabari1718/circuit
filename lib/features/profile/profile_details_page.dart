import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:circuit/features/auth/password_page.dart';
import 'package:circuit/core/services/user_service.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _submitData() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final String enteredName = nameController.text.trim();
      final String enteredAddress = addressController.text.trim();

      // Persistence: Save name and address to session
      await UserService().saveUserData(
        name: enteredName,
        address: enteredAddress,
      );

      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned(top: -100, left: -50, child: _buildBlob(themeColor.withOpacity(0.1), 300)),
          Positioned(bottom: -50, right: -100, child: _buildBlob(const Color(0xFF6366F1).withOpacity(0.08), 350)),

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
                      _progressLine(true, themeColor),
                      _progressDot(true, color: themeColor),
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
                                        gradient: const LinearGradient(colors: [themeColor, Color(0xFF059669)]),
                                        boxShadow: [BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                                      ),
                                      child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 36),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text('Profile Details', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)),
                                    const SizedBox(height: 8),
                                    const Text('Personalize your secure account', style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(32, 10, 32, 32),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), letterSpacing: 0.5)),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: nameController,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        decoration: _inputDecoration('Enter your full name', Icons.person_outline_rounded, themeColor),
                                        validator: (value) => (value == null || value.trim().length < 3) ? 'Minimum 3 characters' : null,
                                      ),
                                      const SizedBox(height: 24),
                                      const Text('Residential Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), letterSpacing: 0.5)),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: addressController,
                                        maxLines: 3,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        decoration: _inputDecoration('Enter your physical address', Icons.location_on_outlined, themeColor),
                                        // FIX 1: Removed min-length 10 validation. Only check for non-empty.
                                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Address is required' : null,
                                      ),
                                      const SizedBox(height: 40),
                                      _buildGradientButton(text: 'Complete Setup', colors: [themeColor, const Color(0xFF059669)], onPressed: _submitData),
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

  InputDecoration _inputDecoration(String hint, IconData icon, Color color) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
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

  Widget _progressDot(bool active, {Color color = const Color(0xFF6366F1)}) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? color : Colors.black12));
  }

  Widget _progressLine(bool active, Color color) {
    return Container(width: 20, height: 2, color: active ? color.withOpacity(0.3) : Colors.black12);
  }
}
