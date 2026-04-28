import 'package:flutter/material.dart';
import '../../widgets/common_dashboard_app_bar.dart';
import '../widgets/common_dashboard_app_bar.dart';

class BusinessStep5Page extends StatefulWidget {
  const BusinessStep5Page({super.key});

  @override
  State<BusinessStep5Page> createState() => _BusinessStep5PageState();
}

class _BusinessStep5PageState extends State<BusinessStep5Page> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Success!"),
          content: const Text("Your business registration is complete and under review."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Go to Dashboard"),
            ),
          ],
        ),
      );
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
              _buildStepIndicator(5),
              const SizedBox(height: 32),
              const Text("Step 5: Bank account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 32),

              _buildSectionCard(
                title: "Payout details",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bank name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: _inputDecoration("Enter bank name", Icons.account_balance_rounded),
                      validator: (v) => (v == null || v.isEmpty) ? "Bank name is required" : null,
                    ),
                    const SizedBox(height: 24),
                    const Text("Account number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accNumberController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Enter account number", Icons.numbers_rounded),
                      validator: (v) => (v == null || v.isEmpty) ? "Account number is required" : null,
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
        Expanded(child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7)]), borderRadius: BorderRadius.circular(100)), child: ElevatedButton(onPressed: _handleSubmit, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))), child: const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
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
