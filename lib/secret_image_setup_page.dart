import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_service.dart';
import 'providers.dart';
import 'home_page.dart';

class SecretImageSetupPage extends ConsumerStatefulWidget {
  final String identifier;

  const SecretImageSetupPage({super.key, required this.identifier});

  @override
  ConsumerState<SecretImageSetupPage> createState() =>
      _SecretImageSetupPageState();
}

class _SecretImageSetupPageState extends ConsumerState<SecretImageSetupPage> {
  String? _selectedImage;
  bool _isSaving = false;

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

  Future<void> _saveAndContinue() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userService = ref.read(userServiceProvider);
      await userService.saveUserSecretImage(
        identifier: widget.identifier,
        imageUrl: _selectedImage!,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving secret image: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Set Secret Image",
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
                "Please select an image. You will need to choose this same image when logging in.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
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
                  onPressed: _isSaving ? null : _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save & Continue",
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
