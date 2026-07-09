import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:circuit/features/upgrade/business_user_model.dart';
import 'package:circuit/features/upgrade/business_user_store.dart';
import 'package:circuit/features/upgrade/business_created_page.dart';

import '../../upgrade/business_created_page.dart';

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
  String? _panFileName;
  Uint8List? _panBytes;
  String? _profileFileName;
  Uint8List? _profileBytes;

  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();

  String _bankDocType = 'Passbook / Bank Statement';
  String? _bankDocFileName;
  Uint8List? _bankDocBytes;

  String _addressProofDocType = 'Aadhaar Card';
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

  void _handleSubmit() {
    if (!_declarationAccepted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Action Required', style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text('Please check this box if you want to proceed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        final String businessId = (1000000000 + (DateTime.now().millisecondsSinceEpoch % 8999999999)).toString();

        final business = BusinessUser(
          id: businessId,
          businessName: "My Business",
          email: "sabari@example.com",
          phone: "9508383027",
          panNumber: _panCtrl.text,
          panFileName: _panFileName,
          panFileBytes: _panBytes,
          signatureFileName: _profileFileName,
          signatureFileBytes: _profileBytes,
          gstNumber: "Not Provided",
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
          businessTypes: ["Trade", "Import", "Export", "Services", "Manufacturing"],
          yearOfEstablishment: "2026",
          employeeRange: "1-10",
          createdDate: DateTime.now(),
          status: "Active",
        );

        BusinessUserStore().addBusiness(business);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BusinessCreatedPage()),
        );
      }
    });
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

  void _mockAutofill(String pin) {
    if (pin == '642101') {
      _areaCtrl.text = 'Aliyar Nagar'; _districtCtrl.text = 'Coimbatore'; _stateCtrl.text = 'Tamil Nadu';
    } else if (pin == '641001') {
      _areaCtrl.text = 'Coimbatore'; _districtCtrl.text = 'Coimbatore'; _stateCtrl.text = 'Tamil Nadu';
    } else if (pin == '600001') {
      _areaCtrl.text = 'Chennai'; _districtCtrl.text = 'Chennai'; _stateCtrl.text = 'Tamil Nadu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF8B5CF6);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, centerTitle: true, iconTheme: const IconThemeData(color: Color(0xFF0F172A)), title: const Text("Business Upgrade", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800))),
      body: Stack(children: [Column(children: [_buildProgressHeader(themeColor), Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _buildCurrentStep(themeColor))), _buildNavigationButtons(themeColor)]), if (_isLoading) Container(color: Colors.black.withOpacity(0.3), child: const Center(child: CircularProgressIndicator(color: Colors.white)))]),
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
    return Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Step ${_currentStep + 1} of 5', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B), fontSize: 13)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE11D48).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(stepLabel, style: const TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w800, fontSize: 11)))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (_currentStep + 1) / 5, minHeight: 6, backgroundColor: const Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation<Color>(color)))]));
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
    return Form(key: _formKey1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader('PAN Details & Photos', Icons.account_box_rounded), _buildFormCard([_buildTextField(label: 'PAN Number', hint: 'E.G. ABCDE1234F', controller: _panCtrl, inputFormatters: [LengthLimitingTextInputFormatter(10), UpperCaseTextFormatter()], validator: (v) => RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v ?? '') ? null : 'Invalid PAN'), const SizedBox(height: 24), _buildUploadBox('PAN Front Photo *', _panFileName, _panBytes, () => _pickFile('pan')), const SizedBox(height: 24), _buildUploadBox('Profile Photo *', _profileFileName, _profileBytes, () => _pickFile('profile'))])]));
  }

  Widget _buildStep2(Color color) {
    return Form(key: _formKey2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader('Bank Account', Icons.account_balance_rounded), _buildFormCard([_buildTextField(label: 'Account Number', hint: 'Enter account number', controller: _accNumberCtrl, keyboardType: TextInputType.number, validator: (v) => (v != null && v.isNotEmpty) ? null : 'Required'), const SizedBox(height: 16), _buildTextField(label: 'Confirm Account Number', hint: 'Re-enter account number', controller: _confirmAccNumberCtrl, keyboardType: TextInputType.number, validator: (v) => (v == _accNumberCtrl.text) ? null : 'Mismatched'), const SizedBox(height: 24), _buildInfoBanner('Check your account number carefully for accuracy', color)])]));
  }

  Widget _buildStep3(Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader('Bank Document', Icons.description_rounded), _buildFormCard([const Text('Document Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))), RadioListTile<String>(title: const Text('Passbook / Bank Statement', style: TextStyle(fontSize: 14)), value: 'Passbook / Bank Statement', groupValue: _bankDocType, activeColor: color, onChanged: (v) => setState(() => _bankDocType = v!)), RadioListTile<String>(title: const Text('Canceled Cheque Leaf', style: TextStyle(fontSize: 14)), value: 'Canceled Cheque Leaf', groupValue: _bankDocType, activeColor: color, onChanged: (v) => setState(() => _bankDocType = v!)), const SizedBox(height: 16), _buildUploadBox('Upload $_bankDocType *', _bankDocFileName, _bankDocBytes, () => _pickFile('bank'))])]);
  }

  Widget _buildStep4(Color themeColor) {
    final docs = ['Aadhaar Card', 'Passport', 'Voter ID', 'Driving License', 'Utility Bill'];
    final addrTypes = ['Home', 'Office', 'Shop', 'Warehouse', 'Factory'];
    return Form(
      key: _formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Address Proof & Details', Icons.location_on_rounded),
          _buildFormCard([
            _buildDropdown(label: 'Document Type', value: _addressProofDocType, items: docs, onChanged: (v) => setState(() => _addressProofDocType = v!)),
            const SizedBox(height: 16),
            _buildUploadBox('Address Proof Document *', _addressProofFileName, _addressProofBytes, () => _pickFile('address')),
            const SizedBox(height: 32),
            const Text('Address Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const Divider(height: 20),
            const Text('Address Type *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF334155))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: _addressTypeError != null ? Colors.red : const Color(0xFFE2E8F0))),
              child: Column(
                children: [
                  RadioListTile<String>(title: const Text('Standard Address Type', style: TextStyle(fontSize: 14)), value: 'Standard Address Type', groupValue: _addressTypeSelection, activeColor: themeColor, onChanged: (v) => setState(() => _addressTypeSelection = v!)),
                  if (_addressTypeSelection == 'Standard Address Type') Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: _buildDropdown(label: '-- Select --', value: _standardAddressTypeValue, items: addrTypes, onChanged: (v) => setState(() => _standardAddressTypeValue = v))),
                  RadioListTile<String>(title: const Text('Add Custom Address Type', style: TextStyle(fontSize: 14)), value: 'Add Custom Address Type', groupValue: _addressTypeSelection, activeColor: themeColor, onChanged: (v) => setState(() => _addressTypeSelection = v!)),
                  if (_addressTypeSelection == 'Add Custom Address Type') Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), child: _buildTextField(label: 'Custom Type', controller: _customAddressTypeCtrl)),
                ],
              ),
            ),
            if (_addressTypeError != null) Padding(padding: const EdgeInsets.only(top: 8, left: 4), child: Text(_addressTypeError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
            const SizedBox(height: 24),
            _buildTextField(label: 'Door Number *', controller: _doorCtrl, validator: (v)=>v!.isEmpty?'Required':null),
            const SizedBox(height: 16),
            _buildTextField(label: 'Street Name *', controller: _streetCtrl, validator: (v)=>v!.isEmpty?'Required':null),
            const SizedBox(height: 24),
            _buildPincodeSearch(themeColor),
            const SizedBox(height: 24),
            Row(children: [Expanded(child: _buildTextField(label: 'Area *', controller: _areaCtrl, validator: (v)=>v!.isEmpty?'Required':null)), const SizedBox(width: 12), Expanded(child: _buildTextField(label: 'District *', controller: _districtCtrl, validator: (v)=>v!.isEmpty?'Required':null))]),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _buildTextField(label: 'Pincode *', controller: _pincodeCtrl, keyboardType: TextInputType.number, validator: (v)=>(v?.length!=6)?'6 digits':null)), const SizedBox(width: 12), Expanded(child: _buildTextField(label: 'State *', controller: _stateCtrl, validator: (v)=>v!.isEmpty?'Required':null))]),
          ]),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHeader('Review', Icons.fact_check_rounded),
      _buildReviewSummary(),
      const SizedBox(height: 24),
      _buildUploadedDocumentsSection(),
      const SizedBox(height: 32),
      _buildInfoBanner('I hereby confirm that all the information provided is true and correct.', Colors.blue),
      const SizedBox(height: 12),
      CheckboxListTile(value: _declarationAccepted, onChanged: (v) => setState(() => _declarationAccepted = v!), title: const Text('I agree to the terms and conditions and confirm accuracy.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero, activeColor: const Color(0xFF8B5CF6))
    ]);
  }

  Widget _buildUploadedDocumentsSection() {
    final docs = [
      {'label': 'PAN Photo', 'name': _panFileName, 'bytes': _panBytes},
      {'label': 'Profile Photo', 'name': _profileFileName, 'bytes': _profileBytes},
      {'label': 'Bank Document', 'name': _bankDocFileName, 'bytes': _bankDocBytes},
      {'label': 'Address Proof', 'name': _addressProofFileName, 'bytes': _addressProofBytes},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("UPLOADED DOCUMENTS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6))),
        const SizedBox(height: 16),
        ...docs.where((d) => d['bytes'] != null).map((d) => _buildFilePreviewCard(d['label'] as String, d['name'] as String?, d['bytes'] as Uint8List?)).toList(),
      ],
    );
  }

  Widget _buildFilePreviewCard(String label, String? name, Uint8List? bytes) {
    bool isImage = name != null && (name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpeg'));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 12),
          if (isImage && bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                bytes,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.description_rounded, color: Color(0xFF8B5CF6), size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name ?? 'Unnamed File', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
                      const Text('PDF / Non-Image File', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReviewSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SUMMARY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6))),
          const SizedBox(height: 20),
          _buildReviewRow('PAN Number', _panCtrl.text),
          _buildReviewRow('Bank Account', _maskAcc(_accNumberCtrl.text)),
          _buildReviewRow('Address Proof', _addressProofDocType),
          _buildReviewRow('Area', _areaCtrl.text),
          _buildReviewRow('District', _districtCtrl.text),
          _buildReviewRow('State', _stateCtrl.text),
          _buildReviewRow('Pincode', _pincodeCtrl.text),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text("All documents successfully uploaded", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String l, String v) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)), Text(v.isEmpty ? 'N/A' : v, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)))]));
  }

  Widget _buildHeader(String title, IconData icon) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(children: [Icon(icon, color: const Color(0xFF8B5CF6), size: 28), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)))]));
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }

  Widget _buildTextField({required String label, String? hint, required TextEditingController controller, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    final isPan = label.toLowerCase().contains('pan') || controller == _panCtrl;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))), const SizedBox(height: 8), TextFormField(controller: controller, inputFormatters: inputFormatters, validator: validator, keyboardType: keyboardType, readOnly: readOnly, textCapitalization: isPan ? TextCapitalization.characters : TextCapitalization.none, decoration: InputDecoration(hintText: hint, filled: readOnly, fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1)))) )]);
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))), const SizedBox(height: 8), DropdownButtonFormField<String>(value: value, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged, decoration: InputDecoration(contentPadding: const EdgeInsets.symmetric(horizontal: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))) ]);
  }

  Widget _buildUploadBox(String label, String? name, Uint8List? bytes, VoidCallback onTap) {
    bool isImage = name != null && (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.jpeg'));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))), const SizedBox(height: 8), InkWell(onTap: onTap, child: Container(width: double.infinity, height: 120, decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))), child: bytes != null ? (isImage ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(bytes, fit: BoxFit.cover)) : Center(child: Text(name!))) : const Center(child: Icon(Icons.cloud_upload_outlined, color: Color(0xFF8B5CF6), size: 32)) ))]);
  }

  Widget _buildInfoBanner(String text, Color color) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(Icons.info_rounded, color: color, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)))]));
  }

  Widget _buildPincodeSearch(Color color) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))), child: Row(children: [Expanded(child: TextField(controller: _pincodeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Enter pincode'))), const SizedBox(width: 12), ElevatedButton(onPressed: () => _mockAutofill(_pincodeCtrl.text), style: ElevatedButton.styleFrom(backgroundColor: color), child: const Text('Search', style: TextStyle(color: Colors.white)))]));
  }

  String _maskAcc(String v) => v.length > 4 ? '****${v.substring(v.length - 4)}' : v;

  Widget _buildNavigationButtons(Color color) {
    return Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white), child: Row(children: [Expanded(child: OutlinedButton(onPressed: _prevStep, child: const Text('Previous'))), const SizedBox(width: 16), Expanded(child: ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(backgroundColor: color), child: Text(_currentStep == 4 ? 'Create Business User' : 'Next', style: const TextStyle(color: Colors.white))))]));
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) => newV.copyWith(text: newV.text.toUpperCase());
}
