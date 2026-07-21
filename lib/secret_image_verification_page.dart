import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_service.dart';
import 'providers.dart';
import 'home_page.dart';

class SecretImageVerificationPage extends ConsumerStatefulWidget {
  final String identifier;

  const SecretImageVerificationPage({super.key, required this.identifier});

  @override
  ConsumerState<SecretImageVerificationPage> createState() =>
      _SecretImageVerificationPageState();
}

class _SecretImageVerificationPageState
    extends ConsumerState<SecretImageVerificationPage> {
  String? _selectedImage;
  bool _isVerifying = false;

  final List<String> _images = [
    'assets/captcha/dog.jpg',
    'assets/captcha/cat.jpg',
    'assets/captcha/parrot.jpg',
    'assets/captcha/car.jpg',
    'assets/captcha/sports_bike.jpg',
    'assets/captcha/train.jpg',
    'assets/captcha/airplane.jpg',
    'assets/captcha/bicycle.jpg',
    'assets/captcha/coconut_tree.jpg',
    'assets/captcha/mountain.jpg',
    'assets/captcha/sunflower.jpg',
    'assets/captcha/temple.jpg',
  ];

  Future<void> _verify() async {
    if (_selectedImage == null) {
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

      if (savedImage == _selectedImage) {
        // Success
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
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final imageUrl = _images[index];
                      final isSelected = _selectedImage == imageUrl;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImage = imageUrl;
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(isSelected ? 10.0 : 0.0),
                                child: Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
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
                  onPressed: _isVerifying ? null : _verify,
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
