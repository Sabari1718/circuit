import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sva_business_user/widgets/common_dashboard_app_bar.dart';

class EmployeePreviewDegreeData {
  final String stream;
  final String degree;
  final String university;
  final String institute;
  final String yearOfPassing;
  final String? certificateName;
  final Uint8List? certificateBytes;

  EmployeePreviewDegreeData({
    required this.stream,
    required this.degree,
    required this.university,
    required this.institute,
    required this.yearOfPassing,
    this.certificateName,
    this.certificateBytes,
  });
}

class EmployeeApplicationPreviewPage extends StatelessWidget {
  final String? workType;
  final String? resumeName;
  final Uint8List? resumeBytes;
  final String? panNumber;
  final bool noPanCard;
  final String? addressProofType;
  final String? addressProofName;
  final Uint8List? addressProofBytes;
  final String? salaryAccount;
  final String? educationBoard;
  final String? primaryStudy;
  final String? primaryMarksheetName;
  final Uint8List? primaryMarksheetBytes;
  final String? after10thPath;
  final String? higherSecondaryClass;
  final String? hsMarksheetName;
  final Uint8List? hsMarksheetBytes;
  final String? itiCourse;
  final String? itiCertificateName;
  final Uint8List? itiCertificateBytes;
  final List<EmployeePreviewDegreeData> degrees;
  final VoidCallback onSubmit;

  const EmployeeApplicationPreviewPage({
    super.key,
    this.workType,
    this.resumeName,
    this.resumeBytes,
    this.panNumber,
    required this.noPanCard,
    this.addressProofType,
    this.addressProofName,
    this.addressProofBytes,
    this.salaryAccount,
    this.educationBoard,
    this.primaryStudy,
    this.primaryMarksheetName,
    this.primaryMarksheetBytes,
    this.after10thPath,
    this.higherSecondaryClass,
    this.hsMarksheetName,
    this.hsMarksheetBytes,
    this.itiCourse,
    this.itiCertificateName,
    this.itiCertificateBytes,
    required this.degrees,
    required this.onSubmit,
  });

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
                "Review Application",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please verify your information before submitting",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
              const SizedBox(height: 32),
              
              _buildSection(
                title: "Personal & Work Profile",
                icon: Icons.person_outline_rounded,
                children: [
                  _previewRow("Work Type", workType ?? "Not specified"),
                  if (!noPanCard)
                    _previewRow("PAN Number", panNumber ?? "Not provided")
                  else ...[
                    _previewRow("PAN Card", "Not available"),
                    _previewRow("Address Proof", addressProofType ?? "Not specified"),
                  ],
                  _previewRow("Salary Account", salaryAccount?.isEmpty ?? true ? "Not provided" : salaryAccount!),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSection(
                title: "Professional Documents",
                icon: Icons.description_outlined,
                children: [
                  _buildFilePreview("Resume", resumeName, resumeBytes, context),
                  if (noPanCard)
                    _buildFilePreview("$addressProofType Document", addressProofName, addressProofBytes, context),
                ],
              ),

              const SizedBox(height: 24),
              _buildSection(
                title: "Academic History",
                icon: Icons.school_outlined,
                children: [
                  _previewRow("Education Board", educationBoard ?? "Not provided"),
                  _previewRow("Primary Study", primaryStudy ?? "Not provided"),
                  if (primaryStudy == '10th Standard')
                    _buildFilePreview("10th Marksheet", primaryMarksheetName, primaryMarksheetBytes, context),
                  if (after10thPath != null) ...[
                    _previewRow("Path After 10th", after10thPath!),
                    if (after10thPath == "Higher Secondary") ...[
                      _previewRow("HS Class", higherSecondaryClass ?? "Not specified"),
                      if (higherSecondaryClass == '12th Standard')
                        _buildFilePreview("12th Marksheet", hsMarksheetName, hsMarksheetBytes, context),
                    ] else if (after10thPath == "ITI") ...[
                      _previewRow("ITI Course", itiCourse ?? "Not specified"),
                      _buildFilePreview("ITI Certificate", itiCertificateName, itiCertificateBytes, context),
                    ],
                  ],
                ],
              ),

              if (degrees.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...degrees.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var degree = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildSection(
                      title: "Degree Qualification ${idx + 1}",
                      icon: Icons.workspace_premium_outlined,
                      children: [
                        _previewRow("Stream", degree.stream),
                        _previewRow("Degree", degree.degree),
                        _previewRow("University", degree.university),
                        _previewRow("Institute", degree.institute),
                        _previewRow("Year of Passing", degree.yearOfPassing),
                        _buildFilePreview("Degree Certificate", degree.certificateName, degree.certificateBytes, context),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: const Text("Edit Details", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFA855F7)]),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: const Text("Confirm & Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6366F1), size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(String label, String? fileName, Uint8List? bytes, BuildContext context) {
    if (fileName == null || bytes == null) {
      return _previewRow(label, "Not uploaded");
    }

    bool isImage = fileName.toLowerCase().endsWith('.jpg') || 
                  fileName.toLowerCase().endsWith('.jpeg') || 
                  fileName.toLowerCase().endsWith('.png');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              if (isImage) {
                _showImagePreview(context, bytes);
              } else {
                _showPdfDialog(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  if (isImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover),
                    )
                  else
                    const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.visibility_outlined, color: Color(0xFF6366F1), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  void _showPdfDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 12),
            Text("PDF Document"),
          ],
        ),
        content: const Text("This PDF file has been uploaded successfully and is ready for submission."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

