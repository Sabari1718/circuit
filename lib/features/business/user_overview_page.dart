import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit/features/upgrade/business_user_store.dart';
import 'package:circuit/features/upgrade/business_created_page.dart';
import 'package:circuit/features/business/business_registration_overview_page.dart';
import 'package:circuit/core/services/user_service.dart';

import '../../upgrade/business_created_page.dart';

class UserOverviewPage extends StatefulWidget {
  const UserOverviewPage({super.key});

  @override
  State<UserOverviewPage> createState() => _UserOverviewPageState();
}

class _UserOverviewPageState extends State<UserOverviewPage> {
  int _currentPageIndex =
      0; // 0: Overview (Page 1), 1: Upgrade Account (Page 2), 2: Identify Verification (Page 3)

  // Data retrieved from SharedPreferences
  String _userMainId = "9508383027";
  String _panNumber = "";
  String _gender = "";
  String _accountType = "Registered";
  String? _panPhotoName;
  Uint8List? _panPhotoBytes;
  bool _isVerified = false; // Whether upgraded

  // Identity Verification Form Controllers
  final TextEditingController _panController = TextEditingController();
  String _selectedGender = "";
  String? _uploadFileName;
  Uint8List? _uploadFileBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadVerificationData();
  }

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  Future<void> _loadVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = await UserService().getUserData();
    setState(() {
      _userMainId = userData['user_main_id'] ?? "9508383027";
      if (_userMainId.isEmpty) _userMainId = "9508383027";
      _panNumber = prefs.getString('user_pan') ?? "";
      _gender = prefs.getString('user_gender') ?? "";
      _accountType = prefs.getString('user_account_type') ?? "Registered";
      _panPhotoName = prefs.getString('user_pan_photo_name');
      final base64Photo = prefs.getString('user_pan_photo_bytes');
      if (base64Photo != null && base64Photo.isNotEmpty) {
        _panPhotoBytes = base64Decode(base64Photo);
      }
      _isVerified = _panNumber.isNotEmpty;
    });
  }

  Future<void> _saveVerificationData(
    String pan,
    String gender,
    String photoName,
    Uint8List photoBytes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pan', pan);
    await prefs.setString('user_gender', gender);
    await prefs.setString('user_account_type', 'Registered');
    await prefs.setString('user_pan_photo_name', photoName);
    await prefs.setString('user_pan_photo_bytes', base64Encode(photoBytes));
    // Also save in UserService
    await UserService().saveUserData(accountType: 'Registered');
    await _loadVerificationData();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.bytes != null) {
        if (file.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File size must be less than 5MB"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          _uploadFileName = file.name;
          _uploadFileBytes = file.bytes;
        });
      }
    }
  }

  void _submitVerification() async {
    final pan = _panController.text.trim().toUpperCase();
    if (pan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter PAN number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    if (!panRegex.hasMatch(pan)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter valid PAN (e.g. ABCDE1234F)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Gender"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_uploadFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload PAN Card Photo (Front)"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Simulate API response
    await _saveVerificationData(
      pan,
      _selectedGender,
      _uploadFileName ?? "PAN Card",
      _uploadFileBytes!,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _currentPageIndex = 0; // Go back to User Overview (Page 1)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "SUCCESSFULLY VERIFIED / ACCOUNT UPGRADED SUCCESS MESSAGE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF1F5F9),
      drawer: !isDesktop
          ? Drawer(elevation: 0, child: _buildSidebar(context, isDrawer: true))
          : null,
      appBar: AppBar(
        title: Text(
          _currentPageIndex == 0
              ? "Account Verification Overview"
              : (_currentPageIndex == 1
                    ? "Upgrade Account"
                    : "Identify Verification"),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) {
            if (!isDesktop) {
              return IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            } else {
              return IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              );
            }
          },
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) _buildSidebar(context, isDrawer: false),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: _buildCurrentPage(isDark, isDesktop),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage(bool isDark, bool isDesktop) {
    switch (_currentPageIndex) {
      case 0:
        return _buildPage1(isDark, isDesktop);
      case 1:
        return _buildPage2(isDark);
      case 2:
        return _buildPage3(isDark);
      default:
        return _buildPage1(isDark, isDesktop);
    }
  }

  Widget _buildPage1(bool isDark, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Update Details Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Account Verification Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _currentPageIndex = 1),
              icon: const Icon(Icons.edit_document, size: 14),
              label: const Text(
                "Update Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? Colors.white30 : Colors.grey[300]!,
                ),
                foregroundColor: isDark
                    ? Colors.white
                    : const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Verification Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF6366F1),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Verification ID: ${_isVerified ? '9508383027' : ''}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Status: Pending Verification",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "User Main ID",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userMainId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Identification Details Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Identification Details Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF3B82F6),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Identification Details",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Responsive Two-Column Details
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isSmall = constraints.maxWidth < 600;
                  final Widget leftColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        "PAN NUMBER",
                        _panNumber.isNotEmpty ? _panNumber : "-",
                      ),
                      const SizedBox(height: 20),
                      _buildDetailItem(
                        "GENDER",
                        _gender.isNotEmpty ? _gender : "-",
                      ),
                      const SizedBox(height: 20),
                      _buildDetailItem("ACCOUNT TYPE", "Registered"),
                    ],
                  );

                  final Widget rightColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PAN CARD FRONT PHOTO",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.03)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white10
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFF94A3B8),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _panPhotoName ?? "PAN Card",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.search,
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFF94A3B8),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Click to enlarge",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white30
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (isSmall) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftColumn,
                        const SizedBox(height: 24),
                        rightColumn,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: leftColumn),
                      const SizedBox(width: 40),
                      Expanded(child: rightColumn),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Processing message
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Your data is being processed. You will be notified once verification is complete.",
                style: TextStyle(
                  color: const Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPage2(bool isDark) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Center Pink/Red Icon Badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_ind_rounded,
                color: Color(0xFFE11D48),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              "Upgrade Account",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              "Upgrade to a registered account to unlock full privileges. Verify your Identity via PAN to continue with project creation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            // Upgrade Register Button
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentPageIndex = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Upgrade Register",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),

            // Features Checklist
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeatureCheck("Full Access"),
                const SizedBox(width: 24),
                _buildFeatureCheck("Priority Support"),
              ],
            ),
            const SizedBox(height: 32),

            // Encrypted info footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_outline, size: 14, color: Color(0xFF94A3B8)),
                SizedBox(width: 8),
                Text(
                  "All information is encrypted and securely stored",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCheck(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPage3(bool isDark) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 650),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                "Identify Verification",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                "Fill in your PAN details and upload a photo to upgrade your account.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isSmall = constraints.maxWidth < 600;
                final Widget panField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "PERMANENT ACCOUNT NUMBER (PAN) *",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _panController,
                      decoration: InputDecoration(
                        hintText: "ABCDE1234F",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.05)
                            : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white10 : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white10 : Colors.grey[200]!,
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        _UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ],
                );

                final Widget genderField = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gender *",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildGenderCheckbox("Male"),
                        _buildGenderCheckbox("Female"),
                        _buildGenderCheckbox("Others"),
                      ],
                    ),
                  ],
                );

                if (isSmall) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      panField,
                      const SizedBox(height: 24),
                      genderField,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: panField),
                    const SizedBox(width: 24),
                    Expanded(child: genderField),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Image Upload Field
            const Text(
              "PAN CARD PHOTO (FRONT) *",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.02)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: _uploadFileBytes != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF10B981),
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _uploadFileName ?? "File selected",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Click to change file",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                color: Color(0xFF6366F1),
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Click to upload photo",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "JPG, PNG or PDF (Max 5MB)",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Action Buttons
            if (_isSubmitting)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _submitVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Verify & Upgrade Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: InkWell(
                      onTap: () => setState(() => _currentPageIndex = 1),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Color(0xFFE11D48),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderCheckbox(String g) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _selectedGender == g,
          onChanged: (val) {
            setState(() {
              _selectedGender = val == true ? g : "";
            });
          },
          activeColor: const Color(0xFF6366F1),
        ),
        Text(
          g,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
    final pinkColor = const Color(0xFFE11D48);
    return Container(
      width: 250,
      height: double.infinity,
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: isDrawer ? 40 : 48,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      "90×25",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFFE11D48),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.home_outlined,
            "Dashboard",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.business_center_outlined,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              title: const Text(
                "Business",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
              dense: true,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          _sidebarSubItem(
            "Business Overview",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              final businesses = BusinessUserStore().businesses;
              if (businesses.isNotEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessRegistrationOverviewPage(
                      business: businesses.first,
                    ),
                  ),
                );
              }
            },
          ),
          _sidebarSubItem(
            "User Overview",
            textColor: Colors.white,
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _sidebarSubItem(
            "Add Business",
            textColor: pinkColor,
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const BusinessCreatedPage(showSelection: true),
                ),
              );
            },
          ),
          _sidebarSubItem(
            "Posted Jobs",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.widgets_outlined,
            "Switch Portal",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {VoidCallback? onTap}) =>
      ListTile(
        leading: Icon(icon, color: Colors.white60, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        onTap: onTap,
        dense: true,
      );

  Widget _sidebarSubItem(
    String title, {
    Color? textColor,
    VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.only(left: 54),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "-",
          style: TextStyle(
            color: Colors.white30,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
    onTap: onTap,
    dense: true,
  );
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
