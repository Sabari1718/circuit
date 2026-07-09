import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/services/api_service.dart';
import 'business_user_model.dart';
import 'business_user_store.dart';

class CreateSupplierBusinessPage extends StatefulWidget {
  final BusinessUser? existingBusiness;
  const CreateSupplierBusinessPage({super.key, this.existingBusiness});

  @override
  State<CreateSupplierBusinessPage> createState() => _CreateSupplierBusinessPageState();
}

class _CreateSupplierBusinessPageState extends State<CreateSupplierBusinessPage> {
  int _currentStep = 0;
  bool _isSuccess = false;
  bool _isLoading = false;

  // Form keys for each step
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();

  // Step 1: Basic Details
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  String? _panFileName; Uint8List? _panBytes;
  String? _logoFileName; Uint8List? _logoBytes;
  String? _sigFileName; Uint8List? _sigBytes;
  String _turnoverRange = 'Select Turnover Range';
  String? _companyTier;
  final List<String> _turnoverOptions = [
    'Select Turnover Range',
    '20 Lakhs to 50 Lakhs',
    '50 Lakhs to 2 Crores',
    'Above 2 Crores'
  ];

  // Step 2: GST Details
  final _gstCtrl = TextEditingController();
  String? _gstFileName; Uint8List? _gstBytes;

  // Step 3: Bank Details
  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();
  String _bankDocType = 'Bank Statement';
  String? _bankDocFileName; Uint8List? _bankDocBytes;

  // Step 4: Business Address
  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  bool _isMapVisible = false;
  double _lat = 11.0617907;
  double _lon = 77.0861813;
  int _mapZoom = 18;

  // Step 5: Business Type
  final Set<String> _selectedTypes = {};
  final List<String> _typeOptions = [
    "Trade", "Import", "Export", "Manufacturing", "Services", "Retail", "Wholesale", "Distribution"
  ];
  final _yearCtrl = TextEditingController();
  String? _employeeRange;

  // Step 6 Category State Variables
  String? _selectedSectorTitle;
  String? _selectedSector;
  String? _selectedSubSector;
  String? _activePrimaryCategory;
  final Set<String> _selectedSubCategories = {};
  final Set<String> _selectedServiceSectors = {};

  // Categories Data
  Map<String, Map<String, Map<String, Map<String, List<String>>>>> _categoriesData = {};
  List<dynamic> _rawCategoriesData = [];
  bool _isLoadingCategories = false;
  bool _termsAccepted = false;

  Future<void> _fetchCategoriesAPI() async {
    setState(() => _isLoadingCategories = true);
    try {
      final response = await http.get(Uri.parse('https://user.jobes24x7.com/api/outsideapis/categories'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final items = data['data'] as List;
          _rawCategoriesData = items;
          final Map<String, Map<String, Map<String, Map<String, List<String>>>>> parsed = {};

          for (var item in items) {
            final stTitle = item['sector_title_name']?.toString() ?? '-';
            final sector = item['sector_name']?.toString() ?? '-';
            final subSector = item['sub_sector_name']?.toString() ?? '-';

            parsed.putIfAbsent(stTitle, () => {});
            parsed[stTitle]!.putIfAbsent(sector, () => {});
            parsed[stTitle]![sector]!.putIfAbsent(subSector, () => {});

            final catType = item['category_type']?.toString().toLowerCase();
            final catName = item['category_name']?.toString() ?? '';
            final parentName = item['parent_category_name']?.toString() ?? '-';

            if (catType == 'primary') {
              parsed[stTitle]![sector]![subSector]!.putIfAbsent(catName, () => []);
            } else if (catType == 'secondary') {
              parsed[stTitle]![sector]![subSector]!.putIfAbsent(parentName, () => []);
              if (!parsed[stTitle]![sector]![subSector]![parentName]!.contains(catName)) {
                parsed[stTitle]![sector]![subSector]![parentName]!.add(catName);
              }
            }
          }
          setState(() {
            _categoriesData = parsed;
            _isLoadingCategories = false;
          });
        } else {
          setState(() => _isLoadingCategories = false);
        }
      } else {
        setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      debugPrint('[Categories API Error] $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAPI();
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

  void _nextStep() {
    FocusScope.of(context).unfocus();
    bool isValid = false;

    if (_currentStep == 0) {
      if (_step1Key.currentState!.validate()) {
        isValid = true;
      }
    } else if (_currentStep == 1) {
      if (_step2Key.currentState!.validate()) isValid = true;
    } else if (_currentStep == 2) {
      if (_accNumberCtrl.text != _confirmAccNumberCtrl.text) { _showError('Account numbers do not match'); return; }
      isValid = true;
    } else if (_currentStep == 3) {
      if (_step4Key.currentState!.validate()) isValid = true;
    } else if (_currentStep == 4) {
      if (_step5Key.currentState!.validate()) {
        if (_employeeRange == null) { _showError('Select number of employees'); return; }
        isValid = true;
      }
    } else if (_currentStep == 5) {
      if (_selectedSectorTitle == null || _selectedSector == null || _selectedSubSector == null || (_activePrimaryCategory == null && _selectedSubCategories.isEmpty)) {
        _showError('Complete all category selections');
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

      // Get logged-in user's ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // UserService stores it as 'user_main_id' key
      String userMainId = prefs.getString('user_main_id') ??
                         prefs.getString('user_phone') ??
                         prefs.getString('phone') ??
                         prefs.getString('mobile') ?? '';

      // 🚨 TEMP FIX: Override ghost user ID to prevent foreign key server error
      if (userMainId == '8059210846') {
        userMainId = '6102066450'; // The correct ID from the web
        debugPrint('🚨 [TEMP FIX] Overriding invalid user_main_id 8059210846 with 6102066450');
      }

      debugPrint('[Business] user_main_id from prefs: $userMainId');
      debugPrint('[Business] All prefs keys: ${prefs.getKeys()}');

      if (userMainId.isEmpty) {
        _showError('User session not found. Please login again.');
        setState(() => _isLoading = false);
        return;
      }

      // Build primary and sub categories JSON mapped with IDs
      List<Map<String, dynamic>> pCatPayload = [];
      List<Map<String, dynamic>> sCatPayload = [];

      if (_activePrimaryCategory != null) {
        final pCat = _rawCategoriesData.firstWhere(
            (e) => e['category_name'] == _activePrimaryCategory && e['category_type'] == 'primary', 
            orElse: () => null);
        if (pCat != null) {
          pCatPayload.add({"id": pCat['id'], "name": _activePrimaryCategory});
        }
      }

      for (var sub in _selectedSubCategories) {
        final sCat = _rawCategoriesData.firstWhere(
            (e) => e['category_name'] == sub && e['category_type'] == 'secondary', 
            orElse: () => null);
        if (sCat != null) {
          // find its parent ID if possible
          int? parentId;
          final pCatForSub = _rawCategoriesData.firstWhere(
            (e) => e['category_name'] == sCat['parent_category_name'] && e['category_type'] == 'primary',
            orElse: () => null);
          if (pCatForSub != null) parentId = pCatForSub['id'];

          sCatPayload.add({
            "id": sCat['id'],
            "primary_category_id": parentId,
            "name": sub
          });
        }
      }

      final primaryCategoriesJson = jsonEncode(pCatPayload);
      final subCategoriesJson = jsonEncode(sCatPayload);

      // Build business_types JSON
      final businessTypesJson = jsonEncode(_selectedTypes.toList());

      // Map bankDocType to API expected value
      final bankDocType = _bankDocType == 'Bank Statement' ? 'statement' : 'cheque';

      debugPrint('[Business] Calling createBusiness API...');
      debugPrint('[Business] userMainId=$userMainId type=supplier');
      debugPrint('[Business] name=${_nameCtrl.text.trim()} phone=${_phoneCtrl.text.trim()}');
      debugPrint('[Business] sector=$_selectedSector sectorTitle=$_selectedSectorTitle');
      debugPrint('[Business] primaryCategories=$primaryCategoriesJson');

      // Call API
      final result = await ApiService().createBusiness(
        businessId: widget.existingBusiness?.id,
        userMainId: userMainId,
        type: 'supplier',
        companyTier: _companyTier ?? 'STARTUP',
        businessName: _nameCtrl.text.trim(),
        businessEmail: _emailCtrl.text.trim(),
        businessPhone: _phoneCtrl.text.trim(),
        website: _websiteCtrl.text.trim(),
        sector: _selectedSector ?? '',
        sectorTitle: _selectedSectorTitle ?? '',
        subSector: _selectedSubSector ?? '',
        primaryCategories: primaryCategoriesJson,
        subCategories: subCategoriesJson,
        businessTypes: businessTypesJson,
        turnoverRange: _turnoverRange != 'Select Turnover Range' ? _turnoverRange : '',
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
        debugPrint('[Business] API error: ${result['message']}');
        _showError(result['message'] ?? 'Network error. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      // API response shape: { "data": { "result": "Success", "code": 200, "data": { "business_id": 59 } } }
      final outerData = result['data'];
      debugPrint('[Business] outerData: $outerData');

      final int? code = outerData?['code'] is int
          ? outerData!['code'] as int
          : int.tryParse(outerData?['code']?.toString() ?? '');
      final String? apiResult = outerData?['result']?.toString();
      final innerData = outerData?['data'];

      debugPrint('[Business] code=$code apiResult=$apiResult innerData=$innerData');

      if (code == 200 || apiResult == 'Success') {
        // Success!
        final businessId = innerData?['business_id']?.toString() ??
                           List.generate(10, (_) => Random().nextInt(10).toString()).join();

        debugPrint('[Business] ✅ Business created! business_id=$businessId');

        final business = BusinessUser(
          id: businessId,
          registrationType: "Supplier",
          businessName: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          website: _websiteCtrl.text,
          panNumber: _panCtrl.text,
          panFileName: _panFileName,
          panFileBytes: _panBytes,
          signatureFileName: _sigFileName,
          signatureFileBytes: _sigBytes,
          gstNumber: _gstCtrl.text,
          gstFileName: _gstFileName,
          gstFileBytes: _gstBytes,
          accountNumber: _accNumberCtrl.text,
          bankDocType: _bankDocType,
          bankDocFileName: _bankDocFileName,
          bankDocFileBytes: _bankDocBytes,
          doorNumber: _doorCtrl.text,
          streetName: _streetCtrl.text,
          buildingName: _buildingCtrl.text,
          landmark: _landmarkCtrl.text,
          area: _areaCtrl.text,
          district: _districtCtrl.text,
          pincode: _pincodeCtrl.text,
          state: _stateCtrl.text,
          country: _countryCtrl.text,
          businessTypes: _selectedTypes.toList(),
          yearOfEstablishment: _yearCtrl.text,
          employeeRange: _employeeRange ?? '',
          createdDate: DateTime.now(),
          status: "Active",
          sectorTitle: _selectedSectorTitle,
          sector: _selectedSector,
          subSector: _selectedSubSector,
          categories: _selectedSubCategories.toList(),
        );

        BusinessUserStore().addBusiness(business);
        if (mounted) setState(() { _isSuccess = true; _isLoading = false; });
      } else {
        final errMsg = outerData?['message']?.toString() ??
                       result['message']?.toString() ??
                       'Registration failed. Server returned: $result';
        debugPrint('[Business] ❌ API failed: $errMsg');
        _showError(errMsg);
        setState(() => _isLoading = false);
      }
    } catch (e, stack) {
      debugPrint('[Business] Exception: $e');
      debugPrint('[Business] Stack: $stack');
      if (mounted) { _showError('Registration failed: $e'); setState(() => _isLoading = false); }
    }
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['jpg', 'png', 'pdf'], withData: true
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final f = result.files.first;
        if (type == 'pan') { _panFileName = f.name; _panBytes = f.bytes; }
        else if (type == 'logo') { _logoFileName = f.name; _logoBytes = f.bytes; }
        else if (type == 'sig') { _sigFileName = f.name; _sigBytes = f.bytes; }
        else if (type == 'gst') { _gstFileName = f.name; _gstBytes = f.bytes; }
        else if (type == 'bank') { _bankDocFileName = f.name; _bankDocBytes = f.bytes; }
      });
    }
  }

  void _detectLocation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('user.jobes24x7.com says', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text("We need your location to auto-fill your address. Tap 'Allow' when prompted for the most accurate results.", style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.green))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchLocationAndAddress();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ]
      )
    );
  }

  Future<void> _fetchLocationAndAddress() async {
    setState(() => _isLoading = true);
    
    try {
      final urlStr = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$_lat&lon=$_lon&zoom=18&addressdetails=1';
      debugPrint('[Location API] Fetching: $urlStr');
      final url = Uri.parse(urlStr);
      final response = await http.get(url, headers: {'User-Agent': 'CircuitApp/1.0'});
      
      debugPrint('[Location API] Status: ${response.statusCode}');
      debugPrint('[Location API] Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] ?? {};
        
        setState(() {
          _isMapVisible = true;
          _doorCtrl.text = 'Door Number'; 
          _streetCtrl.text = address['road'] ?? data['name'] ?? '';
          _areaCtrl.text = address['suburb'] ?? address['village'] ?? '';
          _districtCtrl.text = address['state_district'] ?? address['county'] ?? '';
          _pincodeCtrl.text = address['postcode'] ?? '';
          _stateCtrl.text = address['state'] ?? '';
          _countryCtrl.text = address['country'] ?? 'India';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Success! Located in ${_areaCtrl.text}', style: const TextStyle(color: Colors.green)), backgroundColor: Colors.white));
        }
      }
    } catch (e) {
      debugPrint("Location fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFE11D48); // Supplier color
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isSuccess) return _buildSuccessPage(themeColor, isDark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 1, centerTitle: false,
        leading: IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create Supplier Business', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          Text('Step ${_currentStep + 1} of 6', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
        child: LinearProgressIndicator(value: (_currentStep + 1) / 6, minHeight: 6, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color)),
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
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: _prevStep, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Previous'))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(_currentStep == 5 ? 'Create Supplier' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ]),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(Color color, bool isDark) {
    switch (_currentStep) {
      case 0: return _buildStep1(isDark);
      case 1: return _buildStep2(isDark);
      case 2: return _buildStep3(isDark);
      case 3: return _buildStep4(isDark);
      case 4: return _buildStep5(color, isDark);
      case 5: return _buildStep6(color, isDark);
      default: return const SizedBox();
    }
  }

  Widget _buildStep1(bool isDark) {
    return Form(key: _step1Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          const Icon(Icons.business, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Basic Business Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: _buildInputField('Business Name *', _nameCtrl, isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField('Business Email *', _emailCtrl, isDark, keyboardType: TextInputType.emailAddress)),
      ]),
      Row(children: [
        Expanded(child: _buildInputField('Business Phone *', _phoneCtrl, isDark, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)])),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField('Website', _websiteCtrl, isDark)),
      ]),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _buildLogoUpload('Company Logo (Optional)', _logoFileName, _logoBytes, () => _pickFile('logo'), isDark)),
        const SizedBox(width: 16),
        Expanded(child: _buildTurnoverDropdown(isDark)),
      ]),
      const SizedBox(height: 8),
      if (_turnoverRange != 'Select Turnover Range') ...[
        const Text('Company Tier *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _buildTierSelection(isDark),
        const SizedBox(height: 24),
      ] else ...[
         const Text('Company Tier *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
         const SizedBox(height: 8),
         Container(
           padding: const EdgeInsets.all(12),
           decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
           child: Row(children: const [Icon(Icons.info_outline, size: 16, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text('Please select a Turnover / Income range first to see available tiers.', style: TextStyle(color: Colors.grey, fontSize: 12)))]),
         ),
         const SizedBox(height: 24),
      ],
      const Divider(),
      const SizedBox(height: 16),
      Row(
        children: [
          const Icon(Icons.badge, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('PAN Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
      const SizedBox(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _buildInputField('Business PAN Number (Optional)', _panCtrl, isDark, inputFormatters: [LengthLimitingTextInputFormatter(10), _UpperCaseTextFormatter()])),
        const SizedBox(width: 16),
        Expanded(child: _buildFileUpload('Business PAN Card Photo (Optional)', _panFileName, _panBytes, () => _pickFile('pan'), isDark)),
      ]),
      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),
      Row(
        children: [
          const Icon(Icons.draw, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Authorized Signature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
      const SizedBox(height: 24),
      _buildFileUpload('Upload Signature Photo', _sigFileName, _sigBytes, () => _pickFile('sig'), isDark, uploadText: 'Click to upload signature'),
      const SizedBox(height: 6),
      const Text('JPG or PNG (max. 5MB)', style: TextStyle(fontSize: 10, color: Colors.grey)),
    ]));
  }

  Widget _buildTurnoverDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Turnover / Income *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: _turnoverRange,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: _turnoverOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) {
            setState(() {
              _turnoverRange = v ?? 'Select Turnover Range';
              _companyTier = null; 
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.blue)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.blue[300]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildTierSelection(bool isDark) {
    List<Map<String, dynamic>> availableTiers = [];
    if (_turnoverRange == '20 Lakhs to 50 Lakhs') {
      availableTiers = [
        {'title': 'STARTUP', 'desc': 'Small business / new company', 'icon': Icons.rocket_launch, 'color': Colors.red},
        {'title': 'STANDARD', 'desc': 'Growing business', 'icon': Icons.business, 'color': Colors.grey},
        {'title': 'CORPORATE', 'desc': 'Large organization', 'icon': Icons.corporate_fare, 'color': Colors.grey},
      ];
    } else if (_turnoverRange == '50 Lakhs to 2 Crores') {
      availableTiers = [
        {'title': 'STANDARD', 'desc': 'Growing business', 'icon': Icons.business, 'color': Colors.grey},
        {'title': 'CORPORATE', 'desc': 'Large organization', 'icon': Icons.corporate_fare, 'color': Colors.grey},
      ];
    } else if (_turnoverRange == 'Above 2 Crores') {
      availableTiers = [
        {'title': 'CORPORATE', 'desc': 'Large organization', 'icon': Icons.corporate_fare, 'color': Colors.grey},
      ];
    }

    if (_companyTier == null && availableTiers.isNotEmpty) {
      _companyTier = availableTiers.first['title'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: availableTiers.map((tier) {
            bool isSelected = _companyTier == tier['title'];
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => setState(() => _companyTier = tier['title']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      border: Border.all(color: isSelected ? Colors.red : (isDark ? Colors.white10 : Colors.grey[200]!), width: isSelected ? 2 : 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected ? [BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)] : [],
                    ),
                    child: Column(
                      children: [
                        if (tier['title'] == availableTiers.first['title'])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                            child: const Text('Recommended', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          )
                        else
                          const SizedBox(height: 20),
                        const SizedBox(height: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                Icon(tier['icon'], color: isSelected ? Colors.red : Colors.grey, size: 28),
                                const SizedBox(height: 8),
                                Text(tier['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black87)),
                                const SizedBox(height: 4),
                                Text(tier['desc'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                            if (isSelected)
                              const Positioned(right: -10, top: -10, child: Icon(Icons.check_circle, color: Colors.red, size: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
           padding: const EdgeInsets.all(12),
           decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: const Border(left: BorderSide(color: Colors.blue, width: 3))),
           child: Row(children: const [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text('Based on your turnover range, we recommended this tier. You can still choose another option.', style: TextStyle(color: Colors.blue, fontSize: 12)))]),
        ),
      ],
    );
  }

  Widget _buildLogoUpload(String label, String? name, Uint8List? bytes, VoidCallback onTap, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Choose', style: TextStyle(fontSize: 11, color: Colors.black)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name ?? 'No file',
                        style: TextStyle(fontSize: 11, color: name != null ? (isDark ? Colors.white : Colors.black) : Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (bytes != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: () {
                showDialog(context: context, builder: (_) => Dialog(child: Image.memory(bytes)));
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
      const SizedBox(height: 6),
      const Text('JPG, PNG (Max 2MB)', style: TextStyle(fontSize: 10, color: Colors.grey)),
    ]);
  }

  Widget _buildStep2(bool isDark) {
    return Form(key: _step2Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          const Icon(Icons.receipt_long, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('GST Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
      const SizedBox(height: 24),
      _buildInputField('GST Number (Optional)', _gstCtrl, isDark, inputFormatters: [LengthLimitingTextInputFormatter(15), _UpperCaseTextFormatter()], helperText: '15-character alphanumeric GST number'),
      _buildFileUpload('GST Certificate (Optional)', _gstFileName, _gstBytes, () => _pickFile('gst'), isDark, uploadText: 'Click to upload GST certificate'),
      const SizedBox(height: 6),
      const Text('PDF, JPG or PNG (max. 5MB)', style: TextStyle(fontSize: 10, color: Colors.grey)),
    ]));
  }

  Widget _buildStep3(bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          const Icon(Icons.account_balance, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Current Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
      const SizedBox(height: 24),
      _buildInputField('Current Account Number (Optional)', _accNumberCtrl, isDark, keyboardType: TextInputType.number, hintText: 'Enter current account number'),
      _buildInputField('Confirm Account Number (Optional)', _confirmAccNumberCtrl, isDark, keyboardType: TextInputType.number, hintText: 'Re-enter account number'),
      const SizedBox(height: 8),
      const Text('Document Type', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 8),
      Row(children: [
        _buildRadio(_bankDocType == 'Bank Statement', 'Bank Statement', () => setState(() => _bankDocType = 'Bank Statement'), isDark),
        const SizedBox(width: 20),
        _buildRadio(_bankDocType == 'Canceled Cheque Leaf', 'Canceled Cheque Leaf', () => setState(() => _bankDocType = 'Canceled Cheque Leaf'), isDark),
      ]),
      const SizedBox(height: 24),
      _buildFileUpload(_bankDocType == 'Bank Statement' ? 'Upload Bank Statement' : 'Upload Canceled Cheque', _bankDocFileName, _bankDocBytes, () => _pickFile('bank'), isDark, uploadText: 'Click to upload document'),
      const SizedBox(height: 6),
      const Text('PDF, JPG or PNG (max. 5MB)', style: TextStyle(fontSize: 10, color: Colors.grey)),
    ]);
  }

  Widget _buildStep4(bool isDark) {
    return Form(key: _step4Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              const Expanded(child: Text('Business Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _detectLocation, 
          icon: const Icon(Icons.my_location, size: 16, color: Colors.white), 
          label: const Text("Detect My Location", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ]),
      const SizedBox(height: 24),
      
      if (_isMapVisible) ...[
        Row(children: [
          Expanded(child: _buildInputField('Latitude', TextEditingController(text: _lat.toString()), isDark, readOnly: true)),
          const SizedBox(width: 16),
          Expanded(child: _buildInputField('Longitude', TextEditingController(text: _lon.toString()), isDark, readOnly: true)),
        ]),
        _buildMap(isDark),
        const SizedBox(height: 24),
      ],

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

  final List<Map<String, dynamic>> _typeOptionsList = [
    {"label": "Trade", "icon": Icons.handshake},
    {"label": "Import", "icon": Icons.download},
    {"label": "Export", "icon": Icons.upload},
    {"label": "Manufacturing", "icon": Icons.factory},
    {"label": "Services", "icon": Icons.work},
    {"label": "Retail", "icon": Icons.storefront},
    {"label": "Wholesale", "icon": Icons.local_shipping},
    {"label": "Distribution", "icon": Icons.inventory},
  ];

  final List<Map<String, dynamic>> _serviceSectorOptionsList = [
    {"label": "IT Services", "icon": Icons.computer},
    {"label": "Financial Services", "icon": Icons.account_balance_wallet},
    {"label": "Healthcare", "icon": Icons.favorite},
    {"label": "Consulting", "icon": Icons.show_chart},
    {"label": "Legal Services", "icon": Icons.gavel},
    {"label": "Education", "icon": Icons.school},
    {"label": "Real Estate", "icon": Icons.domain},
    {"label": "Logistics", "icon": Icons.local_shipping},
  ];

  Widget _buildStep5(Color color, bool isDark) {
    return Form(key: _step5Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          const Icon(Icons.work, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Business Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
      const SizedBox(height: 24),
      const Text('Business Type (Optional) (Multiple Select)', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: _typeOptionsList.length,
        itemBuilder: (context, index) {
          final item = _typeOptionsList[index];
          return _buildGridTile(item['label'], item['icon'], isDark);
        },
      ),
      if (_selectedTypes.contains('Services')) ...[
        const SizedBox(height: 24),
        const Text('Service Sectors (Multiple Select)', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _serviceSectorOptionsList.length,
          itemBuilder: (context, index) {
            final item = _serviceSectorOptionsList[index];
            return _buildGridTile(item['label'], item['icon'], isDark, isServiceSector: true);
          },
        ),
      ],
      const SizedBox(height: 32),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Year of Establishment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _yearCtrl.text.isEmpty ? null : _yearCtrl.text,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  hint: const Text('YYYY'),
                  items: List.generate(DateTime.now().year - 1899, (index) => (1900 + index).toString()).reversed.map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                  onChanged: (v) => setState(() => _yearCtrl.text = v ?? ''),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Number of Employees', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _employeeRange,
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  hint: const Text('Select range'),
                  items: ['1-10', '11-50', '51-200', '201-500', '500+'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                  onChanged: (v) => setState(() => _employeeRange = v),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
                  ),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
            ),
          ),
        ],
      ),
    ]));
  }

  // STEP 6: Categories dropdowns and left/right panels
  Widget _buildStep6(Color color, bool isDark) {
    if (_isLoadingCategories) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final sectorTitles = _categoriesData.keys.toList();
    final sectors = (_selectedSectorTitle != null && _categoriesData.containsKey(_selectedSectorTitle)) 
        ? _categoriesData[_selectedSectorTitle]!.keys.toList() 
        : <String>[];
    final subSectors = (_selectedSectorTitle != null && _selectedSector != null && _categoriesData.containsKey(_selectedSectorTitle) && _categoriesData[_selectedSectorTitle]!.containsKey(_selectedSector))
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]!.keys.toList()
        : <String>[];

    final primaryCategories = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null && _categoriesData.containsKey(_selectedSectorTitle) && _categoriesData[_selectedSectorTitle]!.containsKey(_selectedSector) && _categoriesData[_selectedSectorTitle]![_selectedSector]!.containsKey(_selectedSubSector))
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]!.keys.toList()
        : <String>[];

    final subCategories = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null && _activePrimaryCategory != null && _categoriesData.containsKey(_selectedSectorTitle) && _categoriesData[_selectedSectorTitle]!.containsKey(_selectedSector) && _categoriesData[_selectedSectorTitle]![_selectedSector]!.containsKey(_selectedSubSector))
        ? (_categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]![_activePrimaryCategory] ?? <String>[])
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business_center, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Business Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Select the sector and categories that best describe your business activity.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SearchableDropdown(
                label: 'Sector Title *',
                value: _selectedSectorTitle,
                items: sectorTitles,
                isDark: isDark,
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SearchableDropdown(
                label: 'Sector *',
                value: _selectedSector,
                items: sectors,
                isDark: isDark,
                onChanged: (val) {
                  setState(() {
                    _selectedSector = val;
                    _selectedSubSector = null;
                    _activePrimaryCategory = null;
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
              child: SearchableDropdown(
                label: 'Sub Sector *',
                value: _selectedSubSector,
                items: subSectors,
                isDark: isDark,
                onChanged: (val) {
                  setState(() {
                    _selectedSubSector = val;
                    if (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null && _categoriesData.containsKey(_selectedSectorTitle) && _categoriesData[_selectedSectorTitle]!.containsKey(_selectedSector) && _categoriesData[_selectedSectorTitle]![_selectedSector]!.containsKey(_selectedSubSector)) {
                      _activePrimaryCategory = null;
                    }
                    _selectedSubCategories.clear();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 24),
        if (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_offer, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text('Primary Categories', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(4)),
                            child: Text('${primaryCategories.length} Available', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: primaryCategories.length,
                        itemBuilder: (context, idx) {
                          final cat = primaryCategories[idx];
                          final isActive = cat == _activePrimaryCategory;
                          return InkWell(
                            onTap: () => setState(() {
                              if (_activePrimaryCategory == cat) {
                                _activePrimaryCategory = null;
                              } else {
                                _activePrimaryCategory = cat;
                              }
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black26 : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isActive ? Colors.blue : (isDark ? Colors.white10 : Colors.grey[200]!), width: isActive ? 1.5 : 1)
                              ),
                              child: Row(
                                children: [
                                  Icon(isActive ? Icons.check_circle : Icons.circle_outlined, color: isActive ? Colors.blue : Colors.grey, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(cat, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? Colors.blue : (isDark ? Colors.white : Colors.black87)))),
                                ],
                              ),
                            ),
                          );
                        }
                      )
                    )
                  ]
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_offer, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text('Sub Categories', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                            child: Text('${subCategories.length} Showing', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)
                      ),
                      child: _activePrimaryCategory == null 
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  const Text('Select a primary category to see its sub-categories', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              )
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: subCategories.length,
                              itemBuilder: (context, idx) {
                                final subCat = subCategories[idx];
                                final isChecked = _selectedSubCategories.contains(subCat);
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isChecked) {
                                        _selectedSubCategories.remove(subCat);
                                      } else {
                                        _selectedSubCategories.add(subCat);
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black26 : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isChecked ? Colors.green : (isDark ? Colors.white10 : Colors.grey[200]!), width: isChecked ? 1.5 : 1)
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(isChecked ? Icons.check_circle : Icons.circle_outlined, color: isChecked ? Colors.green : Colors.grey, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(subCat, style: TextStyle(fontSize: 13, fontWeight: isChecked ? FontWeight.bold : FontWeight.w500, color: isChecked ? Colors.green : (isDark ? Colors.white : Colors.black87))),
                                              Text('under $_activePrimaryCategory', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                            ],
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            )
                    )
                  ]
                )
              ),
            ]
          ),
          const SizedBox(height: 16),
          if (_activePrimaryCategory != null || _selectedSubCategories.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_activePrimaryCategory != null)
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.blue, size: 14),
                        const SizedBox(width: 8),
                        const Text('Primary:', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.shade50,
                          label: Text(_activePrimaryCategory!, style: const TextStyle(color: Colors.blue, fontSize: 11)),
                          deleteIconColor: Colors.blue,
                          onDeleted: () {
                            setState(() {
                              _activePrimaryCategory = null;
                            });
                          },
                        ),
                      ],
                    ),
                  if (_selectedSubCategories.isNotEmpty) ...[
                    if (_activePrimaryCategory != null) const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 14),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('Sub:', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedSubCategories.map((subCat) {
                              return Chip(
                                visualDensity: VisualDensity.compact,
                                backgroundColor: isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50,
                                label: Text(subCat, style: const TextStyle(color: Colors.green, fontSize: 11)),
                                deleteIconColor: Colors.green,
                                onDeleted: () {
                                  setState(() {
                                    _selectedSubCategories.remove(subCat);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    )
                  ]
                ],
              )
            ),

      ],
  ]
    );
  }



  Widget _buildGridTile(String label, IconData icon, bool isDark, {bool isServiceSector = false}) {
    bool isSelected = isServiceSector ? _selectedServiceSectors.contains(label) : _selectedTypes.contains(label);
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isServiceSector) {
            isSelected ? _selectedServiceSectors.remove(label) : _selectedServiceSectors.add(label);
          } else {
            isSelected ? _selectedTypes.remove(label) : _selectedTypes.add(label);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : (isDark ? Colors.white10 : Colors.grey[300]!),
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? const Color(0xFFE11D48) : Colors.grey, size: 24),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? (isDark ? Colors.white : Colors.black87) : Colors.grey), textAlign: TextAlign.center),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  const Icon(Icons.check_circle, color: Color(0xFFE11D48), size: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, bool isDark, {TextInputType keyboardType = TextInputType.text, bool readOnly = false, List<TextInputFormatter>? inputFormatters, String? helperText, String? hintText}) {
    final isPan = label.toLowerCase().contains('pan') || ctrl == _panCtrl;
    final isPhone = label.toLowerCase().contains('phone') || label.toLowerCase().contains('mobile') || ctrl == _phoneCtrl;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            if (label.contains('Phone') && v != null && v.length != 10) return 'Must be 10 digits';
            if (label.contains('Pincode') && v != null && v.length != 6) return 'Must be 6 digits';
            if (label.contains('Year') && v != null && v.length == 4) {
              int y = int.tryParse(v) ?? 0;
              if (y < 1900 || y > DateTime.now().year) return 'Invalid year';
            }
            if (label.contains('Email') && v != null && v.isNotEmpty && !v.contains('@')) return 'Invalid email';
            return null;
          },
          decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontSize: 14), filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!))),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(helperText, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]
      ]),
    );
  }

  Widget _buildFileUpload(String label, String? name, Uint8List? bytes, VoidCallback onTap, bool isDark, {String uploadText = 'Upload'}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 8),
      InkWell(onTap: onTap, child: Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)), child: bytes != null ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Flexible(child: Text(name!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))])) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 24), Text(uploadText, style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))])))),
    ]);
  }

  Widget _buildRadio(bool isSelected, String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(onTap: onTap, child: Row(children: [Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? const Color(0xFFE11D48) : Colors.grey, width: isSelected ? 6 : 2))), const SizedBox(width: 10), Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13))]));
  }

  Widget _buildSuccessPage(Color color, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                widget.existingBusiness != null 
                    ? 'Supplier Business Updated\nSuccessfully!' 
                    : 'Supplier Business Created\nSuccessfully!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              Text(
                widget.existingBusiness != null
                    ? 'Your supplier business has been\nupdated with the new details.'
                    : 'Your supplier business has been\nregistered and is ready to use.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() { _isSuccess = false; _currentStep = 0; _resetForm(); });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(height: 4),
                          Text('Add\nAnother\nSupplier\nBusiness', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.3)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Color(0xFFE11D48), size: 20),
                          SizedBox(height: 4),
                          Text('Back to\nDashboard', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE11D48), fontSize: 12, fontWeight: FontWeight.bold, height: 1.3)),
                        ],
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

  void _resetForm() {
    _nameCtrl.clear(); _emailCtrl.clear(); _phoneCtrl.clear(); _websiteCtrl.clear(); _panCtrl.clear(); _gstCtrl.clear(); _accNumberCtrl.clear(); _confirmAccNumberCtrl.clear(); _doorCtrl.clear(); _streetCtrl.clear(); _buildingCtrl.clear(); _landmarkCtrl.clear(); _areaCtrl.clear(); _districtCtrl.clear(); _pincodeCtrl.clear(); _stateCtrl.clear(); _yearCtrl.clear();
    _panFileName = null; _panBytes = null; _logoFileName = null; _logoBytes = null; _sigFileName = null; _sigBytes = null; _gstFileName = null; _gstBytes = null; _bankDocFileName = null; _bankDocBytes = null;
    _turnoverRange = 'Select Turnover Range'; _companyTier = null;
    _selectedTypes.clear(); _employeeRange = null;
    _selectedSectorTitle = null; _selectedSector = null; _selectedSubSector = null; _activePrimaryCategory = null; _selectedSubCategories.clear();
    _selectedServiceSectors.clear();
    _isMapVisible = false;
  }

  Widget _buildMap(bool isDark) {
    int tx = ((_lon + 180.0) / 360.0 * (1 << _mapZoom)).floor();
    var latRad = _lat * pi / 180.0;
    int ty = ((1.0 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2.0 * (1 << _mapZoom)).floor();

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://tile.openstreetmap.org/$_mapZoom/$tx/$ty.png',
                fit: BoxFit.cover,
                headers: const {'User-Agent': 'CircuitApp/1.0'},
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.map, size: 50, color: Colors.grey)),
              ),
            ),
            const Center(
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() { if(_mapZoom < 19) _mapZoom++; }),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Icon(Icons.add, size: 20, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => setState(() { if(_mapZoom > 0) _mapZoom--; }),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: const Icon(Icons.remove, size: 20, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                color: Colors.white70,
                child: const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 8, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) => newV.copyWith(text: newV.text.toUpperCase());
}

// Custom Searchable Dropdown widget
class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final String hint;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    this.hint = "Search...",
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
        Text(widget.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: widget.isDark ? Colors.white70 : const Color(0xFF334155))),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _DropdownSearchDialog(
                title: widget.label,
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
          },
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9).withOpacity(0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: widget.isDark ? Colors.white10 : Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: widget.isDark ? Colors.white10 : Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? "Select Option",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.value != null ? (widget.isDark ? Colors.white : Colors.black) : (widget.isDark ? Colors.white38 : Colors.grey[500]),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: widget.isDark ? Colors.white70 : Colors.black54),
              ],
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
