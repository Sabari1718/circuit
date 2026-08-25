import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../widgets/common_dashboard_app_bar.dart';
import '../home_page.dart';
import 'dart:typed_data';
import 'employee_user_store.dart';
import 'employee_user_model.dart';
import '../user_service.dart';

class EmployeeProfileOverviewPage extends StatefulWidget {
  const EmployeeProfileOverviewPage({super.key});

  @override
  State<EmployeeProfileOverviewPage> createState() => _EmployeeProfileOverviewPageState();
}

class _EmployeeProfileOverviewPageState extends State<EmployeeProfileOverviewPage> {
  String _userName = "User";
  String _gender = "Not Provided";
  String _panNumber = "Not Provided";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await UserService().getUserData();
    if (!mounted) return;
    setState(() {
      _userName = data['name'] ?? "User";
    });

    final userMainId = data['user_main_id']?.toString() ?? '';
    if (userMainId.isNotEmpty) {
      final registerData = await UserService().getRegisterDetails(userMainId);
      if (registerData != null && mounted) {
        setState(() {
          _gender = registerData['gender']?.toString() ?? "Not Provided";
          if (_gender != "Not Provided" && _gender.isNotEmpty) {
            _gender = '${_gender[0].toUpperCase()}${_gender.substring(1).toLowerCase()}';
          }
          _panNumber = registerData['pan_number']?.toString() ?? "Not Provided";
          if (_panNumber.isEmpty) _panNumber = "Not Provided";
        });
      }
    }
  }

  EmployeeUser? get employee {
    final store = EmployeeUserStore();
    return store.employees.isNotEmpty ? store.employees.last : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              if (isDesktop)
                Container(
                  width: 250,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "CANDIDATE DESK",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSidebarItem(
                        icon: Icons.person_outline,
                        label: "Profile Overview",
                        isSelected: true,
                      ),
                      const SizedBox(height: 8),
                      _buildSidebarItem(
                        icon: Icons.work_outline,
                        label: "My Jobs",
                        isSelected: false,
                      ),
                    ],
                  ),
                ),
              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDesktop)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Employee Profile Overview",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Your submitted onboarding and verification details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            _buildBackButton(context),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Employee Profile Overview",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Your submitted onboarding and verification details",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildBackButton(context),
                          ],
                        ),
                      const SizedBox(height: 24),
                      _buildStatusBanner(isDesktop),
                      const SizedBox(height: 24),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildPersonalProfileCard(isDesktop)),
                            const SizedBox(width: 24),
                            Expanded(flex: 2, child: _buildUploadedDocumentsCard(isDesktop)),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildPersonalProfileCard(isDesktop),
                            const SizedBox(height: 24),
                            _buildUploadedDocumentsCard(isDesktop),
                          ],
                        ),
                      const SizedBox(height: 24),
                      _buildAcademicHistoryCard(context, isDesktop),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      ),
      icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF2563EB)),
      label: const Text(
        "Back to Portals",
        style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSidebarItem({required IconData icon, required String label, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Active Registration",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Status: Verified Employee",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.security, color: Colors.white, size: isDesktop ? 32 : 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalProfileCard(bool isDesktop) {
    final emp = employee;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.badge, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              const Text(
                "Personal & Work Profile",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDataField("Full Name", _userName),
                      const SizedBox(height: 24),
                      _buildDataField("Gender", _gender),
                      const SizedBox(height: 24),
                      _buildDataField("PAN Number", _panNumber),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48), // Align with second row
                      _buildDataField("Work Type", emp?.workType ?? "Physical Work", isPill: true),
                      const SizedBox(height: 24),
                      _buildDataField("User ID", emp?.id ?? "8594244533"),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataField("Full Name", _userName),
                const SizedBox(height: 16),
                _buildDataField("Gender", _gender),
                const SizedBox(height: 16),
                _buildDataField("PAN Number", _panNumber),
                const SizedBox(height: 16),
                _buildDataField("Work Type", emp?.workType ?? "Physical Work", isPill: true),
                const SizedBox(height: 16),
                _buildDataField("User ID", emp?.id ?? "8594244533"),
              ],
            ),
        ],
      ),
    );
  }

  ImageProvider? _getImageProvider(String? path, Uint8List? bytes) {
    if (path != null && path.isNotEmpty) {
      final fullPath = path.startsWith('http') ? path : 'https://managelogin.jobes24x7.com/api/$path';
      return NetworkImage(fullPath);
    } else if (bytes != null) {
      return MemoryImage(bytes);
    }
    return null;
  }

  void _showPhotoDialog(String title, String? path, Uint8List? bytes) {
    if (path == null && bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No photo uploaded")),
      );
      return;
    }
    
    Widget imageWidget = const SizedBox();
    if (path != null && path.isNotEmpty) {
      final fullPath = path.startsWith('http') ? path : 'https://managelogin.jobes24x7.com/api/$path';
      imageWidget = Image.network(fullPath, fit: BoxFit.contain);
    } else if (bytes != null) {
      imageWidget = Image.memory(bytes, fit: BoxFit.contain);
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            imageWidget,
          ],
        ),
      ),
    );
  }

  void _showPdfDialog(String title, String? path, Uint8List? bytes) {
    if (path == null && bytes == null) return;
    
    Widget pdfWidget = const SizedBox();
    if (path != null && path.isNotEmpty) {
      final fullPath = path.startsWith('http') ? path : 'https://managelogin.jobes24x7.com/api/$path';
      pdfWidget = SfPdfViewer.network(fullPath);
    } else if (bytes != null) {
      pdfWidget = SfPdfViewer.memory(bytes);
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: 800,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: pdfWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataField(String label, String value, {bool isPill = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        if (isPill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4), // Cyan as per screenshot
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
      ],
    );
  }

  Widget _buildUploadedDocumentsCard(bool isDesktop) {
    final emp = employee;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              const Text(
                "Uploaded Documents",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Front Photo (Passport Size)", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showPhotoDialog("Front Photo", emp?.frontPhotoPath, emp?.frontPhotoBytes),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                image: (emp?.frontPhotoPath != null || emp?.frontPhotoBytes != null) ? DecorationImage(
                  image: _getImageProvider(emp?.frontPhotoPath, emp?.frontPhotoBytes)!,
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: (emp?.frontPhotoPath == null && emp?.frontPhotoBytes == null) ? const Center(child: Icon(Icons.person, size: 64, color: Color(0xFFBFDBFE))) : null,
            ),
          ),
          const SizedBox(height: 24),
          const Text("Resume / CV", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              if (emp?.resumePath != null || emp?.resumeBytes != null) {
                _showPdfDialog("Resume / CV", emp?.resumePath, emp?.resumeBytes);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No resume uploaded")),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Open Resume (PDF)",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicHistoryCard(BuildContext context, bool isDesktop) {
    final emp = employee;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Academic History Details",
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: constraints.maxWidth < 600 ? 600 : constraints.maxWidth,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text("QUALIFICATION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text("INSTITUTION & BOARD DETAILS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text("CERTIFICATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            ),
                          ],
                        ),
                      ),
                      _buildAcademicRow(
                        qualification: "10th Standard / SSLC",
                        subtitle: emp?.primaryStudy ?? "Not Provided",
                        board: emp?.educationBoard ?? "Not Provided",
                        nextPath: emp?.after10thPath ?? "Not Provided",
                        imagePath: emp?.primaryMarksheetPath,
                        imageBytes: emp?.primaryMarksheetBytes,
                      ),
                      if (emp?.after10thPath == 'higher_secondary')
                        _buildAcademicRow(
                          qualification: "12th Standard / HSC",
                          subtitle: "Higher Secondary",
                          board: "Passed",
                          nextPath: "Further Studies",
                          imagePath: emp?.hsMarksheetPath,
                          imageBytes: emp?.hsMarksheetBytes,
                        ),
                      if (emp?.degrees != null)
                        ...emp!.degrees.map((degree) => _buildAcademicRow(
                          qualification: degree.degree ?? "Degree",
                          subtitle: degree.institute ?? "Institution",
                          board: degree.year ?? "Year",
                          nextPath: "Work",
                          imagePath: degree.certificatePath,
                          imageBytes: degree.certificateBytes,
                        )),
                    ],
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicRow({
    required String qualification,
    required String subtitle,
    required String board,
    required String nextPath,
    String? imagePath,
    Uint8List? imageBytes,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qualification, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Board: $board", style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                const SizedBox(height: 4),
                Text("Next Path: $nextPath", style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: (imagePath != null || imageBytes != null)
                ? GestureDetector(
                    onTap: () => _showPhotoDialog("$qualification Certificate", imagePath, imageBytes),
                    child: Container(
                      height: 48,
                      width: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        image: DecorationImage(image: _getImageProvider(imagePath, imageBytes)!, fit: BoxFit.cover),
                      ),
                    ),
                  )
                : const Text("No file", style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }
}
