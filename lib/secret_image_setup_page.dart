import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_service.dart';
import 'providers.dart';
import 'home_page.dart';
import 'services/captcha_service.dart';
import 'auth_service.dart';
import 'password_page.dart';

class SecretImageSetupPage extends ConsumerStatefulWidget {
  final String identifier;
  final String? password;
  final String? pin;
  final bool isExistingUser;

  const SecretImageSetupPage({
    super.key,
    required this.identifier,
    this.password,
    this.pin,
    this.isExistingUser = false,
  });

  @override
  ConsumerState<SecretImageSetupPage> createState() =>
      _SecretImageSetupPageState();
}

class _SecretImageSetupPageState extends ConsumerState<SecretImageSetupPage> {
  CaptchaCategory? _selectedCategory;
  bool _isLoadingCategories = true;
  bool _isSaving = false;
  List<CaptchaCategory> _categories = [];
  final CaptchaService _captchaService = CaptchaService();

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load images: $e')));
      }
    }
  }

  Future<void> _showConfirmationDialog(CaptchaCategory category) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          if (!_isSaving) {
                            Navigator.pop(dialogContext);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        category.image,
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 180,
                            width: 180,
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 180,
                            width: 180,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                setStateDialog(() => _isSaving = true);
                                await _registerAndLogin(
                                  category,
                                  dialogContext,
                                );
                                if (mounted) {
                                  setStateDialog(() => _isSaving = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isExistingUser
                                    ? "Save Login Image"
                                    : "Create Account & Login",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (!_isSaving) {
                          Navigator.pop(dialogContext);
                        }
                      },
                      child: const Text(
                        "← Back to Password",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Powered by VA groups",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _registerAndLogin(
    CaptchaCategory category,
    BuildContext dialogContext,
  ) async {
    try {
      final userService = ref.read(userServiceProvider);

      if (!widget.isExistingUser &&
          widget.password != null &&
          widget.pin != null) {
        final data = await userService.getUserData();
        final String name = data['name'] ?? 'User';
        final String email = data['email'] ?? '';
        final String mobile = data['phone'] ?? '';
        final String address = data['address'] ?? 'N/A';

        debugPrint("========== REGISTER USER IN BACKEND ==========");
        debugPrint("NAME: $name");
        debugPrint("PHONE: $mobile");
        debugPrint("EMAIL: $email");
        debugPrint("ADDRESS: $address");
        debugPrint("PIN: ${widget.pin}");
        debugPrint("CAPTCHA: ${category.image}");        await AuthService().register(
          phoneNumber: mobile,
          email: email,
          password: widget.password!,
          address: address,
          userName: name,
          pin: widget.pin!,
          captchaImage: category.image,
          captchaImageId: category.id,
        );

        await userService.saveUserData(
          phone: mobile,
          email: email,
        );

        // Save secret image locally so PasswordPage knows we have an image
        await userService.saveUserSecretImage(
          identifier: mobile.isNotEmpty ? mobile : email,
          imageUrl: category.id.toString(), 
        );

        if (!mounted) return;
        Navigator.pop(dialogContext); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! Please verify your password and secret image.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordPage(
              phoneNumber: mobile.isNotEmpty ? mobile : email,
              email: email,
              isExistingUser: true,
              passedIdentifier: mobile.isNotEmpty ? mobile : email,
            ),
          ),
          (route) => false,
        );
        return;
      } else if (widget.isExistingUser && widget.password != null) {
        debugPrint("========== VERIFY CAPTCHA FOR EXISTING USER ==========");
        final loginResponse = await AuthService().login(
          identifier: widget.identifier,
          password: widget.password!,
          captchaImageId: category.id,
        );
        final userData = loginResponse['data']?['data'] ?? loginResponse['data'];
        if (userData != null && userData is Map<String, dynamic>) {
          await userService.saveFromApiUser(userData);
        }
        await userService.saveUserData(isLoggedIn: true);
      }

      // Save secret image locally using the image URL/ID for verification later
      await userService.saveUserSecretImage(
        identifier: widget.identifier,
        imageUrl: category.id
            .toString(), // We store ID as the secret to match against API IDs
      );

      if (!mounted) return;
      Navigator.pop(dialogContext); // Close dialog
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFEFF6FF,
      ), // Light blue background like the screenshot
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Area
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: const Column(
                        children: [
                          // You would place the logo here
                          Icon(Icons.security, size: 48, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            "Web Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Multi-factor Authentication",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Set your login image",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.isExistingUser
                                ? "Choose your image to proceed"
                                : "Choose an image to secure your new account",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          if (_isLoadingCategories)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_categories.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Text("No images available"),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                    _showConfirmationDialog(category);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      category.image,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return Container(
                                              color: Colors.grey.shade100,
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade100,
                                              child: const Icon(
                                                Icons.error,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                );
                              },
                            ),

                          const SizedBox(height: 30),

                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text(
                                    "← Back to Password",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Powered by VA groups",
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
