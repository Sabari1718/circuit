import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'home_page.dart';
import 'user_service.dart';
import 'set_pin_page.dart';
import 'secret_image_verification_page.dart';

class PasswordPage extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final bool isExistingUser;
  final String passedIdentifier; // exact input from login page

  const PasswordPage({
    super.key,
    required this.phoneNumber,
    this.email = '',
    this.isExistingUser = false,
    this.passedIdentifier = '',
  });

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
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
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final String password = passwordController.text.trim();

      if (widget.isExistingUser) {
        // ==========================================
        // EXISTING USER LOGIN FLOW
        // ==========================================
        debugPrint("EXISTING USER LOGIN => Attempting API verification");

        // Use exact identifier from login page
        final String identifier = widget.passedIdentifier.isNotEmpty
            ? widget.passedIdentifier.trim()
            : (widget.phoneNumber.isNotEmpty
                  ? widget.phoneNumber.trim()
                  : widget.email.trim());

        debugPrint("ENTERED PASSWORD => $password");

        try {
          final response = await AuthService().login(
            identifier: identifier,
            password: password,
          );

          if (!mounted) return;

          // Bypassing SecretImageVerificationPage
          final userData = response['data']?['data'];
          final String userName = userData?['user_name'] ?? 'User';
          final String email = userData?['email'] ?? '';

          if (userData != null) {
            await Provider.of<UserService>(
              context,
              listen: false,
            ).saveFromApiUser(userData);
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userName: userName, email: email),
            ),
            (route) => false,
          );
          return;
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e
                    .toString()
                    .replaceAll('Exception: ', '')
                    .replaceAll('AuthException: ', ''),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      } else {
        // ==========================================
        // NEW USER FLOW
        // ==========================================
        // NOTE:
        // Nee current flow la new user direct SetPinPage ku poguthu.
        // DB save new user registration flow separate page la irundha
        // adha later connect pannalam.
        await userService.saveUserData(isLoggedIn: true);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SetPinPage(password: passwordController.text.trim()),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<_LoginResult> _loginExistingUser({
    required String identifier,
    required String password,
  }) async {
    // 🔥 EMULATOR URL
    // Real mobile use panna: http://YOUR_PC_IP/login_api/login_or_register.php
    const String apiUrl = "http://10.0.2.2/login_api/login_or_register.php";

    try {
      final Map<String, String> body = {'password': password};

      // mobile ah? email ah?
      if (identifier.contains('@')) {
        body['email'] = identifier;
      } else {
        body['mobile'] = identifier;
      }

      debugPrint("API URL => $apiUrl");
      debugPrint("API BODY => $body");

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body,
          )
          .timeout(const Duration(seconds: 5));

      debugPrint("API STATUS => ${response.statusCode}");
      debugPrint("API RESPONSE => ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic data;

        try {
          data = jsonDecode(response.body);
        } catch (e) {
          return const _LoginResult(
            success: false,
            message: 'Invalid server response',
          );
        }

        bool success = data['status'] == true || data['success'] == true;

        if (success) {
          if (data != null && data['user_main_id'] != null) {
            await UserService().saveUserData(
              userMainId: data['user_main_id'].toString(),
            );
          }
          return _LoginResult(
            success: true,
            message: data['message']?.toString() ?? 'Login successful',
          );
        } else {
          return _LoginResult(
            success: false,
            message: data['message']?.toString() ?? 'Invalid credentials',
          );
        }
      } else {
        return _LoginResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return _LoginResult(success: false, message: 'Login request failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF8B5CF6);

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
            child: _buildBlob(const Color(0xFFEC4899).withOpacity(0.08), 350),
          ),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
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
                                            Color(0xFF7C3AED),
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
                                      child: Icon(
                                        widget.isExistingUser
                                            ? Icons.lock_open_rounded
                                            : Icons.lock_person_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      widget.isExistingUser
                                          ? 'Welcome Back'
                                          : 'Secure Vault',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1E293B),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.isExistingUser
                                          ? 'Enter your password to continue'
                                          : 'Choose a master password for your account',
                                      style: const TextStyle(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (widget.isExistingUser) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Text(
                                            widget.passedIdentifier.isNotEmpty
                                                ? widget.passedIdentifier
                                                : (widget.phoneNumber.isNotEmpty
                                                      ? widget.phoneNumber
                                                      : widget.email),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                      ],
                                      Text(
                                        widget.isExistingUser
                                            ? 'Password'
                                            : 'New Password',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: _obscurePassword,
                                        onChanged: widget.isExistingUser
                                            ? null
                                            : _onPasswordChanged,
                                        decoration: _inputDecoration(
                                          widget.isExistingUser
                                              ? 'Enter your password'
                                              : 'Create a strong password',
                                          Icons.lock_outline_rounded,
                                          themeColor,
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                          ),
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Password required';
                                          }
                                          if (!widget.isExistingUser &&
                                              val.trim().length < 6) {
                                            return 'Min 6 characters required';
                                          }
                                          return null;
                                        },
                                      ),
                                      if (!widget.isExistingUser) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: _strength,
                                                backgroundColor: Colors.black12,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      _strength < 0.4
                                                          ? Colors.red
                                                          : (_strength < 0.7
                                                                ? Colors.orange
                                                                : themeColor),
                                                    ),
                                                minHeight: 4,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _strength < 0.4
                                                  ? 'Weak'
                                                  : (_strength < 0.7
                                                        ? 'Fair'
                                                        : 'Strong'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: _strength < 0.4
                                                    ? Colors.red
                                                    : (_strength < 0.7
                                                          ? Colors.orange
                                                          : themeColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        const Text(
                                          'Confirm Password',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        TextFormField(
                                          controller: confirmPasswordController,
                                          obscureText: _obscureConfirmPassword,
                                          decoration: _inputDecoration(
                                            'Repeat your password',
                                            Icons.lock_reset_rounded,
                                            themeColor,
                                            suffix: IconButton(
                                              icon: Icon(
                                                _obscureConfirmPassword
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                                size: 20,
                                              ),
                                              onPressed: () => setState(
                                                () => _obscureConfirmPassword =
                                                    !_obscureConfirmPassword,
                                              ),
                                            ),
                                          ),
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Confirm password required';
                                            }
                                            if (val !=
                                                passwordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                      const SizedBox(height: 40),
                                      _buildGradientButton(
                                        text: _isSubmitting
                                            ? 'Please wait...'
                                            : (widget.isExistingUser
                                                  ? 'Login'
                                                  : 'Finalize Account'),
                                        colors: const [
                                          themeColor,
                                          Color(0xFF7C3AED),
                                        ],
                                        onPressed: _isSubmitting
                                            ? null
                                            : _submit,
                                        isLoading: _isSubmitting,
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

  Widget _progressDot(bool active, {required Color color}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : Colors.black12,
      ),
    );
  }

  Widget _progressLine(bool active, Color color) {
    return Container(
      width: 20,
      height: 2,
      color: active ? color.withOpacity(0.3) : Colors.black12,
    );
  }
}

class _LoginResult {
  final bool success;
  final String message;

  const _LoginResult({required this.success, required this.message});
}
