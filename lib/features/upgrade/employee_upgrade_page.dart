import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sva_business_user/widgets/common_dashboard_app_bar.dart';
import 'package:sva_business_user/core/services/user_service.dart';
import 'employee_resume_selection_page.dart';
import 'employee_application_preview_page.dart';

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
  String? _addressProofType;
  String? _addressProofName;
  Uint8List? _addressProofBytes;

  String? _educationBoard;
  String? _primaryStudy;
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

  final List<String> _addressProofTypes = ['Aadhar Card', 'Driving License', 'Voter ID Card', 'Passport'];
  final List<String> _educationBoards = ['CBSE', 'State Board', 'Matriculation', 'ICSE', 'IB / IGCSE'];
  final List<String> _primaryStudyList = ['5th Standard', '6th Standard', '7th Standard', '8th Standard', '9th Standard', '10th Standard'];
  final List<String> _itiCourses = ['Electrician', 'Fitter', 'Welder', 'Mechanic (Motor Vehicle)', 'Carpenter', 'Plumber', 'Computer Operator & Programming', 'Others'];

  final Map<String, List<String>> _degreeSelectionMap = {
    'Arts/Science': [
      'B.A. – Bachelor of Arts', 'M.A. – Master of Arts', 'B.Sc. – Bachelor of Science', 'M.Sc. – Master of Science',
      'B.Com – Bachelor of Commerce', 'M.Com – Master of Commerce', 'B.B.A. – Bachelor of Business Administration',
      'M.B.A. – Master of Business Administration', 'B.C.A. – Bachelor of Computer Applications',
      'M.C.A. – Master of Computer Applications', 'B.Ed. – Bachelor of Education', 'M.Ed. – Master of Education',
      'B.F.A. – Bachelor of Fine Arts', 'M.F.A. – Master of Fine Arts', 'Other Arts/Science degree'
    ],
    'Engineering': [
      'B.E. – Bachelor of Engineering', 'B.Tech – Bachelor of Technology', 'M.E. – Master of Engineering',
      'M.Tech – Master of Technology', 'Diploma in Engineering', 'Polytechnic', 'Other Engineering degree'
    ],
    'Others': [
      'Law Degree (LLB / LLM)', 'Medical Degree (MBBS / BDS / BAMS / BHMS / Nursing / Pharmacy)',
      'Agriculture Degree', 'Design Degree', 'Hotel Management', 'Aviation', 'Other Professional Degree', 'Other'
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
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
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

    // Optional educational branch validation (if started)
    if (_primaryStudy == '10th Standard' && _primaryMarksheetName == null) {
      _showSnackBar("Please upload 10th marksheet");
      return;
    }
    if (_primaryStudy == '10th Standard' && _after10thPath == "Higher Secondary") {
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

    // Degree Validation
    if (_after10thPath == "Higher Secondary" && _higherSecondaryClass == '12th Standard') {
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

    // Transform degrees
    List<EmployeePreviewDegreeData> degreeData = _degrees.map((d) => EmployeePreviewDegreeData(
      stream: d.stream ?? '',
      degree: d.degree ?? '',
      university: d.universityController.text,
      institute: d.instituteController.text,
      yearOfPassing: d.yearOfPassingController.text,
      certificateName: d.certificateName,
      certificateBytes: d.certificateBytes,
    )).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeApplicationPreviewPage(
          workType: _workType,
          resumeName: _resumeName,
          resumeBytes: _resumeBytes,
          panNumber: _panController.text.toUpperCase(),
          noPanCard: _noPanCard,
          addressProofType: _addressProofType,
          addressProofName: _addressProofName,
          addressProofBytes: _addressProofBytes,
          salaryAccount: _salaryAccountController.text,
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
          degrees: degreeData,
          onSubmit: () {
            Navigator.pop(context);
            _submit();
          },
        ),
      ),
    );
  }

  void _submit() {
    _showSnackBar("Employee registration submitted successfully", isError: false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeResumeSelectionPage(),
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
              _buildStep1(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _indicatorDot(1, "Fill Details", _currentStep >= 1),
        Expanded(child: Container(height: 2, color: _currentStep >= 2 ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0))),
        _indicatorDot(2, "Preview Section", _currentStep >= 2),
      ],
    );
  }

  Widget _indicatorDot(int step, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF6366F1) : Colors.white,
            border: Border.all(color: active ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), width: 2),
          ),
          child: Center(
            child: Text(
              "$step",
              style: TextStyle(color: active ? Colors.white : const Color(0xFF94A3B8), fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? const Color(0xFF1E293B) : const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListenableBuilder(
          listenable: UserService(),
          builder: (context, _) {
            return FutureBuilder<Map<String, String>>(
              future: UserService().getUserData(),
              builder: (context, snapshot) {
                final name = snapshot.data?['name'] ?? "User";
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome, $name! 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),
                    const Text("Complete your employee registration profile", style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Work Type"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _workTypeCard("Physical Work", Icons.engineering_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _workTypeCard("Other Work", Icons.work_outline_rounded)),
                ],
              ),
              const SizedBox(height: 32),
              _sectionTitle("Upload Resume (Optional)"),
              const SizedBox(height: 12),
              _buildUploadCard(
                fileName: _resumeName,
                label: "Browse Files",
                helperText: "PDF, JPG, PNG accepted",
                onTap: () => _pickFile(isResume: true),
              ),
              const SizedBox(height: 32),
              _sectionTitle("Personal Information"),
              const SizedBox(height: 12),
              // Unified PAN Logic
              if (!_noPanCard) ...[
                const Text("PAN Number *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _panController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDecoration("e.g. ABCDE1234F", Icons.badge_outlined),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _noPanCard,
                    onChanged: (val) {
                      setState(() {
                        _noPanCard = val ?? false;
                        if (_noPanCard) {
                          _panController.clear();
                        }
                      });
                    },
                  ),
                  const Text("I don't have a PAN card", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                ],
              ),
              if (_noPanCard) ...[
                const SizedBox(height: 16),
                const Text("Select Address Proof Type *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _addressProofType,
                      hint: const Text("Select Proof Type", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                      isExpanded: true,
                      items: _addressProofTypes.map<DropdownMenuItem<String>>((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _addressProofType = val),
                    ),
                  ),
                ),
                if (_addressProofType != null) ...[
                  const SizedBox(height: 16),
                  const Text("Upload Address Proof Document *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  const SizedBox(height: 8),
                  _buildUploadCard(
                    fileName: _addressProofName,
                    label: "Upload Document",
                    helperText: "PDF, JPG, PNG accepted",
                    onTap: () => _pickProfileFile('address_proof'),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              const Text("Salary Account (Optional)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _salaryAccountController,
                decoration: _inputDecoration("e.g. 1234567890", Icons.account_balance_outlined),
              ),

              // Unified Educational Qualifications Section
              const SizedBox(height: 32),
              _sectionTitle("Educational Qualifications (Optional)"),
              const SizedBox(height: 16),
              const Text("Education Board", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _educationBoard,
                    hint: const Text("Select Board", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                    isExpanded: true,
                    items: _educationBoards.map<DropdownMenuItem<String>>((String val) {
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
              const Text("Primary / Secondary Study (5th - 10th)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _primaryStudy,
                    hint: const Text("Select Class", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                    isExpanded: true,
                    items: _primaryStudyList.map<DropdownMenuItem<String>>((String val) {
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
                const Text("Upload 10th Marksheet", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
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
                const Text("After 10th Path Selection", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                _buildPathRadio(1, "Higher Secondary (11th & 12th)", "Higher Secondary"),
                _buildPathRadio(2, "ITI / Vocational Training", "ITI"),
                _buildPathRadio(3, "Direct Job / Other", "Direct Job"),
                const SizedBox(height: 16),
                if (_after10thPath == "Higher Secondary") ...[
                  const Text("Select Higher Secondary", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _higherSecondaryClass,
                        hint: const Text("Select Class", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                        isExpanded: true,
                        items: <String>['11th Standard', '12th Standard'].map<DropdownMenuItem<String>>((String val) {
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
                            if (_higherSecondaryClass == '12th Standard' && _degrees.isEmpty) {
                              _degrees.add(DegreeQualification());
                            } else if (_higherSecondaryClass != '12th Standard') {
                              _degrees.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  if (_higherSecondaryClass == '12th Standard') ...[
                    const SizedBox(height: 16),
                    const Text("Upload 12th Marksheet", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
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
                      ...List.generate(_degrees.length, (index) => _buildDegreeBlock(index)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _degrees.add(DegreeQualification())),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text("Add More Degree", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ],
                ] else if (_after10thPath == "ITI") ...[
                  const Text("Select ITI Course", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _itiCourse,
                        hint: const Text("Select ITI Course", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                        isExpanded: true,
                        items: _itiCourses.map<DropdownMenuItem<String>>((String val) {
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
                    const Text("Upload ITI Certificate", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
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
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text(
                      "You have selected direct job option. No further educational qualifications are required.",
                      style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _goToPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  child: const Text("Preview Application", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)));
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
          color: selected ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8), size: 28),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: selected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 13)),
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
                color: hasFile ? const Color(0xFF1E293B) : const Color(0xFF6366F1),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!hasFile) ...[
              const SizedBox(height: 4),
              Text(helperText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPathRadio(int value, String label, String path) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
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
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
    );
  }

  Widget _buildDegreeBlock(int index) {
    final degree = _degrees[index];
    final streams = _degreeSelectionMap.keys.toList();
    final List<String> degreeOptions = degree.stream != null ? _degreeSelectionMap[degree.stream]! : <String>[];

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
              Text("Degree Entry ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              if (_degrees.length > 1)
                IconButton(
                  onPressed: () => setState(() => _degrees.removeAt(index)),
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Degree Stream *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: degree.stream,
                hint: const Text("Select Stream", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
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
          const Text("Select Degree *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: degree.stream == null ? const Color(0xFFF1F5F9) : Colors.white,
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
          const Text("University Name *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          TextFormField(
            controller: degree.universityController,
            decoration: _inputDecoration("Enter University", Icons.business_outlined).copyWith(fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))),
          ),
          const SizedBox(height: 16),
          const Text("Institute Name *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          TextFormField(
            controller: degree.instituteController,
            decoration: _inputDecoration("Enter Institute", Icons.school_outlined).copyWith(fillColor: Colors.white, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))),
          ),
          const SizedBox(height: 16),
          const Text("Year of Passing *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          TextFormField(
            controller: degree.yearOfPassingController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: _inputDecoration("e.g. 2023", Icons.calendar_today_outlined).copyWith(fillColor: Colors.white, counterText: "", enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0)))),
          ),
          const SizedBox(height: 16),
          const Text("Upload Degree Certificate *", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
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

