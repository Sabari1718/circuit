import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../features/upgrade/employee_resume_selection_page.dart';
import '../widgets/common_dashboard_app_bar.dart';
import '../user_service.dart';
import 'employee_resume_selection_page.dart';
import 'employee_application_preview_page.dart';
import 'employee_user_store.dart';
import 'employee_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_page.dart';

class DegreeQualification {
  String? stream;
  String? degree;
  final TextEditingController universityController = TextEditingController();
  final TextEditingController instituteController = TextEditingController();
  final TextEditingController yearOfPassingController = TextEditingController();
  String? certificateName;
  Uint8List? certificateBytes;

  DegreeQualification();

  void dispose() {
    universityController.dispose();
    instituteController.dispose();
    yearOfPassingController.dispose();
  }
}

class EmployeeUpgradePage extends StatefulWidget {
  const EmployeeUpgradePage({super.key});

  @override
  State<EmployeeUpgradePage> createState() => _EmployeeUpgradePageState();
}

class _EmployeeUpgradePageState extends State<EmployeeUpgradePage> {
  int _currentStep = 1;

  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'John Doe';
      _userEmail = prefs.getString('user_email') ?? 'john.doe@example.com';
      _userPhone = prefs.getString('user_phone') ?? '+91 00000 00000';
    });
  }

  // Data
  String? _workType;

  // Resume File
  String? _resumeName;
  Uint8List? _resumeBytes;

  // Marksheet File (Conditional)
  String? _marksheetName;
  Uint8List? _marksheetBytes;

  final TextEditingController _panController = TextEditingController();
  final TextEditingController _panStatusController = TextEditingController();

  // Aadhar File (for Other Work)
  String? _aadharName;
  Uint8List? _aadharBytes;

  final TextEditingController _salaryAccountController = TextEditingController();
  String? _selectedClass;

  // Physical Work Specific State
  bool _noPanCard = false;
  String? _addressProofType = '-- Select Document Type --';
  String? _addressProofName;
  Uint8List? _addressProofBytes;

  String? _educationBoard = '-- Select Board --';
  String? _primaryStudy = '-- Select Class --';
  String? _primaryMarksheetName;
  Uint8List? _primaryMarksheetBytes;

  String? _after10thPath; // 'Higher Secondary', 'ITI', 'Direct Job'
  String? _higherSecondaryClass; // '11th', '12th'
  String? _hsMarksheetName;
  Uint8List? _hsMarksheetBytes;

  String? _itiCourse;
  String? _itiCertificateName;
  Uint8List? _itiCertificateBytes;

  final List<DegreeQualification> _degrees = [];

  final List<String> _addressProofTypes = [
    '-- Select Document Type --',
    'Aadhar Card',
    'Driving License',
    'Voter ID Card',
    'Passport'
  ];
  final List<String> _educationBoards = [
    '-- Select Board --',
    'CBSE',
    'State Board',
    'Matriculation',
    'ICSE',
    'IB / IGCSE'
  ];
  final List<String> _primaryStudyList = [
    '-- Select Class --',
    '5th Standard',
    '6th Standard',
    '7th Standard',
    '8th Standard',
    '9th Standard',
    '10th Standard'
  ];
  final List<String> _itiCourses = [
    'Electrician',
    'Fitter',
    'Welder',
    'Mechanic (Motor Vehicle)',
    'Carpenter',
    'Plumber',
    'Computer Operator & Programming',
    'Others'
  ];

  final Map<String, List<String>> _degreeSelectionMap = {
    'Arts/Science': [
      'B.A. – Bachelor of Arts',
      'M.A. – Master of Arts',
      'B.Sc. – Bachelor of Science',
      'M.Sc. – Master of Science',
      'B.Com – Bachelor of Commerce',
      'M.Com – Master of Commerce',
      'B.B.A. – Bachelor of Business Administration',
      'M.B.A. – Master of Business Administration',
      'B.C.A. – Bachelor of Computer Applications',
      'M.C.A. – Master of Computer Applications',
      'B.Ed. – Bachelor of Education',
      'M.Ed. – Master of Education',
      'B.F.A. – Bachelor of Fine Arts',
      'M.F.A. – Master of Fine Arts',
      'Other Arts/Science degree'
    ],
    'Engineering': [
      'B.E. – Bachelor of Engineering',
      'B.Tech – Bachelor of Technology',
      'M.E. – Master of Engineering',
      'M.Tech – Master of Technology',
      'Diploma in Engineering',
      'Polytechnic',
      'Other Engineering degree'
    ],
    'Others': [
      'Law Degree (LLB / LLM)',
      'Medical Degree (MBBS / BDS / BAMS / BHMS / Nursing / Pharmacy)',
      'Agriculture Degree',
      'Design Degree',
      'Hotel Management',
      'Aviation',
      'Other Professional Degree',
      'Other'
    ],
  };

  // Validation
  final RegExp _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  final List<String> _classList = [
    '5th Standard',
    '6th Standard',
    '7th Standard',
    '8th Standard',
    '9th Standard',
    '10th Standard',
    '11th Standard',
    '12th Standard',
    'Diploma',
    'ITI',
    'UG Degree',
    'BE / BTech',
    'BSc',
    'BCom',
    'BA',
    'BCA',
    'Polytechnic',
    'PG Degree',
    'ME / MTech',
    'MSc',
    'MCom',
    'MA',
    'MCA',
    'MBA',
    'Master Degree',
  ];

  Future<void> _pickFile({bool isResume = true}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          if (isResume) {
            _resumeName = result.files.first.name;
            _resumeBytes = result.files.first.bytes;
          } else {
            _marksheetName = result.files.first.name;
            _marksheetBytes = result.files.first.bytes;
          }
        });
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e");
    }
  }

  Future<void> _pickDegreeFile(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _degrees[index].certificateName = result.files.first.name;
          _degrees[index].certificateBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e");
    }
  }

  Future<void> _pickAadhar() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          _aadharName = result.files.first.name;
          _aadharBytes = result.files.first.bytes;
        });
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e");
    }
  }

  Future<void> _pickProfileFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null) {
        setState(() {
          switch (type) {
            case 'address_proof':
              _addressProofName = result.files.first.name;
              _addressProofBytes = result.files.first.bytes;
              break;
            case 'primary_marksheet':
              _primaryMarksheetName = result.files.first.name;
              _primaryMarksheetBytes = result.files.first.bytes;
              break;
            case 'hs_marksheet':
              _hsMarksheetName = result.files.first.name;
              _hsMarksheetBytes = result.files.first.bytes;
              break;
            case 'iti_certificate':
              _itiCertificateName = result.files.first.name;
              _itiCertificateBytes = result.files.first.bytes;
              break;
          }
        });
      }
    } catch (e) {
      _showSnackBar("Error picking file: $e");
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _goToPreview() {
    if (_workType == null) {
      _showSnackBar("Please select a work type");
      return;
    }

    if (!_noPanCard) {
      if (_panController.text.isEmpty) {
        _showSnackBar("Please enter PAN number");
        return;
      }
      if (!_panRegex.hasMatch(_panController.text.toUpperCase())) {
        _showSnackBar("Please enter a valid PAN number");
        return;
      }
    } else {
      if (_addressProofType == null) {
        _showSnackBar("Please select address proof type");
        return;
      }
      if (_addressProofName == null) {
        _showSnackBar("Please upload $_addressProofType document");
        return;
      }
    }

    if (_primaryStudy == '10th Standard' && _primaryMarksheetName == null) {
      _showSnackBar("Please upload 10th marksheet");
      return;
    }

    if (_primaryStudy == '10th Standard' &&
        _after10thPath == "Higher Secondary") {
      if (_higherSecondaryClass == null) {
        _showSnackBar("Please select Higher Secondary class");
        return;
      }
      if (_higherSecondaryClass == '12th Standard' && _hsMarksheetName == null) {
        _showSnackBar("Please upload 12th marksheet");
        return;
      }
    }

    if (_primaryStudy == '10th Standard' && _after10thPath == "ITI") {
      if (_itiCourse == null) {
        _showSnackBar("Please select ITI course");
        return;
      }
      if (_itiCertificateName == null) {
        _showSnackBar("Please upload ITI certificate");
        return;
      }
    }

    if (_after10thPath == "Higher Secondary" &&
        _higherSecondaryClass == '12th Standard') {
      if (_degrees.isEmpty) {
        _showSnackBar("Please add at least one degree qualification");
        return;
      }

      for (int i = 0; i < _degrees.length; i++) {
        final d = _degrees[i];
        final prefix = "Degree Entry ${i + 1}:";

        if (d.stream == null) {
          _showSnackBar("$prefix Please select degree stream");
          return;
        }
        if (d.degree == null) {
          _showSnackBar("$prefix Please select degree");
          return;
        }
        if (d.universityController.text.trim().isEmpty) {
          _showSnackBar("$prefix Please enter university name");
          return;
        }
        if (d.instituteController.text.trim().isEmpty) {
          _showSnackBar("$prefix Please enter institute name");
          return;
        }
        if (d.yearOfPassingController.text.trim().length != 4) {
          _showSnackBar("$prefix Please enter a valid 4-digit year of passing");
          return;
        }
        if (d.certificateName == null) {
          _showSnackBar("$prefix Please upload degree certificate");
          return;
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmployeeApplicationPreviewPage(
          workType: _workType,
          resumeName: _resumeName,
          resumeBytes: _resumeBytes,
          noPanCard: _noPanCard,
          panNumber: _panController.text.trim(),
          addressProofType: _addressProofType,
          addressProofName: _addressProofName,
          addressProofBytes: _addressProofBytes,
          salaryAccount: _salaryAccountController.text.trim(),
          educationBoard: _educationBoard,
          primaryStudy: _primaryStudy,
          primaryMarksheetName: _primaryMarksheetName,
          primaryMarksheetBytes: _primaryMarksheetBytes,
          after10thPath: _after10thPath,
          higherSecondaryClass: _higherSecondaryClass,
          hsMarksheetName: _hsMarksheetName,
          hsMarksheetBytes: _hsMarksheetBytes,
          itiCourse: _itiCourse,
          itiCertificateName: _itiCertificateName,
          itiCertificateBytes: _itiCertificateBytes,
          degrees: _degrees
              .map(
                (d) => EmployeePreviewDegreeData(
              stream: d.stream,
              degree: d.degree,
              university: d.universityController.text.trim(),
              institute: d.instituteController.text.trim(),
              year: d.yearOfPassingController.text.trim(),
              certificateName: d.certificateName,
              certificateBytes: d.certificateBytes,
            ),
          )
              .toList(),
          onConfirmSubmit: _submit,
        ),
      ),
    );
  }

  void _submit() {
    // Save to store
    final employee = EmployeeUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workType: _workType!,
      resumeName: _resumeName,
      resumeBytes: _resumeBytes,
      noPanCard: _noPanCard,
      panNumber: _panController.text.trim(),
      addressProofType: _addressProofType,
      addressProofName: _addressProofName,
      salaryAccount: _salaryAccountController.text.trim(),
      educationBoard: _educationBoard,
      primaryStudy: _primaryStudy,
      after10thPath: _after10thPath,
      degrees: _degrees.map((d) => EmployeeDegreeData(
        stream: d.stream,
        degree: d.degree,
        university: d.universityController.text.trim(),
        institute: d.instituteController.text.trim(),
        year: d.yearOfPassingController.text.trim(),
      )).toList(),
    );
    
    EmployeeUserStore().addEmployee(employee);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    // Top-right success notification (Snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Color(0xFF10B981), size: 16),
            ),
            const SizedBox(width: 12),
            const Text("Employee registration successful!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100, // Show at top
          right: 20,
          left: MediaQuery.of(context).size.width > 600 ? MediaQuery.of(context).size.width - 400 : 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF2563EB), size: 48),
              ),
              const SizedBox(height: 32),
              const Text(
                "Registration Submitted Successfully",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              const Text(
                "Employee Registration Completed",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Text("Onboarding Profile Created", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                    SizedBox(height: 12),
                    Text(
                      "Your records have been uploaded to secure ISO-27001 data stores. The HR administration department has been notified of your submission status.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomePage()), (route) => false),
                      icon: const Icon(Icons.home, color: Color(0xFF475569), size: 18),
                      label: const Text("Go to Dashboard", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EmployeeResumeSelectionPage())),
                      icon: const Icon(Icons.person, color: Colors.white, size: 18),
                      label: const Text("View Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _panController.dispose();
    _panStatusController.dispose();
    _salaryAccountController.dispose();
    for (var degree in _degrees) {
      degree.dispose();
    }
    super.dispose();
  }

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
              _buildStepIndicator(),
              const SizedBox(height: 32),
              if (_currentStep == 1) _buildWorkStep(),
              if (_currentStep == 2) _buildPersonalStep(),
              if (_currentStep == 3) _buildEducationStep(),
              if (_currentStep == 4) _buildStep2(),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentPreview(String fileName, Uint8List fileBytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Document Preview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.memory(
                      fileBytes,
                      fit: BoxFit.contain,
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

  Widget _buildStepIndicator() {
    return Column(
      children: [
        _buildWelcomeHeader(),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _indicatorDot(1, "Work", _currentStep >= 1),
            Expanded(child: Divider(color: _currentStep >= 2 ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), thickness: 1.5)),
            _indicatorDot(2, "Personal", _currentStep >= 2),
            Expanded(child: Divider(color: _currentStep >= 3 ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), thickness: 1.5)),
            _indicatorDot(3, "Education", _currentStep >= 3),
            Expanded(child: Divider(color: _currentStep >= 4 ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), thickness: 1.5)),
            _indicatorDot(4, "Preview", _currentStep >= 4),
          ],
        ),
      ],
    );
  }

  Widget _indicatorDot(int step, String label, bool active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF6366F1) : Colors.white,
            border: Border.all(
              color: active ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              "$step",
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF6366F1) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return ListenableBuilder(
      listenable: UserService(),
      builder: (context, _) {
        return FutureBuilder<Map<String, String>>(
          future: UserService().getUserData(),
          builder: (context, snapshot) {
            return Column(
              children: [
                Container(
                   width: 64,
                   height: 64,
                   decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                   child: const Icon(Icons.work_rounded, color: Color(0xFF2563EB), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Welcome, Employee! 👋",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Complete your employee registration profile",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWorkStep() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                child: const Icon(Icons.work_outline, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("SELECT YOUR WORK TYPE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    Text("Please choose the type of work you will be performing.", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildWorkTypeBox("Physical Work", "Manual labor or on-site physical tasks.", Icons.engineering_rounded, const Color(0xFF3B82F6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildWorkTypeBox("Technical Work", "IT, engineering or specialized technical roles.", Icons.memory_rounded, const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildWorkTypeBox("Physical & Technical Both", "Roles requiring both manual and technical skills.", Icons.build_rounded, const Color(0xFF8B5CF6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildWorkTypeBox("Other Work", "Office, administrative, or other roles.", Icons.desktop_windows_rounded, const Color(0xFFF59E0B))),
                ],
              ),
            ],
          ),
          if (_workType != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text("Upload Resume (Optional)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
            const SizedBox(height: 4),
            const Text("Upload your resume in PDF or DOC format (Max 5MB)", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            _buildUploadCard(
              fileName: _resumeName,
              label: "Browse Files",
              helperText: "",
              onTap: () => _pickFile(isResume: true),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _workType = null;
                    _resumeName = null;
                    _resumeBytes = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Text("Reset", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_workType == null) {
                    _showSnackBar("Please select a work type");
                    return;
                  }
                  setState(() => _currentStep = 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  children: [
                    Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTypeBox(String title, String desc, IconData icon, Color color) {
    bool isSelected = _workType == title;
    return GestureDetector(
      onTap: () => setState(() => _workType = title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalStep() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PERSONAL INFORMATION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    Text("Enter your personal details to continue.", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(
                value: _noPanCard,
                onChanged: (val) {
                  setState(() {
                    _noPanCard = val ?? false;
                    if (_noPanCard) _panController.clear();
                  });
                },
                activeColor: const Color(0xFF2563EB),
              ),
              const Text("I don't have a PAN card", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmall = constraints.maxWidth < 600;
              final leftField = _noPanCard ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Address Proof Type *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2563EB)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _addressProofType,
                        hint: const Text("-- Select Document Type --"),
                        isExpanded: true,
                        items: _addressProofTypes.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (val) => setState(() => _addressProofType = val),
                      ),
                    ),
                  ),
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("PAN Number *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _panController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "e.g. ABCDE1234F",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      suffixIcon: const Icon(Icons.info_outline, size: 16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Enter a valid 10-character PAN number.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              );

              final rightField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Salary Account Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text("Optional", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), backgroundColor: Color(0xFFF1F5F9))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _salaryAccountController,
                    decoration: InputDecoration(
                      hintText: "1234567890123456",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Used only for salary disbursement.", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              );

              if (isSmall) return Column(children: [leftField, const SizedBox(height: 24), rightField]);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: leftField),
                  const SizedBox(width: 24),
                  Expanded(child: rightField),
                ],
              );
            },
          ),
          if (_noPanCard && _addressProofType != null) ...[
            const SizedBox(height: 24),
            const Text("Upload Address Proof Document *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _pickProfileFile('address_proof'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: const Text("Choose File", style: TextStyle(color: Color(0xFF1E293B))),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(_addressProofName ?? "No file chosen", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B))),
                    ),
                  ),
                ],
              ),
            ),
            if (_addressProofName != null && _addressProofBytes != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showDocumentPreview(_addressProofName!, _addressProofBytes!),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.memory(_addressProofBytes!, width: 40, height: 40, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check, color: Color(0xFF10B981), size: 16),
                                SizedBox(width: 4),
                                Text("Uploaded", style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Text(_addressProofName!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _currentStep = 1),
                icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 16),
                label: const Text("Back", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (!_noPanCard) {
                    if (_panController.text.isEmpty) { _showSnackBar("Please enter PAN number"); return; }
                  } else {
                    if (_addressProofType == null || _addressProofType == '-- Select Document Type --') { _showSnackBar("Please select address proof type"); return; }
                    if (_addressProofName == null) { _showSnackBar("Please upload document"); return; }
                  }
                  setState(() => _currentStep = 3);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Row(
                  children: [
                    Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEducationStep() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                child: const Icon(Icons.school_outlined, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("EDUCATIONAL QUALIFICATIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    Text("Enter your educational details.", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
              const SizedBox(height: 16),
              const Text(
                "Education Board",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _educationBoard,
                    hint: const Text(
                      "Select Board",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                    isExpanded: true,
                    items: _educationBoards
                        .map<DropdownMenuItem<String>>((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _educationBoard = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Primary / Secondary Study (5th - 10th)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _primaryStudy,
                    hint: const Text(
                      "Select Class",
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                    isExpanded: true,
                    items: _primaryStudyList
                        .map<DropdownMenuItem<String>>((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _primaryStudy = val;
                        _primaryMarksheetName = null;
                        _primaryMarksheetBytes = null;
                        if (_primaryStudy != '10th Standard') {
                          _after10thPath = null;
                        }
                      });
                    },
                  ),
                ),
              ),
              if (_primaryStudy == '10th Standard') ...[
                const SizedBox(height: 16),
                const Text(
                  "Upload 10th Marksheet",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                _buildUploadCard(
                  fileName: _primaryMarksheetName,
                  label: "Browse Files",
                  helperText: "PDF, JPG, PNG accepted",
                  onTap: () => _pickProfileFile('primary_marksheet'),
                ),
              ],
              if (_primaryStudy == '10th Standard') ...[
                const SizedBox(height: 32),
                const Text(
                  "After 10th Path Selection",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                _buildPathRadio(
                  1,
                  "Higher Secondary (11th & 12th)",
                  "Higher Secondary",
                ),
                _buildPathRadio(2, "ITI / Vocational Training", "ITI"),
                _buildPathRadio(3, "Direct Job / Other", "Direct Job"),
                const SizedBox(height: 16),
                if (_after10thPath == "Higher Secondary") ...[
                  const Text(
                    "Select Higher Secondary",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _higherSecondaryClass,
                        hint: const Text(
                          "Select Class",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                        isExpanded: true,
                        items: <String>['11th Standard', '12th Standard']
                            .map<DropdownMenuItem<String>>((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _higherSecondaryClass = val;
                            _hsMarksheetName = null;
                            _hsMarksheetBytes = null;
                            if (_higherSecondaryClass == '12th Standard' &&
                                _degrees.isEmpty) {
                              _degrees.add(DegreeQualification());
                            } else if (_higherSecondaryClass !=
                                '12th Standard') {
                              _degrees.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  if (_higherSecondaryClass == '12th Standard') ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Upload 12th Marksheet",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadCard(
                      fileName: _hsMarksheetName,
                      label: "Browse Files",
                      helperText: "PDF, JPG, PNG accepted",
                      onTap: () => _pickProfileFile('hs_marksheet'),
                    ),
                    if (_higherSecondaryClass == '12th Standard') ...[
                      const SizedBox(height: 32),
                      _sectionTitle("Degree Qualification"),
                      const SizedBox(height: 16),
                      ...List.generate(
                        _degrees.length,
                            (index) => _buildDegreeBlock(index),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () =>
                            setState(() => _degrees.add(DegreeQualification())),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text(
                          "Add More Degree",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ] else if (_after10thPath == "ITI") ...[
                  const Text(
                    "Select ITI Course",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _itiCourse,
                        hint: const Text(
                          "Select ITI Course",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                        isExpanded: true,
                        items: _itiCourses
                            .map<DropdownMenuItem<String>>((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _itiCourse = val;
                            _itiCertificateName = null;
                            _itiCertificateBytes = null;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_itiCourse != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Upload ITI Certificate",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUploadCard(
                      fileName: _itiCertificateName,
                      label: "Browse Files",
                      helperText: "PDF, JPG, PNG accepted",
                      onTap: () => _pickProfileFile('iti_certificate'),
                    ),
                  ],
                ] else if (_after10thPath == "Direct Job") ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "You have selected direct job option. No further educational qualifications are required.",
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _currentStep = 2),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 16),
                    label: const Text("Back", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_primaryStudy == '10th Standard' && _primaryMarksheetName == null) {
                        _showSnackBar("Please upload 10th marksheet");
                        return;
                      }
                      if (_primaryStudy == '10th Standard' && _after10thPath == "Higher Secondary") {
                        if (_higherSecondaryClass == null) { _showSnackBar("Please select Higher Secondary class"); return; }
                        if (_higherSecondaryClass == '12th Standard' && _hsMarksheetName == null) { _showSnackBar("Please upload 12th marksheet"); return; }
                      }
                      if (_primaryStudy == '10th Standard' && _after10thPath == "ITI") {
                        if (_itiCourse == null) { _showSnackBar("Please select ITI course"); return; }
                        if (_itiCertificateName == null) { _showSnackBar("Please upload ITI certificate"); return; }
                      }
                      setState(() => _currentStep = 4);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      children: [
                        Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
  }

  Widget _buildStep2() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isWide) ...[
              _buildPreviewHeader(),
              const SizedBox(height: 24),
              _buildProfileCompletionCard(),
              const SizedBox(height: 24),
              _buildPersonalAndWorkProfileCard(),
              const SizedBox(height: 24),
              _buildEducationSummaryCard(),
              const SizedBox(height: 24),
              _buildUploadedDocumentsCard(),
              const SizedBox(height: 24),
              _buildDocumentOverviewCard(),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewHeader(),
                        const SizedBox(height: 24),
                        _buildPersonalAndWorkProfileCard(),
                        const SizedBox(height: 24),
                        _buildEducationSummaryCard(),
                        const SizedBox(height: 24),
                        _buildUploadedDocumentsCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCompletionCard(),
                        const SizedBox(height: 24),
                        _buildDocumentOverviewCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            _buildPreviewActionButtons(),
          ],
        );
      },
    );
  }

  Widget _buildPreviewHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.document_scanner, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Review Your Application", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                SizedBox(height: 4),
                Text("Please review all the information below for final submission.", style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(value: 1.0, strokeWidth: 8, backgroundColor: Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB))),
              ),
              const Text("100%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Profile Completion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text("Great! You have completed all steps.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 24),
          _buildCompletionStep("Work Type", true),
          const SizedBox(height: 12),
          _buildCompletionStep("Personal Info", true),
          const SizedBox(height: 12),
          _buildCompletionStep("Education", true),
          const SizedBox(height: 12),
          _buildCompletionStep("Review & Submit", false, isCurrent: true),
        ],
      ),
    );
  }

  Widget _buildCompletionStep(String title, bool completed, {bool isCurrent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_turned_in, size: 16, color: completed ? const Color(0xFF10B981) : const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 14, color: isCurrent ? const Color(0xFF1E293B) : const Color(0xFF64748B), fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            completed ? "Completed" : "Current Step",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: completed ? const Color(0xFF10B981) : const Color(0xFF2563EB)),
          ),
        )
      ],
    );
  }

  Widget _buildPersonalAndWorkProfileCard() {
    return _buildPreviewSectionCard(
      title: "Personal & Work Profile",
      icon: Icons.person,
      iconColor: const Color(0xFF3B82F6),
      onEdit: () => setState(() => _currentStep = 1),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDataField("FULL NAME", _userName)),
              Expanded(child: _buildDataField("WORK TYPE", _workType ?? "Not Selected", isPill: true)),
              Expanded(child: _buildDataField("EMAIL ADDRESS", _userEmail)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDataField("ADDRESS PROOF", _noPanCard ? (_addressProofType ?? "Not Selected") : "PAN Card")),
              Expanded(child: _buildDataField("MOBILE NUMBER", _userPhone)),
              Expanded(child: _buildDataField("SALARY A/C NUMBER", _salaryAccountController.text.isNotEmpty ? _salaryAccountController.text : "Not Provided")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataField(String label, String value, {bool isPill = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        if (isPill)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(value, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          )
        else
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildEducationSummaryCard() {
    return _buildPreviewSectionCard(
      title: "Education Summary",
      icon: Icons.school,
      iconColor: const Color(0xFF6366F1),
      onEdit: () => setState(() => _currentStep = 3),
      child: Column(
        children: [
          if (_primaryStudy != null && _primaryStudy != '-- Select Class --')
            _buildEducationEntry(
              title: _primaryStudy!,
              board: _educationBoard,
              year: "N/A",
            ),
          if (_after10thPath != null)
             _buildEducationEntry(
              title: _after10thPath!,
              board: _higherSecondaryClass ?? _itiCourse,
              year: "N/A",
            ),
          ..._degrees.map((d) => _buildEducationEntry(
            title: d.degree ?? "Degree",
            board: d.instituteController.text,
            year: d.yearOfPassingController.text.isNotEmpty ? d.yearOfPassingController.text : "N/A",
          )),
        ],
      ),
    );
  }

  Widget _buildEducationEntry({required String title, String? board, required String year}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.account_balance, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(board ?? "N/A", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text("Passed: $year", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildUploadedDocumentsCard() {
    return _buildPreviewSectionCard(
      title: "Uploaded Documents",
      icon: Icons.insert_drive_file,
      iconColor: const Color(0xFFF97316),
      onEdit: () => setState(() => _currentStep = 2),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          if (_addressProofName != null) _buildDocumentTile(_addressProofName!, _addressProofBytes, true),
          if (_resumeName != null) _buildDocumentTile(_resumeName!, _resumeBytes, true),
          if (_primaryMarksheetName != null) _buildDocumentTile(_primaryMarksheetName!, _primaryMarksheetBytes, false),
          if (_hsMarksheetName != null) _buildDocumentTile(_hsMarksheetName!, _hsMarksheetBytes, false),
          if (_itiCertificateName != null) _buildDocumentTile(_itiCertificateName!, _itiCertificateBytes, false),
          ..._degrees.where((d) => d.certificateName != null).map((d) => _buildDocumentTile(d.certificateName!, d.certificateBytes, false)),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String fileName, Uint8List? bytes, bool isPDF) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF4444)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const Text("PDF - 450 KB", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          if (bytes != null)
            TextButton.icon(
              onPressed: () => _showDocumentPreview(fileName, bytes),
              icon: const Icon(Icons.zoom_in, size: 16, color: Color(0xFF2563EB)),
              label: const Text("View", style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            )
        ],
      ),
    );
  }

  Widget _buildDocumentOverviewCard() {
    int eduCount = (_primaryMarksheetName != null ? 1 : 0) + (_hsMarksheetName != null || _itiCertificateName != null ? 1 : 0);
    int idCount = (_addressProofName != null ? 1 : 0) + (_resumeName != null ? 1 : 0);
    int degreeCount = _degrees.where((d) => d.certificateName != null).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Document Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
          const SizedBox(height: 24),
          _buildDocCount("Educational", eduCount, 2),
          const SizedBox(height: 16),
          _buildDocCount("ID Proof", idCount, 2),
          const SizedBox(height: 16),
          _buildDocCount("Degree Certificate", degreeCount, _degrees.length > 0 ? _degrees.length : 1),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFF3B82F6)),
                SizedBox(width: 12),
                Expanded(child: Text("All your information is securely verified and protected with industry standard encryption.", style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDocCount(String title, int count, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
            const SizedBox(height: 2),
            Text("$count/$total uploaded", style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        Icon(Icons.check_circle, color: count == total && total > 0 ? const Color(0xFF10B981) : const Color(0xFFCBD5E1), size: 16),
      ],
    );
  }

  Widget _buildPreviewSectionCard({required String title, required IconData icon, required Color iconColor, required VoidCallback onEdit, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 14, color: Color(0xFF2563EB)),
                label: const Text("Edit", style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildPreviewActionButtons() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: () => setState(() => _currentStep = 3),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          label: const Text("Back", style: TextStyle(color: Color(0xFF1E293B))),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, color: Color(0xFF475569)),
          label: const Text("Download Preview", style: TextStyle(color: Color(0xFF475569))),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Confirm & Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ],
          ),
        )
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _workTypeCard(String title, IconData icon) {
    bool selected = _workType == title;
    return InkWell(
      onTap: () {
        setState(() {
          _workType = title;
          // If user switches to Physical Work, clear educational state
          if (_workType == "Physical Work") {
            _selectedClass = null;
            _marksheetName = null;
            _marksheetBytes = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6366F1).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF6366F1)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF94A3B8),
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String? fileName,
    required String label,
    required String helperText,
    required VoidCallback onTap,
  }) {
    bool hasFile = fileName != null;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasFile ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.file_present_rounded : Icons.cloud_upload_outlined,
              color: hasFile ? const Color(0xFF10B981) : const Color(0xFF6366F1),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              fileName ?? label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: hasFile
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF6366F1),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!hasFile) ...[
              const SizedBox(height: 4),
              Text(
                helperText,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPathRadio(int value, String label, String path) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
      value: path,
      groupValue: _after10thPath,
      activeColor: const Color(0xFF6366F1),
      onChanged: (val) => setState(() => _after10thPath = val),
      contentPadding: EdgeInsets.zero,
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF6366F1),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildDegreeBlock(int index) {
    final degree = _degrees[index];
    final streams = _degreeSelectionMap.keys.toList();
    final List<String> degreeOptions =
    degree.stream != null ? _degreeSelectionMap[degree.stream]! : <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Degree Entry ${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              if (_degrees.length > 1)
                IconButton(
                  onPressed: () => setState(() => _degrees.removeAt(index)),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Degree Stream *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: degree.stream,
                hint: const Text(
                  "Select Stream",
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
                isExpanded: true,
                items: streams.map<DropdownMenuItem<String>>((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) => setState(() {
                  degree.stream = val;
                  degree.degree = null; // Reset degree when stream changes
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Select Degree *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: degree.stream == null
                  ? const Color(0xFFF1F5F9)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: degree.degree,
                hint: const Text(
                  'Select Degree',
                  style: TextStyle(color: Colors.grey),
                ),
                isExpanded: true,
                items: degreeOptions.map<DropdownMenuItem<String>>((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: degree.stream == null
                    ? null
                    : (String? val) {
                  setState(() {
                    degree.degree = val;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "University Name *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "University Name *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: degree.universityController,
            decoration: _inputDecoration(
              "Enter University",
              Icons.business_outlined,
            ).copyWith(
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Institute Name *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: degree.instituteController,
            decoration: _inputDecoration(
              "Enter Institute",
              Icons.school_outlined,
            ).copyWith(
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Year of Passing *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: degree.yearOfPassingController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: _inputDecoration(
              "e.g. 2023",
              Icons.calendar_today_outlined,
            ).copyWith(
              fillColor: Colors.white,
              counterText: "",
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Upload Degree Certificate *",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          _buildUploadCard(
            fileName: degree.certificateName,
            label: "Upload Certificate",
            helperText: "PDF, JPG, PNG accepted",
            onTap: () => _pickDegreeFile(index),
          ),
        ],
      ),
    );
  }
}