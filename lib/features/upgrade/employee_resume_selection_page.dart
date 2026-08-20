import 'package:flutter/material.dart';
import 'package:sva_business_user/widgets/common_dashboard_app_bar.dart';
import 'employee_uploaded_resume_page.dart';
import 'verified_resume_builder_page.dart';

class EmployeeResumeSelectionPage extends StatefulWidget {
  const EmployeeResumeSelectionPage({super.key});

  @override
  State<EmployeeResumeSelectionPage> createState() => _EmployeeResumeSelectionPageState();
}

class _EmployeeResumeSelectionPageState extends State<EmployeeResumeSelectionPage> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Professional Resume Selection",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select how you'd like to present your professional credentials. Our system-verified resumes increase your hiring visibility by 40%.",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildOptionCard(
                index: 0,
                title: "Continue With My Own Resume",
                label: "EXISTING",
                description: "Upload your existing resume and continue with your preferred style. You can edit, update, and customize it as needed.",
                borderColor: const Color(0xFF10B981),
                labelColor: const Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                index: 1,
                title: "Create Verified Resume",
                label: "RECOMMENDED",
                description: "Generate a professionally formatted, default verified resume. This version follows standard guidelines and includes verification for authenticity.",
                borderColor: const Color(0xFF3B82F6),
                labelColor: const Color(0xFF3B82F6),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedIndex == -1 ? null : _handleProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D8D),
                    disabledBackgroundColor: const Color(0xFFFF4D8D).withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Proceed with Selected Option",
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

  Widget _buildOptionCard({
    required int index,
    required String title,
    required String label,
    required String description,
    required Color borderColor,
    required Color labelColor,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? borderColor : const Color(0xFFE2E8F0),
            width: 2,
          ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: labelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildSelectionIndicator(isSelected, borderColor),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : const Color(0xFFCBD5E1),
          width: 2,
        ),
        color: isSelected ? color : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }

  void _handleProceed() {
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EmployeeUploadedResumePage(),
        ),
      );
    } else if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const VerifiedResumeBuilderPage(),
        ),
      );
    }
  }
}

