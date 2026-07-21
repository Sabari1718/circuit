import 'dart:ui';
import 'package:flutter/material.dart';
import 'password_page.dart';
import 'user_service.dart';

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordPage(phoneNumber: '',)));
      }
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
            Positioned(top: -100, left: -50, child: _buildBlob(themeColor.withOpacity(0.15), 300)),
            Positioned(bottom: -50, right: -100, child: _buildBlob(const Color(0xFF7000FF).withOpacity(0.15), 350)),

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
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7000FF)]),
                                            boxShadow: [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                                          ),
                                          child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 36),
                                        ),
                                        const SizedBox(height: 24),
                                        const Text('Profile Details', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                                        const SizedBox(height: 8),
                                        Text('Personalize your secure account', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(32, 10, 32, 40),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('FULL NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5), letterSpacing: 1.2)),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: nameController,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                            decoration: _inputDecoration('Enter your full name', Icons.person_outline_rounded, themeColor),
                                            validator: (value) => (value == null || value.trim().length < 3) ? 'Minimum 3 characters' : null,
                                          ),
                                          const SizedBox(height: 24),
                                          Text('RESIDENTIAL ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5), letterSpacing: 1.2)),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: addressController,
                                            maxLines: 3,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                            decoration: _inputDecoration('Enter your physical address', Icons.location_on_outlined, themeColor),
                                            // FIX 1: Removed min-length 10 validation. Only check for non-empty.
                                            validator: (value) => (value == null || value.trim().isEmpty) ? 'Address is required' : null,
                                          ),
                                          const SizedBox(height: 40),
                                          _buildGradientButton(text: 'Complete Setup', colors: const [Color(0xFF00E5FF), Color(0xFF7000FF)], onPressed: _submitData),
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

  InputDecoration _inputDecoration(String hint, IconData icon, Color color) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: Icon(icon, size: 22, color: Colors.white.withOpacity(0.7)),
      ),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color, width: 2)),
      errorStyle: const TextStyle(color: Color(0xFFFF4B4B)),
      alignLabelWithHint: true,
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size, 
      height: size, 
      decoration: BoxDecoration(
        color: color, 
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 20)]
      )
    );
  }

  Widget _buildGradientButton({required String text, required List<Color> colors, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: colors),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
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
      ],
    );
  }
}
