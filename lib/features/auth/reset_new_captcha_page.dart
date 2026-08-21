import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth_service.dart';
import '../../services/captcha_service.dart';
import 'reset_final_login_verification_page.dart';

class ResetNewCaptchaPage extends StatefulWidget {
  final String identifier;
  final String otp;
  final String? newPassword;

  const ResetNewCaptchaPage({
    super.key,
    required this.identifier,
    required this.otp,
    this.newPassword,
  });

  @override
  State<ResetNewCaptchaPage> createState() => _ResetNewCaptchaPageState();
}

class _ResetNewCaptchaPageState extends State<ResetNewCaptchaPage> {
  bool _isLoading = false;
  bool _isLoadingCategories = true;
  List<CaptchaCategory> _categories = [];
  final CaptchaService _captchaService = CaptchaService();
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _captchaService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load images: $e')),
        );
      }
    }
  }

  Future<void> _onResetAndLogin() async {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final selectedCategory = _categories[_selectedIndex!];
      
      await AuthService().resetAccess(
        identifier: widget.identifier,
        otp: widget.otp,
        newPassword: widget.newPassword,
        captchaImageId: selectedCategory.id,
      );

      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetFinalLoginVerificationPage(
            identifier: widget.identifier,
            newPassword: widget.newPassword,
          ),
        ),
      );
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
                            padding: const EdgeInsets.all(20.0),
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
                                    Icons.image_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'New Captcha',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select a new secret image for your account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Image Grid
                                _isLoadingCategories
                                    ? const Center(
                                        child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1,
                                        ),
                                        itemCount: _categories.length,
                                        itemBuilder: (context, index) {
                                          final category = _categories[index];
                                          final isSelected = _selectedIndex == index;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedIndex = index;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: isSelected ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.1),
                                                  width: isSelected ? 3 : 1,
                                                ),
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: const Color(0xFF00E5FF).withOpacity(0.3),
                                                          blurRadius: 12,
                                                          spreadRadius: 2,
                                                        )
                                                      ]
                                                    : null,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(14),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Image.network(
                                                      category.image,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return const Center(
                                                          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                                                        );
                                                      },
                                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                                        Icons.broken_image,
                                                        color: Colors.white54,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    if (isSelected)
                                                      Container(
                                                        color: Colors.black.withOpacity(0.3),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.check_circle,
                                                            color: Color(0xFF00E5FF),
                                                            size: 40,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                const SizedBox(height: 16),
                                
                                // Continue Button
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
                                      onPressed: _isLoading ? null : _onResetAndLogin,
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
                                              'Save & Login',
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
                                
                                // Back Link
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
