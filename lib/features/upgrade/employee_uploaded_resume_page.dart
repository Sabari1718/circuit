import 'package:flutter/material.dart';
import 'package:circuit/widgets/common_dashboard_app_bar.dart';

class EmployeeUploadedResumePage extends StatefulWidget {
  const EmployeeUploadedResumePage({super.key});

  @override
  State<EmployeeUploadedResumePage> createState() => _EmployeeUploadedResumePageState();
}

class _EmployeeUploadedResumePageState extends State<EmployeeUploadedResumePage> {
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
                "Your Uploaded Resume",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 24),
              
              // File Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "My_Professional_Resume.pdf",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            "2.4 MB • Uploaded on April 21, 2026",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                      label: const Text("Preview"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "PDF downloaded successfully",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text("Download PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
