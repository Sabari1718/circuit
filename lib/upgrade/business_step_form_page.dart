import 'package:flutter/material.dart';
import 'business_step2_page.dart';
import '../widgets/common_dashboard_app_bar.dart';

class BusinessStepFormPage extends StatefulWidget {
  const BusinessStepFormPage({super.key});

  @override
  State<BusinessStepFormPage> createState() => _BusinessStepFormPageState();
}

class _BusinessStepFormPageState extends State<BusinessStepFormPage> {
  final TextEditingController _panController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _panFrontUploaded = false;
  bool _photoUploaded = false;
  bool _isUploadingFront = false;
  bool _isUploadingPhoto = false;

  void _handleUpload(bool isFront) async {
    setState(() {
      if (isFront) _isUploadingFront = true;
      else _isUploadingPhoto = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        if (isFront) {
          _isUploadingFront = false;
          _panFrontUploaded = true;
        } else {
          _isUploadingPhoto = false;
          _photoUploaded = true;
        }
      });
      _showSnackBar(isFront ? "PAN Front uploaded" : "Profile photo uploaded", isError: false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (!_panFrontUploaded || !_photoUploaded) {
        _showSnackBar("Please upload both required photos");
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessStep2Page()));
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
              _buildStepIndicator(1),
              const SizedBox(height: 32),
              const Text("Step 1: Identity Verification", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 32),

              _buildSectionCard(
                title: "PAN Card Information",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PAN Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _panController,
                      decoration: _inputDecoration("Enter 10-digit PAN", Icons.badge_outlined),
                      validator: (v) => (v == null || v.length != 10) ? "Enter valid 10-digit PAN" : null,
                    ),
                    const SizedBox(height: 24),
                    const Text("PAN Front Photo", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildUploadBox(_panFrontUploaded, _isUploadingFront, () => _handleUpload(true)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: "Personal Photo",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Live Profile Photo", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildUploadBox(_photoUploaded, _isUploadingPhoto, () => _handleUpload(false)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              _buildFooterButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int current) {
    return Row(
      children: List.generate(5, (i) {
        bool active = i + 1 <= current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == 4 ? 0 : 8),
            decoration: BoxDecoration(color: active ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 20),
        child,
      ]),
    );
  }

  Widget _buildUploadBox(bool done, bool loading, VoidCallback tap) {
    return InkWell(
      onTap: done ? null : tap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: done ? const Color(0xFF10B981) : const Color(0xFFE2E8F0))),
        child: Center(
          child: loading ? const CircularProgressIndicator() : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(done ? Icons.check_circle_rounded : Icons.add_a_photo_outlined, color: done ? const Color(0xFF10B981) : const Color(0xFF94A3B8), size: 32),
              const SizedBox(height: 8),
              Text(done ? "Uploaded" : "Upload File", style: TextStyle(color: done ? const Color(0xFF10B981) : const Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))), child: const Text("Cancel"))),
        const SizedBox(width: 16),
        Expanded(child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7)]), borderRadius: BorderRadius.circular(100)), child: ElevatedButton(onPressed: _handleNext, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))), child: const Text("Next Step", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }
}
