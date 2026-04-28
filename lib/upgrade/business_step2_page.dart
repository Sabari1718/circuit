import 'package:flutter/material.dart';
import 'business_step3_page.dart';
import '../widgets/common_dashboard_app_bar.dart';

class BusinessStep2Page extends StatefulWidget {
  const BusinessStep2Page({super.key});

  @override
  State<BusinessStep2Page> createState() => _BusinessStep2PageState();
}

class _BusinessStep2PageState extends State<BusinessStep2Page> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _regNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const BusinessStep3Page()));
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
              _buildStepIndicator(2),
              const SizedBox(height: 32),
              const Text("Step 2: Business details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 32),

              _buildSectionCard(
                title: "Register details",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Business name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _businessNameController,
                      decoration: _inputDecoration("Enter business name", Icons.store_rounded),
                      validator: (v) => (v == null || v.isEmpty) ? "Business name is required" : null,
                    ),
                    const SizedBox(height: 24),
                    const Text("Registration number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _regNumberController,
                      decoration: _inputDecoration("Enter registration number", Icons.numbers_rounded),
                      validator: (v) => (v == null || v.isEmpty) ? "Registration number is required" : null,
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
