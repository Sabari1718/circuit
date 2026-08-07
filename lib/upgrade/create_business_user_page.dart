import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import 'business_user_model.dart';
import 'business_user_store.dart';

class CreateBusinessUserPage extends StatefulWidget {
  final BusinessUser? existingBusiness;
  const CreateBusinessUserPage({super.key, this.existingBusiness});

  @override
  State<CreateBusinessUserPage> createState() => _CreateBusinessUserPageState();
}

class _CreateBusinessUserPageState extends State<CreateBusinessUserPage> {
  int _currentStep = 0;
  bool _isSuccess = false;
  bool _isLoading = false;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  final _formKey5 = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  String? _panFileName;
  Uint8List? _panBytes;
  String? _sigFileName;
  Uint8List? _sigBytes;
  String? _logoFileName;
  Uint8List? _logoBytes;
  String? _turnoverRange = 'Select Turnover Range';
  String? _selectedTier;

  final _gstCtrl = TextEditingController();
  String? _gstFileName;
  Uint8List? _gstBytes;

  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  String _bankDocType = 'Bank Statement';
  String? _bankDocFileName;
  Uint8List? _bankDocBytes;

  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _udyamCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();

  final Set<String> _selectedTypes = {};
  final Set<String> _selectedServiceSectors = {};
  final _yearCtrl = TextEditingController();
  String? _employeeRange;

  // Step 6 Category State Variables
  String? _selectedSectorTitle;
  String? _selectedSector;
  String? _selectedSubSector;
  String? _activePrimaryCategory;
  final Set<String> _selectedSubCategories = {};
  final Set<String> _selectedPrimaryCategories = {};

  Map<String, Map<String, Map<String, Map<String, List<String>>>>>
  _categoriesData = {};
  bool _isCategoriesLoading = true;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.existingBusiness != null) {
      final b = widget.existingBusiness!;
      _nameCtrl.text = b.businessName;
      _emailCtrl.text = b.email;
      _phoneCtrl.text = b.phone;
      _websiteCtrl.text = b.website ?? '';
      _panCtrl.text = b.panNumber;
      _gstCtrl.text = b.gstNumber;
      _accNumberCtrl.text = b.accountNumber;
      _confirmAccNumberCtrl.text = b.accountNumber;
      _doorCtrl.text = b.doorNumber;
      _streetCtrl.text = b.streetName;
      _buildingCtrl.text = b.buildingName ?? '';
      _landmarkCtrl.text = b.landmark ?? '';
      _areaCtrl.text = b.area;
      _districtCtrl.text = b.district;
      _pincodeCtrl.text = b.pincode;
      _stateCtrl.text = b.state;
      _countryCtrl.text = b.country;
      _yearCtrl.text = b.yearOfEstablishment;
      _employeeRange = b.employeeRange.isNotEmpty ? b.employeeRange : null;
      _selectedTypes.addAll(b.businessTypes);
      _selectedSectorTitle = b.sectorTitle;
      _selectedSector = b.sector;
      _selectedSubSector = b.subSector;
      if (b.categories != null) {
        _selectedSubCategories.addAll(b.categories!);
      }
    }
  }

  Future<void> _fetchCategories() async {
    setState(() => _isCategoriesLoading = true);
    try {
      final res = await ApiService().fetchCategories();
      if (res['success'] == true && res['data'] != null) {
        final List<dynamic> apiData = res['data'];
        Map<String, Map<String, Map<String, Map<String, List<String>>>>>
        newData = {};

        for (var item in apiData) {
          String title = item['sector_title_name']?.toString().trim() ?? '';
          if (title == '-' || title.isEmpty) continue;

          String sector = item['sector_name']?.toString().trim() ?? '';
          String subSector = item['sub_sector_name']?.toString().trim() ?? '';

          newData.putIfAbsent(title, () => {});
          newData[title]!.putIfAbsent(sector, () => {});
          newData[title]![sector]!.putIfAbsent(subSector, () => {});

          String categoryType =
              item['category_type']?.toString().toLowerCase() ?? '';
          String categoryName = item['category_name']?.toString().trim() ?? '';

          if (categoryType == 'primary') {
            newData[title]![sector]![subSector]!.putIfAbsent(
              categoryName,
              () => [],
            );
          } else if (categoryType == 'secondary') {
            String parentName =
                item['parent_category_name']?.toString().trim() ?? '';
            if (parentName != '-' && parentName.isNotEmpty) {
              newData[title]![sector]![subSector]!.putIfAbsent(
                parentName,
                () => [],
              );
              if (!newData[title]![sector]![subSector]![parentName]!.contains(
                categoryName,
              )) {
                newData[title]![sector]![subSector]![parentName]!.add(
                  categoryName,
                );
              }
            }
          }
        }

        setState(() {
          _categoriesData = newData;
          _isCategoriesLoading = false;
        });
      } else {
        setState(() => _isCategoriesLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      setState(() => _isCategoriesLoading = false);
    }
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    bool isValid = false;
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        if (_turnoverRange == null || _turnoverRange == 'Select Turnover Range') {
          _showError('Select Turnover Range');
          return;
        }
        if (_panBytes == null || _sigBytes == null) {
          _showError('Upload PAN and Signature');
          return;
        }
        isValid = true;
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        if (_gstBytes == null) {
          _showError('Upload GST certificate');
          return;
        }
        isValid = true;
      }
    } else if (_currentStep == 2) {
      if (_formKey3.currentState!.validate()) {
        if (_bankDocBytes == null) {
          _showError('Upload bank document');
          return;
        }
        isValid = true;
      }
    } else if (_currentStep == 3) {
      if (_formKey4.currentState!.validate()) isValid = true;
    } else if (_currentStep == 4) {
      if (_selectedTypes.isEmpty) {
        _showError('Select at least one business type');
        return;
      }
      if (_yearCtrl.text.isEmpty) {
        _showError('Year of establishment is required');
        return;
      }
      if (_employeeRange == null) {
        _showError('Select employee range');
        return;
      }
      isValid = true;
    } else if (_currentStep == 5) {
      if (_selectedSectorTitle == null) {
        _showError('Sector Title is required');
        return;
      }
      if (_selectedSector == null) {
        _showError('Sector is required');
        return;
      }
      if (_selectedSubSector == null) {
        _showError('Sub Sector is required');
        return;
      }
      if (_activePrimaryCategory == null && _selectedSubCategories.isEmpty) {
        _showError('Select at least one category');
        return;
      }
      if (!_termsAccepted) {
        _showError('Please accept the Terms and Conditions to proceed');
        return;
      }
      _handleSubmit();
      return;
    }
    if (isValid) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0)
      setState(() => _currentStep--);
    else
      Navigator.pop(context);
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
  );

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      String userMainId = prefs.getString('user_main_id') ?? '';

      // 🚨 TEMP FIX: Override ghost user ID to prevent foreign key server error
      if (userMainId == '8059210846') {
        userMainId = '6102066450'; // The correct ID from the web
        debugPrint(
          '🚨 [TEMP FIX] Overriding invalid user_main_id 8059210846 with 6102066450',
        );
      }

      // Prepare Categories JSON
      final primaryCategoriesList = _selectedSubCategories.toList();
      final primaryCategoriesJson = jsonEncode(
        primaryCategoriesList
            .asMap()
            .entries
            .map((e) => {'id': e.key + 1, 'name': e.value})
            .toList(),
      );

      final businessTypesJson = jsonEncode(_selectedTypes.toList());
      final bankDocType = _bankDocType == 'Bank Statement'
          ? 'statement'
          : 'cheque';

      // Call API
      final result = await ApiService().createBusiness(
        businessId: widget.existingBusiness?.id,
        userMainId: userMainId,
        type: 'propagator',
        companyTier: (_selectedTier ?? 'STARTUP').toUpperCase(),
        businessName: _nameCtrl.text.trim(),
        businessEmail: _emailCtrl.text.trim(),
        businessPhone: _phoneCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
        sector: _selectedSector ?? '',
        sectorTitle: _selectedSectorTitle ?? '',
        subSector: _selectedSubSector ?? '',
        primaryCategories: primaryCategoriesJson,
        subCategories: '[]',
        businessTypes: businessTypesJson,
        turnoverRange: _turnoverRange ?? '',
        employeeCount: _employeeRange ?? '',
        doorNumber: _doorCtrl.text.trim(),
        streetName: _streetCtrl.text.trim(),
        buildingName: _buildingCtrl.text.trim(),
        landmark: _landmarkCtrl.text.trim(),
        area: _areaCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        pincode: _pincodeCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
        latitude: '',
        longitude: '',
        panNumber: _panCtrl.text.trim(),
        gstNumber: _gstCtrl.text.trim(),
        currentAccountNumber: _accNumberCtrl.text.trim(),
        bankDocumentType: bankDocType,
        yearOfEstablishment: _yearCtrl.text.isNotEmpty ? _yearCtrl.text : null,
        // Files
        companyLogoBytes: _logoBytes,
        companyLogoFileName: _logoFileName ?? 'logo.jpg',
        signImageBytes: _sigBytes,
        signImageFileName: _sigFileName ?? 'signature.jpg',
        panCardPhotoBytes: _panBytes,
        panCardPhotoFileName: _panFileName ?? 'pan.jpg',
        gstCertificateBytes: _gstBytes,
        gstCertificateFileName: _gstFileName ?? 'gst.pdf',
        bankDocumentBytes: _bankDocBytes,
        bankDocumentFileName: _bankDocFileName ?? 'bank.pdf',
      );

      debugPrint('[Business] API raw result: $result');

      // Network/catch error
      if (result['status'] == 'error') {
        _showError(result['message'] ?? 'Network error. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Registration failed: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final f = result.files.first;
        if (type == 'logo') {
          _logoFileName = f.name;
          _logoBytes = f.bytes;
        } else if (type == 'pan') {
          _panFileName = f.name;
          _panBytes = f.bytes;
        } else if (type == 'sig') {
          _sigFileName = f.name;
          _sigBytes = f.bytes;
        } else if (type == 'gst') {
          _gstFileName = f.name;
          _gstBytes = f.bytes;
        } else if (type == 'bank') {
          _bankDocFileName = f.name;
          _bankDocBytes = f.bytes;
        }
      });
    }
  }

  void _autofillPincode(String pin) {
    if (pin == '642101') {
      _areaCtrl.text = 'Aliyar Nagar';
      _districtCtrl.text = 'Coimbatore';
      _stateCtrl.text = 'Tamil Nadu';
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF8B5CF6);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isSuccess) return _buildSuccessPage(themeColor, isDark);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 1,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: _prevStep,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Propagator Business',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            Text(
              'Complete the steps below to register your business',
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontWeight: FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildStepperHeader(themeColor, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _buildCurrentStep(themeColor, isDark),
                    ),
                  ),
                ),
              ),
              _buildControlButtons(themeColor, isDark),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: themeColor,
                  strokeWidth: 5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepperHeader(Color color, bool isDark) {
    final labels = [
      'Basic Details',
      'GST Details',
      'Bank Details',
      'Address',
      'Type',
      'Categories',
    ];
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          6,
          (i) => Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: i < _currentStep
                            ? Colors.green
                            : (i == _currentStep
                                  ? color
                                  : (isDark
                                        ? Colors.white10
                                        : const Color(0xFFE2E8F0))),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: i < _currentStep
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: i == _currentStep
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: i == _currentStep
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: i == _currentStep
                            ? color
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                if (i < 5)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i < _currentStep
                          ? Colors.green
                          : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                      margin: const EdgeInsets.only(bottom: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStep == 5) ...[
            InkWell(
              onTap: () {
                setState(() {
                  _termsAccepted = !_termsAccepted;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _termsAccepted,
                      onChanged: (val) {
                        setState(() {
                          _termsAccepted = val ?? false;
                        });
                      },
                      activeColor: color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'I agree to the terms and conditions and confirm accuracy.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF4338CA),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentStep == 5 ? 'Create Business' : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  Widget _buildCurrentStep(Color color, bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(isDark);
      case 1:
        return _buildStep2(isDark);
      case 2:
        return _buildStep3(isDark);
      case 3:
        return _buildStep4(color, isDark);
      case 4:
        return _buildStep5(color, isDark);
      case 5:
        return _buildStep6(color, isDark);
      default:
        return const SizedBox();
    }
  }

  Widget _buildCardSection(String title, IconData icon, bool isDark, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputWithVerify(String label, TextEditingController ctrl, bool isDark, {String? hintText, TextInputType keyboardType = TextInputType.text}) {
    final isPhone = label.toLowerCase().contains('phone') || label.toLowerCase().contains('mobile');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ctrl,
                keyboardType: isPhone ? TextInputType.number : keyboardType,
                inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)] : null,
                validator: (val) {
                  if (label.contains('*') && (val == null || val.trim().isEmpty)) {
                    return 'This field is required';
                  }
                  return null;
                },
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[400], fontSize: 13, fontWeight: FontWeight.normal),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9).withOpacity(0.5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1), // Indigo color
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Verify', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildResponsiveRow(Widget child1, Widget child2) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              child1,
              const SizedBox(height: 16),
              child2,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: child1),
            const SizedBox(width: 16),
            Expanded(child: child2),
          ],
        );
      },
    );
  }

  Widget _buildStep1(bool isDark) => Form(
    key: _formKey1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardSection('Basic Business Details', Icons.business, isDark, [
          _buildResponsiveRow(
            _buildInputField('Business Name *', _nameCtrl, isDark, showPadding: false, hintText: 'Enter business name'),
            _buildInputWithVerify('Business Email *', _emailCtrl, isDark, hintText: 'business@example.com'),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildInputWithVerify('Business Phone *', _phoneCtrl, isDark, hintText: '10-digit mobile number', keyboardType: TextInputType.phone),
            _buildInputField('Website', _websiteCtrl, isDark, showPadding: false, hintText: 'https://www.example.com'),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildInputField('Udyam Registration Number *', _udyamCtrl, isDark, showPadding: false, hintText: 'Enter Udyam Registration Number (e.g., UDYAM-TN-12-0001234)'),
            _buildInputField('Corporate Identification Number (CIN)', _cinCtrl, isDark, showPadding: false, hintText: 'Enter CIN (e.g., U12345TN2024PTC123456)'),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildLogoUploadField('Company Logo (Optional)', _logoFileName, _logoBytes, () => _pickFile('logo'), isDark, showPadding: false),
            _buildTurnoverDropdown(isDark, showPadding: false),
          ),
        ]),
        
        _buildCardSection('Company Tier *', Icons.stars, isDark, [
           if (_turnoverRange == null || _turnoverRange == 'Select Turnover Range')
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
               child: Row(children: [
                 Icon(Icons.info, color: Colors.grey[600], size: 20),
                 const SizedBox(width: 8),
                 Expanded(child: Text("Please select a Turnover / Income range first to see available tiers.", style: TextStyle(color: Colors.grey[600]))),
               ]),
             )
           else ...[
             Row(
               children: [
                 if (_turnoverRange == '20 Lakhs to 50 Lakhs') ...[
                   Expanded(
                     child: _buildTierCard(
                       'Startup',
                       'Small business / new company',
                       Icons.rocket_launch,
                       Colors.red,
                       _selectedTier == 'Startup',
                       isDark,
                       _turnoverRange == '20 Lakhs to 50 Lakhs',
                     ),
                   ),
                   const SizedBox(width: 8),
                 ],
                 if (_turnoverRange == '20 Lakhs to 50 Lakhs' ||
                     _turnoverRange == '50 Lakhs to 2 Crores') ...[
                   Expanded(
                     child: _buildTierCard(
                       'Standard',
                       'Growing business',
                       Icons.domain,
                       Colors.blue,
                       _selectedTier == 'Standard',
                       isDark,
                       _turnoverRange == '50 Lakhs to 2 Crores',
                     ),
                   ),
                   const SizedBox(width: 8),
                 ],
                 Expanded(
                   child: _buildTierCard(
                     'Corporate',
                     'Large organization',
                     Icons.apartment,
                     Colors.green,
                     _selectedTier == 'Corporate',
                     isDark,
                     _turnoverRange == 'Above 2 Crores',
                   ),
                 ),
                 if (_turnoverRange == '50 Lakhs to 2 Crores') ...[
                   const SizedBox(width: 8),
                   const Expanded(child: SizedBox()),
                 ],
                 if (_turnoverRange == 'Above 2 Crores') ...[
                   const SizedBox(width: 8),
                   const Expanded(child: SizedBox()),
                   const SizedBox(width: 8),
                   const Expanded(child: SizedBox()),
                 ],
               ],
             ),
             const SizedBox(height: 12),
             Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.lightBlueAccent.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Row(
                 children: [
                   const Icon(Icons.info, color: Colors.blue, size: 16),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       'Based on your turnover range, we recommended this tier. You can still choose another option.',
                       style: TextStyle(
                         fontSize: 11,
                         color: isDark ? Colors.white70 : Colors.black87,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           ]
        ]),

        _buildCardSection('PAN Details', Icons.credit_card, isDark, [
          _buildResponsiveRow(
            _buildInputField('Business PAN Number *', _panCtrl, isDark, showPadding: false, hintText: '10-character alphanumeric PAN number'),
            _buildFileUpload('Business PAN Card Photo *', _panFileName, _panBytes, () => _pickFile('pan'), isDark, uploadText: 'Click to upload PAN card', subText: 'PDF, JPG or PNG (max. 5MB)', showPadding: false),
          ),
        ]),

        _buildCardSection('Authorized Signature', Icons.draw, isDark, [
           _buildFileUpload('Upload Signature Photo *', _sigFileName, _sigBytes, () => _pickFile('sig'), isDark, uploadText: 'Click to upload signature', subText: 'JPG or PNG (max. 5MB)', showPadding: false),
        ]),
      ],
    ),
  );

  Widget _buildStep2(bool isDark) => Form(
    key: _formKey2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardSection('GST Details', Icons.description, isDark, [
          _buildInputField(
            'GST Number *',
            _gstCtrl,
            isDark,
            showPadding: false,
            hintText: '15-character alphanumeric GST number',
          ),
          const SizedBox(height: 16),
          _buildFileUpload(
            'GST Certificate *',
            _gstFileName,
            _gstBytes,
            () => _pickFile('gst'),
            isDark,
            uploadText: 'Click to upload GST certificate',
            subText: 'PDF, JPG or PNG (max. 5MB)',
            showPadding: false,
          ),
        ]),
      ],
    ),
  );

  Widget _buildStep3(bool isDark) => Form(
    key: _formKey3,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              const Icon(Icons.account_balance, color: Colors.blue, size: 22),
              const SizedBox(width: 10),
              Text(
                'Current Account Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        _buildFormCard([
          _buildInputField(
            'Current Account Number *',
            _accNumberCtrl,
            isDark,
            hintText: 'Enter current account number',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Confirm Account Number *',
            _confirmAccNumberCtrl,
            isDark,
            hintText: 'Re-enter account number',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Type *',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRadioOption('Bank Statement', isDark),
                    const SizedBox(width: 16),
                    _buildRadioOption('Canceled Cheque Leaf', isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildFileUpload(
              'Upload $_bankDocType *',
              _bankDocFileName,
              _bankDocBytes,
              () => _pickFile('bank'),
              isDark,
              uploadText: 'Click to upload document',
              subText: 'PDF, JPG or PNG (max. 5MB)',
            ),
          ),
        ]),
      ],
    ),
  );

  Widget _buildStep4(Color color, bool isDark) => Form(
    key: _formKey4,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 22),
              const SizedBox(width: 10),
              Text(
                'Business Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        _buildFormCard([
          _buildResponsiveRow(
            _buildInputField(
              'Door Number *',
              _doorCtrl,
              isDark,
              hintText: 'Door Number',
              showPadding: false,
            ),
            _buildInputField(
              'Street Name *',
              _streetCtrl,
              isDark,
              hintText: 'Street Name',
              showPadding: false,
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildInputField(
              'Building Name',
              _buildingCtrl,
              isDark,
              hintText: 'Building Name',
              showPadding: false,
            ),
            _buildInputField(
              'Landmark',
              _landmarkCtrl,
              isDark,
              hintText: 'Landmark',
              showPadding: false,
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildInputField(
              'Area *',
              _areaCtrl,
              isDark,
              hintText: 'Area',
              showPadding: false,
            ),
            _buildInputField(
              'District *',
              _districtCtrl,
              isDark,
              hintText: 'District',
              showPadding: false,
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildInputField(
              'Pincode *',
              _pincodeCtrl,
              isDark,
              hintText: 'Pincode',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              showPadding: false,
            ),
            _buildInputField(
              'State *',
              _stateCtrl,
              isDark,
              hintText: 'State',
              showPadding: false,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            'Country',
            _countryCtrl,
            isDark,
            readOnly: true,
            hintText: 'India',
            showPadding: false,
          ),
        ]),
      ],
    ),
  );

  Widget _buildStep5(Color color, bool isDark) {
    final List<Map<String, dynamic>> localOptions = [
      {"label": "Trade", "icon": Icons.swap_horiz_rounded},
      {"label": "Import", "icon": Icons.download_rounded},
      {"label": "Export", "icon": Icons.upload_rounded},
      {"label": "Manufacturing", "icon": Icons.factory_rounded},
      {"label": "Services", "icon": Icons.design_services_rounded},
      {"label": "Retail", "icon": Icons.store_rounded},
      {"label": "Wholesale", "icon": Icons.storefront_rounded},
      {"label": "Distribution", "icon": Icons.local_shipping_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              const Icon(Icons.business_center, color: Colors.blue, size: 22),
              const SizedBox(width: 10),
              Text(
                'Business Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Business Type * (Multiple Select)',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemCount: localOptions.length,
          itemBuilder: (context, i) {
            final type = localOptions[i];
            bool isSelected = _selectedTypes.contains(type['label']);
            return InkWell(
              onTap: () => setState(
                () => isSelected
                    ? _selectedTypes.remove(type['label'])
                    : _selectedTypes.add(type['label']),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? Colors.white.withOpacity(0.02)
                            : Colors.white),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue.withOpacity(0.5)
                        : (isDark ? Colors.white10 : Colors.grey[200]!),
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'],
                      size: 24,
                      color: isSelected
                          ? Colors.redAccent
                          : (isDark ? Colors.white70 : Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type['label'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedTypes.contains('Services')) ...[
          const SizedBox(height: 24),
          Text(
            'Service Sectors (Multiple Select)',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
            ),
            itemCount: 8,
            itemBuilder: (context, i) {
              final List<Map<String, dynamic>> serviceSectors = [
                {"label": "IT Services", "icon": Icons.computer},
                {
                  "label": "Financial Services",
                  "icon": Icons.account_balance_wallet,
                },
                {"label": "Healthcare", "icon": Icons.favorite},
                {"label": "Consulting", "icon": Icons.show_chart},
                {"label": "Legal Services", "icon": Icons.gavel},
                {"label": "Education", "icon": Icons.school},
                {"label": "Real Estate", "icon": Icons.apartment},
                {"label": "Logistics", "icon": Icons.local_shipping},
              ];
              final sector = serviceSectors[i];
              bool isSelected = _selectedServiceSectors.contains(
                sector['label'],
              );
              return InkWell(
                onTap: () => setState(
                  () => isSelected
                      ? _selectedServiceSectors.remove(sector['label'])
                      : _selectedServiceSectors.add(sector['label']),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? Colors.white.withOpacity(0.02)
                              : Colors.white),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.5)
                          : (isDark ? Colors.white10 : Colors.grey[200]!),
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected && !isDark
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sector['icon'],
                        size: 24,
                        color: isSelected
                            ? Colors.redAccent
                            : (isDark ? Colors.white70 : Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sector['label'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.redAccent,
                            size: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(),
        ),
        SearchableDropdown(
          label: 'Year of Establishment *',
          value: _yearCtrl.text.isEmpty ? null : _yearCtrl.text,
          items: List.generate(
            2026 - 1950 + 1,
            (index) => (2026 - index).toString(),
          ),
          isDark: isDark,
          onChanged: (val) {
            setState(() {
              _yearCtrl.text = val;
            });
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Number of Employees *',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          value: _employeeRange,
          items: ['1-10', '11-50', '51-100', '101-500', '500+']
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _employeeRange = v),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey[300]!,
              ),
            ),
          ),
        ),
      ],
    );
  }
   Widget _buildCategoryDropdownCard({
    required int index,
    required Color color,
    required String title,
    required int selectedCount,
    required IconData prefixIcon,
    required String hint,
    required bool isDark,
    required List<String> items,
    required String? value,
    required ValueChanged<String> onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$selectedCount Selected',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const SizedBox(height: 12),
                SearchableDropdown(
                  label: '',
                  value: value,
                  items: items,
                  isDark: isDark,
                  hint: hint,
                  enabled: enabled,
                  onChanged: onChanged,
                  prefixIcon: prefixIcon,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6(Color color, bool isDark) {
    if (_isCategoriesLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: color),
        ),
      );
    }

    final sectorTitles = _categoriesData.keys.toList();
    final sectors =
        _selectedSectorTitle != null
            ? _categoriesData[_selectedSectorTitle]!.keys.toList()
            : <String>[];
    final subSectors =
        (_selectedSectorTitle != null && _selectedSector != null)
            ? _categoriesData[_selectedSectorTitle]![_selectedSector]!
                .keys
                .toList()
            : <String>[];

    final primaryCategories =
        (_selectedSectorTitle != null &&
                _selectedSector != null &&
                _selectedSubSector != null)
            ? _categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]!
                .keys
                .toList()
            : <String>[];

    final List<String> subCategoriesList = [];
    if (_selectedSectorTitle != null &&
        _selectedSector != null &&
        _selectedSubSector != null) {
      for (final pc in _selectedPrimaryCategories) {
        final subs =
            _categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]![pc] ??
            <String>[];
        subCategoriesList.addAll(subs);
      }
    }

    String? selectedPrimary =
        _selectedPrimaryCategories.isNotEmpty
            ? _selectedPrimaryCategories.first
            : null;
    String? selectedSub =
        _selectedSubCategories.isNotEmpty
            ? _selectedSubCategories.first
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Business Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Select the categories that best match your business.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCategoryDropdownCard(
                index: 1,
                color: Colors.deepPurpleAccent,
                title: 'Sector Title',
                selectedCount: _selectedSectorTitle != null ? 1 : 0,
                prefixIcon: Icons.folder,
                hint: 'Select Sector Title...',
                isDark: isDark,
                items: sectorTitles,
                value: _selectedSectorTitle,
                onChanged: (val) {
                  setState(() {
                    _selectedSectorTitle = val;
                    _selectedSector = null;
                    _selectedSubSector = null;
                    _selectedPrimaryCategories.clear();
                    _selectedSubCategories.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCategoryDropdownCard(
                index: 4,
                color: Colors.green,
                title: 'Primary Categories',
                selectedCount: _selectedPrimaryCategories.length,
                prefixIcon: Icons.local_offer,
                hint: 'Select Primary Categories...',
                isDark: isDark,
                items: primaryCategories,
                value: selectedPrimary,
                enabled: primaryCategories.isNotEmpty,
                onChanged: (val) {
                  setState(() {
                    _selectedPrimaryCategories.clear();
                    _selectedPrimaryCategories.add(val);
                    _selectedSubCategories.clear();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCategoryDropdownCard(
                index: 2,
                color: Colors.blue,
                title: 'Sector',
                selectedCount: _selectedSector != null ? 1 : 0,
                prefixIcon: Icons.business_center,
                hint: 'Select Sector...',
                isDark: isDark,
                items: sectors,
                value: _selectedSector,
                enabled: _selectedSectorTitle != null,
                onChanged: (val) {
                  setState(() {
                    _selectedSector = val;
                    _selectedSubSector = null;
                    _selectedPrimaryCategories.clear();
                    _selectedSubCategories.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCategoryDropdownCard(
                index: 5,
                color: Colors.orange,
                title: 'Sub Categories',
                selectedCount: _selectedSubCategories.length,
                prefixIcon: Icons.style,
                hint: 'Select Sub Categories...',
                isDark: isDark,
                items: subCategoriesList.toSet().toList(),
                value: selectedSub,
                enabled: subCategoriesList.isNotEmpty,
                onChanged: (val) {
                  setState(() {
                    _selectedSubCategories.clear();
                    _selectedSubCategories.add(val);
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCategoryDropdownCard(
                index: 3,
                color: Colors.teal,
                title: 'Sub Sector',
                selectedCount: _selectedSubSector != null ? 1 : 0,
                prefixIcon: Icons.layers,
                hint: 'Select Sub Sector...',
                isDark: isDark,
                items: subSectors,
                value: _selectedSubSector,
                enabled: _selectedSector != null,
                onChanged: (val) {
                  setState(() {
                    _selectedSubSector = val;
                    _selectedPrimaryCategories.clear();
                    _selectedSubCategories.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCategoryDropdownCard(
                index: 6,
                color: Colors.pinkAccent,
                title: 'Brand',
                selectedCount: 0,
                prefixIcon: Icons.workspace_premium,
                hint: 'Select Brands...',
                isDark: isDark,
                items: [],
                value: null,
                enabled: false,
                onChanged: (val) {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String label, bool isDark) {
    bool isSelected = _bankDocType == label;
    return GestureDetector(
      onTap: () => setState(() => _bankDocType = label),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF8B5CF6)
                    : (isDark ? Colors.white30 : const Color(0xFFCBD5E1)),
                width: isSelected ? 5 : 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : (isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading(String title, String subtitle, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
  Widget _buildFormCard(List<Widget> children) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  Widget _buildInputField(
    String label,
    TextEditingController ctrl,
    bool isDark, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool showPadding = true,
    String? hintText,
  }) {
    final isPan = label.toLowerCase().contains('pan') || ctrl == _panCtrl;
    final isPhone =
        label.toLowerCase().contains('phone') ||
        label.toLowerCase().contains('mobile') ||
        ctrl == _phoneCtrl;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showPadding ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            keyboardType: isPhone ? TextInputType.number : keyboardType,
            inputFormatters: isPan
                ? [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(10),
                  ]
                : isPhone
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ]
                : inputFormatters,
            validator:
                validator ??
                (label.contains('*')
                    ? (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }
                    : null),
            readOnly: readOnly,
            textCapitalization: isPan
                ? TextCapitalization.characters
                : TextCapitalization.none,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9).withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[200]!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnoverDropdown(bool isDark, {bool showPadding = true}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showPadding ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Turnover / Income *',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            value: _turnoverRange,
            hint: Text(
              'Select Turnover Range',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.grey[500],
              ),
            ),
            items:
                [
                      'Select Turnover Range',
                      '20 Lakhs to 50 Lakhs',
                      '50 Lakhs to 2 Crores',
                      'Above 2 Crores',
                    ]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (v) {
              setState(() {
                _turnoverRange = v;
                if (v == 'Select Turnover Range') {
                  _selectedTier = null;
                } else if (v == '20 Lakhs to 50 Lakhs') {
                  _selectedTier = 'Startup';
                } else if (v == '50 Lakhs to 2 Crores') {
                  _selectedTier = 'Standard';
                } else if (v == 'Above 2 Crores') {
                  _selectedTier = 'Corporate';
                }
              });
            },
            validator: (value) =>
                value == null || value == 'Select Turnover Range' ? 'Select Turnover Range' : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9).withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[200]!,
                ),
              ),
            ),
          ),
          // The tier section has been moved to _buildStep1 directly.


        ],
      ),
    );
  }

  Widget _buildLogoUploadField(
    String label,
    String? name,
    Uint8List? bytes,
    VoidCallback onTap,
    bool isDark,
    {bool showPadding = true}
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: showPadding ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : const Color(0xFFF1F5F9).withOpacity(0.5),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.white,
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Choose File',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name ?? 'No file chosen',
                            style: TextStyle(
                              fontSize: 13,
                              color: name != null
                                  ? (isDark ? Colors.white : Colors.black87)
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (bytes != null &&
                  (name?.toLowerCase().endsWith('.jpg') == true ||
                      name?.toLowerCase().endsWith('.png') == true ||
                      name?.toLowerCase().endsWith('.jpeg') == true)) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(bytes, fit: BoxFit.contain),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey[300]!,
                      ),
                      image: DecorationImage(
                        image: MemoryImage(bytes),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'JPG, PNG (Max 2MB)',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTierCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool isSelected,
    bool isDark,
    bool isRecommended,
  ) {
    final activeIconColor = isSelected ? iconColor : Colors.grey;

    return GestureDetector(
      onTap: () => setState(() => _selectedTier = title),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white.withOpacity(0.02) : Colors.white),
              border: Border.all(
                color: isSelected
                    ? Colors.blue.withOpacity(0.5)
                    : (isDark ? Colors.white10 : Colors.grey[200]!),
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected && !isDark
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeIconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: activeIconColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 8),
                      const SizedBox(width: 2),
                      const Text(
                        'Recommended',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileUpload(
    String label,
    String? name,
    Uint8List? bytes,
    VoidCallback onTap,
    bool isDark, {
    String uploadText = 'Upload Document',
    String? subText,
    bool showPadding = true,
  }) => Padding(
    padding: EdgeInsets.symmetric(horizontal: showPadding ? 20 : 0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: isDark ? Colors.white70 : Colors.black,
        ),
      ),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFFF8FAFC),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: bytes != null
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          name!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload,
                      color: Color(0xFF64748B),
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      uploadText,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subText,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    ],
  ));

  Widget _buildSuccessPage(Color color, bool isDark) => Scaffold(
    backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 32),
            Text(
              'Business Created Successfully!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your propagator business has been registered and is ready to use.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _isSuccess = false;
                  _currentStep = 0;
                  _resetControllers();
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Add Another',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : const Color(0xFF4338CA),
                  ),
                ),
                child: Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF4338CA),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _resetControllers() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _websiteCtrl.clear();
    _panCtrl.clear();
    _gstCtrl.clear();
    _accNumberCtrl.clear();
    _confirmAccNumberCtrl.clear();
    _ifscCtrl.clear();
    _bankNameCtrl.clear();
    _holderNameCtrl.clear();
    _doorCtrl.clear();
    _streetCtrl.clear();
    _buildingCtrl.clear();
    _landmarkCtrl.clear();
    _areaCtrl.clear();
    _districtCtrl.clear();
    _pincodeCtrl.clear();
    _stateCtrl.clear();
    _yearCtrl.clear();
    _panBytes = null;
    _sigBytes = null;
    _gstBytes = null;
    _bankDocBytes = null;
    _logoBytes = null;
    _logoFileName = null;
    _turnoverRange = null;
    _selectedTier = null;
    _selectedTypes.clear();
    _employeeRange = null;
    _selectedSectorTitle = null;
    _selectedSector = null;
    _selectedSubSector = null;
    _activePrimaryCategory = null;
    _selectedSubCategories.clear();
  }
}

// Custom Searchable Dropdown widget
class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String hint;
  final bool enabled;
  final IconData? prefixIcon;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    this.hint = "Search...",
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: widget.enabled
              ? () {
                  showDialog(
                    context: context,
                    builder: (context) => _DropdownSearchDialog(
                      title: widget.label.isEmpty ? 'Search' : widget.label,
                      items: widget.items,
                      initialValue: widget.value,
                      isDark: widget.isDark,
                      hint: widget.hint,
                    ),
                  ).then((val) {
                    if (val != null) {
                      widget.onChanged(val);
                    }
                  });
                }
              : null,
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,
            child: InputDecorator(
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFFF1F5F9).withOpacity(0.5),
                prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: Colors.grey[600], size: 18) : null,
                prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isDark ? Colors.white10 : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.isDark ? Colors.white10 : Colors.grey[200]!,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.value ?? widget.hint,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: widget.value != null
                            ? (widget.isDark ? Colors.white : Colors.black)
                            : (widget.isDark
                                  ? Colors.white38
                                  : Colors.grey[500]),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownSearchDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? initialValue;
  final bool isDark;
  final String hint;

  const _DropdownSearchDialog({
    required this.title,
    required this.items,
    this.initialValue,
    required this.isDark,
    required this.hint,
  });

  @override
  State<_DropdownSearchDialog> createState() => _DropdownSearchDialogState();
}

class _DropdownSearchDialogState extends State<_DropdownSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filter(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 450, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _filter,
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: widget.isDark ? Colors.white30 : Colors.grey[400],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.isDark ? Colors.white70 : Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item == widget.initialValue;
                  return ListTile(
                    title: Text(
                      item,
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
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
