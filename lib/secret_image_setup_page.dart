import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'user_service.dart';

class SecretImageSetupPage extends StatefulWidget {
  final String mobile;
  final String email;
  final String password;
  final String pin;

  const SecretImageSetupPage({
    super.key,
    required this.mobile,
    required this.email,
    required this.password,
    required this.pin,
  });

  @override
  State<SecretImageSetupPage> createState() => _SecretImageSetupPageState();
}

class _SecretImageSetupPageState extends State<SecretImageSetupPage> {
  String? _selectedImage;
  bool _isSaving = false;

  final List<String> _images = List.generate(
    15,
    (index) => 'https://picsum.photos/id/${index + 10}/200/200',
  );

  Future<void> _submit() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a secret image')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      
      // Save user with the secret image
      await userService.saveRegisteredUser(
        mobile: widget.mobile,
        email: widget.email,
        password: widget.password,
        pin: widget.pin,
        secretImage: _selectedImage!,
      );

      // Set user as logged in with the session data
      await userService.saveUserData(
        phone: widget.mobile,
        email: widget.email,
        secretImage: _selectedImage,
        isLoggedIn: true,
      );

      final userData = await userService.getUserData();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: userData['name'] ?? 'User',
            email: userData['email'] ?? '',
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Setup failed: $e')),
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
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(color: themeColor.withOpacity(0.12), shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Security Image',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Select one secret image for your account. You will need to select this same image during future logins.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: GridView.builder(
                      itemCount: _images.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final img = _images[index];
                        final isSelected = _selectedImage == img;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedImage = img),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? themeColor : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                              ] : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.network(
                                img,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(color: Colors.grey.shade100);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(colors: [themeColor, Color(0xFF4F46E5)]),
                      boxShadow: [
                        BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Complete Setup',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
