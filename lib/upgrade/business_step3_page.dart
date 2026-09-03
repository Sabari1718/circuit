import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'business_step4_page.dart';
import '../widgets/common_dashboard_app_bar.dart';

class BusinessStep3Page extends StatefulWidget {
  const BusinessStep3Page({super.key});

  @override
  State<BusinessStep3Page> createState() => _BusinessStep3PageState();
}

class _BusinessStep3PageState extends State<BusinessStep3Page> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _selectedDocumentType;
  String? _selectedAddressType;
  String? _selectedProofType;

  String? _bankDocFileName;
  String? _addressDocFileName;
  
  Uint8List? _bankDocBytes;
  Uint8List? _addressDocBytes;
  
  bool _isLoading = false;

  // Bank Controllers
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _confirmAccountController =
      TextEditingController();

  // Address Controllers
  final TextEditingController _pincodeController = TextEditingController();

  // Dynamic Address Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _plotBlockController = TextEditingController();
  final TextEditingController _estateController = TextEditingController();
  final TextEditingController _customAddressTypeController =
      TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  // Common Address Controllers
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(
    text: 'India',
  );

  Future<void> _pickFile(bool isBankDoc) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      Uint8List? bytes = result.files.single.bytes;
      if (bytes == null && result.files.single.path != null) {
        bytes = File(result.files.single.path!).readAsBytesSync();
      }

      setState(() {
        if (isBankDoc) {
          _bankDocFileName = result.files.single.name;
          _bankDocBytes = bytes;
        } else {
          _addressDocFileName = result.files.single.name;
          _addressDocBytes = bytes;
        }
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }
    
    if (_bankDocBytes == null || _addressDocBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload the required documents")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userMainId = prefs.getString('user_main_id') ?? '';

      String bankDocMime = _bankDocFileName!.toLowerCase().endsWith('.png') ? 'image/png' : (_bankDocFileName!.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg');
      String bankDocBase64 = "data:$bankDocMime;base64,${base64Encode(_bankDocBytes!)}";

      String addressDocMime = _addressDocFileName!.toLowerCase().endsWith('.png') ? 'image/png' : (_addressDocFileName!.toLowerCase().endsWith('.pdf') ? 'application/pdf' : 'image/jpeg');
      String addressDocBase64 = "data:$addressDocMime;base64,${base64Encode(_addressDocBytes!)}";

      String addressDocTypeMapped = '';
      if (_selectedProofType == 'Aadhaar Card') addressDocTypeMapped = 'aadhar';
      else if (_selectedProofType == 'Passport') addressDocTypeMapped = 'passport';
      else if (_selectedProofType == 'Voter ID') addressDocTypeMapped = 'voter';
      else if (_selectedProofType == 'Driving Licence') addressDocTypeMapped = 'driving';
      else if (_selectedProofType == 'Utility Bill') addressDocTypeMapped = 'utility';
      
      String mappedAddressType = '';
      if (_selectedAddressType == 'Factory') mappedAddressType = 'factory';
      else if (_selectedAddressType == 'Warehouse / Godown') mappedAddressType = 'warehouse';
      else if (_selectedAddressType == 'Office') mappedAddressType = 'office';
      else if (_selectedAddressType == 'Other') mappedAddressType = 'other';
      else mappedAddressType = _selectedAddressType?.toLowerCase() ?? '';

      final payload = {
        "user_main_id": userMainId,
        "bank_account_number": _bankAccountController.text.trim(),
        "bank_document_type": _selectedDocumentType == 'Cancelled Cheque' ? 'cheque' : 'passbook',
        "bank_document": bankDocBase64,
        "address_doc_type": addressDocTypeMapped,
        "address_proof": addressDocBase64,
        "address_type": mappedAddressType,
        "selected_address_type": _selectedAddressType,
        "customer_address_type": _selectedAddressType == 'Other' ? _customAddressTypeController.text.trim() : _selectedAddressType,
        "door_number": _noController.text.trim(),
        "street_name": _streetController.text.trim(),
        "street": _streetController.text.trim(),
        "building_name": _nameController.text.trim(),
        "landmark": _landmarkController.text.trim(),
        "area": _areaController.text.trim(),
        "district": _districtController.text.trim(),
        "pincode": _pincodeController.text.trim(),
        "state": _stateController.text.trim(),
        "country": _countryController.text.trim(),
        
        "factory_name": _selectedAddressType == 'Factory' ? _nameController.text.trim() : "",
        "unit_no": _noController.text.trim(),
        "plat_no": _plotBlockController.text.trim(),
        "indus_estate": _estateController.text.trim(),
        
        "warehouse_name": _selectedAddressType == 'Warehouse / Godown' ? _nameController.text.trim() : "",
        "warehouse_no": _selectedAddressType == 'Warehouse / Godown' ? _noController.text.trim() : "",
        "plot_no": _plotBlockController.text.trim(),
        "block": _plotBlockController.text.trim(),
        
        "office_name": _selectedAddressType == 'Office' ? _nameController.text.trim() : "",
        "office_num": _selectedAddressType == 'Office' ? _noController.text.trim() : "",
        "bloack_wing": _plotBlockController.text.trim(),
        "floor": _floorController.text.trim()
      };

      String url = 'https://managelogin.jobes24x7.com/api/business-reg/create';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('=== BUSINESS REGISTRATION REQUEST PAYLOAD ===');
      print(jsonEncode(payload));
      print('=== BUSINESS REGISTRATION API RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        http.get(Uri.parse('https://managelogin.jobes24x7.com/api/login/$userMainId')).catchError((_) => http.Response('', 200));
        http.get(Uri.parse('https://managelogin.jobes24x7.com/api/business-reg/user/$userMainId')).catchError((_) => http.Response('', 200));
        http.get(Uri.parse('https://managelogin.jobes24x7.com/api/user_register/main/$userMainId')).catchError((_) => http.Response('', 200));
        http.get(Uri.parse('https://managelogin.jobes24x7.com/api/api/verified-user/$userMainId')).catchError((_) => http.Response('', 200));

        await prefs.setBool('is_main_business_registered', true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Business Registration created successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BusinessStep4Page()));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to register business. Status: ${response.statusCode}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildResponsiveRow(bool isMobile, List<Widget> children) {
    if (isMobile) {
      List<Widget> colChildren = [];
      for (var child in children) {
        if (child is Expanded) {
          colChildren.add(child.child);
          colChildren.add(const SizedBox(height: 16));
        } else if (child is SizedBox) {
          // Skip spacing since Column handles it
        } else {
          colChildren.add(child);
          colChildren.add(const SizedBox(height: 16));
        }
      }
      if (colChildren.isNotEmpty && colChildren.last is SizedBox) {
        colChildren.removeLast();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: colChildren,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 24 : 32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Step 3: Business User Firm Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Submit corporate entity profile and bank information to finalise your business registration.",
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Progress Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "1",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Business User",
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Main Form Card
                  Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bank Section
                        _buildResponsiveRow(isMobile, [
                          Expanded(
                            child: _buildTextField(
                              "Bank Account Number",
                              "Enter Bank Account Number",
                              _bankAccountController,
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              "Confirm Account Number",
                              "Confirm Account Number",
                              _confirmAccountController,
                              isRequired: true,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildResponsiveRow(isMobile, [
                          Expanded(
                            child: _buildDropdown(
                              label: "Document Type",
                              hint: "Bank Passbook (Front Page)",
                              value: _selectedDocumentType,
                              items: [
                                "Bank Passbook (Front Page)",
                                "Bank Statement (Last 3 Months)",
                                "Cancelled Cheque",
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedDocumentType = val),
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildFileUpload(
                              "Upload Bank Document",
                              isRequired: true,
                              fileName: _bankDocFileName,
                              onTap: () => _pickFile(true),
                            ),
                          ),
                        ]),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),

                        // Corporate Entity Location
                        const Text(
                          "Corporate Entity & Business Location details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(isMobile, [
                          Expanded(
                            child: _buildDropdown(
                              label: "Business Address Type",
                              hint: "Select Address Type...",
                              value: _selectedAddressType,
                              items: [
                                "Factory",
                                "Warehouse / Godown",
                                "Office",
                                "Branch",
                                "Shop",
                                "Other",
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedAddressType = val;
                                  _nameController.clear();
                                  _noController.clear();
                                  _plotBlockController.clear();
                                  _estateController.clear();
                                  _customAddressTypeController.clear();
                                  _floorController.clear();
                                });
                              },
                              isRequired: true,
                            ),
                          ),
                          if (_selectedAddressType == 'Other') ...[
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildTextField(
                                "Custom Address Type",
                                "e.g. Retail Shop",
                                _customAddressTypeController,
                                isRequired: true,
                              ),
                            ),
                          ],
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    text: "Business Pincode ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "*",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _pincodeController,
                                          decoration: const InputDecoration(
                                            hintText: "Pincode",
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (v) =>
                                              (v == null || v.isEmpty)
                                              ? "Required"
                                              : null,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {},
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 13,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2563EB),
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "Fetch",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // Dynamic Address Fields
                        if (_selectedAddressType != null) ...[
                          _buildDynamicAddressFields(isMobile),
                          const SizedBox(height: 24),
                        ],

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),

                        // Address Proof
                        const Text(
                          "Corporate Entity Address Proof",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildResponsiveRow(isMobile, [
                          Expanded(
                            child: _buildDropdown(
                              label: "Select Document Proof Type",
                              hint: "Aadhaar Card",
                              value: _selectedProofType,
                              items: [
                                "Aadhaar Card",
                                "Passport",
                                "Voter ID",
                                "Driving Licence",
                                "Utility Bill",
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedProofType = val),
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildFileUpload(
                              "Upload Document",
                              isRequired: true,
                              fileName: _addressDocFileName,
                              onTap: () => _pickFile(false),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Cancel"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitRegistration,
                        icon: _isLoading 
                           ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                           : const Icon(Icons.save, size: 18),
                        label: Text(_isLoading ? "Submitting..." : "Submit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicAddressFields(bool isMobile) {
    String nameLabel = "Business Name";
    String noLabel = "Unit No";
    String blockLabel = "Block / Plot";
    bool showEstate = false;
    bool isOffice = false;
    bool isOther = false;

    if (_selectedAddressType == 'Factory') {
      nameLabel = "Factory Name";
      noLabel = "Unit Number";
      blockLabel = "Plot Number";
      showEstate = true;
    } else if (_selectedAddressType == 'Warehouse / Godown') {
      nameLabel = "Warehouse Name";
      noLabel = "Warehouse No";
      blockLabel = "Block / Wing";
    } else if (_selectedAddressType == 'Office') {
      isOffice = true;
      nameLabel = "Office Name";
      noLabel = "Office Number";
    } else if (_selectedAddressType == 'Other') {
      isOther = true;
      noLabel = "Door Number";
      nameLabel = "Building Name";
      blockLabel = "Block / Wing";
    } else {
      nameLabel = "$_selectedAddressType Name";
      noLabel = "$_selectedAddressType No";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResponsiveRow(isMobile, [
          if (isOffice) ...[
            Expanded(
              child: _buildTextField(
                nameLabel,
                "Office/Building Name",
                _nameController,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                noLabel,
                "Office No",
                _noController,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                "Floor",
                "e.g. 3rd Floor",
                _floorController,
                isRequired: false,
              ),
            ),
          ] else if (isOther) ...[
            Expanded(
              child: _buildTextField(
                noLabel,
                "Door No",
                _noController,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                nameLabel,
                "Building Name",
                _nameController,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                blockLabel,
                "Block",
                _plotBlockController,
                isRequired: false,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                "Floor",
                "Floor",
                _floorController,
                isRequired: false,
              ),
            ),
          ] else ...[
            Expanded(
              child: _buildTextField(
                nameLabel,
                nameLabel,
                _nameController,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                noLabel,
                noLabel,
                _noController,
                isRequired: true,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildTextField(
                blockLabel,
                blockLabel.split(' / ').first,
                _plotBlockController,
                isRequired: false,
              ),
            ),
            if (showEstate) ...[
              const SizedBox(width: 24),
              Expanded(
                child: _buildTextField(
                  "Industrial Estate",
                  "e.g. SIPCOT",
                  _estateController,
                  isRequired: false,
                ),
              ),
            ],
          ],
        ]),
        const SizedBox(height: 24),
        _buildResponsiveRow(isMobile, [
          Expanded(
            child: _buildTextField(
              "Street Name",
              "Street/Road Name",
              _streetController,
              isRequired: true,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildTextField(
              "Area / Locality",
              "Area Name",
              _areaController,
              isRequired: true,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildTextField(
              "District / City",
              "District",
              _districtController,
              isRequired: true,
            ),
          ),
        ]),
        const SizedBox(height: 24),
        _buildResponsiveRow(isMobile, [
          Expanded(
            child: _buildTextField(
              "State",
              "State",
              _stateController,
              isRequired: true,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildTextField(
              "Landmark",
              "Landmark",
              _landmarkController,
              isRequired: false,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildTextField(
              "Country",
              "India",
              _countryController,
              isRequired: false,
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "$label ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: "*",
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
          validator: isRequired
              ? (v) => (v == null || v.isEmpty) ? "Required" : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "$label ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: "*",
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8))),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF475569)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: isRequired ? (v) => v == null ? "Required" : null : null,
        ),
      ],
    );
  }

  Widget _buildFileUpload(
    String label, {
    required bool isRequired,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    String displayFileName = fileName ?? "No file chosen";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "$label ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: "*",
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  child: const Text(
                    "Choose File",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    displayFileName,
                    style: const TextStyle(color: Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Document Uploaded: $fileName",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
