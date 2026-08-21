import 'dart:ui';
import 'package:flutter/material.dart';
import '../../auth_service.dart';
import 'reset_otp_verification_page.dart';

class ResetOtpMethodPage extends StatefulWidget {
  final bool isPasswordSelected;
  final bool isCaptchaSelected;

  const ResetOtpMethodPage({
    super.key,
    required this.isPasswordSelected,
    required this.isCaptchaSelected,
  });

  @override
  State<ResetOtpMethodPage> createState() => _ResetOtpMethodPageState();
}

class _ResetOtpMethodPageState extends State<ResetOtpMethodPage> {
  bool isWhatsAppSelected = true; // WhatsApp by default
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _onSendOtp() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter ${isWhatsAppSelected ? 'WhatsApp number' : 'Email'}')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().requestResetOtp(
        input,
        isCaptchaOnly: widget.isCaptchaSelected && !widget.isPasswordSelected,
      );
      
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetOtpVerificationPage(
            sentTo: input,
            method: isWhatsAppSelected ? 'WhatsApp' : 'Email',
            identifier: input,
            isPasswordSelected: widget.isPasswordSelected,
            isCaptchaSelected: widget.isCaptchaSelected,
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

  Widget _buildMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E5FF) : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00E5FF).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF00E5FF) : Colors.white54,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
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
                                    Icons.message_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Send OTP',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Choose how you want to receive the OTP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.6),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Selection Cards
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildMethodCard(
                                        title: 'WhatsApp',
                                        subtitle: 'Send to WhatsApp number',
                                        icon: Icons.chat_outlined,
                                        isSelected: isWhatsAppSelected,
                                        onTap: () {
                                          setState(() {
                                            isWhatsAppSelected = true;
                                            _inputController.clear();
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildMethodCard(
                                        title: 'Email',
                                        subtitle: 'Send to email address',
                                        icon: Icons.email_outlined,
                                        isSelected: !isWhatsAppSelected,
                                        onTap: () {
                                          setState(() {
                                            isWhatsAppSelected = false;
                                            _inputController.clear();
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                
                                // Input Field
                                TextField(
                                  controller: _inputController,
                                  keyboardType: isWhatsAppSelected ? TextInputType.phone : TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: isWhatsAppSelected ? 'Enter WhatsApp Number' : 'Enter Email Address',
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
                                    prefixIcon: Icon(
                                      isWhatsAppSelected ? Icons.phone_android : Icons.email_outlined,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // Send OTP Button
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
                                      onPressed: _isLoading ? null : _onSendOtp,
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
                                              'Send OTP',
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
