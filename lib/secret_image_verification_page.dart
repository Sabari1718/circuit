import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_service.dart';
import 'providers.dart';
import 'home_page.dart';
import 'services/captcha_service.dart';
import 'auth_service.dart';

class SecretImageVerificationPage extends ConsumerStatefulWidget {
  final String identifier;
  final String? password;

  const SecretImageVerificationPage({super.key, required this.identifier, this.password});

  @override
  ConsumerState<SecretImageVerificationPage> createState() =>
      _SecretImageVerificationPageState();
}

class _SecretImageVerificationPageState
    extends ConsumerState<SecretImageVerificationPage> {
  CaptchaCategory? _selectedCategory;
  bool _isVerifying = false;
  bool _isLoadingCategories = true;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load images: $e')),
        );
      }
    }
  }

  Future<void> _verify() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your secret image')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final userService = ref.read(userServiceProvider);
      final savedImage = await userService.getUserSecretImage(widget.identifier);

      if (!mounted) return;

      // We saved the image ID as a string during setup
      if (savedImage == _selectedCategory!.id.toString() || savedImage == _selectedCategory!.image) {
        
        // If password was passed, verify via API to get the token!
        if (widget.password != null) {
          try {
            final response = await AuthService().login(
              identifier: widget.identifier,
              password: widget.password!,
              captchaImageId: _selectedCategory!.id,
            );
            
            final userData = response['data']?['data'];
            if (userData != null) {
              await userService.saveFromApiUser(userData);
            }
          } catch (apiError) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(apiError.toString().replaceAll('AuthException: ', '')),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
        }
        
        // Success
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      } else {
        // Failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect secret image! Access denied.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying image: $e')),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Verify Identity",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                "Please select your secret image to proceed.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: _isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : _categories.isEmpty
                          ? const Center(child: Text("No images available"))
                          : GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                              ),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final isSelected =
                                    _selectedCategory?.id == category.id;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          padding: EdgeInsets.all(
                                              isSelected ? 10.0 : 0.0),
                                          child: Image.network(
                                            category.image,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return Container(
                                                color: Colors.grey.shade200,
                                                child: const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.error,
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF6366F1),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying || _selectedCategory == null ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verify & Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
