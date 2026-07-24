import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'business_user_store.dart';
import 'business_created_page.dart';
import 'business_registration_overview_page.dart';
import '../user_service.dart';

class UserOverviewPage extends StatefulWidget {
  final int initialPage;
  const UserOverviewPage({super.key, this.initialPage = 1});

  @override
  State<UserOverviewPage> createState() => _UserOverviewPageState();
}

class _UserOverviewPageState extends State<UserOverviewPage> {
  late int _currentPageIndex; // 0: Overview (Page 1), 1: Upgrade Account (Page 2), 2: Identify Verification (Page 3)

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
  String? _profileFileName;
  Uint8List? _profileFileBytes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialPage;
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

  Future<void> _pickProfileFile() async {
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
          _profileFileName = file.name;
          _profileFileBytes = file.bytes;
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

    if (_profileFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload Profile Photo"),
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
        _currentPageIndex = 3; // Go to Secure Manager Account (Page 4)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "save successfully",
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
                    : (_currentPageIndex == 2 ? "Identity Verification" : "Secure Your Manager Account")),
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
      case 3:
        return _buildPage4(isDark);
      default:
        return _buildPage1(isDark, isDesktop);
    }
  }

  Widget _buildPage1(bool isDark, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Back to Dashboard Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Account Verification Overview",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Your account verification information is shown below.",
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Back to Dashboard",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Main Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 700;
              
              final leftContent = Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: isSmall 
                      ? const BorderRadius.vertical(top: Radius.circular(20)) 
                      : const BorderRadius.horizontal(left: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security, color: Color(0xFF2563EB), size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text("USER TYPE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Text("register", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 24),
                    const Text("USER MAIN ID", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(_userMainId, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              );

              final rightContent = Padding(
                padding: const EdgeInsets.all(32.0),
                child: isSmall ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileSection(),
                    const Divider(height: 48),
                    _buildDetailsSection(),
                    const Divider(height: 48),
                    _buildDocumentSection(),
                  ],
                ) : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(),
                    Container(
                      width: 1,
                      height: 120,
                      color: const Color(0xFFE2E8F0),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    Expanded(child: _buildDetailsSection()),
                    const SizedBox(width: 32),
                    Expanded(child: _buildDocumentSection()),
                  ],
                ),
              );

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftContent,
                    rightContent,
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: leftContent),
                    Expanded(flex: 7, child: rightContent),
                  ],
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("PROFILE PHOTO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            shape: BoxShape.circle,
            image: _profileFileBytes != null ? DecorationImage(image: MemoryImage(_profileFileBytes!), fit: BoxFit.cover) : null,
          ),
          child: _profileFileBytes == null 
              ? const Center(child: Text("US", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)))
              : null,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text("REGISTER", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PAN NUMBER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(_panNumber.isNotEmpty ? _panNumber : "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
        const SizedBox(height: 24),
        const Text("GENDER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Text(_gender.isNotEmpty ? _gender : "-", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
      ],
    );
  }

  Widget _buildDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PAN CARD DOCUMENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            if (_uploadFileBytes != null) {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.all(24),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InteractiveViewer(
                          child: Image.memory(_uploadFileBytes!, fit: BoxFit.contain),
                        ),
                      ),
                      Positioned(
                        top: -12,
                        right: -12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          child: Container(
            height: 100,
            width: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              image: _uploadFileBytes != null ? DecorationImage(image: MemoryImage(_uploadFileBytes!), fit: BoxFit.cover) : null,
            ),
            child: _uploadFileBytes == null 
                ? const Icon(Icons.description, color: Color(0xFFCBD5E1), size: 40)
                : null,
          ),
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
            // Center Blue Shield Icon Badge
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield,
                color: Color(0xFF2563EB),
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

            // Action Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _currentPageIndex = 2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
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
                SizedBox(
                  width: 120,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
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
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Identity Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Provide your PAN details and profile photo to complete security verification.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.all(isSmall ? 16 : 24),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      isSmall ? Column(
                        children: [
                          _buildPanField(),
                          const SizedBox(height: 24),
                          _buildGenderField(),
                        ],
                      ) : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPanField()),
                          const SizedBox(width: 24),
                          Expanded(child: _buildGenderField()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      isSmall ? Column(
                        children: [
                          _buildPanPhotoField(),
                          const SizedBox(height: 24),
                          _buildProfilePhotoField(),
                        ],
                      ) : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildPanPhotoField()),
                          const SizedBox(width: 24),
                          Expanded(flex: 4, child: _buildProfilePhotoField()),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      height: 48,
                      width: 120,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentPageIndex = 1),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const FittedBox(child: Text("Cancel", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700))),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      width: 140,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const FittedBox(child: Text("Continue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildPanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PAN NUMBER *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              _UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(10),
            ],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155), letterSpacing: 1.5),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("GENDER *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildGenderPill("Male"),
            _buildGenderPill("Female"),
            _buildGenderPill("Others"),
          ],
        ),
      ],
    );
  }

  Widget _buildPanPhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PAN CARD PHOTO (FRONT) *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _uploadFileBytes != null ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
            ),
            child: _uploadFileBytes != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_uploadFileBytes!, fit: BoxFit.cover, width: double.infinity),
                          ),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                          SizedBox(width: 4),
                          Flexible(child: Text("Uploaded successfully", overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(height: 12),
                      const FittedBox(child: Text("Click to upload photo", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)))),
                      const SizedBox(height: 4),
                      const FittedBox(child: Text("JPG, PNG or PDF (Max 5MB)", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PROFILE PHOTO *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickProfileFile,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _profileFileBytes != null ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
            ),
            child: _profileFileBytes != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: MemoryImage(_profileFileBytes!), fit: BoxFit.cover),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                            ),
                          ),
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                          SizedBox(width: 4),
                          Flexible(child: Text("Uploaded successfully", overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(height: 12),
                      const FittedBox(child: Text("Click to upload photo", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155)))),
                      const SizedBox(height: 4),
                      const FittedBox(child: Text("JPG or PNG (Max 5MB)", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPill(String g) {
    bool isSelected = _selectedGender == g;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = g),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          g,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- Secure Manager Account Page (Page 4) ---

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedCaptcha;
  final List<String> _captchaImages = [
    'assets/captcha/dog.jpg',
    'assets/captcha/cat.jpg',
    'assets/captcha/parrot.jpg',
    'assets/captcha/car.jpg',
    'assets/captcha/sports_bike.jpg',
    'assets/captcha/train.jpg',
    'assets/captcha/airplane.jpg',
    'assets/captcha/coconut_tree.jpg',
    'assets/captcha/sunflower.jpg',
  ];

  Widget _buildPage4(bool isDark) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(40),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Secure Your Manager Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Configure password and select a personal captcha image to secure your privilege setup.",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 600;
                return isSmall ? Column(
                  children: [
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildConfirmPasswordField(),
                  ],
                ) : Row(
                  children: [
                    Expanded(child: _buildPasswordField()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildConfirmPasswordField()),
                  ],
                );
              }
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Set Captcha Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text("Choose a custom captcha configuration token", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final asset = _captchaImages[index];
                    final isSelected = _selectedCaptcha == asset;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCaptcha = asset),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.transparent, width: 3),
                          image: DecorationImage(
                            image: AssetImage(asset),
                            fit: BoxFit.cover,
                            onError: (e, s) => null, // fallback if asset not found
                          ),
                          color: Colors.grey[200], // fallback color
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 48,
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_registered_upgraded', true);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Credentials Saved Successfully!"),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Save Credentials", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PASSWORD *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.vpn_key, color: Color(0xFF64748B), size: 20),
              ),
              Expanded(
                child: TextField(
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    hintText: "Enter password",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                child: Text(_obscurePassword ? "Show" : "Hide", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CONFIRM PASSWORD *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.vpn_key, color: Color(0xFF64748B), size: 20),
              ),
              Expanded(
                child: TextField(
                  obscureText: _obscureConfirmPassword,
                  decoration: const InputDecoration(
                    hintText: "Confirm password",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                child: Text(_obscureConfirmPassword ? "Show" : "Hide", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
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
