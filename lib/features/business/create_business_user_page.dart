import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:circuit/features/upgrade/business_user_model.dart';
import 'package:circuit/features/upgrade/business_user_store.dart';

class CreateBusinessUserPage extends StatefulWidget {
  const CreateBusinessUserPage({super.key});

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
  String? _panFileName; Uint8List? _panBytes;
  String? _sigFileName; Uint8List? _sigBytes;

  final _gstCtrl = TextEditingController();
  String? _gstFileName; Uint8List? _gstBytes;

  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  String _bankDocType = 'Bank Statement';
  String? _bankDocFileName; Uint8List? _bankDocBytes;

  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');

  final Set<String> _selectedTypes = {};
  final _yearCtrl = TextEditingController();
  String? _employeeRange;

  // Step 6 Category State Variables
  String? _selectedSectorTitle;
  String? _selectedSector;
  String? _selectedSubSector;
  String? _activePrimaryCategory;
  final Set<String> _selectedSubCategories = {};

  // Mock Category Hierarchy Dataset
  final Map<String, Map<String, Map<String, Map<String, List<String>>>>> _categoriesData = {
    "Agriculture & Allied": {
      "Farming": {
        "Organic Farming": {
          "Fruits & Veggies": ["Organic Apples", "Organic Berries", "Organic Leafy Greens", "Organic Tomatoes"],
          "Grains & Pulses": ["Organic Rice", "Organic Wheat", "Organic Lentils", "Organic Oats"],
        },
        "Commercial Crops": {
          "Fibers": ["Cotton", "Jute", "Hemp"],
          "Beverages": ["Tea Leaves", "Coffee Beans", "Cocoa"],
        }
      },
      "Livestock": {
        "Dairy Farming": {
          "Milk Products": ["Fresh Milk", "Cheese & Butter", "Yogurt", "Ghee"],
        },
        "Poultry": {
          "Eggs & Meat": ["Broiler Chicken", "Organic Eggs", "Turkey"],
        }
      }
    },
    "Manufacturing & Industrial": {
      "Textiles": {
        "Apparel": {
          "Men's Wear": ["Casual Shirts", "Denim Pants", "Formal Suits", "Activewear"],
          "Women's Wear": ["Ethnic Wear", "Dresses", "Sarees", "Formal Blazers"],
        },
        "Home Textiles": {
          "Bedding": ["Bed Sheets", "Pillows", "Duvets"],
          "Curtains": ["Blackout Curtains", "Sheer Curtains"],
        }
      },
      "Electronics": {
        "Consumer Electronics": {
          "Smartphones": ["Android Phones", "iOS Phones", "Refurbished Devices"],
          "Home Appliances": ["Smart TVs", "Air Conditioners", "Refrigerators", "Microwaves"],
        }
      }
    },
    "Service Sector": {
      "Technology": {
        "Software Development": {
          "Web Apps": ["Frontend Projects", "Backend APIs", "Fullstack Systems", "SaaS Platforms"],
          "Mobile Apps": ["Flutter Apps", "Native iOS Apps", "Native Android Apps", "Hybrid Apps"],
        },
        "IT Services": {
          "Cloud Infrastructure": ["AWS Services", "Google Cloud Projects", "Azure Management", "DevOps Pipelines"],
          "Cybersecurity": ["Penetration Testing", "Security Audits", "Identity Management"],
        }
      },
      "Healthcare": {
        "Medical Clinics": {
          "General Health": ["Consultation Services", "Diagnostic Tests", "Therapy Sessions"],
          "Pharmacy": ["Prescription Drugs", "OTC Medicines", "Health Supplements"],
        }
      }
    }
  };

  void _nextStep() {
    FocusScope.of(context).unfocus();
    bool isValid = false;
    if (_currentStep == 0) {
      if (_formKey1.currentState!.validate()) {
        if (_panBytes == null || _sigBytes == null) { _showError('Upload PAN and Signature'); return; }
        isValid = true;
      }
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        if (_gstBytes == null) { _showError('Upload GST certificate'); return; }
        isValid = true;
      }
    } else if (_currentStep == 2) {
      if (_formKey3.currentState!.validate()) {
        if (_bankDocBytes == null) { _showError('Upload bank document'); return; }
        isValid = true;
      }
    } else if (_currentStep == 3) {
      if (_formKey4.currentState!.validate()) isValid = true;
    } else if (_currentStep == 4) {
      if (_selectedTypes.isEmpty) { _showError('Select at least one business type'); return; }
      if (_yearCtrl.text.isEmpty) { _showError('Year of establishment is required'); return; }
      if (_employeeRange == null) { _showError('Select employee range'); return; }
      isValid = true;
    } else if (_currentStep == 5) {
      if (_selectedSectorTitle == null) { _showError('Sector Title is required'); return; }
      if (_selectedSector == null) { _showError('Sector is required'); return; }
      if (_selectedSubSector == null) { _showError('Sub Sector is required'); return; }
      if (_selectedSubCategories.isEmpty) { _showError('Select at least one category'); return; }
      _handleSubmit();
      return;
    }
    if (isValid) setState(() => _currentStep++);
  }

  void _prevStep() { if (_currentStep > 0) setState(() => _currentStep--); else Navigator.pop(context); }
  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red[700]));

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    try {
      setState(() => _isLoading = true);

      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // SAFE 10-DIGIT ID GENERATION
      final random = Random();
      String generatedId = '';
      for (int i = 0; i < 10; i++) {
        generatedId += random.nextInt(10).toString();
      }

      final business = BusinessUser(
        id: generatedId,
        registrationType: "Propagator",
        businessName: _nameCtrl.text,
        email: _emailCtrl.text,
        phone: _phoneCtrl.text,
        website: _websiteCtrl.text.isNotEmpty ? _websiteCtrl.text : null,
        panNumber: _panCtrl.text,
        panFileName: _panFileName,
        panFileBytes: _panBytes,
        signatureFileName: _sigFileName,
        signatureFileBytes: _sigBytes,
        gstNumber: _gstCtrl.text,
        gstFileName: _gstFileName,
        gstFileBytes: _gstBytes,
        accountNumber: _accNumberCtrl.text,
        ifscCode: _ifscCtrl.text,
        bankName: _bankNameCtrl.text,
        accountHolderName: _holderNameCtrl.text,
        bankDocType: _bankDocType,
        bankDocFileName: _bankDocFileName,
        bankDocFileBytes: _bankDocBytes,
        doorNumber: _doorCtrl.text,
        streetName: _streetCtrl.text,
        buildingName: _buildingCtrl.text.isNotEmpty ? _buildingCtrl.text : null,
        landmark: _landmarkCtrl.text.isNotEmpty ? _landmarkCtrl.text : null,
        area: _areaCtrl.text,
        district: _districtCtrl.text,
        pincode: _pincodeCtrl.text,
        state: _stateCtrl.text,
        country: _countryCtrl.text,
        businessTypes: _selectedTypes.toList(),
        yearOfEstablishment: _yearCtrl.text,
        employeeRange: _employeeRange!,
        partnerCount: 0,
        createdDate: DateTime.now(),
        status: 'Active',
        sectorTitle: _selectedSectorTitle,
        sector: _selectedSector,
        subSector: _selectedSubSector,
        categories: _selectedSubCategories.toList(),
      );

      BusinessUserStore().addBusiness(business);

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'pdf'], withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final f = result.files.first;
        if (type == 'pan') { _panFileName = f.name; _panBytes = f.bytes; }
        else if (type == 'sig') { _sigFileName = f.name; _sigBytes = f.bytes; }
        else if (type == 'gst') { _gstFileName = f.name; _gstBytes = f.bytes; }
        else if (type == 'bank') { _bankDocFileName = f.name; _bankDocBytes = f.bytes; }
      });
    }
  }

  void _autofillPincode(String pin) {
    if (pin == '642101') { _areaCtrl.text = 'Aliyar Nagar'; _districtCtrl.text = 'Coimbatore'; _stateCtrl.text = 'Tamil Nadu'; }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF8B5CF6);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isSuccess) return _buildSuccessPage(themeColor, isDark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 1,
        centerTitle: false,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF0F172A)), onPressed: _prevStep),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Create Propagator Business', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 16)), Text('Complete the steps below to register your business', style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontWeight: FontWeight.normal, fontSize: 11))]),
        actions: [IconButton(icon: Icon(Icons.close, color: isDark ? Colors.white : const Color(0xFF0F172A)), onPressed: () => Navigator.pop(context))],
      ),
      body: Stack(children: [Column(children: [_buildStepperHeader(themeColor, isDark), Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), child: Center(child: Container(constraints: const BoxConstraints(maxWidth: 600), child: _buildCurrentStep(themeColor, isDark))))), _buildControlButtons(themeColor, isDark)]), if (_isLoading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator(color: themeColor, strokeWidth: 5)))]),
    );
  }

  Widget _buildStepperHeader(Color color, bool isDark) {
    final labels = ['Basic Details', 'GST Details', 'Bank Details', 'Address', 'Type', 'Categories'];
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white, padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) => Expanded(child: Row(children: [Column(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: i < _currentStep ? Colors.green : (i == _currentStep ? color : (isDark ? Colors.white10 : const Color(0xFFE2E8F0))), shape: BoxShape.circle), child: Center(child: i < _currentStep ? const Icon(Icons.check, color: Colors.white, size: 18) : Text('${i + 1}', style: TextStyle(color: i == _currentStep ? Colors.white : const Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 13)))), const SizedBox(height: 6), Text(labels[i], style: TextStyle(fontSize: 8, fontWeight: i == _currentStep ? FontWeight.w800 : FontWeight.w600, color: i == _currentStep ? color : const Color(0xFF94A3B8)))]), if (i < 5) Expanded(child: Container(height: 2, color: i < _currentStep ? Colors.green : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)), margin: const EdgeInsets.only(bottom: 18)))])))),
    );
  }

  Widget _buildControlButtons(Color color, bool isDark) {
    return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!))), child: Row(children: [Expanded(child: OutlinedButton(onPressed: _prevStep, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: isDark ? Colors.white24 : Colors.grey[300]!)), child: Text('Previous', style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF4338CA))))), const SizedBox(width: 16), Expanded(child: ElevatedButton(onPressed: _nextStep, style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), child: Text(_currentStep == 5 ? 'Create Business' : 'Next', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white))))]));
  }

  Widget _buildCurrentStep(Color color, bool isDark) {
    switch (_currentStep) {
      case 0: return _buildStep1(isDark);
      case 1: return _buildStep2(isDark);
      case 2: return _buildStep3(isDark);
      case 3: return _buildStep4(color, isDark);
      case 4: return _buildStep5(color, isDark);
      case 5: return _buildStep6(color, isDark);
      default: return const SizedBox();
    }
  }

  Widget _buildStep1(bool isDark) => Form(key: _formKey1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeading('Basic Details', 'Organisation information', isDark), _buildFormCard([_buildInputField('Business Name *', _nameCtrl, isDark), _buildInputField('Email *', _emailCtrl, isDark), _buildInputField('Phone *', _phoneCtrl, isDark, keyboardType: TextInputType.phone), _buildInputField('Website', _websiteCtrl, isDark), const Divider(height: 48), Text('PAN Details', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 16), _buildInputField('PAN Number *', _panCtrl, isDark), _buildFileUpload('PAN Photo *', _panFileName, _panBytes, () => _pickFile('pan'), isDark), const SizedBox(height: 24), Text('Authorized Signature', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black)), const SizedBox(height: 16), _buildFileUpload('Signature Photo *', _sigFileName, _sigBytes, () => _pickFile('sig'), isDark)])]));
  
  Widget _buildStep2(bool isDark) => Form(key: _formKey2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeading('GST Details', 'Verify registration', isDark), _buildFormCard([_buildInputField('GST Number *', _gstCtrl, isDark), _buildFileUpload('GST Certificate *', _gstFileName, _gstBytes, () => _pickFile('gst'), isDark)])]));
  
  Widget _buildStep3(bool isDark) => Form(key: _formKey3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeading('Bank Details', 'Current account info', isDark), _buildFormCard([_buildInputField('Account Number *', _accNumberCtrl, isDark), _buildInputField('Confirm Number *', _confirmAccNumberCtrl, isDark), _buildInputField('IFSC Code *', _ifscCtrl, isDark), _buildInputField('Bank Name *', _bankNameCtrl, isDark), _buildInputField('Holder Name *', _holderNameCtrl, isDark), const SizedBox(height: 16), Text('Document Type *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : Colors.black)), Row(children: [_buildRadioOption('Bank Statement', isDark), const SizedBox(width: 16), _buildRadioOption('Canceled Cheque Leaf', isDark)]), const SizedBox(height: 16), _buildFileUpload('Upload $_bankDocType *', _bankDocFileName, _bankDocBytes, () => _pickFile('bank'), isDark)])]));
  
  Widget _buildStep4(Color color, bool isDark) => Form(key: _formKey4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeading('Address', 'Headquarters location', isDark), _buildFormCard([Row(children: [Expanded(child: _buildInputField('Door *', _doorCtrl, isDark)), const SizedBox(width: 16), Expanded(child: _buildInputField('Street *', _streetCtrl, isDark))]), const SizedBox(height: 16), _buildInputField('Building', _buildingCtrl, isDark), const SizedBox(height: 16), _buildInputField('Landmark', _landmarkCtrl, isDark), const SizedBox(height: 20), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.05), border: Border.all(color: color.withOpacity(0.1)), borderRadius: BorderRadius.circular(14)), child: Row(children: [Expanded(child: _buildInputField('Pincode *', _pincodeCtrl, isDark, showPadding: false)), const SizedBox(width: 12), ElevatedButton(onPressed: () => _autofillPincode(_pincodeCtrl.text), style: ElevatedButton.styleFrom(backgroundColor: color), child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))])), const SizedBox(height: 20), _buildInputField('Area *', _areaCtrl, isDark), Row(children: [Expanded(child: _buildInputField('District *', _districtCtrl, isDark)), const SizedBox(width: 16), Expanded(child: _buildInputField('State *', _stateCtrl, isDark))])])]));
  
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
        _buildHeading('Business Type', 'Configure business classification', isDark),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemCount: localOptions.length,
          itemBuilder: (context, i) {
            final type = localOptions[i];
            bool isSelected = _selectedTypes.contains(type['label']);
            return InkWell(
              onTap: () => setState(() => isSelected ? _selectedTypes.remove(type['label']) : _selectedTypes.add(type['label'])),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? color : (isDark ? Colors.white12 : const Color(0xFF6366F1).withOpacity(0.08)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? color : (isDark ? Colors.white10 : Colors.grey[200]!)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(type['icon'], size: 18, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                      const SizedBox(width: 12),
                      Text(
                        type['label'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ],
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
        Text('Number of Employees *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1E293B))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          value: _employeeRange,
          items: ['1-10', '11-50', '51-100', '101-500', '500+']
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black))))
              .toList(),
          onChanged: (v) => setState(() => _employeeRange = v),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep6(Color color, bool isDark) {
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
        _buildHeading('Categories', 'Select business sectors & categories', isDark),
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
          Text('Select Categories *', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1E293B))),
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
            Text('Selected Categories:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: isDark ? Colors.white70 : Colors.black54)),
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

  Widget _buildRadioOption(String label, bool isDark) { bool isSelected = _bankDocType == label; return GestureDetector(onTap: () => setState(() => _bankDocType = label), child: Row(children: [Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.white30 : const Color(0xFFCBD5E1)), width: isSelected ? 5 : 1.5))), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500, color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.white60 : const Color(0xFF64748B))))])); }
  Widget _buildHeading(String title, String subtitle, bool isDark) => Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A))), const SizedBox(height: 6), Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF64748B), fontWeight: FontWeight.w500))]));
  Widget _buildFormCard(List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  Widget _buildInputField(String label, TextEditingController ctrl, bool isDark, {TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters, String? Function(String?)? validator, bool readOnly = false, bool showPadding = true}) {
    final isPan = label.toLowerCase().contains('pan') || ctrl == _panCtrl;
    final isPhone = label.toLowerCase().contains('phone') || label.toLowerCase().contains('mobile') || ctrl == _phoneCtrl;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: showPadding ? 20 : 0,
      ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF334155))), const SizedBox(height: 8), TextFormField(controller: ctrl, keyboardType: isPhone ? TextInputType.number : keyboardType, inputFormatters: isPan ? [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(10)] : isPhone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)] : inputFormatters, validator: validator, readOnly: readOnly, textCapitalization: isPan ? TextCapitalization.characters : TextCapitalization.none, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(filled: true, fillColor: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9).withOpacity(0.5), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[300]!)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!))))]));
  }
  Widget _buildFileUpload(String label, String? name, Uint8List? bytes, VoidCallback onTap, bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: isDark ? Colors.white70 : Colors.black)), const SizedBox(height: 8), InkWell(onTap: onTap, child: Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)), child: bytes != null ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8), Text(name!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))])) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.cloud_upload_outlined, color: Color(0xFF8B5CF6)), Text('Upload Document', style: TextStyle(color: const Color(0xFF8B5CF6), fontSize: 13, fontWeight: FontWeight.bold))])) )]);

  Widget _buildSuccessPage(Color color, bool isDark) => Scaffold(backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white, body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80), const SizedBox(height: 32), Text('Business Created Successfully!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0F172A))), const SizedBox(height: 16), Text('Your propagator business has been registered and is ready to use.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF64748B), fontSize: 14)), const SizedBox(height: 48), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() { _isSuccess = false; _currentStep = 0; _resetControllers(); }), style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Add Another', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFF4338CA))), child: Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF4338CA)))))]))));

  void _resetControllers() {
    _nameCtrl.clear(); _emailCtrl.clear(); _phoneCtrl.clear(); _websiteCtrl.clear(); _panCtrl.clear(); _gstCtrl.clear(); _accNumberCtrl.clear(); _confirmAccNumberCtrl.clear(); _ifscCtrl.clear(); _bankNameCtrl.clear(); _holderNameCtrl.clear(); _doorCtrl.clear(); _streetCtrl.clear(); _buildingCtrl.clear(); _landmarkCtrl.clear(); _areaCtrl.clear(); _districtCtrl.clear(); _pincodeCtrl.clear(); _stateCtrl.clear(); _yearCtrl.clear(); _panBytes = null; _sigBytes = null; _gstBytes = null; _bankDocBytes = null; _selectedTypes.clear(); _employeeRange = null;
    _selectedSectorTitle = null; _selectedSector = null; _selectedSubSector = null; _activePrimaryCategory = null; _selectedSubCategories.clear();
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
