import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'addresses_and_proof_page.dart';
import '../../user_service.dart';

class IdentityVerificationPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const IdentityVerificationPage({super.key, this.initialData});

  @override
  State<IdentityVerificationPage> createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  String? selectedGender;
  
  String? profilePhotoName;
  String? panDocName;
  
  String? profilePhotoBase64;
  String? panDocBase64;
  
  late final TextEditingController _panController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _panController = TextEditingController(text: widget.initialData?['pan_number']?.toString() ?? '');
    
    final initialGender = widget.initialData?['gender']?.toString();
    if (initialGender != null && initialGender.isNotEmpty) {
      final formattedGender = initialGender[0].toUpperCase() + initialGender.substring(1).toLowerCase();
      if (["Male", "Female", "Other"].contains(formattedGender)) {
        selectedGender = formattedGender;
      }
    }

    final initialProfilePath = widget.initialData?['profile_photo_path']?.toString() ?? widget.initialData?['profile_photo']?.toString();
    if (initialProfilePath != null && initialProfilePath.isNotEmpty) {
      profilePhotoName = initialProfilePath.split('/').last;
    }
    
    final initialPanPath = widget.initialData?['pan_document_path']?.toString() ?? widget.initialData?['pan_front_photo']?.toString();
    if (initialPanPath != null && initialPanPath.isNotEmpty) {
      panDocName = initialPanPath.split('/').last;
    }
  }

  Future<void> _pickFile(Function(String?, String?) onPicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final base64String = "data:image/png;base64,${base64Encode(bytes)}";
      onPicked(result.files.single.name, base64String);
    }
  }

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Step 1: Registered User Account Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Provide your basic identification and PAN card properties to register.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Stepper mockup
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator("1", "Registered User", true),
                      Container(width: 40, height: 1, color: const Color(0xFFE2E8F0)),
                      _buildStepIndicator("2", "Verified User", false),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Form
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    if (isMobile) {
                      return Column(
                        children: [
                          _buildDropdownField("Gender *", "Select Gender", ["Male", "Female", "Other"], selectedGender, (v) => setState(() => selectedGender = v)),
                          const SizedBox(height: 24),
                          _buildTextField("PAN Number *", "Enter PAN Number", _panController, isUpperCase: true),
                          const SizedBox(height: 24),
                          _buildFilePicker("Profile Photo *", profilePhotoName, () => _pickFile((name, base64) => setState(() { profilePhotoName = name; profilePhotoBase64 = base64; })), isImage: true),
                          const SizedBox(height: 24),
                          _buildFilePicker("PAN Card Photo (Front) *", panDocName, () => _pickFile((name, base64) => setState(() { panDocName = name; panDocBase64 = base64; }))),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDropdownField("Gender *", "Select Gender", ["Male", "Female", "Other"], selectedGender, (v) => setState(() => selectedGender = v)),
                              const SizedBox(height: 24),
                              _buildTextField("PAN Number *", "Enter PAN Number", _panController, isUpperCase: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilePicker("Profile Photo *", profilePhotoName, () => _pickFile((name, base64) => setState(() { profilePhotoName = name; profilePhotoBase64 = base64; })), isImage: true),
                              const SizedBox(height: 24),
                              _buildFilePicker("PAN Card Photo (Front) *", panDocName, () => _pickFile((name, base64) => setState(() { panDocName = name; panDocBase64 = base64; }))),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                Row(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        color: Colors.white,
                      ),
                      child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Color(0xFF0F172A), size: 18),
                        label: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF2563EB),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : () async {
                            bool hasProfile = profilePhotoBase64 != null || (widget.initialData?['profile_photo_path'] != null) || (widget.initialData?['profile_photo'] != null);
                            bool hasPanDoc = panDocBase64 != null || (widget.initialData?['pan_document_path'] != null) || (widget.initialData?['pan_front_photo'] != null);

                            if (selectedGender == null || 
                                _panController.text.isEmpty ||
                                !hasProfile ||
                                !hasPanDoc) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill all required fields and upload images')),
                              );
                              return;
                            }

                            // If they haven't completed Registered User upgrade yet, submit it now
                            if (widget.initialData == null) {
                              setState(() => _isLoading = true);
                              
                              final userData = await UserService().getUserData();
                              final String actualUserMainId = userData['user_main_id']?.toString() ?? "";
                              
                              if (actualUserMainId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error: User ID not found. Please log in again.')),
                                );
                                setState(() => _isLoading = false);
                                return;
                              }

                              final payload = {
                                "user_main_id": actualUserMainId,
                                "pan_number": _panController.text,
                                "gender": selectedGender!.toLowerCase(),
                                "is_verified": 0,
                                "pan_front_photo": panDocBase64 ?? "",
                                "profile_photo": profilePhotoBase64 ?? "",
                                "user_type": "register"
                              };

                              final response = await UserService().registerUserUpgrade(payload);
                              
                              if (!mounted) return;
                              setState(() => _isLoading = false);

                              if (response != null) {
                                final inner = response['data'] as Map<String, dynamic>?;
                                if (inner?['code'] != 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(inner?['message'] ?? 'Failed to register basic details.')),
                                  );
                                  return;
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to submit. Please try again later.')),
                                );
                                return;
                              }
                            }
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddressesAndProofPage(
                                  gender: selectedGender!,
                                  panNumber: _panController.text,
                                  profilePhotoBase64: profilePhotoBase64 ?? widget.initialData?['profile_photo']?.toString() ?? widget.initialData?['profile_photo_path']?.toString() ?? '',
                                  panDocBase64: panDocBase64 ?? widget.initialData?['pan_front_photo']?.toString() ?? widget.initialData?['pan_document_path']?.toString() ?? '',
                                  initialData: widget.initialData,
                                ),
                              ),
                            );
                          },
                          icon: _isLoading 
                              ? const SizedBox(width: 18) 
                              : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          label: _isLoading
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "Next",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String number, String title, bool isActive) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {bool isUpperCase = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            textCapitalization: isUpperCase ? TextCapitalization.characters : TextCapitalization.none,
            inputFormatters: isUpperCase ? [UpperCaseTextFormatter()] : null,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, String? fileName, VoidCallback onTap, {bool isImage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onTap,
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: const Center(
                    child: Text(
                      "Choose File",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    fileName ?? "No file chosen",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: fileName != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (fileName != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showImageModal(context, fileName, isImage),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(isImage ? Icons.image : Icons.insert_drive_file, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 4),
                            const Text("Uploaded", style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(fileName, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ],
    );
  }

  void _showImageModal(BuildContext context, String fileName, bool isImage) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const Text("Set Secret Image", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              const Text("Please select an image. You will need to choose this same image when logging in.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.image, color: Colors.grey[400]),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save & Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    final bool isRequired = label.endsWith("*");
    final String labelText = isRequired ? label.substring(0, label.length - 1).trim() : label;
    
    return RichText(
      text: TextSpan(
        text: labelText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFEF4444)),
                )
              ]
            : [],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
