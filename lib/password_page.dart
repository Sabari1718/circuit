import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'auth_service.dart';
import 'home_page.dart';
import 'user_service.dart';
import 'set_pin_page.dart';
import 'secret_image_verification_page.dart';
import 'secret_image_setup_page.dart';

class PasswordPage extends ConsumerStatefulWidget {
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
  ConsumerState<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<PasswordPage> {
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
      final userService = ref.read(userServiceProvider);
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

          // Navigate to SecretImageVerificationPage for existing user
          final userData = response['data']?['data'];

          if (userData != null) {
            await ref.read(userServiceProvider).saveFromApiUser(userData);
          }

          // Check if local secret image exists (handles fresh app install scenario)
          final localData = await ref.read(userServiceProvider).getUserData();
          final String localPhone = localData['phone'] ?? '';
          final String localEmail = localData['email'] ?? '';
          final String localUserMainId = localData['user_main_id'] ?? '';

          final List<String> possibleIdentifiers = [
            identifier, // Exact input user typed
            if (localPhone.isNotEmpty) localPhone, // API formatted phone
            if (localEmail.isNotEmpty) localEmail, // API formatted email
            if (localUserMainId.isNotEmpty) localUserMainId, // Invariant ID
          ];

          String? savedImage;
          String? correctIdentifier;

          for (final id in possibleIdentifiers) {
            savedImage = await ref
                .read(userServiceProvider)
                .getUserSecretImage(id);
            if (savedImage != null) {
              correctIdentifier = id;
              break;
            }
          }

          if (!mounted) return;

          if (savedImage == null) {
            // Fresh install or cleared data -> route to setup
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SecretImageSetupPage(identifier: identifier, password: password, isExistingUser: true),
              ),
              (route) => false,
            );
          } else {
            // Secret image exists -> route to verify
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => SecretImageVerificationPage(
                  identifier: correctIdentifier ?? identifier,
                  password: password,
                ),
              ),
              (route) => false,
            );
          }
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
    const Color themeColor = Color(0xFF00E5FF);
    final isExistingUser = widget.isExistingUser;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      children: [
                        if (!isExistingUser) ...[
                          _buildProgressIndicator(themeColor),
                          const SizedBox(height: 40),
                        ],
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
                                                color: themeColor.withOpacity(
                                                  0.4,
                                                ),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            isExistingUser
                                                ? Icons.lock_open_rounded
                                                : Icons.lock_person_rounded,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          isExistingUser
                                              ? 'Welcome Back'
                                              : 'Secure Vault',
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          isExistingUser
                                              ? 'Enter your password to continue'
                                              : 'Choose a master password for your account',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 32,
                                      right: 32,
                                      bottom: 40,
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (isExistingUser) ...[
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.1),
                                                ),
                                              ),
                                              child: Text(
                                                widget
                                                        .passedIdentifier
                                                        .isNotEmpty
                                                    ? widget.passedIdentifier
                                                    : (widget
                                                              .phoneNumber
                                                              .isNotEmpty
                                                          ? widget.phoneNumber
                                                          : widget.email),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                          ],
                                          Text(
                                            isExistingUser
                                                ? 'PASSWORD'
                                                : 'NEW PASSWORD',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller: passwordController,
                                            obscureText: _obscurePassword,
                                            onChanged: isExistingUser
                                                ? null
                                                : _onPasswordChanged,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            decoration: _inputDecoration(
                                              isExistingUser
                                                  ? 'Enter your password'
                                                  : 'Create a strong password',
                                              Icons.lock_outline_rounded,
                                              themeColor,
                                              suffix: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                            .visibility_outlined
                                                      : Icons
                                                            .visibility_off_outlined,
                                                  size: 20,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
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
                                              if (!isExistingUser &&
                                                  val.trim().length < 6) {
                                                return 'Min 6 characters required';
                                              }
                                              return null;
                                            },
                                          ),
                                          if (!isExistingUser) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: LinearProgressIndicator(
                                                    value: _strength,
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.1),
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          _strength < 0.4
                                                              ? const Color(
                                                                  0xFFFF4B4B,
                                                                )
                                                              : (_strength < 0.7
                                                                    ? const Color(
                                                                        0xFFF59E0B,
                                                                      )
                                                                    : themeColor),
                                                        ),
                                                    minHeight: 4,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),
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
                                                        ? const Color(
                                                            0xFFFF4B4B,
                                                          )
                                                        : (_strength < 0.7
                                                              ? const Color(
                                                                  0xFFF59E0B,
                                                                )
                                                              : themeColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            Text(
                                              'CONFIRM PASSWORD',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white.withOpacity(
                                                  0.5,
                                                ),
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextFormField(
                                              controller:
                                                  confirmPasswordController,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                              decoration: _inputDecoration(
                                                'Repeat your password',
                                                Icons.lock_reset_rounded,
                                                themeColor,
                                                suffix: IconButton(
                                                  icon: Icon(
                                                    _obscureConfirmPassword
                                                        ? Icons
                                                              .visibility_outlined
                                                        : Icons
                                                              .visibility_off_outlined,
                                                    size: 20,
                                                    color: Colors.white
                                                        .withOpacity(0.5),
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
                                                : (isExistingUser
                                                      ? 'Login'
                                                      : 'Finalize Account'),
                                            colors: const [
                                              Color(0xFF00E5FF),
                                              Color(0xFF7000FF),
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
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 20)],
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

  Widget _buildProgressIndicator(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 8,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 28,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginResult {
  final bool success;
  final String message;

  const _LoginResult({required this.success, required this.message});
}
