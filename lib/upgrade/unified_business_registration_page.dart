import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_dashboard_app_bar.dart';
import '../widgets/business_sidebar_menu.dart';
import '../features/upgrade/add_business_welcome_widget.dart';
import '../features/store/store_configuration_widget.dart';
import '../features/store/create_store_page.dart';
import '../user_service.dart';
import 'posted_jobs_page.dart';
import 'post_job_page.dart';
import 'applied_list_page.dart';
import 'assign_candidate_page.dart';

import 'business_user_model.dart';
import 'create_business_user_page.dart';
import 'create_partner_business_page.dart';
import 'create_supplier_business_page.dart';

class UnifiedBusinessRegistrationPage extends StatefulWidget {
  final BusinessUser? existingBusiness;
  const UnifiedBusinessRegistrationPage({super.key, this.existingBusiness});

  @override
  State<UnifiedBusinessRegistrationPage> createState() =>
      _UnifiedBusinessRegistrationPageState();
}

class _UnifiedBusinessRegistrationPageState
    extends State<UnifiedBusinessRegistrationPage> {
  // Unified Registration State Variables
  int _mainStep = 0; // 0: Registered, 1: Verified, 2: Business

  // --- Registered User Variables ---
  final _panController = TextEditingController();
  String? selectedGender;
  String? profilePhotoName;
  String? panDocName;
  String? profilePhotoBase64;
  String? panDocBase64;

  // --- Verified User Variables ---
  String? selectedIdType;
  String? idDocName;
  String? idDocBase64;

  final _vAddressTypeController = TextEditingController();
  final _vPincodeController = TextEditingController();
  final _vDoorController = TextEditingController();
  final _vStreetController = TextEditingController();
  final _vBuildingController = TextEditingController();
  final _vLandmarkController = TextEditingController();
  final _vAreaController = TextEditingController();
  final _vCityController = TextEditingController();
  final _vDistrictController = TextEditingController();
  final _vStateController = TextEditingController();
  final _vCountryController = TextEditingController(text: 'India');

  String? vSelectedPropertyType;
  String? vSelectedDocumentType;
  String? vAddressProofFileName;
  String? vAddressProofBase64;

  Future<void> _pickUnifiedFile(
    Function(String?, String?) onPicked, {
    bool isImage = false,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final base64String = "data:image/png;base64,${base64Encode(bytes)}";
      onPicked(result.files.single.name, base64String);
    }
  }

  void _mainNextStep() async {
    if (_mainStep == 0) {
      if (selectedGender == null ||
          _panController.text.isEmpty ||
          profilePhotoBase64 == null ||
          panDocBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please fill all required fields for Registered User',
            ),
          ),
        );
        return;
      }
      setState(() => _mainStep++);
    } else if (_mainStep == 1) {
      if (selectedIdType == null ||
          idDocBase64 == null ||
          _vPincodeController.text.isEmpty ||
          vAddressProofBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please fill all required fields and upload proofs for Verified User',
            ),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final prefs = await SharedPreferences.getInstance();
        final userMainId = prefs.getString('user_main_id') ?? '';

        // Prepare verified user payload
        final payload = {
          "user_main_id": userMainId,
          "gender": selectedGender,
          "address_proof": {
            "proof_type": vSelectedDocumentType ?? "Aadhaar",
            "proof_document": vAddressProofBase64,
          },
          "pan_number": _panController.text.trim(),
          "government_id_type": selectedIdType,
          "pan_document": panDocBase64,
          "government_id_document": idDocBase64,
          "profile_photo": profilePhotoBase64,
          "addresses": [
            {
              "address_type": _vAddressTypeController.text.isEmpty
                  ? "Permanent"
                  : _vAddressTypeController.text.trim(),
              "property_type": vSelectedPropertyType ?? "Independent House",
              "pincode": _vPincodeController.text.trim(),
              "house_no": _vDoorController.text.trim(),
              "building_name": _vBuildingController.text.trim(),
              "street_name": _vStreetController.text.trim(),
              "area": _vAreaController.text.trim(),
              "landmark": _vLandmarkController.text.trim(),
              "city": _vCityController.text.trim(),
              "district": _vDistrictController.text.trim(),
              "state": _vStateController.text.trim(),
              "country": _vCountryController.text.trim(),
            },
          ],
        };

        await UserService().submitVerifiedRegistration(payload);

        setState(() {
          _mainStep++;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving verified details: $e')),
        );
      }
    }
  }

  void _mainPrevStep() {
    if (_mainStep > 0) {
      setState(() => _mainStep--);
    } else {
      Navigator.pop(context);
    }
  }

  int _currentStep = 0;
  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();

  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _pinCodeCtrl = TextEditingController();

  String _selectedBankDocType = 'Passbook / Bank Statement';
  Uint8List? _bankDocBytes;

  String _selectedAddressDocType = 'Select document type';
  Uint8List? _addressDocBytes;

  String _selectedAddressType = '-- Select Address Type --';

  Map<String, dynamic>? _verifiedUserDetails;

  @override
  void initState() {
    super.initState();
    _loadVerifiedUserDetails();
    if (widget.existingBusiness != null) {
      final biz = widget.existingBusiness!;
      _accNumberCtrl.text = biz.accountNumber;
      _confirmAccNumberCtrl.text = biz.accountNumber;
      _doorCtrl.text = biz.doorNumber;
      _streetCtrl.text = biz.streetName;
      _buildingCtrl.text = biz.buildingName ?? '';
      _landmarkCtrl.text = biz.landmark ?? '';
      _areaCtrl.text = biz.area;
      _districtCtrl.text = biz.district;
      _stateCtrl.text = biz.state;
      _pinCodeCtrl.text = biz.pincode;

      if (biz.bankDocType.toLowerCase() == 'cheque') {
        _selectedBankDocType = 'Cancelled Cheque';
      } else {
        _selectedBankDocType = 'Passbook / Bank Statement';
      }

      if (biz.addressDocType != null && biz.addressDocType!.isNotEmpty) {
        switch (biz.addressDocType!.toLowerCase()) {
          case 'aadhar':
            _selectedAddressDocType = 'Aadhar Card';
            break;
          case 'passport':
            _selectedAddressDocType = 'Passport';
            break;
          case 'voter':
            _selectedAddressDocType = 'Voter ID';
            break;
          case 'driving':
            _selectedAddressDocType = 'Driving License';
            break;
          case 'utility':
            _selectedAddressDocType = 'Utility Bill';
            break;
          default:
            _selectedAddressDocType = 'Select document type';
            break;
        }
      }

      if (biz.addressType != null && biz.addressType!.isNotEmpty) {
        switch (biz.addressType!.toLowerCase()) {
          case 'factory':
            _selectedAddressType = 'Factory';
            break;
          case 'warehouse':
            _selectedAddressType = 'Warehouse / Godown';
            break;
          case 'office':
            _selectedAddressType = 'Office';
            break;
          case 'other':
            _selectedAddressType = 'Other';
            break;
        }
      }
    }
  }

  Future<void> _loadVerifiedUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userMainId = prefs.getString('user_main_id') ?? '';
    if (userMainId.isEmpty) return;

    final url =
        'https://managelogin.jobes24x7.com/api/api/verified-user/$userMainId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final data = decoded['data'] as Map<String, dynamic>;
          final verification = data['verification'] as Map<String, dynamic>?;
          if (verification != null && mounted) {
            setState(() {
              _verifiedUserDetails = verification;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting verification details: $e');
    }
  }

  bool _isLoading = false;

  bool _isConfirmed = false;

  String _activeItem = 'business_overview';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _pickImage(bool isBankDoc) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (isBankDoc) {
          _bankDocBytes = bytes;
        } else {
          _addressDocBytes = bytes;
        }
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (_accNumberCtrl.text.isEmpty ||
        _doorCtrl.text.isEmpty ||
        _streetCtrl.text.isEmpty ||
        _areaCtrl.text.isEmpty ||
        _districtCtrl.text.isEmpty ||
        _stateCtrl.text.isEmpty ||
        _pinCodeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (_selectedAddressType == '-- Select Address Type --') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an Address Type")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userMainId = prefs.getString('user_main_id') ?? '';

      String? bankDocBase64;
      if (_bankDocBytes != null) {
        bankDocBase64 =
            "data:image/jpeg;base64," + base64Encode(_bankDocBytes!);
      }

      String? addressDocBase64;
      if (_addressDocBytes != null) {
        addressDocBase64 =
            "data:image/jpeg;base64," + base64Encode(_addressDocBytes!);
      }

      String addressDocTypeMapped = '';
      switch (_selectedAddressDocType) {
        case 'Aadhar Card':
          addressDocTypeMapped = 'aadhar';
          break;
        case 'Passport':
          addressDocTypeMapped = 'passport';
          break;
        case 'Voter ID':
          addressDocTypeMapped = 'voter';
          break;
        case 'Driving License':
          addressDocTypeMapped = 'driving';
          break;
        case 'Utility Bill':
          addressDocTypeMapped = 'utility';
          break;
        default:
          addressDocTypeMapped = '';
          break;
      }

      String bankDocToSend = bankDocBase64 ?? '';
      if (bankDocBase64 == null &&
          widget.existingBusiness?.bankDocFileName != null) {
        bankDocToSend = widget.existingBusiness!.bankDocFileName!;
      }

      String addressDocToSend = addressDocBase64 ?? '';
      if (addressDocBase64 == null &&
          widget.existingBusiness?.addressDocFileName != null) {
        addressDocToSend = widget.existingBusiness!.addressDocFileName!;
      }

      String mappedAddressType = '';
      if (_selectedAddressType == 'Factory')
        mappedAddressType = 'factory';
      else if (_selectedAddressType == 'Warehouse / Godown')
        mappedAddressType = 'warehouse';
      else if (_selectedAddressType == 'Office')
        mappedAddressType = 'office';
      else if (_selectedAddressType == 'Other')
        mappedAddressType = 'other';

      final payload = {
        "user_main_id": userMainId,
        "bank_account_number": _accNumberCtrl.text.trim(),
        "bank_document_type":
            _selectedBankDocType == 'Passbook / Bank Statement'
            ? 'passbook'
            : 'cheque',
        "bank_document": bankDocToSend,
        "address_doc_type": addressDocTypeMapped,
        "address_proof": addressDocToSend,
        "address_type": mappedAddressType,
        "selected_address_type": _selectedAddressType,
        "customer_address_type": _selectedAddressType,
        "door_number": _doorCtrl.text.trim(),
        "street_name": _streetCtrl.text.trim(),
        "street": _streetCtrl.text.trim(),
        "building_name": _buildingCtrl.text.trim(),
        "landmark": _landmarkCtrl.text.trim(),
        "area": _areaCtrl.text.trim(),
        "district": _districtCtrl.text.trim(),
        "pincode": _pinCodeCtrl.text.trim(),
        "state": _stateCtrl.text.trim(),
        "country": _countryCtrl.text.trim(),
        "factory_name": _selectedAddressType == 'Factory'
            ? _buildingCtrl.text.trim()
            : "",
        "unit_no": _doorCtrl.text.trim(),
        "plat_no": "",
        "indus_estate": _areaCtrl.text.trim(),
        "warehouse_name": _selectedAddressType == 'Warehouse / Godown'
            ? _buildingCtrl.text.trim()
            : "",
        "warehouse_no": "",
        "plot_no": "",
        "block": "",
        "office_name": _selectedAddressType == 'Office'
            ? _buildingCtrl.text.trim()
            : "",
        "office_num": "",
        "bloack_wing": "",
        "floor": "",
      };

      bool isEdit = widget.existingBusiness != null;
      String url = isEdit
          ? 'https://managelogin.jobes24x7.com/api/business-reg/update/${widget.existingBusiness!.actualId ?? widget.existingBusiness!.id}'
          : 'https://managelogin.jobes24x7.com/api/business-reg/create';

      final response = isEdit
          ? await http.put(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
          : await http.post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            );

      debugPrint("=== API REQUEST: ${isEdit ? 'PUT' : 'POST'} $url ===");
      // debugPrint("Payload: ${jsonEncode(payload)}"); // Don't print full payload because base64 is huge
      debugPrint("=== API RESPONSE [${response.statusCode}] ===");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh all user state APIs as requested
        try {
          // 1. Refresh Login User
          await http.get(
            Uri.parse(
              'https://managelogin.jobes24x7.com/api/login/$userMainId',
            ),
          );

          // 2. Refresh Business Registration User
          await http.get(
            Uri.parse(
              'https://managelogin.jobes24x7.com/api/business-reg/user/$userMainId',
            ),
          );

          // 3. Refresh User Register Main
          await http.get(
            Uri.parse(
              'https://managelogin.jobes24x7.com/api/user_register/main/$userMainId',
            ),
          );

          // 4. Refresh Verified User (Note the /api/api/ path as provided)
          await http.get(
            Uri.parse(
              'https://managelogin.jobes24x7.com/api/api/verified-user/$userMainId',
            ),
          );
        } catch (e) {
          debugPrint("Error fetching refresh APIs: $e");
        }

        // Also update shared preferences that business is registered locally
        await prefs.setBool('is_main_business_registered', true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration Submitted Successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Pop with success true
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to register business. Error: ${response.statusCode}",
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
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

  void _onSectionChanged(String newItem) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }

    if (newItem == 'post_job') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PostJobPage()));
      return;
    } else if (newItem == 'view_posted_jobs') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PostedJobsPage()),
      );
      return;
    } else if (newItem == 'applied_candidates') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AppliedListPage(isBusinessMode: true),
        ),
      );
      return;
    } else if (newItem == 'assign_candidate') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AssignCandidatePage()),
      );
      return;
    }

    setState(() {
      _activeItem = newItem;
    });
  }

  @override
  void dispose() {
    _accNumberCtrl.dispose();
    _confirmAccNumberCtrl.dispose();
    _doorCtrl.dispose();
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _landmarkCtrl.dispose();
    _areaCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pinCodeCtrl.dispose();
    super.dispose();
  }

  Widget _buildMainStepper() {
    final steps = ['Registered User', 'Verified User', 'Business User'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 != 0) {
          return Expanded(
            child: Container(height: 2, color: const Color(0xFFE2E8F0)),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex == _mainStep;
        final isCompleted = stepIndex < _mainStep;

        return Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive || isCompleted
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        "${stepIndex + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              steps[stepIndex],
              style: TextStyle(
                color: isActive || isCompleted
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildUnifiedForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildMainStepper(),
              const SizedBox(height: 32),
              _mainStep == 0
                  ? _buildRegisteredUserStep()
                  : _mainStep == 1
                  ? _buildVerifiedUserStep()
                  : _buildRegistrationForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredUserStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 1: Registered User Account Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Provide your basic identification and PAN card properties to register.",
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "PAN Number *",
                  "Enter PAN Number",
                  _panController,
                  isUpperCase: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  "Gender *",
                  "Select Gender",
                  ["Male", "Female", "Other"],
                  selectedGender,
                  (v) => setState(() => selectedGender = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFilePicker(
                  "PAN Card Photo (Front) *",
                  panDocName,
                  () => _pickUnifiedFile(
                    (name, base64) => setState(() {
                      panDocName = name;
                      panDocBase64 = base64;
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildFilePicker(
                  "Profile Photo *",
                  profilePhotoName,
                  () => _pickUnifiedFile(
                    (name, base64) => setState(() {
                      profilePhotoName = name;
                      profilePhotoBase64 = base64;
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _mainPrevStep,
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _mainNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                ),
                child: const Text(
                  "Next →",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedUserStep() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Step 2: Verified User Credentials & Address",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your address proofs and government-issued ID card scans.",
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Select ID Type *",
                  "Select ID",
                  [
                    "Aadhaar Card",
                    "Passport",
                    "Driving Licence",
                    "Voter ID Card",
                  ],
                  selectedIdType,
                  (v) => setState(() => selectedIdType = v),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildFilePicker(
                  "Upload ID Document *",
                  idDocName,
                  () => _pickUnifiedFile(
                    (name, base64) => setState(() {
                      idDocName = name;
                      idDocBase64 = base64;
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Add Your Address Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Address Type *",
                  "e.g. Permanent, Rental",
                  _vAddressTypeController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  "Property Type *",
                  "Select Property Type",
                  [
                    "Independent House",
                    "Apartment / Flat",
                    "Row House",
                    "PG (Paying Guest)",
                    "Other",
                  ],
                  vSelectedPropertyType,
                  (v) => setState(() => vSelectedPropertyType = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Pincode *",
                  "Pincode",
                  _vPincodeController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "House No. *",
                  "e.g. 12A",
                  _vDoorController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Building Name",
                  "e.g. Skyline Apts",
                  _vBuildingController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Street/Road *",
                  "Street name",
                  _vStreetController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Area/Locality *",
                  "e.g. Downtown",
                  _vAreaController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  "Landmark (Optional)",
                  "e.g. Near Park",
                  _vLandmarkController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField("City *", "City", _vCityController),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "District *",
                  "District",
                  _vDistrictController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField("State *", "State", _vStateController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField("Country", "India", _vCountryController),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Upload Address Proof Document",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Select Proof Type *",
                  "Select Proof",
                  [
                    "Passport",
                    "Driving Licence",
                    "Electricity Bill",
                    "Water Bill",
                    "Gas Connection Bill",
                    "Rental Agreement (if accepted)",
                    "Property Tax Receipt",
                  ],
                  vSelectedDocumentType,
                  (v) => setState(() => vSelectedDocumentType = v),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildFilePicker(
                  "Upload Document *",
                  vAddressProofFileName,
                  () => _pickUnifiedFile(
                    (name, base64) => setState(() {
                      vAddressProofFileName = name;
                      vAddressProofBase64 = base64;
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _mainPrevStep,
                child: const Text("← Back"),
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _mainNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                      child: const Text(
                        "Next →",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                hint,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
              value: value,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B),
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isUpperCase = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            textCapitalization: isUpperCase
                ? TextCapitalization.characters
                : TextCapitalization.none,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePicker(String label, String? fileName, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onTap,
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: const Center(
                    child: Text(
                      "Choose File",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    fileName ?? "No file chosen",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: fileName != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Uploaded: $fileName",
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    final bool isRequired = label.endsWith("*");
    final String labelText = isRequired
        ? label.substring(0, label.length - 1).trim()
        : label;
    return RichText(
      text: TextSpan(
        text: labelText,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFEF4444)),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStepper(),
              const SizedBox(height: 32),
              _buildCurrentStepContent(),
              const SizedBox(height: 32),
              _buildFooterButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_activeItem == 'add_business') {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: AddBusinessWelcomeWidget(
              onRegistrationTypeSelected: (String type) {
                if (type == 'Propagator') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateBusinessUserPage(),
                    ),
                  );
                } else if (type == 'Partner') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePartnerBusinessPage(),
                    ),
                  );
                } else if (type == 'Create Supplier') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateSupplierBusinessPage(),
                    ),
                  );
                } else {
                  setState(() {
                    _activeItem = 'business_overview';
                  });
                }
              },
            ),
          ),
        ),
      );
    } else if (_activeItem == 'create_store_category') {
      return StoreConfigurationWidget(onContinue: () {});
    } else if (_activeItem == 'create_store') {
      return const CreateStorePage();
    } else {
      return _buildUnifiedForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      drawer: isMobile
          ? Drawer(
              child: BusinessSidebarMenu(
                activeItem: _activeItem,
                onSectionChanged: _onSectionChanged,
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(
              width: 250,
              child: BusinessSidebarMenu(
                activeItem: _activeItem,
                onSectionChanged: _onSectionChanged,
              ),
            ),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.badge_outlined,
            color: Color(0xFF2563EB),
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Business Register!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(width: 8),
            Text("🏢", style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Complete your business user registration profile",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    final steps = ['Account', 'Document', 'Address', 'Preview'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 != 0) {
          // Divider
          return Expanded(
            child: Container(height: 2, color: const Color(0xFFE2E8F0)),
          );
        }
        final stepIndex = index ~/ 2;
        final isActive = stepIndex == _currentStep;
        final isCompleted = stepIndex < _currentStep;

        return Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive || isCompleted
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        "${stepIndex + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              steps[stepIndex],
              style: TextStyle(
                color: isActive || isCompleted
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAccountStep();
      case 1:
        return _buildDocumentStep();
      case 2:
        return _buildAddressStep();
      case 3:
        return _buildPreviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAccountStep() {
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
          // Bank Account Number Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BANK ACCOUNT NUMBER",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Enter your bank account details",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Number
          const Text(
            "Account Number *",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _accNumberCtrl,
            decoration: _inputDecoration("Enter your bank account number"),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Enter the account number as shown in your passbook",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Confirm Account Number
          const Text(
            "Confirm Account Number",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmAccNumberCtrl,
            decoration: _inputDecoration("Re-enter account number"),
          ),
          const SizedBox(height: 16),

          // Warning Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Double-check your account number for accuracy",
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStep() {
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BANK DOCUMENT UPLOAD",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Provide bank passbook or cancelled cheque proof",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Document Type Radios
          const Text(
            "Document Type",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildRadioOption("Passbook / Bank Statement"),
              _buildRadioOption("Canceled Cheque Leaf"),
            ],
          ),
          const SizedBox(height: 24),

          // Upload Box
          Row(
            children: [
              Text(
                _selectedBankDocType,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text(
                " *",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildUploadBox(bytes: _bankDocBytes, onTap: () => _pickImage(true)),
          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF14B8A6), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Ensure account number is clearly visible in the document",
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedBankDocType = value;
          _bankDocBytes = null; // Clear on change
        });
      },
      child: Row(
        children: [
          Icon(
            _selectedBankDocType == value
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: _selectedBankDocType == value
                ? const Color(0xFF2563EB)
                : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    final addressTypes = [
      'Select document type',
      'Aadhar Card',
      'Passport',
      'Voter ID',
      'Driving License',
      'Utility Bill',
    ];

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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ADDRESS PROOF & DETAILS",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Provide address proof and your business location details",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Document Type Dropdown
          const Text(
            "Document Type",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedAddressDocType,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                items: addressTypes.map((String type) {
                  bool isSelected = _selectedAddressDocType == type;
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Container(
                      width: double.infinity,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedAddressDocType = val;
                      _addressDocBytes = null; // Clear on change
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upload Box
          const Row(
            children: [
              Text(
                "Upload Document ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "*",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildUploadBox(
            bytes: _addressDocBytes,
            onTap: () => _pickImage(false),
            isAddress: true,
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),

          // Address Details Header
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                "Address Details",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Address Form Fields
          _buildResponsiveGrid(context, [
            _buildRegistrationDropdownField("Address Type", "-- Select Address Type --", [
              '-- Select Address Type --',
              'Factory',
              'Warehouse / Godown',
              'Office',
              'Other (Custom Address Type)',
            ]),
            _buildRegistrationTextField(
              "Door Number",
              "Door Number",
              required: true,
              controller: _doorCtrl,
            ),
            _buildRegistrationTextField(
              "Street Name",
              "Street Name",
              required: true,
              controller: _streetCtrl,
            ),
          ]),
          const SizedBox(height: 16),
          _buildResponsiveGrid(context, [
            _buildRegistrationTextField(
              "Building Name",
              "Building Name",
              controller: _buildingCtrl,
            ),
            _buildRegistrationTextField(
              "Landmark (Optional)",
              "Landmark (Optional)",
              controller: _landmarkCtrl,
            ),
            const SizedBox(),
          ]),
          const SizedBox(height: 32),

          // Location & Regional Details
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                "Location & Regional Details",
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildResponsiveGrid(context, [
            _buildRegistrationTextField(
              "Area / Locality",
              "Enter Area / Locality",
              required: true,
              controller: _areaCtrl,
            ),
            _buildRegistrationTextField("City", "Enter City", controller: _cityCtrl),
            _buildRegistrationTextField(
              "District",
              "District",
              required: true,
              controller: _districtCtrl,
            ),
          ]),
          const SizedBox(height: 16),
          _buildResponsiveGrid(context, [
            _buildPinCodeField(),
            _buildRegistrationTextField(
              "State",
              "State",
              required: true,
              controller: _stateCtrl,
            ),
            _buildRegistrationTextField(
              "Country",
              "India",
              required: true,
              controller: _countryCtrl,
            ),
          ]),
          const SizedBox(height: 24),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFF14B8A6), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Address should match with your address proof document",
                    style: TextStyle(
                      color: Color(0xFF0F766E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, List<Widget> children) {
    if (MediaQuery.of(context).size.width < 768) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 16), child: c),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: c == children.last ? 0 : 16),
            child: c,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegistrationTextField(
    String label,
    String hint, {
    bool required = false,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
            if (required)
              const Text(
                " *",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildRegistrationDropdownField(String label, String hint, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedAddressType,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items.map((String type) {
                bool isSelected = _selectedAddressType == type;
                return DropdownMenuItem<String>(
                  value: type,
                  child: Container(
                    width: double.infinity,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedAddressType = val;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "PIN Code",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
            const Text(" *", style: TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pinCodeCtrl,
                decoration: _inputDecoration("6-digit PIN Code"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search, size: 18),
              label: const Text("Search"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Click Search or press Enter to auto-fill area,\ncity & state",
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildUploadBox({
    required Uint8List? bytes,
    required VoidCallback onTap,
    bool isAddress = false,
  }) {
    if (bytes != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Image.memory(bytes, height: 120, fit: BoxFit.contain),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
              label: const Text(
                "Change",
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(Icons.save_as_outlined, color: Colors.grey[700], size: 36),
            const SizedBox(height: 12),
            Text(
              isAddress
                  ? "Click to upload address proof"
                  : "Click to upload document",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "JPG, PNG or PDF (max. 5MB)",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "REVIEW YOUR APPLICATION",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Verify all entered details before submission",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Verified User Details & Bank Details
        _buildResponsiveGrid(context, [
          _buildPreviewCard(
            title: "Verified User Details",
            icon: Icons.person_outline,
            children: [
              _buildPreviewRow(
                "Full Name:",
                _verifiedUserDetails?['name']?.toString() ?? "---",
              ),
              _buildPreviewRow(
                "Gender:",
                _verifiedUserDetails?['gender']?.toString() ?? "---",
              ),
              _buildPreviewRow(
                "PAN Number:",
                _verifiedUserDetails?['pan_number']?.toString() ?? "---",
                isLink: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profile Photo:",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Center(
                            child: Text(
                              _verifiedUserDetails?['profile_photo'] != null
                                  ? "Uploaded"
                                  : "Not uploaded",
                              style: TextStyle(
                                color:
                                    _verifiedUserDetails?['profile_photo'] !=
                                        null
                                    ? Colors.green
                                    : Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PAN Photo:",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Center(
                            child: Text(
                              _verifiedUserDetails?['pan_document'] != null
                                  ? "Uploaded"
                                  : "Not uploaded",
                              style: TextStyle(
                                color:
                                    _verifiedUserDetails?['pan_document'] !=
                                        null
                                    ? Colors.green
                                    : Colors.grey[400],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildPreviewCard(
            title: "Bank Details",
            icon: Icons.account_balance_outlined,
            children: [
              _buildPreviewRow(
                "Account:",
                _accNumberCtrl.text.isNotEmpty ? _accNumberCtrl.text : "---",
                isLink: true,
              ),
              const SizedBox(height: 16),
              _buildPreviewImage("Document:", _bankDocBytes, height: 150),
            ],
          ),
        ]),
        const SizedBox(height: 24),

        // Address Details & Documents
        _buildResponsiveGrid(context, [
          _buildPreviewCard(
            title: "Address Details",
            icon: Icons.location_on_outlined,
            children: [
              _buildPreviewRow(
                "Type:",
                _selectedAddressType == '-- Select Address Type --'
                    ? "---"
                    : _selectedAddressType,
              ),
              _buildPreviewRow(
                "Door No.:",
                _doorCtrl.text.isNotEmpty ? _doorCtrl.text : "---",
              ),
              _buildPreviewRow(
                "Street:",
                _streetCtrl.text.isNotEmpty ? _streetCtrl.text : "---",
              ),
              _buildPreviewRow(
                "Landmark:",
                _landmarkCtrl.text.isNotEmpty ? _landmarkCtrl.text : "---",
              ),
              _buildPreviewRow(
                "Area:",
                _areaCtrl.text.isNotEmpty ? _areaCtrl.text : "---",
              ),
              _buildPreviewRow(
                "City:",
                _cityCtrl.text.isNotEmpty ? _cityCtrl.text : "---",
              ),
              _buildPreviewRow(
                "District:",
                _districtCtrl.text.isNotEmpty ? _districtCtrl.text : "---",
              ),
              _buildPreviewRow(
                "Pincode:",
                _pinCodeCtrl.text.isNotEmpty ? _pinCodeCtrl.text : "---",
              ),
              _buildPreviewRow(
                "State:",
                _stateCtrl.text.isNotEmpty ? _stateCtrl.text : "---",
              ),
              _buildPreviewRow(
                "Country:",
                _countryCtrl.text.isNotEmpty ? _countryCtrl.text : "---",
              ),
            ],
          ),
          _buildPreviewCard(
            title: "Documents",
            icon: Icons.description_outlined,
            children: [
              _buildPreviewImage(
                "Address Proof:",
                _addressDocBytes,
                height: 200,
              ),
            ],
          ),
        ]),
        const SizedBox(height: 32),

        // Declaration Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: "Declaration: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "I hereby confirm that all the information provided is true and correct.",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Checkbox
        InkWell(
          onTap: () {
            setState(() {
              _isConfirmed = !_isConfirmed;
            });
          },
          child: Row(
            children: [
              Checkbox(
                value: _isConfirmed,
                onChanged: (val) {
                  setState(() {
                    _isConfirmed = val ?? false;
                  });
                },
                activeColor: const Color(0xFF2563EB),
              ),
              Expanded(
                child: const Text(
                  "I agree to the terms and conditions and confirm accuracy.",
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isLink ? const Color(0xFF2563EB) : Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImage(
    String label,
    Uint8List? bytes, {
    double height = 80,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: bytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(bytes, fit: BoxFit.cover),
                )
              : Center(
                  child: Text(
                    "Not uploaded",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _prevStep,
          child: Row(
            children: [
              if (_currentStep > 0)
                const Icon(Icons.arrow_back, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _currentStep == 0 ? "Cancel" : "Back",
                style: TextStyle(
                  color: _currentStep == 0
                      ? Colors.redAccent
                      : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _currentStep == 3
              ? (_isConfirmed && !_isLoading ? _submitRegistration : null)
              : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentStep == 3
                ? const Color(0xFF10B981) // Green for Submit
                : const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading) ...[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _isLoading
                    ? "Submitting..."
                    : (_currentStep == 3 ? "Submit Registration" : "Next"),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentStep == 3) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Colors.white, size: 18),
              ] else if (_currentStep < 3) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
