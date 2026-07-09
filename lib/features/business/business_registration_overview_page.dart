import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:circuit/features/upgrade/business_created_page.dart';
import 'package:circuit/features/upgrade/business_user_model.dart';
import 'package:circuit/features/upgrade/business_user_store.dart';
import 'package:circuit/features/business/create_business_user_page.dart';
import '../../upgrade/business_created_page.dart';
import 'user_overview_page.dart';


class BusinessRegistrationOverviewPage extends StatefulWidget {
  final BusinessUser business;

  const BusinessRegistrationOverviewPage({super.key, required this.business});

  @override
  State<BusinessRegistrationOverviewPage> createState() => _BusinessRegistrationOverviewPageState();
}

class _BusinessRegistrationOverviewPageState extends State<BusinessRegistrationOverviewPage> {
  bool _isEditing = false;
  late BusinessUser _currentBusiness;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _accNumberCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  final _doorCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _buildingCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  String? _bankDocType;
  String? _employeeRange;

  Uint8List? _newPanBytes;
  String? _newPanName;
  Uint8List? _newSigBytes;
  String? _newSigName;
  Uint8List? _newGstBytes;
  String? _newGstName;
  Uint8List? _newBankDocBytes;
  String? _newBankDocName;

  @override
  void initState() {
    super.initState();
    _currentBusiness = widget.business;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameCtrl.text = _currentBusiness.businessName;
    _emailCtrl.text = _currentBusiness.email;
    _phoneCtrl.text = _currentBusiness.phone;
    _websiteCtrl.text = _currentBusiness.website ?? '';
    _panCtrl.text = _currentBusiness.panNumber;
    _gstCtrl.text = _currentBusiness.gstNumber;
    _accNumberCtrl.text = _currentBusiness.accountNumber;
    _ifscCtrl.text = _currentBusiness.ifscCode ?? '';
    _bankNameCtrl.text = _currentBusiness.bankName ?? '';
    _holderNameCtrl.text = _currentBusiness.accountHolderName ?? '';
    _doorCtrl.text = _currentBusiness.doorNumber;
    _streetCtrl.text = _currentBusiness.streetName;
    _buildingCtrl.text = _currentBusiness.buildingName ?? '';
    _landmarkCtrl.text = _currentBusiness.landmark ?? '';
    _areaCtrl.text = _currentBusiness.area;
    _districtCtrl.text = _currentBusiness.district;
    _pincodeCtrl.text = _currentBusiness.pincode;
    _stateCtrl.text = _currentBusiness.state;
    _countryCtrl.text = _currentBusiness.country;
    _yearCtrl.text = _currentBusiness.yearOfEstablishment;
    _bankDocType = _currentBusiness.bankDocType;
    _employeeRange = _currentBusiness.employeeRange;
  }

  void _toggleEdit() {
    if (_isEditing) {
      _initializeControllers();
      setState(() {
        _isEditing = false;
        _newPanBytes = null;
        _newSigBytes = null;
        _newGstBytes = null;
        _newBankDocBytes = null;
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _applyChanges() {
    final updated = BusinessUser(
      id: _currentBusiness.id,
      registrationType: _currentBusiness.registrationType,
      businessName: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      website: _websiteCtrl.text,
      panNumber: _panCtrl.text,
      panFileName: _newPanName ?? _currentBusiness.panFileName,
      panFileBytes: _newPanBytes ?? _currentBusiness.panFileBytes,
      signatureFileName: _newSigName ?? _currentBusiness.signatureFileName,
      signatureFileBytes: _newSigBytes ?? _currentBusiness.signatureFileBytes,
      gstNumber: _gstCtrl.text,
      gstFileName: _newGstName ?? _currentBusiness.gstFileName,
      gstFileBytes: _newGstBytes ?? _currentBusiness.gstFileBytes,
      accountNumber: _accNumberCtrl.text,
      ifscCode: _ifscCtrl.text,
      bankName: _bankNameCtrl.text,
      accountHolderName: _holderNameCtrl.text,
      bankDocType: _bankDocType ?? _currentBusiness.bankDocType,
      bankDocFileName: _newBankDocName ?? _currentBusiness.bankDocFileName,
      bankDocFileBytes: _newBankDocBytes ?? _currentBusiness.bankDocFileBytes,
      doorNumber: _doorCtrl.text,
      streetName: _streetCtrl.text,
      buildingName: _buildingCtrl.text,
      landmark: _landmarkCtrl.text,
      area: _areaCtrl.text,
      district: _districtCtrl.text,
      pincode: _pincodeCtrl.text,
      state: _stateCtrl.text,
      country: _countryCtrl.text,
      businessTypes: _currentBusiness.businessTypes,
      yearOfEstablishment: _yearCtrl.text,
      employeeRange: _employeeRange ?? _currentBusiness.employeeRange,
      createdDate: _currentBusiness.createdDate,
      status: _currentBusiness.status,
    );

    BusinessUserStore().updateBusiness(updated);
    setState(() {
      _currentBusiness = updated;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changes applied successfully!")));
  }

  Future<void> _pickEditFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png', 'pdf'], withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        final f = result.files.first;
        if (type == 'pan') { _newPanBytes = f.bytes; _newPanName = f.name; }
        else if (type == 'sig') { _newSigBytes = f.bytes; _newSigName = f.name; }
        else if (type == 'gst') { _newGstBytes = f.bytes; _newGstName = f.name; }
        else if (type == 'bank') { _newBankDocBytes = f.bytes; _newBankDocName = f.name; }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFE11D48);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      drawer: !isDesktop ? Drawer(elevation: 0, child: _buildSidebar(context, isDrawer: true)) : null,
      appBar: AppBar(
        title: Text("Registration Overview", style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) _buildSidebar(context, isDrawer: false),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(context, themeColor, isDark),
                  const SizedBox(height: 24),
                  _buildStatusBanner(context),
                  const SizedBox(height: 32),

                  _buildDetailsSection(themeColor, isDark, !isDesktop),

                  if (_isEditing) ...[
                    const SizedBox(height: 48),
                    Center(
                      child: SizedBox(
                        width: isDesktop ? 300 : double.infinity,
                        child: ElevatedButton(
                          onPressed: _applyChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Apply Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(Color color, bool isDark, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildBasicDetailsCard(color, isDark),
          const SizedBox(height: 24),
          _buildIdentificationCard(color, isDark),
          const SizedBox(height: 24),
          _buildBankInfoCard(color, isDark),
          const SizedBox(height: 24),
          _buildAddressDetailsCard(color, isDark),
          const SizedBox(height: 24),
          _buildBusinessProfileCard(color, isDark),
        ],
      );
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBasicDetailsCard(color, isDark)),
            const SizedBox(width: 32),
            Expanded(child: _buildIdentificationCard(color, isDark)),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildBankInfoCard(color, isDark)),
            const SizedBox(width: 32),
            Expanded(child: _buildBusinessProfileCard(color, isDark)),
          ],
        ),
        const SizedBox(height: 32),
        _buildAddressDetailsCard(color, isDark),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context, Color themeColor, bool isDark) {
    return Wrap(
      spacing: 16, runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_ind_rounded, color: Color(0xFF3B82F6), size: 28),
            const SizedBox(width: 12),
            Flexible(child: Text("Registration Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1E293B)))),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _toggleEdit,
          icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_document, color: Colors.white, size: 16),
          label: Text(_isEditing ? "Cancel Edit" : "Edit Registration", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing ? const Color(0xFF8B5CF6) : themeColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 32)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("BUSINESS ID: ${_currentBusiness.id}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                Text("Registered as: ${_currentBusiness.registrationType ?? 'General'}", style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsCard(Color color, bool isDark) {
    return _buildCard(isDark, title: "Basic Business Details", icon: Icons.business_rounded, children: [
      _buildFieldLabel("BUSINESS NAME"),
      _buildEditableField(_nameCtrl, "Name", isDark, readonly: !_isEditing),
      const SizedBox(height: 16),
      _buildFieldLabel("BUSINESS EMAIL"),
      _buildEditableField(_emailCtrl, "Email", isDark, readonly: !_isEditing),
      const SizedBox(height: 16),
      _buildFieldLabel("BUSINESS PHONE"),
      _buildEditableField(_phoneCtrl, "Phone", isDark, readonly: !_isEditing),
      const SizedBox(height: 16),
      _buildFieldLabel("WEBSITE"),
      _buildEditableField(_websiteCtrl, "Website", isDark, readonly: !_isEditing),
    ],
    );
  }

  Widget _buildIdentificationCard(Color color, bool isDark) {
    return _buildCard(isDark, title: "Identification Docs", icon: Icons.badge_rounded, children: [
      _buildFieldLabel("PAN NUMBER"),
      _buildEditableField(_panCtrl, "PAN", isDark, readonly: !_isEditing),
      const SizedBox(height: 20),
      _buildImagePreview("PAN PHOTO", _newPanName ?? _currentBusiness.panFileName, _newPanBytes ?? _currentBusiness.panFileBytes, 'pan', isDark),
      const Divider(height: 40),
      _buildFieldLabel("GST NUMBER"),
      _buildEditableField(_gstCtrl, "GST", isDark, readonly: !_isEditing),
      const SizedBox(height: 20),
      _buildImagePreview("GST CERTIFICATE", _newGstName ?? _currentBusiness.gstFileName, _newGstBytes ?? _currentBusiness.gstFileBytes, 'gst', isDark),
      const Divider(height: 40),
      _buildImagePreview("SIGNATURE", _newSigName ?? _currentBusiness.signatureFileName, _newSigBytes ?? _currentBusiness.signatureFileBytes, 'sig', isDark),
    ],
    );
  }

  Widget _buildBankInfoCard(Color color, bool isDark) {
    return _buildCard(isDark, title: "Bank Details", icon: Icons.account_balance_rounded, children: [
      _buildFieldLabel("ACCOUNT HOLDER NAME"),
      _buildEditableField(_holderNameCtrl, "Holder Name", isDark, readonly: !_isEditing),
      const SizedBox(height: 16),
      _buildFieldLabel("ACCOUNT NUMBER"),
      _buildEditableField(_accNumberCtrl, "Account No", isDark, readonly: !_isEditing),
      const SizedBox(height: 16),
      _buildFieldLabel("IFSC CODE"),
      _buildEditableField(_ifscCtrl, "IFSC", isDark, readonly: !_isEditing),
      const SizedBox(height: 16),
      _buildFieldLabel("BANK NAME"),
      _buildEditableField(_bankNameCtrl, "Bank Name", isDark, readonly: !_isEditing),
      const SizedBox(height: 20),
      _buildFieldLabel("DOCUMENT TYPE"),
      _buildDropdownField(_bankDocType, ['Bank Statement', 'Canceled Cheque Leaf'], (v) => setState(() => _bankDocType = v), isDark, readonly: !_isEditing),
      const SizedBox(height: 20),
      _buildImagePreview("BANK DOCUMENT", _newBankDocName ?? _currentBusiness.bankDocFileName, _newBankDocBytes ?? _currentBusiness.bankDocFileBytes, 'bank', isDark),
    ],
    );
  }

  Widget _buildBusinessProfileCard(Color color, bool isDark) {
    return _buildCard(isDark, title: "Business Profile", icon: Icons.list_alt_rounded, children: [
      _buildFieldLabel("BUSINESS TYPES"),
      Wrap(spacing: 8, runSpacing: 8, children: _currentBusiness.businessTypes.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 11)), backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9))).toList()),
      const SizedBox(height: 24),
      _buildFieldLabel("ESTABLISHMENT YEAR"),
      _buildEditableField(_yearCtrl, "Year", isDark, readonly: !_isEditing),
      const SizedBox(height: 16),
      _buildFieldLabel("EMPLOYEE RANGE"),
      _buildDropdownField(_employeeRange, ['1-10', '11-50', '51-200', '201-500', '500+'], (v) => setState(() => _employeeRange = v), isDark, readonly: !_isEditing),
    ],
    );
  }

  Widget _buildAddressDetailsCard(Color color, bool isDark) {
    final bool isSmall = MediaQuery.of(context).size.width < 600;
    return _buildCard(isDark, title: "Address Details", icon: Icons.location_on_rounded, children: [
      _buildResponsiveGrid(isSmall, [
        _gridItem("DOOR NUMBER", _buildEditableField(_doorCtrl, "Door", isDark, readonly: !_isEditing)),
        _gridItem("STREET NAME", _buildEditableField(_streetCtrl, "Street", isDark, readonly: !_isEditing)),
        _gridItem("BUILDING NAME", _buildEditableField(_buildingCtrl, "Building", isDark, readonly: !_isEditing)),
      ]),
      const SizedBox(height: 16),
      _buildResponsiveGrid(isSmall, [
        _gridItem("LANDMARK", _buildEditableField(_landmarkCtrl, "Landmark", isDark, readonly: !_isEditing)),
        _gridItem("AREA / LOCALITY", _buildEditableField(_areaCtrl, "Area", isDark, readonly: !_isEditing)),
        _gridItem("PINCODE", _buildEditableField(_pincodeCtrl, "Pincode", isDark, readonly: !_isEditing)),
      ]),
      const SizedBox(height: 16),
      _buildResponsiveGrid(isSmall, [
        _gridItem("DISTRICT", _buildEditableField(_districtCtrl, "District", isDark, readonly: !_isEditing)),
        _gridItem("STATE", _buildEditableField(_stateCtrl, "State", isDark, readonly: !_isEditing)),
        _gridItem("COUNTRY", _buildEditableField(_countryCtrl, "Country", isDark, readonly: !_isEditing)),
      ]),
    ],
    );
  }

  Widget _buildResponsiveGrid(bool isMobile, List<Widget> children) {
    if (isMobile) return Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList());
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: children.map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c))).toList());
  }

  Widget _gridItem(String label, Widget field) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildFieldLabel(label), field]);

  Widget _buildCard(bool isDark, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: const Color(0xFF3B82F6), size: 20), const SizedBox(width: 12), Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF1E293B)))]), const Divider(height: 40), ...children]),
    );
  }

  Widget _buildFieldLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)));

  Widget _buildEditableField(TextEditingController ctrl, String hint, bool isDark, {bool readonly = true}) {
    final isPan = hint.toLowerCase() == 'pan' || ctrl == _panCtrl;
    final isPhone = hint.toLowerCase() == 'phone' || ctrl == _phoneCtrl;
    return TextFormField(
      controller: ctrl, readOnly: readonly,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B)),
      textCapitalization: isPan ? TextCapitalization.characters : TextCapitalization.none,
      keyboardType: isPhone ? TextInputType.number : TextInputType.text,
      inputFormatters: isPan
          ? [UpperCaseTextFormatter(), LengthLimitingTextInputFormatter(10)]
          : isPhone
              ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]
              : null,
      decoration: InputDecoration(hintText: hint, filled: true, fillColor: readonly ? (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9).withOpacity(0.5)) : (isDark ? const Color(0xFF0F172A) : Colors.white), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: readonly ? Colors.transparent : (isDark ? Colors.white24 : const Color(0xFFCBD5E1))))),
    );
  }

  Widget _buildDropdownField(String? value, List<String> items, ValueChanged<String?>? onChanged, bool isDark, {bool readonly = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: readonly ? (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9).withOpacity(0.5)) : (isDark ? const Color(0xFF0F172A) : Colors.white), borderRadius: BorderRadius.circular(12), border: Border.all(color: readonly ? Colors.transparent : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)))),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white, value: items.contains(value) ? value : items.first, isExpanded: true, items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)))).toList(), onChanged: readonly ? null : onChanged)),
    );
  }

  Widget _buildImagePreview(String label, String? name, Uint8List? bytes, String type, bool isDark) {
    bool isImage = name != null && (name.toLowerCase().endsWith('.jpg') || name.toLowerCase().endsWith('.png') || name.toLowerCase().endsWith('.jpeg'));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildFieldLabel(label), Container(width: double.infinity, height: 140, decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))), child: Stack(children: [if (bytes != null && isImage) ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(bytes, width: double.infinity, height: double.infinity, fit: BoxFit.cover)) else if (name != null) Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis))])) else const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32)), if (_isEditing) Positioned(top: 8, right: 8, child: InkWell(onTap: () => _pickEditFile(type), child: const CircleAvatar(radius: 16, backgroundColor: Colors.white, child: Icon(Icons.edit, size: 16, color: Colors.blue))))]))]);
  }

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
    final pinkColor = const Color(0xFFE11D48);
    return Container(
      width: 250,
      height: double.infinity,
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: isDrawer ? 40 : 48,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      "90×25",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFFE11D48),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.home_outlined,
            "Dashboard",
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.business_center_outlined,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              title: const Text(
                "Business",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
              dense: true,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          _sidebarSubItem(
            "Business Overview",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _sidebarSubItem(
            "User Overview",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserOverviewPage()),
              );
            },
          ),
          _sidebarSubItem(
            "Add Business",
            textColor: pinkColor,
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BusinessCreatedPage(showSelection: true)),
                (route) => route.isFirst,
              );
            },
          ),
          _sidebarSubItem(
            "Posted Jobs",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.widgets_outlined,
            "Switch Portal",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {VoidCallback? onTap}) => ListTile(
        leading: Icon(icon, color: Colors.white60, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white60, fontSize: 14)),
        onTap: onTap,
        dense: true,
      );

  Widget _sidebarSubItem(String title, {Color? textColor, VoidCallback? onTap}) => ListTile(
        contentPadding: const EdgeInsets.only(left: 54),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "-",
              style: TextStyle(color: Colors.white30, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor ?? Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        onTap: onTap,
        dense: true,
      );
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
