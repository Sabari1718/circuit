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
    'https://picsum.photos/id/237/200', // dog
    'https://picsum.photos/id/1025/200', // pug
    'https://picsum.photos/id/1074/200', // lion
    'https://picsum.photos/id/219/200', // tiger
    'https://picsum.photos/id/200/200', // cow
    'https://picsum.photos/id/1071/200', // car
    'https://picsum.photos/id/1072/200', // car 2
    'https://picsum.photos/id/146/200', // bike
    'https://picsum.photos/id/1080/200', // strawberry
    'https://picsum.photos/id/43/200', // coffee
    'https://picsum.photos/id/1040/200', // castle
    'https://picsum.photos/id/250/200', // camera
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
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  );
                },
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
