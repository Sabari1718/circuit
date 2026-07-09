import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'business_user_model.dart';
import 'business_user_store.dart';
import 'business_created_page.dart';
import '../user_service.dart';
import '../core/services/api_service.dart';
class BusinessUpgradePage extends StatefulWidget {
  const BusinessUpgradePage({super.key});

  @override
  State<BusinessUpgradePage> createState() => _BusinessUpgradePageState();
}

class _BusinessUpgradePageState extends State<BusinessUpgradePage> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  final _panCtrl = TextEditingController();
  String _gender = 'Male';
  String? _panFileName;
  Uint8List? _panBytes;
  String? _profileFileName;
  Uint8List? _profileBytes;

  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();

  String _bankDocType = 'Passbook / Bank Statement';
  String? _bankDocFileName;
  Uint8List? _bankDocBytes;

  String? _addressProofDocType;
  String? _addressProofFileName;
  Uint8List? _addressProofBytes;

  String _addressTypeSelection = 'Standard Address Type';
  String? _standardAddressTypeValue;
  final _customAddressTypeCtrl = TextEditingController();
  String? _addressTypeError;

  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');

  bool _declarationAccepted = false;
  bool _showDeclarationError = false;
  bool _isLoading = false;

  void _nextStep() {
    FocusScope.of(context).unfocus();
    bool stepValid = false;

    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        if (_panBytes == null) { _showError('Please upload PAN card photo'); return; }
        if (_profileBytes == null) { _showError('Please upload profile photo'); return; }
        stepValid = true;
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        stepValid = true;
      }
    } else if (_currentStep == 2) {
      if (_bankDocBytes == null) { _showError('Please upload bank document'); return; }
      stepValid = true;
    } else if (_currentStep == 3) {
      bool typeValid = false;
      if (_addressTypeSelection == 'Standard Address Type') {
        if (_standardAddressTypeValue != null) typeValid = true;
      } else if (_addressTypeSelection == 'Add Custom Address Type') {
        if (_customAddressTypeCtrl.text.isNotEmpty) typeValid = true;
      }

      if (!typeValid) {
        setState(() => _addressTypeError = 'Please select an address type');
        _showError('Please select an address type');
        return;
      } else {
        setState(() => _addressTypeError = null);
      }

      if (_formKey4.currentState!.validate()) {
        if (_addressProofBytes == null) { _showError('Please upload address proof'); return; }
        stepValid = true;
      }
    } else if (_currentStep == 4) {
      _handleSubmit();
      return;
    }

    if (stepValid && _currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFE11D48)));
  }

  Future<void> _handleSubmit() async {
    if (!_declarationAccepted) {
      setState(() => _showDeclarationError = true);
      return;
    }
    setState(() => _showDeclarationError = false);
    setState(() => _isLoading = true);

    try {
      final userData = await UserService().getUserData();
      final String userMainId = userData['user_main_id'] ?? '';

      if (userMainId.isEmpty) {
        _showError("User ID missing. Please login again.");
        setState(() => _isLoading = false);
        return;
      }

      final response = await ApiService().createBusinessUser(
        userMainId: userMainId,
        panNumber: _panCtrl.text,
        gender: _gender.toLowerCase(),
        addressDocType: _addressProofDocType?.toLowerCase().split(' ').first ?? 'aadhar',
        addressType: _addressTypeSelection == 'Add Custom Address Type' ? 'custom' : 'standard',
        selectedAddressType: _addressTypeSelection == 'Add Custom Address Type' ? _customAddressTypeCtrl.text : (_standardAddressTypeValue ?? ''),
        area: _areaCtrl.text,
        bankAccountNumber: _accNumberCtrl.text,
        bankDocumentType: _bankDocType.toLowerCase().contains('passbook') ? 'passbook' : 'statement',
        buildingName: _buildingCtrl.text,
        country: _countryCtrl.text,
        district: _districtCtrl.text,
        doorNumber: _doorCtrl.text,
        landmark: _landmarkCtrl.text,
        pincode: _pincodeCtrl.text,
        state: _stateCtrl.text,
        streetName: _streetCtrl.text,
        addressProofBytes: _addressProofBytes,
        addressProofFileName: _addressProofFileName ?? 'address.jpg',
        bankDocumentBytes: _bankDocBytes,
        bankDocumentFileName: _bankDocFileName ?? 'bank.jpg',
        panFrontPhotoBytes: _panBytes,
        panFrontPhotoFileName: _panFileName ?? 'pan.jpg',
        profilePhotoBytes: _profileBytes,
        profilePhotoFileName: _profileFileName ?? 'profile.jpg',
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (response['status'] == 'error' || 
          response['result'] == 'Error' || 
          (response['data'] != null && (response['data']['result'] == 'Error' || response['data']['result'] == 'Failure'))) {
        
        String errorMsg = response['message'] ?? 'Failed to create business.';
        if (response['data'] != null && response['data']['message'] != null) {
          errorMsg = response['data']['message'];
        }
        
        _showError(errorMsg);
      } else {
        final prefs = await   SharedPreferences.getInstance();
        await prefs.setBool('is_main_business_registered', true);
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business User Created Successfully!'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError("An unexpected error occurred: $e");
      }
    }
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['jpg', 'png', 'pdf'], withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final file = result.files.first;
        if (type == 'pan') { _panFileName = file.name; _panBytes = file.bytes; }
        else if (type == 'profile') { _profileFileName = file.name; _profileBytes = file.bytes; }
        else if (type == 'bank') { _bankDocFileName = file.name; _bankDocBytes = file.bytes; }
        else if (type == 'address') { _addressProofFileName = file.name; _addressProofBytes = file.bytes; }
      });
    }
  }

  Future<void> _fetchPincodeDetails(String pin) async {
    if (pin.length != 6) return;
    try {
      final response = await http.get(Uri.parse('https://api.postalpincode.in/pincode/$pin'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          setState(() {
            _areaCtrl.text = postOffice['Name'] ?? '';
            _districtCtrl.text = postOffice['District'] ?? '';
            _stateCtrl.text = postOffice['State'] ?? '';
            _countryCtrl.text = postOffice['Country'] ?? 'India';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Pincode or no data found')));
        }
      }
    } catch (e) {
      debugPrint('Error fetching pincode: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF8B5CF6);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Color(0xFF0F172A)), title: const Text("Business Upgrade", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800))),
      body: Stack(
        children: [
          Column(
            children: [
              _buildWelcomeHeader(),
              _buildProgressHeader(themeColor),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: _buildCurrentStep(themeColor),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 14, color: Color(0xFF94A3B8)),
                          SizedBox(width: 8),
                          Text("All information is encrypted and securely stored", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(themeColor)
            ],
          ),
          if (_isLoading) Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator(color: Colors.white)))
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return FutureBuilder<Map<String, String>>(
      future: UserService().getUserData(),
      builder: (context, snapshot) {
        final name = snapshot.data?['name']?.split(' ').first ?? 'Sabari';
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome Back, $name! 👋", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    const Text("Create a new business user account", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildProgressHeader(Color color) {
    String stepLabel = '';
    switch (_currentStep) {
      case 0: stepLabel = 'PAN & Photos'; break;
      case 1: stepLabel = 'Bank Account'; break;
      case 2: stepLabel = 'Bank Document'; break;
      case 3: stepLabel = 'Address Proof'; break;
      case 4: stepLabel = 'Review'; break;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Step ${_currentStep + 1} of 5', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155), fontSize: 14)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(12)), child: Text(stepLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11))),
            ]
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: (_currentStep + 1) / 5, minHeight: 6, backgroundColor: const Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF8B5CF6))),
          )
        ],
      ),
    );
  }

  Widget _buildCurrentStep(Color color) {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2(color);
      case 2: return _buildStep3(color);
      case 3: return _buildStep4(color);
      case 4: return _buildStep5();
      default: return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('PAN Details & Photos', 'Enter your PAN number and upload required photos', Icons.badge_rounded),
            _buildTextField(label: 'PAN Number *', hint: 'E.G., ABCDE1234F', controller: _panCtrl, inputFormatters: [LengthLimitingTextInputFormatter(10), UpperCaseTextFormatter()], validator: (v) => RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v ?? '') ? null : 'Invalid PAN'),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF64748B), size: 14),
                SizedBox(width: 6),
                Expanded(child: Text("Enter 10-character alphanumeric PAN", style: TextStyle(color: Color(0xFF64748B), fontSize: 11))),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Gender *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildGenderOption('Male'),
                _buildGenderOption('Female'),
                _buildGenderOption('Others'),
              ],
            ),
            const SizedBox(height: 32),
            _buildUploadBox('PAN Front Photo *', _panFileName, _panBytes, () => _pickFile('pan')),
            const SizedBox(height: 24),
            _buildUploadBox('Profile Photo *', _profileFileName, _profileBytes, () => _pickFile('profile')),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9E42F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Your PAN details and photos are encrypted and securely stored",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label) {
    final isSelected = _gender == label;
    return InkWell(
      onTap: () => setState(() => _gender = label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildStep2(Color color) {
    return Form(
      key: _formKey2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Bank Account Number', 'Enter your bank account details', Icons.account_balance_rounded),
            _buildTextField(label: 'Account Number *', hint: 'Enter your bank account number', controller: _accNumberCtrl, keyboardType: TextInputType.number, validator: (v) => (v != null && v.isNotEmpty) ? null : 'Required'),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF64748B), size: 14),
                SizedBox(width: 6),
                Expanded(child: Text("Enter the account number as shown in your passbook", style: TextStyle(color: Color(0xFF64748B), fontSize: 11))),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(label: 'Confirm Account Number', hint: 'Re-enter account number', controller: _confirmAccNumberCtrl, keyboardType: TextInputType.number, validator: (v) => (v == _accNumberCtrl.text) ? null : 'Mismatched'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF737BC5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Double-check your account number for accuracy",
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3(Color color) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Bank Document', 'Upload passbook statement or canceled cheque', Icons.receipt_long_rounded),
          const Text('Document Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildRadioOption('Passbook / Bank Statement'),
              _buildRadioOption('Canceled Cheque Leaf'),
            ],
          ),
          const SizedBox(height: 24),
          _buildUploadBox('$_bankDocType *', _bankDocFileName, _bankDocBytes, () => _pickFile('bank')),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF9E42F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.cyanAccent, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Ensure account number is clearly visible in the document",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label) {
    final isSelected = _bankDocType == label;
    return InkWell(
      onTap: () => setState(() => _bankDocType = label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildStep4(Color themeColor) {
    final docs = ['Aadhar Card', 'Passport', 'Voter ID', 'Driving License', 'Utility Bill'];
    final addrTypes = ['Residential', 'Commercial', 'Office', 'Other'];
    return Form(
      key: _formKey4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader('Address Proof & Details', 'Upload address proof and enter address details', Icons.map_rounded),
            _buildDropdown(label: 'Document Type', hint: 'Select document type', value: _addressProofDocType, items: docs, onChanged: (v) => setState(() => _addressProofDocType = v)),
            const SizedBox(height: 24),
            _buildUploadBox('Upload Document *', _addressProofFileName, _addressProofBytes, () => _pickFile('address')),
            const SizedBox(height: 32),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 32),
            Row(
              children: const [
                Icon(Icons.location_on, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text('Address Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Address Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildAddressTypeRadio('Standard Address Type'),
                _buildAddressTypeRadio('Add Custom Address Type'),
              ],
            ),
            const SizedBox(height: 16),
            if (_addressTypeSelection == 'Standard Address Type')
              _buildDropdown(label: '', hint: '-- Select Address Type --', value: _standardAddressTypeValue, items: addrTypes, onChanged: (v) => setState(() => _standardAddressTypeValue = v)),
            if (_addressTypeSelection == 'Add Custom Address Type')
              _buildTextField(label: '', hint: 'Enter custom address type', controller: _customAddressTypeCtrl),
            if (_addressTypeError != null) Padding(padding: const EdgeInsets.only(top: 8, left: 4), child: Text(_addressTypeError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
            const SizedBox(height: 24),
            Row(children: [Expanded(child: _buildTextField(label: 'Door Number: *', hint: 'Door Number', controller: _doorCtrl, validator: (v)=>v!.isEmpty?'Required':null)), const SizedBox(width: 16), Expanded(child: _buildTextField(label: 'Street Name: *', hint: 'Street Name', controller: _streetCtrl, validator: (v)=>v!.isEmpty?'Required':null))]),
            const SizedBox(height: 24),
            Row(children: [Expanded(child: _buildTextField(label: 'Building Name:', hint: 'Building Name', controller: _buildingCtrl)), const SizedBox(width: 16), Expanded(child: _buildTextField(label: 'Landmark:', hint: 'Landmark', controller: _landmarkCtrl))]),
            const SizedBox(height: 32),
            Center(child: _buildPincodeSearch(themeColor)),
            const SizedBox(height: 32),
            Row(children: [Expanded(child: _buildTextField(label: 'Area Name: *', hint: 'Enter Area Name', controller: _areaCtrl, validator: (v)=>v!.isEmpty?'Required':null)), const SizedBox(width: 16), Expanded(child: _buildTextField(label: 'District: *', hint: 'District', controller: _districtCtrl, validator: (v)=>v!.isEmpty?'Required':null))]),
            const SizedBox(height: 24),
            Row(children: [Expanded(child: _buildTextField(label: 'Pincode: *', hint: 'Pincode', controller: _pincodeCtrl, keyboardType: TextInputType.number, validator: (v)=>(v?.length!=6)?'6 digits':null)), const SizedBox(width: 16), Expanded(child: _buildTextField(label: 'State: *', hint: 'State', controller: _stateCtrl, validator: (v)=>v!.isEmpty?'Required':null))]),
            const SizedBox(height: 24),
            Row(children: [Expanded(child: _buildTextField(label: 'Country: *', hint: 'India', controller: _countryCtrl, readOnly: true)), const Spacer()]),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9E42F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.cyanAccent, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Address should match with your address proof document",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTypeRadio(String label) {
    final isSelected = _addressTypeSelection == label;
    return InkWell(
      onTap: () => setState(() => _addressTypeSelection = label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Review & Submit', 'Verify all information before submitting', Icons.check_circle),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final cards = [
                _buildReviewCard('Personal Details', Icons.person, _buildPersonalReviewContent()),
                _buildReviewCard('Bank Details', Icons.account_balance, _buildBankReviewContent()),
                _buildReviewCard('Address Details', Icons.location_on, _buildAddressReviewContent()),
                _buildReviewCard('Documents', Icons.description, _buildDocumentsReviewContent()),
              ];

              if (isWide) {
                return Column(
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: cards[0]), const SizedBox(width: 24), Expanded(child: cards[1])]),
                    const SizedBox(height: 24),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: cards[2]), const SizedBox(width: 24), Expanded(child: cards[3])]),
                  ],
                );
              }
              return Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24), child: c)).toList());
            },
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text("Declaration: I hereby confirm that all the information provided is true and correct.", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _declarationAccepted,
            onChanged: (v) {
              setState(() {
                _declarationAccepted = v!;
                if (_declarationAccepted) _showDeclarationError = false;
              });
            },
            title: const Text('I agree to the terms and conditions and confirm accuracy.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF8B5CF6),
            visualDensity: VisualDensity.compact,
          ),
          if (_showDeclarationError)
            Container(
              margin: const EdgeInsets.only(left: 12, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.deepOrange, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text("Please check this box if you want to proceed.", style: TextStyle(fontSize: 11, color: Colors.black87))),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildPersonalReviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Text('PAN: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)), Text(_panCtrl.text.isEmpty ? 'N/A' : _panCtrl.text, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13))]),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Photo:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)), const SizedBox(height: 8), _buildMiniPreview(_profileFileName, _profileBytes)])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('PAN Photo:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)), const SizedBox(height: 8), _buildMiniPreview(_panFileName, _panBytes)])),
          ],
        )
      ],
    );
  }

  Widget _buildBankReviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const Text('Account: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)), Text(_maskAcc(_accNumberCtrl.text).isEmpty ? 'N/A' : _maskAcc(_accNumberCtrl.text), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13))]),
        const SizedBox(height: 16),
        const Text('Document:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 8),
        _buildMiniPreview(_bankDocFileName, _bankDocBytes),
      ],
    );
  }

  Widget _buildAddressReviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAddrRow('Door No:', _doorCtrl.text),
        _buildAddrRow('Street:', _streetCtrl.text),
        _buildAddrRow('Area:', _areaCtrl.text),
        _buildAddrRow('District:', _districtCtrl.text),
        _buildAddrRow('Pincode:', _pincodeCtrl.text),
        _buildAddrRow('State:', _stateCtrl.text),
        _buildAddrRow('Country:', _countryCtrl.text),
      ],
    );
  }

  Widget _buildDocumentsReviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address Proof:', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 8),
        _buildMiniPreview(_addressProofFileName, _addressProofBytes),
      ],
    );
  }

  Widget _buildAddrRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildMiniPreview(String? name, Uint8List? bytes) {
    if (bytes == null) return Container(height: 80, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Not Uploaded', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))));
    bool isImg = name != null && (name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpeg'));
    return GestureDetector(
      onTap: () {
        if (isImg) {
          showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.85),
            builder: (ctx) => Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Center(child: InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain))),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot preview non-image files yet.')));
        }
      },
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCBD5E1)), borderRadius: BorderRadius.circular(8), color: Colors.white),
        child: isImg ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.memory(bytes, fit: BoxFit.cover)) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.description, color: Color(0xFF8B5CF6), size: 24), const SizedBox(height: 4), Text(name ?? 'Doc', style: const TextStyle(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)]),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE11D48),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, String? hint, required TextEditingController controller, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    final isPan = label.toLowerCase().contains('pan') || controller == _panCtrl;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label.isNotEmpty) ...[Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B))), const SizedBox(height: 8)],
      TextFormField(controller: controller, inputFormatters: inputFormatters, validator: validator, keyboardType: keyboardType, readOnly: readOnly, textCapitalization: isPan ? TextCapitalization.characters : TextCapitalization.none, decoration: InputDecoration(hintText: hint, filled: true, fillColor: readOnly ? const Color(0xFFE2E8F0) : Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1)))))
    ]);
  }

  Widget _buildDropdown({required String label, String? hint, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label.isNotEmpty) ...[Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF64748B))), const SizedBox(height: 8)],
      DropdownButtonFormField<String>(value: value, hint: hint != null ? Text(hint) : null, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged, decoration: InputDecoration(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1)))))
    ]);
  }

  Widget _buildUploadBox(String label, String? name, Uint8List? bytes, VoidCallback onTap) {
    bool isImage = name != null && (name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpeg'));
    bool isProfile = label.toLowerCase().contains('profile');
    bool isPhoto = label.toLowerCase().contains('photo');
    
    // Determine the empty state text/icon based on the context
    IconData emptyIcon = Icons.insert_drive_file_outlined;
    String emptyTitle = "Click to upload document";
    String emptySub = "JPG, PNG or PDF (max. 5MB)";
    if (label.toLowerCase().contains('address') || label.toLowerCase().contains('upload document')) {
      emptyIcon = Icons.badge_outlined;
      emptyTitle = "Click to upload address proof";
      emptySub = "JPG, PNG or PDF (max. 5MB)";
    } else if (isProfile) {
      emptyIcon = Icons.account_circle;
      emptyTitle = "Click to upload";
      emptySub = "JPG, PNG (max. 2MB)";
    } else if (isPhoto) {
      emptyIcon = Icons.cloud_upload_outlined;
      emptyTitle = "Click to upload";
      emptySub = "JPG, PNG (max. 5MB)";
    }
    
    // Determine border color (use blue if active/selected, though standard is grey)
    // For bank documents we use a standard color as per design.
    Color borderColor = const Color(0xFFE2E8F0);
    if (label.contains('Passbook') && _bankDocType.contains('Passbook')) {
       borderColor = const Color(0xFF3B82F6);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: bytes != null ? 180 : 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bytes == null ? borderColor : const Color(0xFFE2E8F0), width: bytes == null && borderColor != const Color(0xFFE2E8F0) ? 1.5 : 1),
            ),
            child: bytes != null
                ? (isImage
                    ? (isProfile
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                  image: DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildChangeButton(onTap),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(bytes, fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                              _buildChangeButton(onTap),
                              const SizedBox(height: 12),
                            ],
                          ))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_rounded, color: Color(0xFF8B5CF6), size: 40),
                          const SizedBox(height: 8),
                          Text(name ?? 'Document', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
                          const SizedBox(height: 12),
                          _buildChangeButton(onTap),
                        ],
                      ))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(emptyIcon, color: const Color(0xFFCBD5E1), size: 40),
                      const SizedBox(height: 12),
                      Text(emptyTitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(emptySub, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeButton(VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.sync_rounded, color: Color(0xFFE11D48), size: 16),
      label: const Text("Change", style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE11D48)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      ),
    );
  }

  Widget _buildInfoBanner(String text, Color color) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(Icons.info_rounded, color: color, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)))]));
  }

  Widget _buildPincodeSearch(Color color) {
    return Container(
      width: 400, // Matching the constrained width in mockup
      child: Column(
        children: [
          const Text("Fill Address Using", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.push_pin, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Text('Use Pincode', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
                const SizedBox(height: 16),
                const Text('Search by 6-digit pincode', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pincodeCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter pincode',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        )
                      )
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _fetchPincodeDetails(_pincodeCtrl.text),
                      icon: const Icon(Icons.search, size: 16, color: Color(0xFFE11D48)),
                      label: const Text('Search', style: TextStyle(color: Color(0xFFE11D48))),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1F2),
                        side: const BorderSide(color: Color(0xFFE11D48)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      )
                    )
                  ]
                )
              ]
            )
          )
        ]
      )
    );
  }

  String _maskAcc(String v) => v.length > 4 ? '****${v.substring(v.length - 4)}' : v;

  Widget _buildNavigationButtons(Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 16,
        children: [
          OutlinedButton.icon(
            onPressed: _prevStep,
            icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFFE11D48)),
            label: const Text('Previous', style: TextStyle(color: Color(0xFFE11D48))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE11D48)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == 4 ? const Color(0xFF8B5CF6) : const Color(0xFFE11D48),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Reduced padding for better fit
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_currentStep == 4 ? 'Create Business User' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                if (_currentStep == 4) const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, size: 16, color: Colors.white),
                ) else if (_currentStep < 4) const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) => newV.copyWith(text: newV.text.toUpperCase());
}
