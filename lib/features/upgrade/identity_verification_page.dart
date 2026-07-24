import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'addresses_and_proof_page.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() => _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  String? selectedGender;
  String? selectedIdType;
  
  String? profilePhotoName;
  String? panDocName;
  String? idDocName;
  
  final TextEditingController _panController = TextEditingController();

  Future<void> _pickFile(Function(String?) onPicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      onPicked(result.files.single.name);
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
                  "Identity Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Verify your identity documents and address details to upgrade your credentials.",
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
                      _buildStepIndicator("1", "Identity & Location", true),
                      Container(width: 40, height: 1, color: const Color(0xFFE2E8F0)),
                      _buildStepIndicator("2", "Addresses & Proof", false),
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
                          _buildDropdownField("Select ID Type *", "Select Government ID Type", ["Aadhaar Card", "Passport", "Driving Licence", "Voter ID Card"], selectedIdType, (v) => setState(() => selectedIdType = v)),
                          const SizedBox(height: 24),
                          _buildFilePicker("Profile Photo *", profilePhotoName, () => _pickFile((name) => setState(() => profilePhotoName = name)), isImage: true),
                          const SizedBox(height: 24),
                          _buildFilePicker("Upload PAN Document *", panDocName, () => _pickFile((name) => setState(() => panDocName = name))),
                          const SizedBox(height: 24),
                          _buildFilePicker("Upload ID Document *", idDocName, () => _pickFile((name) => setState(() => idDocName = name))),
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
                              const SizedBox(height: 24),
                              _buildDropdownField("Select ID Type *", "Select Government ID Type", ["Aadhaar Card", "Passport", "Driving Licence", "Voter ID Card"], selectedIdType, (v) => setState(() => selectedIdType = v)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFilePicker("Profile Photo *", profilePhotoName, () => _pickFile((name) => setState(() => profilePhotoName = name)), isImage: true),
                              const SizedBox(height: 24),
                              _buildFilePicker("Upload PAN Document *", panDocName, () => _pickFile((name) => setState(() => panDocName = name))),
                              const SizedBox(height: 24),
                              _buildFilePicker("Upload ID Document *", idDocName, () => _pickFile((name) => setState(() => idDocName = name))),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddressesAndProofPage()),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          label: const Text(
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
