import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../user_service.dart';

class AddressesAndProofPage extends StatefulWidget {
  final String gender;
  final String panNumber;
  final String profilePhotoBase64;
  final String panDocBase64;
  final Map<String, dynamic>? initialData;

  const AddressesAndProofPage({
    super.key,
    required this.gender,
    required this.panNumber,
    required this.profilePhotoBase64,
    required this.panDocBase64,
    this.initialData,
  });

  @override
  State<AddressesAndProofPage> createState() => _AddressesAndProofPageState();
}

class _AddressesAndProofPageState extends State<AddressesAndProofPage> {
  final TextEditingController _addressTypeController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _doorController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(text: 'India');
  
  // Dynamic fields
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetRoadController = TextEditingController();
  final TextEditingController _areaLocalityController = TextEditingController();
  final TextEditingController _aptNameController = TextEditingController();
  final TextEditingController _towerBlockController = TextEditingController();
  final TextEditingController _flatNoController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _communityNameController = TextEditingController();
  final TextEditingController _blockController = TextEditingController();
  final TextEditingController _pgNameController = TextEditingController();
  final TextEditingController _roomNoController = TextEditingController();
  final TextEditingController _bedNoController = TextEditingController();
  final TextEditingController _blockWingController = TextEditingController();
  
  String? selectedPropertyType;
  bool isAddressAdded = false;
  bool isAddressSelected = false;
  String? selectedDocumentType;
  String? addressProofFileName;
  String? addressProofBase64;
  
  String? selectedIdType;
  String? idDocName;
  String? idDocBase64;

  bool _isLoading = false;
  bool _isFetchingPincode = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final addresses = widget.initialData!['addresses'] as List?;
      if (addresses != null && addresses.isNotEmpty) {
        final address = addresses.first;
        isAddressAdded = true;
        isAddressSelected = true;
        _pincodeController.text = address['pincode']?.toString() ?? '';
        
        final propType = address['property_type']?.toString();
        if (propType != null && [
          "Independent House", "Apartment / Flat", "Row House", "PG (Paying Guest)", "Other"
        ].contains(propType)) {
          selectedPropertyType = propType;
        }

        // We can optionally populate other fields if they are in the DB, 
        // but for now setting the minimum required fields is enough to pass validation
        _addressTypeController.text = address['address_type']?.toString() ?? '';
        _cityController.text = address['city']?.toString() ?? '';
        _stateController.text = address['state']?.toString() ?? '';
      }

      final addressProof = widget.initialData!['address_proof'] as Map<String, dynamic>?;
      if (addressProof != null) {
        final proofType = addressProof['proof_type']?.toString();
        if (proofType != null && [
          "Passport", "Driving Licence", "Electricity Bill", "Water Bill",
          "Gas Connection Bill", "Rental Agreement (if accepted)", "Property Tax Receipt"
        ].contains(proofType)) {
          selectedDocumentType = proofType;
        }
        
        final proofDoc = addressProof['proof_document']?.toString();
        if (proofDoc != null && proofDoc.isNotEmpty) {
          addressProofFileName = proofDoc.split('/').last;
        }
      }

      final initialIdType = widget.initialData!['government_id_type']?.toString();
      if (initialIdType != null && ["Aadhaar Card", "Passport", "Driving Licence", "Voter ID Card"].contains(initialIdType)) {
        selectedIdType = initialIdType;
      }
      
      final initialIdDocPath = widget.initialData!['government_id_document_path']?.toString();
      if (initialIdDocPath != null && initialIdDocPath.isNotEmpty) {
        idDocName = initialIdDocPath.split('/').last;
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final base64String = "data:image/png;base64,${base64Encode(bytes)}";
      setState(() {
        addressProofFileName = result.files.single.name;
        addressProofBase64 = base64String;
      });
    }
  }

  Future<void> _pickIdFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      setState(() {
        idDocName = result.files.single.name;
        idDocBase64 = "data:image/png;base64,${base64Encode(bytes)}";
      });
    }
  }

  Future<void> _fetchPincodeDetails() async {
    final pincode = _pincodeController.text.trim();
    debugPrint("=== Fetching Pincode: $pincode ===");
    if (pincode.length != 6) {
      debugPrint("Invalid pincode length: ${pincode.length}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit Pincode')),
      );
      return;
    }

    setState(() {
      _isFetchingPincode = true;
    });

    try {
      final url = 'https://managelogin.jobes24x7.com/api/outsideapis/pincode/details?pincode=$pincode';
      debugPrint("API CALL: $url");
      final response = await http.get(Uri.parse(url));
      debugPrint("API STATUS: ${response.statusCode}");
      debugPrint("API BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decodedBody = json.decode(response.body);
        final responseData = decodedBody['data'];
        
        if (responseData != null && responseData['code'] == 200 && responseData['data'] != null && responseData['data'].isNotEmpty) {
          final pData = responseData['data'][0];
          setState(() {
            _cityController.text = pData['city_name']?.toString() ?? '';
            _districtController.text = pData['district_name']?.toString() ?? '';
            _stateController.text = pData['state_name']?.toString() ?? '';
            _countryController.text = pData['country_name']?.toString() ?? 'India';
            
            // Try to set area/taluk as well
            if (_areaLocalityController.text.isEmpty) {
              _areaLocalityController.text = pData['taluk_name']?.toString() ?? '';
            }
            if (_areaController.text.isEmpty) {
              _areaController.text = pData['taluk_name']?.toString() ?? '';
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pincode details fetched successfully', style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch details for this pincode')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching pincode details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingPincode = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _addressTypeController.dispose();
    _pincodeController.dispose();
    _doorController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _houseNoController.dispose();
    _streetRoadController.dispose();
    _areaLocalityController.dispose();
    _aptNameController.dispose();
    _towerBlockController.dispose();
    _flatNoController.dispose();
    _floorController.dispose();
    _communityNameController.dispose();
    _blockController.dispose();
    _pgNameController.dispose();
    _roomNoController.dispose();
    _bedNoController.dispose();
    _blockWingController.dispose();
    super.dispose();
  }

  void _addAddress() {
    setState(() {
      isAddressAdded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Address added successfully"),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Step 2: Verified User Credentials & Address",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    "Enter your address proofs and government-issued ID card scans.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Stepper mockup
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator("1", "Registered User", true, isCompleted: true),
                      Container(width: 40, height: 1, color: const Color(0xFFE2E8F0)),
                      _buildStepIndicator("2", "Verified User", true),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        SizedBox(
                          width: isMobile ? double.infinity : (constraints.maxWidth - 24) / 2,
                          child: _buildDropdownField("Select ID Type *", "Select Government ID Type", ["Aadhaar Card", "Passport", "Driving Licence", "Voter ID Card"], selectedIdType, (v) => setState(() => selectedIdType = v)),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : (constraints.maxWidth - 24) / 2,
                          child: _buildFilePicker("Upload ID Document *", idDocName, _pickIdFile),
                        ),
                      ],
                    );
                  }
                ),

                const SizedBox(height: 32),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 32),

                const Text(
                  "1. Add Your Address Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 24),
                
                // Form Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: [
                        SizedBox(
                          width: isMobile ? double.infinity : (constraints.maxWidth - 48) / 3,
                          child: _buildTextField("Address Type *", "e.g. Permanent, Rental...", _addressTypeController),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : (constraints.maxWidth - 48) / 3,
                          child: _buildDropdownField("Property Type *", "Select Property Type...", 
                            ["Independent House", "Apartment / Flat", "Row House", "PG (Paying Guest)", "Other"], 
                            selectedPropertyType, (v) => setState(() => selectedPropertyType = v)),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : (constraints.maxWidth - 48) / 3,
                          child: _buildTextFieldWithButton("Pincode *", "Enter Pincode", _pincodeController, _isFetchingPincode ? "..." : "Fetch", _isFetchingPincode ? () {} : _fetchPincodeDetails, isNumber: true),
                        ),
                        
                        ..._buildDynamicFields(isMobile, constraints.maxWidth),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        onPressed: _addAddress,
                        icon: const Icon(Icons.add, color: Color(0xFF0F172A), size: 16),
                        label: const Text("Add Address", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                
                if (isAddressAdded) ...[
                  const SizedBox(height: 48),
                  const Text(
                    "2. Select the Address to Provide Proof For *",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isAddressSelected = !isAddressSelected;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 400,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isAddressSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                              width: isAddressSelected ? 1.5 : 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isAddressSelected ? const Color(0xFFEFF6FF) : Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Icon(
                                  isAddressSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isAddressSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 4.0,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2563EB),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text("JHH", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                            borderRadius: BorderRadius.circular(12),
                                            color: Colors.white,
                                          ),
                                          child: Text(selectedPropertyType ?? "Independent House", style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "${_doorController.text.isNotEmpty ? _doorController.text : '123'}, ${_streetController.text.isNotEmpty ? _streetController.text : 'Main Temple Buildisssss, 2/220A'}\n"
                                      "${_areaController.text.isNotEmpty ? _areaController.text : 'THOTTATHUSALAI'}\n"
                                      ",SOKKANUR,KINATHUKADAVU, Near\nMain Gate,\n"
                                      "h, ${_cityController.text.isNotEmpty ? _cityController.text : 'Chennai'}, ${_stateController.text.isNotEmpty ? _stateController.text : 'Tamil Nadu'} - ${_pincodeController.text.isNotEmpty ? _pincodeController.text : '642109'}",
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.5, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            ],
                          ),
                        ),
                        if (isAddressSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(11),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text("Selected", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                if (isAddressSelected) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: "3. Upload Address Proof ",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            children: [
                              TextSpan(
                                text: "(jhh)",
                                style: TextStyle(color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isMobile = constraints.maxWidth < 600;
                            return Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              children: [
                                SizedBox(
                                  width: isMobile ? double.infinity : (constraints.maxWidth - 24) / 2,
                                  child: _buildDropdownField(
                                    "Select Address Proof Type *",
                                    "Select Document...",
                                    [
                                      "Passport",
                                      "Driving Licence",
                                      "Electricity Bill",
                                      "Water Bill",
                                      "Gas Connection Bill",
                                      "Rental Agreement (if accepted)",
                                      "Property Tax Receipt"
                                    ],
                                    selectedDocumentType,
                                    (v) => setState(() => selectedDocumentType = v),
                                    prefixIcon: Icons.description_outlined,
                                  ),
                                ),
                                SizedBox(
                                  width: isMobile ? double.infinity : (constraints.maxWidth - 24) / 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Upload Address Document *"),
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
                                            const SizedBox(width: 16),
                                            const Icon(Icons.upload_file, color: Color(0xFF64748B), size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                addressProofFileName != null ? "Document Selected" : "Choose file...",
                                                style: TextStyle(
                                                  color: addressProofFileName != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8), 
                                                  fontSize: 14
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: _pickFile,
                                              child: Container(
                                                margin: const EdgeInsets.all(4),
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                                  borderRadius: BorderRadius.circular(20),
                                                  color: Colors.white,
                                                ),
                                                child: const Center(
                                                  child: Text("Browse", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (addressProofFileName != null) ...[
                                        const SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _showDocumentModal(context, addressProofFileName!),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                              borderRadius: BorderRadius.circular(8),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Icon(Icons.image, color: Colors.grey[600]),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.check, color: Color(0xFF10B981), size: 16),
                                                          const SizedBox(width: 4),
                                                          const Text("Uploaded", style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(addressProofFileName!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 48),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: const Text("Back", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          bool hasAddressProof = addressProofBase64 != null || (widget.initialData?['address_proof'] != null && widget.initialData!['address_proof']['proof_document'] != null);
                          bool hasIdDoc = idDocBase64 != null || (widget.initialData?['government_id_document_path'] != null);
                          
                          if (!isAddressAdded || !isAddressSelected || selectedDocumentType == null || !hasAddressProof || selectedIdType == null || !hasIdDoc) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please complete all required fields and upload documents')),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          final userData = await UserService().getUserData();
                          final String actualUserMainId = userData['user_main_id']?.toString() ?? "";

                          if (actualUserMainId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error: User ID not found. Please log in again.')),
                            );
                            setState(() => _isLoading = false);
                            return;
                          }

                          final payload = {
                            "user_main_id": actualUserMainId,
                            "gender": widget.gender,
                            "address_proof": {
                              "proof_type": selectedDocumentType,
                              "proof_document": addressProofBase64 ?? "",
                            },
                            "addresses": [
                              {
                                "address_type": _addressTypeController.text,
                                "property_type": selectedPropertyType,
                                "pincode": _pincodeController.text,
                              }
                            ],
                            "government_id_document": idDocBase64 ?? "",
                            "government_id_type": selectedIdType,
                            "pan_document": widget.panDocBase64,
                            "pan_number": widget.panNumber,
                            "profile_photo": widget.profilePhotoBase64,
                          };

                          final response = await UserService().submitVerifiedRegistration(payload);
                          
                          setState(() => _isLoading = false);

                          if (!mounted) return;

                          if (response['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message'] ?? "Finished successfully!")),
                            );
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message'] ?? "Failed to submit.")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Finish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String number, String title, bool isActive, {bool isCompleted = false}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF10B981) : (isActive ? const Color(0xFF2563EB) : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? const Color(0xFF10B981) : (isActive ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted 
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    number,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDynamicFields(bool isMobile, double maxWidth) {
    double thirdWidth = isMobile ? double.infinity : (maxWidth - 48) / 3;
    double halfWidth = isMobile ? double.infinity : (maxWidth - 24) / 2;
    
    String propertyType = selectedPropertyType ?? "Independent House";
    
    if (propertyType == "Independent House") {
      return [
        SizedBox(width: thirdWidth, child: _buildTextField("House No. *", "e.g. 12A", _houseNoController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Building Name", "e.g. Skyline Apts", _buildingController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Street/Road *", "e.g. Main St", _streetRoadController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Area/Locality *", "e.g. Downtown", _areaLocalityController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Landmark (Optional)", "e.g. Near Park", _landmarkController)),
        SizedBox(width: thirdWidth, child: _buildTextField("City *", "e.g. Chennai", _cityController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("District *", "e.g. Chennai", _districtController)),
        SizedBox(width: thirdWidth, child: _buildTextField("State *", "e.g. Tamil Nadu", _stateController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Country", "India", _countryController)),
      ];
    } else if (propertyType == "Apartment / Flat") {
      return [
        SizedBox(width: thirdWidth, child: _buildTextField("Apartment Name *", "e.g. Skyline Apts", _aptNameController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Tower/Block", "e.g. A", _towerBlockController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Flat No. *", "e.g. 101", _flatNoController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Floor", "e.g. 1st Floor", _floorController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Street/Road *", "e.g. Main St", _streetRoadController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Area/Locality *", "e.g. Downtown", _areaLocalityController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Landmark (Optional)", "e.g. Near Park", _landmarkController)),
        SizedBox(width: thirdWidth, child: _buildTextField("City *", "e.g. Chennai", _cityController)),
        SizedBox(width: thirdWidth, child: _buildTextField("District *", "e.g. Chennai", _districtController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("State *", "e.g. Tamil Nadu", _stateController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Country", "India", _countryController)),
      ];
    } else if (propertyType == "Row House") {
      return [
        SizedBox(width: thirdWidth, child: _buildTextField("Community Name *", "e.g. Green Meadows", _communityNameController)),
        SizedBox(width: thirdWidth, child: _buildTextField("House No. *", "e.g. 12A", _houseNoController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Block", "e.g. B", _blockController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Street/Road *", "e.g. Main St", _streetRoadController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Area/Locality *", "e.g. Downtown", _areaLocalityController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Landmark (Optional)", "e.g. Near Park", _landmarkController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("City *", "e.g. Chennai", _cityController)),
        SizedBox(width: thirdWidth, child: _buildTextField("District *", "e.g. Chennai", _districtController)),
        SizedBox(width: thirdWidth, child: _buildTextField("State *", "e.g. Tamil Nadu", _stateController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Country", "India", _countryController)),
      ];
    } else if (propertyType == "PG (Paying Guest)") {
      return [
        SizedBox(width: thirdWidth, child: _buildTextField("PG Name *", "e.g. Sunrise PG", _pgNameController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Room Number *", "e.g. 101", _roomNoController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Bed Number (Optional)", "e.g. 2", _bedNoController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Floor *", "e.g. 1st Floor", _floorController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Building Name", "e.g. Skyline Apts", _buildingController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Block / Wing (Optional)", "e.g. A Wing", _blockWingController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Street / Road *", "e.g. Main St", _streetRoadController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Area / Locality *", "e.g. Downtown", _areaLocalityController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Landmark (Optional)", "e.g. Near Park", _landmarkController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("City *", "e.g. Chennai", _cityController)),
        SizedBox(width: thirdWidth, child: _buildTextField("District *", "e.g. Chennai", _districtController)),
        SizedBox(width: thirdWidth, child: _buildTextField("State *", "e.g. Tamil Nadu", _stateController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Country", "India", _countryController)),
      ];
    } else {
      // Other
      return [
        SizedBox(width: thirdWidth, child: _buildTextField("Door Number *", "e.g. 12A", _doorController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Street Name *", "e.g. Main St", _streetController)),
        SizedBox(width: thirdWidth, child: _buildTextField("Building Name", "e.g. Skyline Apts", _buildingController)),
        
        SizedBox(width: halfWidth, child: _buildTextField("Landmark (Optional)", "e.g. Near Park", _landmarkController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Area / Village *", "e.g. Downtown", _areaController)),
        SizedBox(width: thirdWidth, child: _buildTextField("City / District *", "e.g. Chennai", _cityController)),
        SizedBox(width: thirdWidth, child: _buildTextField("State *", "e.g. Tamil Nadu", _stateController)),
        
        SizedBox(width: thirdWidth, child: _buildTextField("Country", "India", _countryController)),
      ];
    }
  }

  void _showDocumentModal(BuildContext context, String fileName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Document Preview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(fileName, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    final bool isRequired = label.endsWith("*");
    final String labelText = isRequired ? label.substring(0, label.length - 1).trim() : label;
    
    return RichText(
      text: TextSpan(
        text: labelText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: isRequired
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFEF4444)),
                )
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
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
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithButton(String label, String hint, TextEditingController controller, String btnText, VoidCallback onTap, {bool isNumber = false}) {
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
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                  inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(btnText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, String? value, ValueChanged<String?> onChanged, {IconData? prefixIcon}) {
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
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, color: const Color(0xFF64748B), size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                    value: value,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A))),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
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
                      color: fileName != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (fileName != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showDocumentModal(context, fileName),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.insert_drive_file, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 4),
                            const Text("Uploaded", style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(fileName, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ],
    );
  }
}
