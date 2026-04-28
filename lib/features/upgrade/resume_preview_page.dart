import 'package:flutter/material.dart';
import 'package:circuit/widgets/common_dashboard_app_bar.dart';
import 'resume_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ResumePreviewPage extends StatelessWidget {
  final ResumeData resumeData;

  const ResumePreviewPage({super.key, required this.resumeData});

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        resumeData.fullName,
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text("VERIFIED", style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text("${resumeData.email} | ${resumeData.phone} | ${resumeData.location}",
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Professional Summary", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Text(resumeData.professionalSummary),
            pw.SizedBox(height: 20),
            pw.Text("Work Experience", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            ...resumeData.experience.map((exp) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(exp.position, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(exp.duration),
                      ],
                    ),
                    pw.Text(exp.company, style: const pw.TextStyle(color: PdfColors.grey700)),
                    pw.Bullet(text: exp.responsibilities),
                    pw.SizedBox(height: 12),
                  ],
                )),
            pw.SizedBox(height: 20),
            pw.Text("Education", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            ...resumeData.education.map((edu) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(edu.degree, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(edu.duration),
                      ],
                    ),
                    pw.Text(edu.institution, style: const pw.TextStyle(color: PdfColors.grey700)),
                    pw.SizedBox(height: 12),
                  ],
                )),
            pw.SizedBox(height: 20),
            pw.Text("Skills", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: resumeData.skills.map((s) => pw.Text(s)).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Projects", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            ...resumeData.projects.map((proj) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(proj.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (proj.link.isNotEmpty) pw.Text(proj.link, style: const pw.TextStyle(color: PdfColors.blue, fontSize: 10)),
                    pw.Text(proj.description),
                    pw.SizedBox(height: 12),
                  ],
                )),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(resumeData.fullName,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: const Text("VERIFIED",
                                style: TextStyle(color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("${resumeData.email} | ${resumeData.phone} | ${resumeData.location}",
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      const SizedBox(height: 32),
                      _sectionTitle("Professional Summary"),
                      Text(resumeData.professionalSummary, style: const TextStyle(height: 1.5, color: Color(0xFF334155))),
                      const SizedBox(height: 32),
                      _sectionTitle("Work Experience"),
                      ...resumeData.experience.map((exp) => _buildExperienceItem(exp)),
                      const SizedBox(height: 32),
                      _sectionTitle("Education"),
                      ...resumeData.education.map((edu) => _buildEducationItem(edu)),
                      const SizedBox(height: 32),
                      _sectionTitle("Skills"),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: resumeData.skills
                            .map((s) => Chip(
                                  label: Text(s, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      _sectionTitle("Projects"),
                      ...resumeData.projects.map((proj) => _buildProjectItem(proj)),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildExperienceItem(ExperienceItem exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(exp.position, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(exp.duration, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
          Text(exp.company, style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Text(exp.responsibilities, style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildEducationItem(EducationItem edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(edu.degree, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(edu.duration, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
          Text(edu.institution, style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildProjectItem(ProjectItem proj) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(proj.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          if (proj.link.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(proj.link, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
            ),
          const SizedBox(height: 4),
          Text(proj.description, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: const Text("Edit Resume", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text("Download PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D8D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
