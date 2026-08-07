import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/common_dashboard_app_bar.dart';
import '../user_service.dart';
import 'dart:convert';
class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final TextEditingController _panController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploading = false;
  bool _panUploaded = false;
  File? _panImageFile;

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (pickedFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      setState(() {
        _panImageFile = File(pickedFile.path);
        _panUploaded = true;
        _isUploading = false;
      });

      _showSnackBar("PAN Photo uploaded successfully", isError: false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _panUploaded = false;
        _panImageFile = null;
      });

      _showSnackBar("Failed to upload PAN photo");
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validatePan(String? value) {
    final pan = (value ?? '').trim().toUpperCase();

    if (pan.isEmpty) {
      return "Enter PAN number";
    }

    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(pan)) {
      return "Enter valid PAN (e.g. ABCDE1234F)";
    }

    return null;
  }

  void _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (!_panUploaded || _panImageFile == null) {
        _showSnackBar("Please upload PAN photo first");
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        final userData = await UserService().getUserData();
        final String userMainId = userData['user_main_id'] ?? '';
        if (userMainId.isEmpty) {
          _showSnackBar("User ID not found, please login again");
          return;
        }

        final panBytes = await _panImageFile!.readAsBytes();
        final panBase64 = 'data:image/jpeg;base64,' + base64Encode(panBytes);

        String profilePhotoBase64 = '';
        if (UserService().profilePhotoBytes != null) {
          profilePhotoBase64 = 'data:image/jpeg;base64,' + base64Encode(UserService().profilePhotoBytes!);
        }

        // 1. Register User Upgrade
        final registerPayload = {
          "user_main_id": userMainId,
          "pan_number": _panController.text.trim().toUpperCase(),
          "gender": "male",
          "is_verified": 0,
          "pan_front_photo": panBase64,
          "profile_photo": profilePhotoBase64,
          "user_type": "register"
        };

        final registerRes = await UserService().registerUserUpgrade(registerPayload);
        
        bool isSuccess = false;
        if (registerRes != null) {
           if (registerRes['code'] == 200) {
              isSuccess = true;
           } else if (registerRes['data'] != null && registerRes['data']['code'] == 200) {
              isSuccess = true;
           }
        }

        if (!isSuccess) {
          _showSnackBar("Failed to register upgrade");
          return;
        }

        // 2. Fetch User from Login API
        await UserService().getManageLoginUser(userMainId);

        // 3. Fetch Captcha Images
        final captchaImages = await UserService().getCaptchaImages(3);
        if (captchaImages != null && captchaImages.isNotEmpty) {
          final firstImage = captchaImages[0];
          
          // 4. Create Manage Captcha
          final captchaPayload = {
            "user_main_id": userMainId,
            "manage_captcha_id": firstImage['id'],
            "password": "123456", 
            "key": "Manage_login_pass",
            "image": firstImage['image_path']
          };

          await UserService().createManageCaptcha(captchaPayload);
        }

        _showSnackBar("Account upgraded to REGISTERED!", isError: false);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        _showSnackBar("An error occurred during upgrade");
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upgrade to Registered",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Complete verification to unlock standard features",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PAN Number",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _panController,
                      decoration: _inputDecoration(
                        "Enter 10-digit PAN",
                        Icons.badge_outlined,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(10),
                        UpperCaseTextFormatter(),
                      ],
                      validator: _validatePan,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "PAN Card Photo (Front)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _isUploading ? null : _handleUpload,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _panUploaded
                                ? const Color(0xFF10B981)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _isUploading
                              ? const Center(
                            child: CircularProgressIndicator(),
                          )
                              : _panImageFile != null
                              ? Image.file(
                            _panImageFile!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                              : Center(
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  color: Color(0xFF94A3B8),
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Click to Upload Photo",
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
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
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Verify & Upgrade Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}


