import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/common_dashboard_app_bar.dart';
import '../widgets/business_sidebar_menu.dart';

class NewBusinessRegisterPage extends StatefulWidget {
  const NewBusinessRegisterPage({super.key});

  @override
  State<NewBusinessRegisterPage> createState() => _NewBusinessRegisterPageState();
}

class _NewBusinessRegisterPageState extends State<NewBusinessRegisterPage> {
  int _currentStep = 0;
  final _accNumberCtrl = TextEditingController();
  final _confirmAccNumberCtrl = TextEditingController();

  String _selectedBankDocType = 'Passbook / Bank Statement';
  Uint8List? _bankDocBytes;

  String _selectedAddressDocType = 'Select document type';
  Uint8List? _addressDocBytes;

  String _selectedAddressType = '-- Select Address Type --';
  final _pinCodeCtrl = TextEditingController();

  bool _isConfirmed = false;

  Future<void> _pickImage(bool isBankDoc) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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

  void _submitRegistration() {
    // Show success dialog or navigate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registration Submitted Successfully!")),
    );
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

  @override
  void dispose() {
    _accNumberCtrl.dispose();
    _confirmAccNumberCtrl.dispose();
    _pinCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(
        automaticallyImplyLeading: true,
      ),
      drawer: isMobile
          ? Drawer(
              child: BusinessSidebarMenu(activeItem: ''),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            const SizedBox(
              width: 250,
              child: BusinessSidebarMenu(activeItem: ''),
            ),
          Expanded(
            child: SingleChildScrollView(
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
            ),
          ),
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
          child: const Icon(Icons.badge_outlined, color: Color(0xFF2563EB), size: 32),
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
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
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
            child: Container(
              height: 2,
              color: const Color(0xFFE2E8F0),
            ),
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
                color: isActive || isCompleted ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
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
                color: isActive || isCompleted ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
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
                  child: const Icon(Icons.account_balance, color: Colors.white, size: 24),
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Number
          const Text("Account Number *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                child: Text("Enter the account number as shown in your passbook", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Confirm Account Number
          const Text("Confirm Account Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
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
                  child: const Icon(Icons.description, color: Colors.white, size: 24),
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Document Type Radios
          const Text("Document Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              Text(_selectedBankDocType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Text(" *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
            ],
          ),
          const SizedBox(height: 8),
          _buildUploadBox(
            bytes: _bankDocBytes,
            onTap: () => _pickImage(true),
          ),
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
            _selectedBankDocType == value ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: _selectedBankDocType == value ? const Color(0xFF2563EB) : Colors.grey[400],
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
                  child: const Icon(Icons.map_outlined, color: Colors.white, size: 24),
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
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Document Type Dropdown
          const Text("Document Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.5)),
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
                      color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
              Text("Upload Document ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text("*", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
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
            _buildDropdownField("Address Type", "-- Select Address Type --", ['-- Select Address Type --', 'Factory', 'Warehouse / Godown', 'Office', 'Other (Custom Address Type)']),
            _buildTextField("Door Number", "Door Number", required: true),
            _buildTextField("Street Name", "Street Name", required: true),
          ]),
          const SizedBox(height: 16),
          _buildResponsiveGrid(context, [
            _buildTextField("Building Name", "Building Name"),
            _buildTextField("Landmark (Optional)", "Landmark (Optional)"),
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
            _buildTextField("Area / Locality", "Enter Area / Locality", required: true),
            _buildTextField("City", "Enter City"),
            _buildTextField("District", "District", required: true),
          ]),
          const SizedBox(height: 16),
          _buildResponsiveGrid(context, [
            _buildPinCodeField(),
            _buildTextField("State", "State", required: true),
            _buildTextField("Country", "India", required: true),
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
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
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

  Widget _buildTextField(String label, String hint, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[800])),
            if (required) const Text(" *", style: TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[800])),
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
                    color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
            Text("PIN Code", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey[800])),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildUploadBox({required Uint8List? bytes, required VoidCallback onTap, bool isAddress = false}) {
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
              label: const Text("Change", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
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
              isAddress ? "Click to upload address proof" : "Click to upload document",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "JPG, PNG or PDF (max. 5MB)",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
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
                child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
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
              _buildPreviewRow("Full Name:", "---"),
              _buildPreviewRow("Gender:", "---"),
              _buildPreviewRow("PAN Number:", "---", isLink: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildPreviewImage("Profile Photo:", null)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildPreviewImage("PAN Photo:", null)),
                ],
              ),
            ],
          ),
          _buildPreviewCard(
            title: "Bank Details",
            icon: Icons.account_balance_outlined,
            children: [
              _buildPreviewRow("Account:", _accNumberCtrl.text.isNotEmpty ? _accNumberCtrl.text : "---", isLink: true),
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
              _buildPreviewRow("Type:", _selectedAddressType == '-- Select Address Type --' ? "---" : _selectedAddressType),
              _buildPreviewRow("Door No.:", "---"),
              _buildPreviewRow("Street:", "---"),
              _buildPreviewRow("Landmark:", "---"),
              _buildPreviewRow("Area:", "---"),
              _buildPreviewRow("City:", "---"),
              _buildPreviewRow("District:", "---"),
              _buildPreviewRow("Pincode:", _pinCodeCtrl.text.isNotEmpty ? _pinCodeCtrl.text : "---"),
              _buildPreviewRow("State:", "---"),
              _buildPreviewRow("Country:", "---"),
            ],
          ),
          _buildPreviewCard(
            title: "Documents",
            icon: Icons.description_outlined,
            children: [
              _buildPreviewImage("Address Proof:", _addressDocBytes, height: 200),
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
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Color(0xFF92400E), fontSize: 13, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(text: "Declaration: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "I hereby confirm that all the information provided is true and correct."),
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

  Widget _buildPreviewCard({required String title, required IconData icon, required List<Widget> children}) {
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

  Widget _buildPreviewImage(String label, Uint8List? bytes, {double height = 80}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
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
              if (_currentStep > 0) const Icon(Icons.arrow_back, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _currentStep == 0 ? "Cancel" : "Back",
                style: TextStyle(
                  color: _currentStep == 0 ? Colors.redAccent : Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _currentStep == 3 
              ? (_isConfirmed ? _submitRegistration : null) 
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
              Text(
                _currentStep == 3 ? "Submit Registration" : "Next",
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
