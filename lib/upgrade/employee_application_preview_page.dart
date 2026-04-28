import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EmployeePreviewDegreeData {
  final String? stream;
  final String? degree;
  final String? university;
  final String? institute;
  final String? year;
  final String? certificateName;
  final Uint8List? certificateBytes;

  const EmployeePreviewDegreeData({
    this.stream,
    this.degree,
    this.university,
    this.institute,
    this.year,
    this.certificateName,
    this.certificateBytes,
  });
}

class EmployeeApplicationPreviewPage extends StatelessWidget {
  final String? workType;

  final String? resumeName;
  final Uint8List? resumeBytes;

  final bool noPanCard;
  final String? panNumber;

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
  final bool isViewOnly;
  final VoidCallback? onConfirmSubmit;

  const EmployeeApplicationPreviewPage({
    super.key,
    required this.workType,
    required this.resumeName,
    required this.resumeBytes,
    required this.noPanCard,
    required this.panNumber,
    required this.addressProofType,
    required this.addressProofName,
    required this.addressProofBytes,
    required this.salaryAccount,
    required this.educationBoard,
    required this.primaryStudy,
    required this.primaryMarksheetName,
    required this.primaryMarksheetBytes,
    required this.after10thPath,
    required this.higherSecondaryClass,
    required this.hsMarksheetName,
    required this.hsMarksheetBytes,
    required this.itiCourse,
    required this.itiCertificateName,
    required this.itiCertificateBytes,
    required this.degrees,
    this.onConfirmSubmit,
    this.isViewOnly = false,
  });

  String _valueOrDefault(String? value, {String fallback = "Not provided"}) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  bool _isPdf(String? fileName) {
    if (fileName == null) return false;
    return fileName.toLowerCase().endsWith('.pdf');
  }

  bool _isImage(String? fileName) {
    if (fileName == null) return false;
    final lower = fileName.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  void _openDocumentPreview(
      BuildContext context, {
        required String title,
        required String? fileName,
        required Uint8List? bytes,
      }) {
    if (bytes == null || fileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("File not available"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isImage(fileName)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ImagePreviewScreen(
            title: title,
            imageBytes: bytes,
          ),
        ),
      );
      return;
    }

    if (_isPdf(fileName)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PdfPreviewScreen(
            title: title,
            pdfBytes: bytes,
          ),
        ),
      );
      return;
    }
  }

  Widget _buildInfoTile(String label, String value, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Icon(icon, color: const Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildDocumentTile(
      BuildContext context, {
        required String title,
        required String? fileName,
        required Uint8List? bytes,
        String emptyText = "Not uploaded",
        bool showResumeButton = false,
      }) {
    final hasFile = fileName != null && bytes != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (!hasFile)
            Text(
              emptyText,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
            )
          else if (_isImage(fileName))
            InkWell(
              onTap: () => _openDocumentPreview(
                context,
                title: title,
                fileName: fileName,
                bytes: bytes,
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  bytes!,
                  fit: BoxFit.contain,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fileName!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: showResumeButton ? double.infinity : null,
                  child: ElevatedButton.icon(
                    onPressed: () => _openDocumentPreview(
                      context,
                      title: title,
                      fileName: fileName,
                      bytes: bytes,
                    ),
                    icon: const Icon(Icons.description_rounded, size: 18),
                    label: Text(
                      showResumeButton ? "Open Resume (PDF)" : "Open PDF",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAcademicRow(
      BuildContext context, {
        required String qualification,
        required String details,
        required String? fileName,
        required Uint8List? bytes,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              qualification,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              details,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: (fileName == null || bytes == null)
                ? const Text(
              "Not provided",
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
              ),
            )
                : InkWell(
              onTap: () => _openDocumentPreview(
                context,
                title: qualification,
                fileName: fileName,
                bytes: bytes,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: _isImage(fileName)
                    ? Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panValue = noPanCard
        ? "Not available"
        : _valueOrDefault(
      panNumber?.toUpperCase(),
      fallback: "Not provided",
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF1E293B),
        title: const Text(
          "Preview Your Application",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE11D48), Color(0xFFDB2777)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Preview Your Application",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Verify your details before final submission",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Personal & Work Profile
                    _buildSectionCard(
                      icon: Icons.badge_outlined,
                      title: "Personal & Work Profile",
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 650;
                          return GridView.count(
                            crossAxisCount: isWide ? 2 : 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: isWide ? 3.2 : 3.0,
                            children: [
                              _buildInfoTile(
                                "Work Type",
                                _valueOrDefault(workType),
                                highlight: true,
                              ),
                              _buildInfoTile("PAN / ID", panValue),
                              _buildInfoTile(
                                "Address Proof Type",
                                _valueOrDefault(
                                  noPanCard ? addressProofType : "PAN Card",
                                ),
                              ),
                              _buildInfoTile(
                                "Salary Account",
                                _valueOrDefault(salaryAccount),
                              ),
                              _buildInfoTile(
                                "Education Board",
                                _valueOrDefault(educationBoard),
                              ),
                              _buildInfoTile(
                                "Primary Study",
                                _valueOrDefault(primaryStudy),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Professional Documents
                    _buildSectionCard(
                      icon: Icons.folder_open_rounded,
                      title: "Professional Documents",
                      child: Column(
                        children: [
                          _buildDocumentTile(
                            context,
                            title: "Resume / CV",
                            fileName: resumeName,
                            bytes: resumeBytes,
                            emptyText: "Resume not uploaded",
                            showResumeButton: true,
                          ),
                          if (noPanCard)
                            _buildDocumentTile(
                              context,
                              title: "Address Proof Document",
                              fileName: addressProofName,
                              bytes: addressProofBytes,
                              emptyText: "No document uploaded",
                            ),
                          if (primaryMarksheetName != null &&
                              primaryMarksheetBytes != null)
                            _buildDocumentTile(
                              context,
                              title: "10th Marksheet",
                              fileName: primaryMarksheetName,
                              bytes: primaryMarksheetBytes,
                            ),
                          if (hsMarksheetName != null && hsMarksheetBytes != null)
                            _buildDocumentTile(
                              context,
                              title: "12th Marksheet",
                              fileName: hsMarksheetName,
                              bytes: hsMarksheetBytes,
                            ),
                          if (itiCertificateName != null &&
                              itiCertificateBytes != null)
                            _buildDocumentTile(
                              context,
                              title: "ITI Certificate",
                              fileName: itiCertificateName,
                              bytes: itiCertificateBytes,
                            ),
                          ...degrees.asMap().entries.map(
                                (entry) => _buildDocumentTile(
                              context,
                              title: "Degree Certificate ${entry.key + 1}",
                              fileName: entry.value.certificateName,
                              bytes: entry.value.certificateBytes,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Academic History
                    _buildSectionCard(
                      icon: Icons.school_outlined,
                      title: "Academic History",
                      child: Column(
                        children: [
                          _buildAcademicRow(
                            context,
                            qualification: "Primary / Secondary",
                            details:
                            "${_valueOrDefault(primaryStudy)}${primaryStudy == '10th Standard' ? ' • ${_valueOrDefault(after10thPath)}' : ''}",
                            fileName: primaryMarksheetName,
                            bytes: primaryMarksheetBytes,
                          ),
                          if (higherSecondaryClass != null)
                            _buildAcademicRow(
                              context,
                              qualification: "Higher Secondary",
                              details:
                              "${_valueOrDefault(higherSecondaryClass)} • ${_valueOrDefault(educationBoard)}",
                              fileName: hsMarksheetName,
                              bytes: hsMarksheetBytes,
                            ),
                          if (itiCourse != null)
                            _buildAcademicRow(
                              context,
                              qualification: "ITI / Vocational",
                              details: _valueOrDefault(itiCourse),
                              fileName: itiCertificateName,
                              bytes: itiCertificateBytes,
                            ),
                          ...degrees.map(
                                (degree) => _buildAcademicRow(
                              context,
                              qualification: degree.degree ?? "Degree",
                              details:
                              "${_valueOrDefault(degree.stream)}\n${_valueOrDefault(degree.university)}\n${_valueOrDefault(degree.institute)} • Year: ${_valueOrDefault(degree.year)}",
                              fileName: degree.certificateName,
                              bytes: degree.certificateBytes,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            if (!isViewOnly)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text("Edit Details"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          foregroundColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE11D48), Color(0xFFDB2777)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onConfirmSubmit,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text("Confirm & Submit Application"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  final String title;
  final Uint8List imageBytes;

  const _ImagePreviewScreen({
    required this.title,
    required this.imageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(imageBytes),
        ),
      ),
    );
  }
}

class _PdfPreviewScreen extends StatelessWidget {
  final String title;
  final Uint8List pdfBytes;

  const _PdfPreviewScreen({
    required this.title,
    required this.pdfBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Text(title),
      ),
      body: SfPdfViewer.memory(pdfBytes),
    );
  }
}