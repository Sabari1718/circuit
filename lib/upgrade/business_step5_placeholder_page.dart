import 'package:flutter/material.dart';

class BusinessStep5PlaceholderPage extends StatelessWidget {
  const BusinessStep5PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          color: const Color(0xFF232B3E),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.layers_rounded, color: Color(0xFFF59E0B), size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    "UserPortal",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFF59E0B),
                    child: Text("S", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.verified_user_rounded, size: 64, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 32),
            const Text(
              "Step 5 of 5",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            const Text(
              "Review & Submit",
              style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            const Text(
              "We are finalizing your registration experience.",
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Go Back", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
