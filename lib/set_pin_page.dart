import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'user_service.dart';
import 'app_lock_service.dart';
import 'auth_service.dart';
import 'secret_image_setup_page.dart';

class SetPinPage extends ConsumerStatefulWidget {
  final String password;

  const SetPinPage({super.key, required this.password});

  @override
  ConsumerState<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends ConsumerState<SetPinPage> {
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
      final userService = ref.read(userServiceProvider);
      final String pin = pinController.text.trim();

      // Save user's own PIN + password fallback + enable app lock
      await AppLockService().enableAppLock(pin: pin, password: widget.password);

      final data = await userService.getUserData();
      final String name = data['name'] ?? 'User';
      final String email = data['email'] ?? '';
      final String mobile = data['phone'] ?? '';
      final String address = data['address'] ?? 'N/A';

      print("========== REGISTER USER IN BACKEND ==========");
      print("NAME: $name");
      print("PHONE: $mobile");
      print("EMAIL: $email");
      print("ADDRESS: $address");
      print("PIN: $pin");

      final registerResult = await AuthService().register(
        phoneNumber: mobile,
        email: email,
        password: widget.password,
        address: address,
        userName: name,
        pin: pin,
      );

      print("REGISTER RESULT: $registerResult");

      try {
        // Verify if token exists locally, if not, perform a programmatic login to get the JWT token.
        final String? token = await AuthService().getToken();
        if (token == null || token.trim().isEmpty) {
          print(
            "No token in registration response. Logging in programmatically...",
          );
          final String identifier = mobile.isNotEmpty ? mobile : email;
          final loginResponse = await AuthService().login(
            identifier: identifier,
            password: widget.password,
          );
          final userData = loginResponse['data']?['data'];
          if (userData != null) {
            await userService.saveFromApiUser(userData);
          }
        }
      } catch (loginErr) {
        print("Programmatic login failed: $loginErr");
      }

      try {
        // Only save session data. Registration data is stored securely in DB.
        // Set user session data with isLoggedIn: true
        await userService.saveUserData(
          phone: mobile,
          email: email,
          secretImage: 'bypassed',
          isLoggedIn: true,
        );
      } catch (saveErr) {
        print("Saving user session locally failed: $saveErr");
      }

      print("PIN SAVED AND USER REGISTERED SUCCESSFULLY");

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SecretImageSetupPage(identifier: mobile.isNotEmpty ? mobile : email)),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Error Saving PIN",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            e
                .toString()
                .replaceAll('Exception: ', '')
                .replaceAll('AuthException: ', ''),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
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
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Create your own 6-digit PIN for app unlock',
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
                                            'NEW PIN',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.5),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: pinController,
                                            obscureText: _obscurePin,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                            decoration: _inputDecoration(
                                              'Enter 6-digit PIN',
                                              Icons.pin_outlined,
                                              themeColor,
                                              suffix: IconButton(
                                                icon: Icon(
                                                  _obscurePin
                                                      ? Icons.visibility_outlined
                                                      : Icons.visibility_off_outlined,
                                                  size: 20,
                                                  color: Colors.white.withOpacity(0.5),
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscurePin = !_obscurePin,
                                                ),
                                              ),
                                            ),
                                            validator: (val) {
                                              final pin = val?.trim() ?? '';
                                              if (pin.length != 6) {
                                                return 'PIN must be exactly 6 digits';
                                              }
                                              if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
                                                return 'Only 6 digits allowed';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'CONFIRM PIN',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.5),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: confirmPinController,
                                            obscureText: _obscureConfirmPin,
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                            decoration: _inputDecoration(
                                              'Re-enter 6-digit PIN',
                                              Icons.lock_reset_rounded,
                                              themeColor,
                                              suffix: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPin
                                                      ? Icons.visibility_outlined
                                                      : Icons.visibility_off_outlined,
                                                  size: 20,
                                                  color: Colors.white.withOpacity(0.5),
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscureConfirmPin = !_obscureConfirmPin,
                                                ),
                                              ),
                                            ),
                                            validator: (val) {
                                              final confirmPin = val?.trim() ?? '';
                                              final originalPin = pinController.text.trim();
                                              if (confirmPin.length != 6) {
                                                return 'Confirm PIN must be 6 digits';
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
                                              Color(0xFF00E5FF),
                                              Color(0xFF7000FF),
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

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    Color color, {
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 15),
      counterText: '',
      prefixIcon: Icon(icon, size: 22, color: Colors.white.withOpacity(0.7)),
      suffixIcon: suffix,
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
        borderSide: BorderSide(color: color, width: 2),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF4B4B)),
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
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
