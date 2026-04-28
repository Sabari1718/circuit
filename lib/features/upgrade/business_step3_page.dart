import 'package:flutter/material.dart';
import '../../widgets/common_dashboard_app_bar.dart';
import 'business_step4_page.dart';
import '../widgets/common_dashboard_app_bar.dart';

class BusinessStep3Page extends StatefulWidget {
  const BusinessStep3Page({super.key});

  @override
  State<BusinessStep3Page> createState() => _BusinessStep3PageState();
}

class _BusinessStep3PageState extends State<BusinessStep3Page> {
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessStep4Page()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const   CommonDashboardAppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(3),
              const SizedBox(height: 32),
              const Text("Step 3: Business address", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 32),

              _buildSectionCard(
                title: "Physical address",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Address", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 3,
                      decoration: _inputDecoration("Enter full business address", Icons.location_on_outlined),
                      validator: (v) => (v == null || v.isEmpty) ? "Address is required" : null,
                    ),
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

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))), child: const Text("Back"))),
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
