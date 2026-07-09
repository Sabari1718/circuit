import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:circuit/features/upgrade/business_user_model.dart';
import 'package:circuit/features/upgrade/business_user_store.dart';
import '../../core/services/api_service.dart';

class CreatePartnerBusinessPage extends StatefulWidget {
  const CreatePartnerBusinessPage({super.key});

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
  final _panCtrl = TextEditingController();
  String? _logoFileName; Uint8List? _logoBytes;
  String? _turnoverRange;
  String? _selectedTier;
  String? _panFileName; Uint8List? _panBytes;
  String? _sigFileName; Uint8List? _sigBytes;

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

  Map<String, Map<String, Map<String, Map<String, List<String>>>>> _categoriesData = {};
  bool _isCategoriesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isCategoriesLoading = true);
    try {
      final res = await ApiService().fetchCategories();
      if (res['success'] == true && res['data'] != null) {
        final List<dynamic> apiData = res['data'];
        Map<String, Map<String, Map<String, Map<String, List<String>>>>> newData = {};

        for (var item in apiData) {
          String title = item['sector_title_name']?.toString().trim() ?? '';
          if (title == '-' || title.isEmpty) continue;

          String sector = item['sector_name']?.toString().trim() ?? '';
          String subSector = item['sub_sector_name']?.toString().trim() ?? '';
          
          newData.putIfAbsent(title, () => {});
          newData[title]!.putIfAbsent(sector, () => {});
          newData[title]![sector]!.putIfAbsent(subSector, () => {});

          String categoryType = item['category_type']?.toString().toLowerCase() ?? '';
          String categoryName = item['category_name']?.toString().trim() ?? '';

          if (categoryType == 'primary') {
            newData[title]![sector]![subSector]!.putIfAbsent(categoryName, () => []);
          } else if (categoryType == 'secondary') {
            String parentName = item['parent_category_name']?.toString().trim() ?? '';
            if (parentName != '-' && parentName.isNotEmpty) {
              newData[title]![sector]![subSector]!.putIfAbsent(parentName, () => []);
              if (!newData[title]![sector]![subSector]![parentName]!.contains(categoryName)) {
                newData[title]![sector]![subSector]![parentName]!.add(categoryName);
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

  void _addPartner() {
    if (_partners.length < 10) {
      setState(() => _partners.add(_PartnerFormController()));
    }
  }

  void _removePartner(int index) {
    if (_partners.length > 1) {
      setState(() => _partners.removeAt(index));
    }
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    bool isValid = false;

    if (_currentStep == 0) {
      // Step 1 validation: at least 1 partner and check fields
      bool allValid = true;
      for (var p in _partners) {
        if (p.nameCtrl.text.isEmpty || p.panCtrl.text.isEmpty) allValid = false;
      }
      if (!allValid) {
        _showError('Fill all partner names and PAN numbers');
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
      if (_selectedSubCategories.isEmpty) { _showError('Select at least one category'); return; }
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
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulate work

      // SAFE 10-DIGIT ID
      final random = Random();
      String generatedId = List.generate(10, (_) => random.nextInt(10).toString()).join();

      final business = BusinessUser(
        id: generatedId,
        registrationType: "Partner",
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
        employeeRange: _employeeRange!,
        partnerCount: _partners.length,
        partners: _partners.map((p) => PartnerModel(
          name: p.nameCtrl.text,
          panNumber: p.panCtrl.text,
          accessLevel: p.accessLevel,
          partnershipDealFileName: p.dealFileName,
          partnershipDealFileBytes: p.dealBytes,
          writtenLetterFileName: p.letterFileName,
          writtenLetterFileBytes: p.letterBytes,
        )).toList(),
        createdDate: DateTime.now(),
        status: "Active",
        sectorTitle: _selectedSectorTitle,
        sector: _selectedSector,
        subSector: _selectedSubSector,
        categories: _selectedSubCategories.toList(),
      );

      BusinessUserStore().addBusiness(business);
      if (mounted) setState(() { _isSuccess = true; _isLoading = false; });
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
          if (type == 'pan') { _panFileName = f.name; _panBytes = f.bytes; }
          else if (type == 'sig') { _sigFileName = f.name; _sigBytes = f.bytes; }
          else if (type == 'gst') { _gstFileName = f.name; _gstBytes = f.bytes; }
          else if (type == 'bank') { _bankDocFileName = f.name; _bankDocBytes = f.bytes; }
          else if (type == 'logo') { _logoFileName = f.name; _logoBytes = f.bytes; }
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
      child: Row(children: [
        Expanded(child: OutlinedButton(onPressed: _prevStep, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Previous'))),
        const SizedBox(width: 16),
        Expanded(child: ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(_currentStep == 6 ? 'Create Business' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
      ]),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt, color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 8),
                    const Text('Partner Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Maximum of 10 partners can be added. (${_partners.length}/10 added)', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          if (_partners.length < 10)
            ElevatedButton.icon(
              onPressed: _addPartner,
              icon: const Icon(Icons.add, color: Colors.white, size: 14),
              label: const Text('Add Partner', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                elevation: 0,
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      if (_partners.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.02) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.person_add_alt_1, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 12),
              const Text('No partners added yet', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 4),
              const Text('Click "Add Partner" to add business partners (Max 10)', style: TextStyle(fontSize: 11, color: Colors.grey)),
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
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Partner ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF3B82F6))),
          InkWell(
            onTap: () => _removePartner(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF818CF8)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.close, color: Color(0xFF818CF8), size: 14),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInputField('Partner Name *', p.nameCtrl, isDark)),
            const SizedBox(width: 16),
            Expanded(child: _buildInputField('PAN Number *', p.panCtrl, isDark)),
          ],
        ),
        const Text('Access Level', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        Row(children: [
          _buildRadio(p.accessLevel == 'View Only', 'View Only', () => setState(() => p.accessLevel = 'View Only'), isDark),
          const SizedBox(width: 24),
          _buildRadio(p.accessLevel == 'Full Access', 'Full Access', () => setState(() => p.accessLevel = 'Full Access'), isDark),
        ]),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFileUpload('Partnership Deal *', p.dealFileName, p.dealBytes, () => _pickFile('', partnerIndex: index, partnerFileType: 'deal'), isDark),
            ),
            if (p.accessLevel == 'View Only') ...[
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFileUpload('Written Letter (with sign) *', p.letterFileName, p.letterBytes, () => _pickFile('', partnerIndex: index, partnerFileType: 'letter'), isDark),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.amber, size: 12),
                        SizedBox(width: 4),
                        Text('Required for view only mode', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()), // Placeholder to keep the Partnership Deal box the same size
            ]
          ],
        ),
      ]),
    );
  }

  // STEP 2: Basic Details
  Widget _buildStep2(bool isDark) {
    return Form(key: _step2Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Basic Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 24),
      _buildInputField('Business Name *', _nameCtrl, isDark),
      _buildInputField('Business Email *', _emailCtrl, isDark, keyboardType: TextInputType.emailAddress),
      _buildInputField('Business Phone *', _phoneCtrl, isDark, keyboardType: TextInputType.phone),
      _buildInputField('Website', _websiteCtrl, isDark),
      _buildInputField('Business PAN Number *', _panCtrl, isDark),
      _buildFileUpload('Business PAN Card Photo *', _panFileName, _panBytes, () => _pickFile('pan'), isDark),
      const SizedBox(height: 16),
      _buildFileUpload('Signature Photo *', _sigFileName, _sigBytes, () => _pickFile('sig'), isDark),
    ]));
  }

  // STEP 3: GST Details
  Widget _buildStep3(bool isDark) {
    return Form(key: _step3Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('GST Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 24),
      _buildInputField('GST Number *', _gstCtrl, isDark),
      _buildFileUpload('GST Certificate *', _gstFileName, _gstBytes, () => _pickFile('gst'), isDark),
    ]));
  }

  // STEP 4: Bank Details
  Widget _buildStep4(bool isDark) {
    return Form(key: _step4Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Bank Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 24),
      _buildInputField('Current Account Number *', _accNumberCtrl, isDark, keyboardType: TextInputType.number),
      _buildInputField('Confirm Account Number *', _confirmAccNumberCtrl, isDark, keyboardType: TextInputType.number),
      const SizedBox(height: 8),
      const Text('Document Type *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      Row(children: [
        _buildRadio(_bankDocType == 'Bank Statement', 'Bank Statement', () => setState(() => _bankDocType = 'Bank Statement'), isDark),
        const SizedBox(width: 20),
        _buildRadio(_bankDocType == 'Canceled Cheque Leaf', 'Canceled Cheque Leaf', () => setState(() => _bankDocType = 'Canceled Cheque Leaf'), isDark),
      ]),
      const SizedBox(height: 16),
      _buildFileUpload('Upload Bank Document *', _bankDocFileName, _bankDocBytes, () => _pickFile('bank'), isDark),
    ]));
  }

  // STEP 5: Business Address
  Widget _buildStep5(bool isDark) {
    return Form(key: _step5Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Business Address', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
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
        Expanded(child: _buildInputField('Pincode *', _pincodeCtrl, isDark, keyboardType: TextInputType.number)),
        const SizedBox(width: 16),
        Expanded(child: _buildInputField('State *', _stateCtrl, isDark)),
      ]),
      _buildInputField('Country', _countryCtrl, isDark, readOnly: true),
    ]));
  }

  // STEP 6: Business Type
  Widget _buildStep6(Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Business Type', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        const Text('Select business types that apply:', style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemCount: _typeOptions.length,
          itemBuilder: (context, i) {
            final type = _typeOptions[i];
            bool isSelected = _selectedTypes.contains(type);
            return InkWell(
              onTap: () => setState(() => isSelected ? _selectedTypes.remove(type) : _selectedTypes.add(type)),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? color : (isDark ? Colors.white12 : const Color(0xFF3B82F6).withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? color : (isDark ? Colors.white10 : Colors.grey[200]!)),
                ),
                child: Center(
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
        SearchableDropdown(
          label: 'Year of Establishment *',
          value: _yearCtrl.text.isEmpty ? null : _yearCtrl.text,
          items: List.generate(2026 - 1950 + 1, (index) => (2026 - index).toString()),
          isDark: isDark,
          onChanged: (val) {
            setState(() {
              _yearCtrl.text = val;
            });
          },
        ),
        const SizedBox(height: 24),
        const Text('Number of Employees *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _employeeRange,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: ['1-10', '11-50', '51-100', '101-500', '500+'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
          onChanged: (v) => setState(() => _employeeRange = v),
          decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!))),
        ),
      ],
    );
  }

  // STEP 7: Business Categories
  Widget _buildStep7(Color color, bool isDark) {
    if (_isCategoriesLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: color),
        ),
      );
    }
    final sectorTitles = _categoriesData.keys.toList();
    final sectors = _selectedSectorTitle != null ? _categoriesData[_selectedSectorTitle]!.keys.toList() : <String>[];
    final subSectors = (_selectedSectorTitle != null && _selectedSector != null)
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]!.keys.toList()
        : <String>[];

    final primaryCategories = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null)
        ? _categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]!.keys.toList()
        : <String>[];

    final subCategories = (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null && _activePrimaryCategory != null)
        ? (_categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]![_activePrimaryCategory] ?? <String>[])
        : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Select business sectors & categories', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 24),
        SearchableDropdown(
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
        const SizedBox(height: 16),
        SearchableDropdown(
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
        const SizedBox(height: 16),
        SearchableDropdown(
          label: 'Sub Sector *',
          value: _selectedSubSector,
          items: subSectors,
          isDark: isDark,
          onChanged: (val) {
            setState(() {
              _selectedSubSector = val;
              final primaryCats = _categoriesData[_selectedSectorTitle]![_selectedSector]![_selectedSubSector]!.keys.toList();
              _activePrimaryCategory = primaryCats.isNotEmpty ? primaryCats.first : null;
              _selectedSubCategories.clear();
            });
          },
        ),
        const SizedBox(height: 24),
        if (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null) ...[
          const Text('Select Categories *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
                      color: isDark ? Colors.white.withOpacity(0.01) : const Color(0xFFF8FAFC),
                    ),
                    child: ListView.builder(
                      itemCount: primaryCategories.length,
                      itemBuilder: (context, idx) {
                        final cat = primaryCategories[idx];
                        final isActive = cat == _activePrimaryCategory;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _activePrimaryCategory = cat;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            color: isActive ? (isDark ? Colors.white.withOpacity(0.05) : Colors.white) : Colors.transparent,
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                                color: isActive ? color : (isDark ? Colors.white70 : Colors.black54),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: subCategories.length,
                    itemBuilder: (context, idx) {
                      final subCat = subCategories[idx];
                      final isChecked = _selectedSubCategories.contains(subCat);
                      return CheckboxListTile(
                        activeColor: color,
                        title: Text(
                          subCat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        value: isChecked,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedSubCategories.add(subCat);
                            } else {
                              _selectedSubCategories.remove(subCat);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedSubCategories.isNotEmpty) ...[
            const Text('Selected Categories:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSubCategories.map((subCat) {
                return Chip(
                  backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                  label: Text(
                    subCat,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                  onDeleted: () {
                    setState(() {
                      _selectedSubCategories.remove(subCat);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ],
    );
  }

  // HELPERS
  Widget _buildTierCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool isSelected,
    bool isDark,
    bool isRecommended,
  ) {
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
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
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

Widget _buildLogoUploadField(
    String label,
    String? name,
    Uint8List? bytes,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        Container(
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

Widget _buildTurnoverDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                if (v == '20 Lakhs to 50 Lakhs') {
                  _selectedTier = 'Startup';
                } else if (v == '50 Lakhs to 2 Crores') {
                  _selectedTier = 'Standard';
                } else if (v == 'Above 2 Crores') {
                  _selectedTier = 'Corporate';
                }
              });
            },
            validator: (value) =>
                value == null ? 'Select Turnover Range' : null,
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
          if (_turnoverRange != null) ...[
            const SizedBox(height: 24),
            Text(
              'Company Tier *',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
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
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, bool isDark, {TextInputType keyboardType = TextInputType.text, bool readOnly = false, List<TextInputFormatter>? inputFormatters}) {
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
          validator: (v) => (v == null || v.isEmpty) && label.contains('*') ? 'Required' : null,
          decoration: InputDecoration(filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!))),
        ),
      ]),
    );
  }

  Widget _buildFileUpload(String label, String? name, Uint8List? bytes, VoidCallback onTap, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 8),
      InkWell(onTap: onTap, child: Container(width: double.infinity, height: 80, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)), child: bytes != null ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text(name!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])) : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 24), Text('Upload', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold))])))),
    ]);
  }

  Widget _buildRadio(bool isSelected, String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(onTap: onTap, child: Row(children: [Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : Colors.grey, width: isSelected ? 6 : 2))), const SizedBox(width: 10), Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13))]));
  }

  Widget _buildSuccessPage(Color color, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 100),
        const SizedBox(height: 24),
        const Text('Partner Business Created Successfully!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        const Text('Your business registration has been completed and added to your dashboard.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 48),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() { _isSuccess = false; _currentStep = 0; _resetControllers(); }), style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Add Another Partner Business', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Back to Dashboard'))),
      ]))),
    );
  }

  void _resetControllers() {
    _nameCtrl.clear(); _emailCtrl.clear(); _phoneCtrl.clear(); _websiteCtrl.clear(); _panCtrl.clear(); _gstCtrl.clear(); _accNumberCtrl.clear(); _confirmAccNumberCtrl.clear(); _doorCtrl.clear(); _streetCtrl.clear(); _buildingCtrl.clear(); _landmarkCtrl.clear(); _areaCtrl.clear(); _districtCtrl.clear(); _pincodeCtrl.clear(); _stateCtrl.clear(); _yearCtrl.clear(); _panBytes = null; _sigBytes = null; _gstBytes = null; _bankDocBytes = null; _selectedTypes.clear(); _employeeRange = null; _logoFileName = null; _logoBytes = null; _turnoverRange = null; _selectedTier = null;
    _selectedSectorTitle = null; _selectedSector = null; _selectedSubSector = null; _activePrimaryCategory = null; _selectedSubCategories.clear();
    _partners.clear();
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
