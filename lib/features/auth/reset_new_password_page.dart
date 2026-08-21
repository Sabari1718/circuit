import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth_service.dart';
import 'reset_new_captcha_page.dart';
import 'reset_final_login_verification_page.dart';

class ResetNewPasswordPage extends StatefulWidget {
  final bool isCaptchaSelected;
  final String identifier;
  final String otp;

  const ResetNewPasswordPage({
    super.key,
    required this.isCaptchaSelected,
    required this.identifier,
    required this.otp,
  });

  @override
  State<ResetNewPasswordPage> createState() => _ResetNewPasswordPageState();
}

class _ResetNewPasswordPageState extends State<ResetNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    final pass = _passwordController.text;
    final conf = _confirmController.text;

    if (pass.isEmpty || conf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter and confirm your new password')),
      );
      return;
    }

    if (pass != conf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (widget.isCaptchaSelected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetNewCaptchaPage(
            identifier: widget.identifier,
            otp: widget.otp,
            newPassword: pass,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService().resetAccess(
          identifier: widget.identifier,
          otp: widget.otp,
          newPassword: pass,
        );

        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetFinalLoginVerificationPage(
              identifier: widget.identifier,
              newPassword: pass,
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
                                    Icons.lock_reset,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'New Password',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create a new strong password',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // New Password Input
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'New Password',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
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
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Confirm Password Input
                                TextField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Confirm Password',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
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
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.white54,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirm = !_obscureConfirm;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
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
                                      onPressed: _isLoading ? null : _onNext,
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
                                          : Text(
                                              widget.isCaptchaSelected ? 'Next' : 'Save & Login',
                                              style: const TextStyle(
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
