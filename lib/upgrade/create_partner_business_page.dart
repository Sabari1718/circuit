import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'business_user_model.dart';
import 'business_user_store.dart';

class CreatePartnerBusinessPage extends StatefulWidget {
  final BusinessUser? existingBusiness;
  const CreatePartnerBusinessPage({super.key, this.existingBusiness});

  @override
  State<CreatePartnerBusinessPage> createState() => _CreatePartnerBusinessPageState();
}

class _CreatePartnerBusinessPageState extends State<CreatePartnerBusinessPage> {
  int _currentStep = 0;
  bool _isSuccess = false;
  bool _isLoading = false;

  // Form keys for each step
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();

  // Step 1: Partner Details
  final List<_PartnerFormController> _partners = [];

  // Step 2: Basic Details
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _udyamCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  String? _panFileName; Uint8List? _panBytes;
  String? _sigFileName; Uint8List? _sigBytes;
  String? _turnoverRange;
  String _companyTier = 'STARTUP';
  String? _logoFileName; Uint8List? _logoBytes;
  final List<String> _turnoverOptions = [
    '20 Lakhs to 50 Lakhs',
    '50 Lakhs to 2 Crores',
    'Above 2 Crores'
  ];

  // Step 3: GST Details
  final _gstCtrl = TextEditingController();
  String? _gstFileName; Uint8List? _gstBytes;

  // Step 4: Bank Details
  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();
  String _bankDocType = 'Bank Statement';
  String? _bankDocFileName; Uint8List? _bankDocBytes;

  // Step 5: Business Address
  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');

  // Step 6: Business Type
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedServiceSectors = {};
  final List<String> _typeOptions = [
    "Trade", "Import", "Export", "Manufacturing", "Services", "Retail", "Wholesale", "Distribution"
  ];
  final _yearCtrl = TextEditingController();
  String? _employeeRange;

  // Step 7 Category State Variables
  String? _selectedSectorTitle;
  String? _selectedSector;
  String? _selectedSubSector;
  String? _activePrimaryCategory;
  final Set<String> _selectedSubCategories = {};

  // Dynamic Category Hierarchy Dataset
  Map<String, Map<String, Map<String, Map<String, List<String>>>>> _categoriesData = {};
  bool _isLoadingCategories = true;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await ApiService().getCategories();
    if (response['success'] == true && response['data'] != null) {
      final data = response['data'] as List;
      final parsed = <String, Map<String, Map<String, Map<String, List<String>>>>> {};

      // First pass: collect all primary categories
      for (var item in data) {
        if (item['category_type'] == 'primary') {
          final title = item['sector_title_name']?.toString() ?? '-';
          final sector = item['sector_name']?.toString() ?? '-';
          final subSector = item['sub_sector_name']?.toString() ?? '-';
          final category = item['category_name']?.toString() ?? '-';

          parsed.putIfAbsent(title, () => {});
          parsed[title]!.putIfAbsent(sector, () => {});
          parsed[title]![sector]!.putIfAbsent(subSector, () => {});
          parsed[title]![sector]![subSector]!.putIfAbsent(category, () => []);
        }
      }

      // Second pass: collect secondary categories and put them under primary
      for (var item in data) {
        if (item['category_type'] == 'secondary') {
          final title = item['sector_title_name']?.toString() ?? '-';
          final sector = item['sector_name']?.toString() ?? '-';
          final subSector = item['sub_sector_name']?.toString() ?? '-';
          final parentCat = item['parent_category_name']?.toString() ?? '-';
          final category = item['category_name']?.toString() ?? '-';

          if (parsed.containsKey(title) && 
              parsed[title]!.containsKey(sector) && 
              parsed[title]![sector]!.containsKey(subSector)) {
              
              if (parsed[title]![sector]![subSector]!.containsKey(parentCat)) {
                parsed[title]![sector]![subSector]![parentCat]!.add(category);
              } else {
                parsed[title]![sector]![subSector]!.putIfAbsent(parentCat, () => []);
                parsed[title]![sector]![subSector]![parentCat]!.add(category);
              }
          } else {
              parsed.putIfAbsent(title, () => {});
              parsed[title]!.putIfAbsent(sector, () => {});
              parsed[title]![sector]!.putIfAbsent(subSector, () => {});
              parsed[title]![sector]![subSector]!.putIfAbsent(parentCat, () => []);
              parsed[title]![sector]![subSector]![parentCat]!.add(category);
          }
        }
      }

      if (mounted) {
        setState(() {
          _categoriesData = parsed;
          _isLoadingCategories = false;
        });
      }
    } else {
      if (mounted) {
         setState(() => _isLoadingCategories = false);
      }
    }
  }

  void _addPartner() {
    if (_partners.length < 10) {
      setState(() => _partners.add(_PartnerFormController()));
    }
  }

  void _removePartner(int index) {
    setState(() => _partners.removeAt(index));
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    bool isValid = false;

    if (_currentStep == 0) {
      if (_partners.isEmpty) {
        _showError('Add at least one partner to proceed');
        return;
      }
      // Step 1 validation: at least 1 partner and check fields
      bool allValid = true;
      for (var p in _partners) {
        if (p.nameCtrl.text.isEmpty || p.panCtrl.text.isEmpty) allValid = false;
        if (p.dealBytes == null) allValid = false;
        if (p.accessLevel == 'View Only' && p.letterBytes == null) allValid = false;
      }
      if (!allValid) {
        _showError('Fill all required fields and upload documents for all partners');
        return;
      }
      isValid = true;
    } else if (_currentStep == 1) {
      if (_step2Key.currentState!.validate()) {
        if (_panBytes == null || _sigBytes == null) { _showError('Upload PAN and Signature photo'); return; }
        isValid = true;
      }
    } else if (_currentStep == 2) {
      if (_step3Key.currentState!.validate()) {
        if (_gstBytes == null) { _showError('Upload GST certificate'); return; }
        isValid = true;
      }
    } else if (_currentStep == 3) {
      if (_step4Key.currentState!.validate()) {
        if (_accNumberCtrl.text != _confirmAccNumberCtrl.text) { _showError('Account numbers do not match'); return; }
        if (_bankDocBytes == null) { _showError('Upload bank document'); return; }
        isValid = true;
      }
    } else if (_currentStep == 4) {
      if (_step5Key.currentState!.validate()) isValid = true;
    } else if (_currentStep == 5) {
      if (_selectedTypes.isEmpty) { _showError('Select at least one business type'); return; }
      if (_yearCtrl.text.isEmpty) { _showError('Year of establishment is required'); return; }
      if (_employeeRange == null) { _showError('Select employee range'); return; }
      isValid = true;
    } else if (_currentStep == 6) {
      if (_selectedSectorTitle == null) { _showError('Sector Title is required'); return; }
      if (_selectedSector == null) { _showError('Sector is required'); return; }
      if (_selectedSubSector == null) { _showError('Sub Sector is required'); return; }
      if (_activePrimaryCategory == null && _selectedSubCategories.isEmpty) { _showError('Select at least one category'); return; }
      if (!_termsAccepted) { _showError('Please accept the Terms and Conditions to proceed'); return; }
      _handleSubmit();
      return;
    }

    if (isValid) setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
    else Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red[700]));
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    try {
      setState(() => _isLoading = true);

      // Get logged-in user's ID
      final prefs = await SharedPreferences.getInstance();
      String userMainId = prefs.getString('user_main_id') ??
                         prefs.getString('user_phone') ??
                         prefs.getString('phone') ??
                         prefs.getString('mobile') ?? '';

      // ðŸš¨ TEMP FIX: Override ghost user ID to prevent foreign key server error
      if (userMainId == '8059210846') {
        userMainId = '6102066450'; // The correct ID from the web
        debugPrint('ðŸš¨ [TEMP FIX] Overriding invalid user_main_id 8059210846 with 6102066450');
      }

      if (userMainId.isEmpty) {
        _showError('User session not found. Please login again.');
        setState(() => _isLoading = false);
        return;
      }

      final primaryCategoriesList = _selectedSubCategories.toList();
      final primaryCategoriesJson = jsonEncode(
        primaryCategoriesList.asMap().entries.map((e) => {
          'id': e.key + 1,
          'name': e.value,
        }).toList(),
      );

      final businessTypesJson = jsonEncode(_selectedTypes.toList());
      final serviceSectorsJson = jsonEncode(_selectedServiceSectors.toList());
      final bankDocType = _bankDocType == 'Bank Statement' ? 'statement' : 'cheque';

      // Build partners data
      final List<String> partNames = [];
      final List<String> partPans = [];
      final List<String?> partEmails = [];
      final List<String?> partPhones = [];
      String? partnersLevel;
      Uint8List? dealBytes;
      String dealFileName = 'deal.pdf';
      Uint8List? letterBytes;
      String letterFileName = 'letter.pdf';
      
      final List<Map<String, dynamic>> partnersList = [];
      for (var p in _partners) {
        partNames.add(p.nameCtrl.text.trim());
        partPans.add(p.panCtrl.text.trim());
        partEmails.add(null);
        partPhones.add(null);
        
        if (partnersLevel == null) {
          partnersLevel = p.accessLevel == 'View Only' ? 'read only' : 'full access';
        }
        if (dealBytes == null && p.dealBytes != null) {
          dealBytes = p.dealBytes;
          dealFileName = p.dealFileName ?? 'deal.jpg';
        }
        if (letterBytes == null && p.letterBytes != null) {
          letterBytes = p.letterBytes;
          letterFileName = p.letterFileName ?? 'letter.jpg';
        }

        Map<String, dynamic> pData = {
          'name': p.nameCtrl.text.trim(),
          'pan_number': p.panCtrl.text.trim(),
          'access_level': p.accessLevel == 'View Only' ? 'read only' : 'full access',
        };
        // Optional file attachments for each partner
        if (p.dealBytes != null) {
          pData['deal_file_name'] = p.dealFileName;
          pData['deal_file_base64'] = base64Encode(p.dealBytes!); 
        }
        if (p.letterBytes != null) {
          pData['letter_file_name'] = p.letterFileName;
          pData['letter_file_base64'] = base64Encode(p.letterBytes!);
        }
        partnersList.add(pData);
      }
      final partnersDataJson = jsonEncode(partnersList);
      debugPrint('[Partner] Partners payload: $partnersDataJson');

      final result = await ApiService().createBusiness(
        businessId: widget.existingBusiness?.id,
        userMainId: userMainId,
        type: 'partner',
        companyTier: _companyTier,
        businessName: _nameCtrl.text.trim(),
        businessEmail: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : '',
        businessPhone: _phoneCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
        sector: _selectedSector ?? '',
        sectorTitle: _selectedSectorTitle ?? '',
        subSector: _selectedSubSector ?? '',
        primaryCategories: primaryCategoriesJson,
        subCategories: '[]',
        businessTypes: businessTypesJson,
        serviceSectors: serviceSectorsJson,
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
        panNumber: _panCtrl.text.trim(),
        gstNumber: _gstCtrl.text.trim(),
        currentAccountNumber: _accNumberCtrl.text.trim(),
        bankDocumentType: bankDocType,
        yearOfEstablishment: _yearCtrl.text.isNotEmpty ? _yearCtrl.text : null,
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
        partnerCount: _partners.length.toString(),
        partnersData: partnersDataJson,
        partName: jsonEncode(partNames),
        partPan: jsonEncode(partPans),
        partEmail: jsonEncode(partEmails),
        partPhone: jsonEncode(partPhones),
        partners: partnersLevel,
        partnershipDealBytes: dealBytes,
        partnershipDealFileName: dealFileName,
        writtenLetterBytes: letterBytes,
        writtenLetterFileName: letterFileName,
      );

      debugPrint('[Partner] API Response: $result');
      debugPrint('[Partner] Email sent: ${_emailCtrl.text.trim()}');

      if (result['status'] == 'error') {
        _showError(result['message'] ?? 'Network error. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      // Success - same simple pattern as Propagator
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) { _showError('Registration failed: $e'); setState(() => _isLoading = false); }
    }
  }

  Future<void> _pickFile(String type, {int? partnerIndex, String? partnerFileType}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['jpg', 'png', 'pdf'], withData: true
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final f = result.files.first;
        if (partnerIndex != null) {
          if (partnerFileType == 'deal') {
            _partners[partnerIndex].dealFileName = f.name;
            _partners[partnerIndex].dealBytes = f.bytes;
          } else {
            _partners[partnerIndex].letterFileName = f.name;
            _partners[partnerIndex].letterBytes = f.bytes;
          }
        } else {
          if (type == 'logo') { _logoFileName = f.name; _logoBytes = f.bytes; }
          else if (type == 'pan') { _panFileName = f.name; _panBytes = f.bytes; }
          else if (type == 'sig') { _sigFileName = f.name; _sigBytes = f.bytes; }
          else if (type == 'gst') { _gstFileName = f.name; _gstBytes = f.bytes; }
          else if (type == 'bank') { _bankDocFileName = f.name; _bankDocBytes = f.bytes; }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF3B82F6);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSuccess) return _buildSuccessPage(themeColor, isDark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 1, centerTitle: false,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black), onPressed: _prevStep),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create Partner Business', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text('Step ${_currentStep + 1} of 7', style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ]),
      ),
      body: Stack(children: [
        Column(children: [
          _buildStepperHeader(themeColor, isDark),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 600), child: _buildCurrentStep(themeColor, isDark))))),
          _buildControlButtons(themeColor, isDark),
        ]),
        if (_isLoading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: themeColor))),
      ]),
    );
  }

  Widget _buildStepperHeader(Color color, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(value: (_currentStep + 1) / 7, minHeight: 6, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color)),
      ),
    );
  }

  Widget _buildControlButtons(Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStep == 6) ...[
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
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _prevStep, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Previous'))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(_currentStep == 6 ? 'Create Business' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ]),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(Color color, bool isDark) {
    switch (_currentStep) {
      case 0: return _buildStep1(color, isDark);
      case 1: return _buildStep2(isDark);
      case 2: return _buildStep3(isDark);
      case 3: return _buildStep4(isDark);
      case 4: return _buildStep5(isDark);
      case 5: return _buildStep6(color, isDark);
      case 6: return _buildStep7(color, isDark);
      default: return const SizedBox();
    }
  }

  // STEP 1: Partner Details
  Widget _buildStep1(Color color, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handshake_outlined, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    const Text('Partner Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Maximum of 10 partners can be added. (${_partners.length}/10 added)', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          if (_partners.length < 10)
            ElevatedButton.icon(
              onPressed: _addPartner,
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text('Add Partner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Blue color from screenshot
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: 0,
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      if (_partners.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.person_add, size: 56, color: Colors.grey[600]),
              const SizedBox(height: 16),
              const Text('No partners added yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text('Click "Add Partner" to add business partners (Max 10)', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        )
      else
        ...List.generate(_partners.length, (index) => _buildPartnerBlock(index, color, isDark)),
    ]);
  }

  Widget _buildPartnerBlock(int index, Color color, bool isDark) {
    final p = _partners[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.03) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Partner ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3B82F6))),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            onPressed: () => _removePartner(index),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ]),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildInputField('Partner Name *', p.nameCtrl, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildInputField('PAN Number *', p.panCtrl, isDark)),
          ],
        ),
        const Text('Access Level', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(children: [
          _buildRadio(p.accessLevel == 'View Only', 'View Only', () => setState(() => p.accessLevel = 'View Only'), isDark),
          const SizedBox(width: 32),
          _buildRadio(p.accessLevel == 'Full Access', 'Full Access', () => setState(() => p.accessLevel = 'Full Access'), isDark),
        ]),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFileUpload('Partnership Deal *', p.dealFileName, p.dealBytes, () => _pickFile('', partnerIndex: index, partnerFileType: 'deal'), isDark)),
            const SizedBox(width: 16),
            Expanded(child: p.accessLevel == 'View Only' ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFileUpload('Written Letter (with sign) *', p.letterFileName, p.letterBytes, () => _pickFile('', partnerIndex: index, partnerFileType: 'letter'), isDark),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 12),
                      SizedBox(width: 4),
                      Expanded(child: Text('Required for view only mode', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ) : const SizedBox()),
          ],
        ),
      ]),
    );
  }

  // STEP 2: Basic Details
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
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2(bool isDark) {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection('Basic Business Details', Icons.business_center, isDark, [
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
              _buildLogoUpload('Company Logo (Optional)', _logoFileName, _logoBytes, () => _pickFile('logo'), isDark),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Turnover / Income *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _turnoverRange,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    hint: const Text('Select Turnover Range', style: TextStyle(fontSize: 14)),
                    items: _turnoverOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _turnoverRange = v;
                        if (v == '20 Lakhs to 50 Lakhs') _companyTier = 'STARTUP';
                        else if (v == '50 Lakhs to 2 Crores') _companyTier = 'STANDARD';
                        else if (v == 'Above 2 Crores') _companyTier = 'CORPORATE';
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
                    ),
                  ),
                ],
              ),
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
                       child: _buildTierBox(
                         'STARTUP',
                         'Small business / new company',
                         Icons.rocket_launch,
                         _companyTier == 'STARTUP',
                         _turnoverRange == '20 Lakhs to 50 Lakhs',
                         isDark,
                       ),
                     ),
                     const SizedBox(width: 8),
                   ],
                   if (_turnoverRange == '20 Lakhs to 50 Lakhs' ||
                       _turnoverRange == '50 Lakhs to 2 Crores') ...[
                     Expanded(
                       child: _buildTierBox(
                         'STANDARD',
                         'Growing business',
                         Icons.domain,
                         _companyTier == 'STANDARD',
                         _turnoverRange == '50 Lakhs to 2 Crores',
                         isDark,
                       ),
                     ),
                     const SizedBox(width: 8),
                   ],
                   Expanded(
                     child: _buildTierBox(
                       'CORPORATE',
                       'Large organization',
                       Icons.apartment,
                       _companyTier == 'CORPORATE',
                       _turnoverRange == 'Above 2 Crores',
                       isDark,
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
              _buildDragDropUpload('Business PAN Card Photo *', _panFileName, _panBytes, () => _pickFile('pan'), isDark, 'Click to upload PAN card', isFullWidth: true),
            ),
          ]),

          _buildCardSection('Authorized Signature', Icons.draw_outlined, isDark, [
             _buildDragDropUpload('Upload Signature Photo *', _sigFileName, _sigBytes, () => _pickFile('sig'), isDark, 'Click to upload signature', isFullWidth: true),
          ]),
        ],
      ),
    );
  }

  Widget _buildTierBox(String title, String subtitle, IconData icon, bool isSelected, bool isRecommended, bool isDark) {
    Color activeColor = title == 'STARTUP' ? Colors.red : (title == 'STANDARD' ? Colors.blue : Colors.green);
    return GestureDetector(
      onTap: () => setState(() => _companyTier = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : (isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF8FAFC)),
          border: Border.all(color: isSelected ? activeColor : (isDark ? Colors.white10 : Colors.grey[200]!), width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Icon(icon, color: isSelected ? activeColor : Colors.grey, size: 28),
                const SizedBox(height: 12),
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            if (isRecommended)
              Positioned(
                top: -28,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: activeColor, borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 10),
                      SizedBox(width: 4),
                      Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            if (isSelected)
              Positioned(
                top: -16,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoUpload(String label, String? name, Uint8List? bytes, VoidCallback onTap, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: onTap,
                    child: Container(
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[100],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                        border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Choose File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(bytes != null ? name! : 'No file chosen', style: TextStyle(fontSize: 12, color: bytes != null ? (isDark ? Colors.white : Colors.black) : Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (bytes != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                showDialog(context: context, builder: (_) => Dialog(
                  child: InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain)),
                ));
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  image: DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 4),
      const Text('JPG, PNG (Max 2MB)', style: TextStyle(fontSize: 10, color: Colors.grey)),
    ]);
  }

  Widget _buildDragDropUpload(String label, String? name, Uint8List? bytes, VoidCallback onTap, bool isDark, String hintText, {bool isFullWidth = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 8),
      InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: isFullWidth ? 120 : 100,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF8FAFC),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: bytes != null
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Flexible(child: Text(name!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_rounded, color: Color(0xFF64748B), size: 32),
                      const SizedBox(height: 8),
                      Text(hintText, style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('PDF, JPG or PNG (max. 5MB)', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
        ),
      ),
    ]);
  }

  // STEP 3: GST Details
  Widget _buildStep3(bool isDark) {
    return Form(key: _step3Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          const Icon(Icons.receipt_long, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 8),
          const Text('GST Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
      const SizedBox(height: 24),
      _buildInputField('GST Number *', _gstCtrl, isDark),
      Transform.translate(
        offset: const Offset(0, -16),
        child: const Text('15-character alphanumeric GST number', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ),
      _buildDragDropUpload('GST Certificate *', _gstFileName, _gstBytes, () => _pickFile('gst'), isDark, 'Click to upload GST certificate', isFullWidth: true),
    ]));
  }

  // STEP 4: Bank Details
  Widget _buildStep4(bool isDark) {
    return Form(key: _step4Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          const Icon(Icons.account_balance, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 8),
          const Text('Current Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
      const SizedBox(height: 24),
      _buildInputField('Current Account Number *', _accNumberCtrl, isDark, keyboardType: TextInputType.number, hintText: 'Enter current account number'),
      _buildInputField('Confirm Account Number *', _confirmAccNumberCtrl, isDark, keyboardType: TextInputType.number, hintText: 'Re-enter account number'),
      const SizedBox(height: 8),
      const Text('Document Type', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      Row(children: [
        _buildRadio(_bankDocType == 'Bank Statement', 'Bank Statement', () => setState(() => _bankDocType = 'Bank Statement'), isDark),
        const SizedBox(width: 20),
        _buildRadio(_bankDocType == 'Canceled Cheque Leaf', 'Canceled Cheque Leaf', () => setState(() => _bankDocType = 'Canceled Cheque Leaf'), isDark),
      ]),
      const SizedBox(height: 24),
      _buildDragDropUpload(
        _bankDocType == 'Bank Statement' ? 'Upload Bank Statement *' : 'Upload Canceled Cheque *',
        _bankDocFileName,
        _bankDocBytes,
        () => _pickFile('bank'),
        isDark,
        'Click to upload document',
        isFullWidth: true,
      ),
    ]));
  }

  // STEP 5: Business Address
  Widget _buildStep5(bool isDark) {
    return Form(key: _step5Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 8),
          const Text('Business Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: _buildInputField('Door Number *', _doorCtrl, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField('Street Name *', _streetCtrl, isDark)),
      ]),
      _buildInputField('Building Name', _buildingCtrl, isDark),
      _buildInputField('Landmark', _landmarkCtrl, isDark),
      Row(children: [
        Expanded(child: _buildInputField('Area *', _areaCtrl, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField('District *', _districtCtrl, isDark)),
      ]),
      Row(children: [
        Expanded(child: _buildInputField('Pincode *', _pincodeCtrl, isDark, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)])),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField('State *', _stateCtrl, isDark)),
      ]),
      _buildInputField('Country', _countryCtrl, isDark, readOnly: true),
    ]));
  }

  // STEP 6: Business Type
  Widget _buildStep6(Color color, bool isDark) {
    final Map<String, IconData> typeIcons = {
      "Trade": Icons.handshake_outlined,
      "Import": Icons.download_outlined,
      "Export": Icons.upload_outlined,
      "Manufacturing": Icons.factory_outlined,
      "Services": Icons.business_center_outlined,
      "Retail": Icons.storefront_outlined,
      "Wholesale": Icons.local_shipping_outlined,
      "Distribution": Icons.group_outlined,
    };

    final Map<String, IconData> serviceIcons = {
      "IT Services": Icons.computer_outlined,
      "Financial Services": Icons.account_balance_outlined,
      "Healthcare": Icons.local_hospital_outlined,
      "Consulting": Icons.person_pin_outlined,
      "Legal Services": Icons.gavel_outlined,
      "Education": Icons.school_outlined,
      "Real Estate": Icons.location_city_outlined,
      "Logistics": Icons.local_shipping_outlined,
    };

    final serviceSectorList = serviceIcons.keys.toList();
    final int crossAxisCount = MediaQuery.of(context).size.width < 600 ? 2 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business_center, color: Color(0xFF3B82F6), size: 20),
            const SizedBox(width: 8),
            const Text('Business Type & Partners', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Business Type * (Multiple Select)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemCount: _typeOptions.length,
          itemBuilder: (context, i) {
            final type = _typeOptions[i];
            bool isSelected = _selectedTypes.contains(type);
            return InkWell(
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedTypes.remove(type);
                  if (type == 'Services') _selectedServiceSectors.clear();
                } else {
                  _selectedTypes.add(type);
                }
              }),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : (isDark ? Colors.white10 : Colors.grey[200]!), width: isSelected ? 1.5 : 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(typeIcons[type], color: isSelected ? color : Colors.grey[600], size: 24),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? color : Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 4),
                      Icon(Icons.check_circle, color: color, size: 12),
                    ]
                  ],
                ),
              ),
            );
          },
        ),

        if (_selectedTypes.contains('Services')) ...[
          const SizedBox(height: 24),
          const Text('Service Sectors (Multiple Select)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: serviceSectorList.length,
            itemBuilder: (context, i) {
              final type = serviceSectorList[i];
              bool isSelected = _selectedServiceSectors.contains(type);
              return InkWell(
                onTap: () => setState(() => isSelected ? _selectedServiceSectors.remove(type) : _selectedServiceSectors.add(type)),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : (isDark ? Colors.white10 : Colors.grey[200]!), width: isSelected ? 1.5 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(serviceIcons[type], color: isSelected ? color : Colors.grey[600], size: 24),
                      const SizedBox(height: 4),
                      Text(
                        type,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? color : Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Icon(Icons.check_circle, color: color, size: 12),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ],

        const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Year of Establishment', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _yearCtrl.text.isEmpty ? null : _yearCtrl.text,
                    hint: const Text('YYYY', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    items: List.generate(2026 - 1950 + 1, (index) => (2026 - index).toString())
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _yearCtrl.text = v!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white10 : const Color(0xFF3B82F6))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white10 : const Color(0xFF3B82F6))),
                    ),
                  ),
                ]
              )
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Number of Employees', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _employeeRange,
                    hint: const Text('Select range', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    items: ['1-10', '11-50', '51-200', '201-500', '500+'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _employeeRange = v),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                    ),
                  ),
                ]
              )
            ),
          ],
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$selectedCount Selected",
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

  // STEP 7: Business Categories
  Widget _buildStep7(Color color, bool isDark) {
    final sectorTitles = _categoriesData.keys.toList();
    final sectors = _selectedSectorTitle != null ? _categoriesData[_selectedSectorTitle]!.keys.toList() : <String>[];
    final subSectors = (_selectedSectorTitle != null && _selectedSector != null)
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]!.keys.toList()
        : <String>[];

    final primaryCategories = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null)
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]!.keys.toList()
        : <String>[];

    final subCategoriesList = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null && _activePrimaryCategory != null)
        ? (_categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]![_activePrimaryCategory] ?? <String>[])
        : <String>[];

    String? selectedSub = _selectedSubCategories.isNotEmpty ? _selectedSubCategories.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.business_center, color: color, size: 24),
            const SizedBox(width: 8),
            const Text('Business Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Select the sector and categories that best describe your business activity.', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 24),
        if (_isLoadingCategories)
          const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
        else ...[
          _buildResponsiveRow(
            _buildCategoryDropdownCard(
              index: 1,
              color: Colors.deepPurpleAccent,
              title: 'Sector Title *',
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
                  _activePrimaryCategory = null;
                  _selectedSubCategories.clear();
                });
              },
            ),
            _buildCategoryDropdownCard(
              index: 4,
              color: Colors.green,
              title: 'Primary Categories',
              selectedCount: _activePrimaryCategory != null ? 1 : 0,
              prefixIcon: Icons.local_offer,
              hint: 'Select Primary Categories...',
              isDark: isDark,
              items: primaryCategories,
              value: _activePrimaryCategory,
              enabled: primaryCategories.isNotEmpty,
              onChanged: (val) {
                setState(() {
                  _activePrimaryCategory = val;
                  _selectedSubCategories.clear();
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildCategoryDropdownCard(
              index: 2,
              color: Colors.blue,
              title: 'Sector *',
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
                  _activePrimaryCategory = null;
                  _selectedSubCategories.clear();
                });
              },
            ),
            _buildCategoryDropdownCard(
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
          const SizedBox(height: 16),
          _buildResponsiveRow(
            _buildCategoryDropdownCard(
              index: 3,
              color: Colors.teal,
              title: 'Sub Sector *',
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
                  _activePrimaryCategory = null;
                  _selectedSubCategories.clear();
                });
              },
            ),
            _buildCategoryDropdownCard(
              index: 6,
              color: Colors.pinkAccent,
              title: 'Brand',
              selectedCount: 0,
              prefixIcon: Icons.workspace_premium,
              hint: 'Select Brands...',
              isDark: isDark,
              items: new List<String>.empty(growable: true),
              value: null,
              enabled: false,
              onChanged: (val) {},
            ),
          ),
        ],
      ],
    );
  }
  // HELPERS
  Widget _buildInputField(String label, TextEditingController ctrl, bool isDark, {TextInputType keyboardType = TextInputType.text, bool readOnly = false, List<TextInputFormatter>? inputFormatters, String? hintText, bool showPadding = true}) {
    final isPan = label.toLowerCase().contains('pan') || ctrl == _panCtrl;
    final isPhone = label.toLowerCase().contains('phone') || label.toLowerCase().contains('mobile') || ctrl == _phoneCtrl;
    Widget content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl, keyboardType: isPhone ? TextInputType.number : keyboardType, readOnly: readOnly,
        textCapitalization: isPan ? TextCapitalization.characters : TextCapitalization.none,
        inputFormatters: isPan
            ? [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(10)]
            : isPhone
                ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]
                : inputFormatters,
        validator: (v) {
          if ((v == null || v.isEmpty) && label.contains('*')) return 'Required';
          if (v != null && v.isNotEmpty && label.toLowerCase().contains('email')) {
            final emailRegex = RegExp(r'^[\w.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$');
            if (!emailRegex.hasMatch(v.trim())) return 'Enter a valid email address';
          }
          return null;
        },
        decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 13), filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!))),
      ),
    ]);
    return showPadding ? Padding(padding: const EdgeInsets.only(bottom: 20), child: content) : content;
  }

  Widget _buildFileUpload(String label, String? name, Uint8List? bytes, VoidCallback onTap, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 8),
      InkWell(onTap: onTap, child: Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)), child: bytes != null ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Flexible(child: Text(name!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))])) : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 24), Text('Upload', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))])))),
    ]);
  }

  Widget _buildRadio(bool isSelected, String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(onTap: onTap, child: Row(children: [Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.grey, width: isSelected ? 6 : 2))), const SizedBox(width: 10), Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13))]));
  }

  Widget _buildSuccessPage(Color color, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Partner Business Created\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your partner business has been registered\nand is ready to use.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _isSuccess = false;
                        _currentStep = 0;
                        _resetControllers();
                      }),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        'Add\nAnother\nPartner\nBusiness',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFFE11D48)),
                      label: const Text(
                        'Back to\nDashboard',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  void _resetControllers() {
    _nameCtrl.clear(); _emailCtrl.clear(); _phoneCtrl.clear(); _websiteCtrl.clear(); _panCtrl.clear(); _gstCtrl.clear(); _accNumberCtrl.clear(); _confirmAccNumberCtrl.clear(); _doorCtrl.clear(); _streetCtrl.clear(); _buildingCtrl.clear(); _landmarkCtrl.clear(); _areaCtrl.clear(); _districtCtrl.clear(); _pincodeCtrl.clear(); _stateCtrl.clear(); _yearCtrl.clear(); _panBytes = null; _sigBytes = null; _gstBytes = null; _bankDocBytes = null; _selectedTypes.clear(); _employeeRange = null;
    _selectedSectorTitle = null; _selectedSector = null; _selectedSubSector = null; _activePrimaryCategory = null; _selectedSubCategories.clear();
    _partners.clear(); _partners.add(_PartnerFormController());
  }
}

class _PartnerFormController {
  final nameCtrl = TextEditingController();
  final panCtrl = TextEditingController();
  String accessLevel = 'View Only';
  String? dealFileName; Uint8List? dealBytes;
  String? letterFileName; Uint8List? letterBytes;
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

class _DropdownSearchDialogState extends State<_DropdownSearchDialog> {  final TextEditingController _searchController = TextEditingController();
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
          children: [
            Text(widget.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _filter,
              style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: widget.isDark ? Colors.white30 : Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: widget.isDark ? Colors.white70 : Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item == widget.initialValue;
                  return ListTile(
                    title: Text(
                      item,
                      style: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
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


