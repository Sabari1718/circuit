import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'business_user_model.dart';
import 'business_user_store.dart';

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
  final _step1Key = GlobalKey<FormState>(); // Note: Step 1 is "Partner Details" but I will store the list.
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();
  final _step6Key = GlobalKey<FormState>();

  // Step 1: Partner Details
  final List<_PartnerFormController> _partners = [_PartnerFormController()];

  // Step 2: Basic Details
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
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
      if (_step6Key.currentState!.validate()) {
        if (_selectedTypes.isEmpty) { _showError('Select at least one business type'); return; }
        if (_employeeRange == null) { _showError('Select employee range'); return; }
        _handleSubmit();
        return;
      }
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
      child: Row(children: [
        Expanded(child: OutlinedButton(onPressed: _prevStep, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Previous'))),
        const SizedBox(width: 16),
        Expanded(child: ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(_currentStep == 5 ? 'Create Business' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
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
      default: return const SizedBox();
    }
  }

  // STEP 1: Partner Details
  Widget _buildStep1(Color color, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Partner Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('Add information about your business partners (up to 10)', style: TextStyle(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 24),
      ...List.generate(_partners.length, (index) => _buildPartnerBlock(index, color, isDark)),
      if (_partners.length < 10)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: TextButton.icon(onPressed: _addPartner, icon: const Icon(Icons.add, color: Color(0xFF3B82F6)), label: const Text('Add Another Partner', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold))),
        ),
    ]);
  }

  Widget _buildPartnerBlock(int index, Color color, bool isDark) {
    final p = _partners[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.03) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Partner ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3B82F6))),
          if (_partners.length > 1) IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20), onPressed: () => _removePartner(index)),
        ]),
        const SizedBox(height: 16),
        _buildInputField('Partner Name', p.nameCtrl, isDark),
        _buildInputField('PAN Number', p.panCtrl, isDark),
        const Text('Access Level', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        Row(children: [
          _buildRadio(p.accessLevel == 'View Only', 'View Only', () => setState(() => p.accessLevel = 'View Only'), isDark),
          const SizedBox(width: 20),
          _buildRadio(p.accessLevel == 'Full Access', 'Full Access', () => setState(() => p.accessLevel = 'Full Access'), isDark),
        ]),
        const SizedBox(height: 16),
        _buildFileUpload('Partnership Deal Upload', p.dealFileName, p.dealBytes, () => _pickFile('', partnerIndex: index, partnerFileType: 'deal'), isDark),
        const SizedBox(height: 16),
        _buildFileUpload('Written Letter with Sign', p.letterFileName, p.letterBytes, () => _pickFile('', partnerIndex: index, partnerFileType: 'letter'), isDark),
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
    return Form(key: _step6Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Business Type', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 16),
      const Text('Select business types that apply:', style: TextStyle(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 16),
      Wrap(spacing: 12, runSpacing: 12, children: _typeOptions.map((t) => _buildTypeTile(t, color, isDark)).toList()),
      const SizedBox(height: 32),
      _buildInputField('Year of Establishment *', _yearCtrl, isDark, keyboardType: TextInputType.number),
      const Text('Number of Employees *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _employeeRange,
        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        items: ['1-10', '11-50', '51-100', '101-500', '500+'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
        onChanged: (v) => setState(() => _employeeRange = v),
        decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ]));
  }

  Widget _buildTypeTile(String label, Color color, bool isDark) {
    bool isSelected = _selectedTypes.contains(label);
    return InkWell(
      onTap: () => setState(() => isSelected ? _selectedTypes.remove(label) : _selectedTypes.add(label)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: isSelected ? color : (isDark ? Colors.white.withOpacity(0.05) : Colors.white), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? color : (isDark ? Colors.white10 : Colors.grey[300]!))),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 13)),
      ),
    );
  }

  // HELPERS
  Widget _buildInputField(String label, TextEditingController ctrl, bool isDark, {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl, keyboardType: keyboardType, readOnly: readOnly,
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
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() { _isSuccess = false; _currentStep = 0; }), style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Add Another Partner Business', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Back to Dashboard'))),
      ]))),
    );
  }
}

class _PartnerFormController {
  final nameCtrl = TextEditingController();
  final panCtrl = TextEditingController();
  String accessLevel = 'View Only';
  String? dealFileName; Uint8List? dealBytes;
  String? letterFileName; Uint8List? letterBytes;
}
