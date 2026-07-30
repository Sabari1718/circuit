import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateStorePage extends StatefulWidget {
  const CreateStorePage({super.key});

  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  Uint8List? _coverImageBytes;

  // Step 1 controllers
  final _storeNameCtrl = TextEditingController();
  final _shopContactNameCtrl = TextEditingController();
  final _shopPhoneCtrl = TextEditingController();
  final _salesContactNameCtrl = TextEditingController();
  final _salesPhoneCtrl = TextEditingController();

  String _branchManagementModel = 'Single Branch (Automatic Single Setup)';
  final List<String> _branchModels = [
    'Single Branch (Automatic Single Setup)',
    'Multi-Branch Franchise',
    'Warehouse / Storage Outlet',
  ];

  String _salesType = 'Both (Wholesale & Retail)';
  final List<String> _salesTypes = ['Retail', 'Wholesale', 'Both (Wholesale & Retail)'];

  // Step 2 controllers
  int _locationTab = 0;
  final _shortcutPincodeCtrl = TextEditingController();
  final _shortcutOutletAddressCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _stateCtrl = TextEditingController(text: 'Tamil Nadu');
  final _districtCtrl = TextEditingController();
  final _talukCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _mapSearchCtrl = TextEditingController();

  // Step 3 controllers
  String? _selectedBusiness;
  String? _selectedBusinessType;
  String? _selectedSectorTitle;
  String? _selectedSector;
  String? _selectedSubSector;
  
  final List<String> _businessList = ['Antigravity Mega Showrooms', 'SuperMart', 'Tech Store'];
  final List<String> _businessTypes = ['Online', 'Local', 'Local & Online', 'Import and Export'];
  final List<String> _sectorTitles = ['Product', 'Devotees', 'Service', 'Real Estate'];
  final List<String> _sectors = ['Electronics', 'Electrical', 'Security', 'Network'];
  final List<String> _subSectors = ['Mobiles', 'Laptops', 'Accessories'];

  // Grid State
  final List<String> _dummyPrimary = ['XT Connector', 'Electrical Plug and Joints', 'Electrical Pin and Block'];
  final List<String> _dummySub = ['trh'];
  final List<String> _dummyBrands = ['Imported'];
  final List<String> _dummyProducts = ['XT90 Connector', 'XT60 Connector', 'XT30 Connector'];
  
  bool _selectAllPrimary = false;
  List<String> _selectedPrimary = [];
  bool _selectAllSub = false;
  List<String> _selectedSub = [];
  bool _selectAllBrands = false;
  List<String> _selectedBrands = [];
  bool _selectAllProducts = false;
  List<String> _selectedProducts = [];

  // Step 4
  String _preferredLanguage = 'English';
  final List<String> _languages = ['English', 'Tamil', 'Hindi'];
  bool _enableNotifications = true;
  bool _enableAutoBackup = false;

  final List<String> _stepTitles = ['Store Info', 'Location', 'Setup', 'Preferences'];

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _shopContactNameCtrl.dispose();
    _shopPhoneCtrl.dispose();
    _salesContactNameCtrl.dispose();
    _salesPhoneCtrl.dispose();
    _shortcutPincodeCtrl.dispose();
    _shortcutOutletAddressCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _districtCtrl.dispose();
    _talukCtrl.dispose();
    _cityCtrl.dispose();
    _mapSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _coverImageBytes = bytes);
    }
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitStore();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _submitStore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store created successfully!'), backgroundColor: Color(0xFF6366F1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        SizedBox(height: 4),
                        Text('Create and manage your store locations', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.list, size: 16),
                    label: const Text('List'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Main Form Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(isMobile ? 20 : 28, 24, isMobile ? 20 : 28, 20),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create New Store', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          SizedBox(height: 4),
                          Text('Fill in the details below to add a new store location', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28),
                      child: _buildStepper(isMobile),
                    ),
                    const SizedBox(height: 4),
                    Divider(color: Colors.grey.shade100, thickness: 1),
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 28),
                      child: Form(key: _formKey, child: _buildStepContent(isMobile)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(bool isMobile) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_stepTitles.length, (index) {
            final isActive = index == _currentStep;
            final isCompleted = index < _currentStep;
            final isLast = index == _stepTitles.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step Circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (isActive || isCompleted) ? const Color(0xFF6366F1) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (isActive || isCompleted) ? const Color(0xFF6366F1) : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                // Step Title
                Text(
                  _stepTitles[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: (isActive || isCompleted) ? const Color(0xFF1E293B) : Colors.grey.shade400,
                  ),
                ),
                // Connector Line
                if (!isLast)
                  Container(
                    width: isMobile ? 20 : 40,
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: Colors.grey.shade300,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isMobile) {
    switch (_currentStep) {
      case 0: return _buildStep1(isMobile);
      case 1: return _buildStep2(isMobile);
      case 2: return _buildStep3(isMobile);
      case 3: return _buildStep4(isMobile);
      default: return const SizedBox();
    }
  }

  Widget _buildStep1(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Store Cover Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 16),
        _buildImageUploadBox(),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.store_outlined, 'Store Information', 'Provide your business and store details'),
        const SizedBox(height: 20),
        _buildLabel('Business Store Name', required: true),
        const SizedBox(height: 8),
        _buildTextField(controller: _storeNameCtrl, hint: 'Antigravity Mega Showrooms', helperText: 'Enter your registered business store name'),
        const SizedBox(height: 20),
        isMobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildStoreCodeField(),
                const SizedBox(height: 16),
                _buildBranchModelDropdown(),
                const SizedBox(height: 16),
                _buildSalesTypeDropdown(),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _buildStoreCodeField()),
                const SizedBox(width: 16),
                Expanded(child: _buildBranchModelDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildSalesTypeDropdown()),
              ]),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.person_outline, 'Personal Information', 'Provide contact details for your store'),
        const SizedBox(height: 20),
        isMobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildContactField('Shop Contact Name', _shopContactNameCtrl, 'e.g. Shop Manager', 'Enter shop manager or primary contact name'),
                const SizedBox(height: 16),
                _buildContactField('Shop Phone Number', _shopPhoneCtrl, 'e.g. +91 98765 43210', 'Enter primary contact number'),
                const SizedBox(height: 16),
                _buildContactField('Sales Contact Name', _salesContactNameCtrl, 'e.g. Sales Executive', 'Enter sales executive or secondary contact name'),
                const SizedBox(height: 16),
                _buildContactField('Sales Phone Number', _salesPhoneCtrl, 'e.g. +91 98765 43211', 'Enter secondary contact number'),
              ])
            : Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _buildContactField('Shop Contact Name', _shopContactNameCtrl, 'e.g. Shop Manager', 'Enter shop manager or primary contact name')),
                  const SizedBox(width: 20),
                  Expanded(child: _buildContactField('Shop Phone Number', _shopPhoneCtrl, 'e.g. +91 98765 43210', 'Enter primary contact number')),
                ]),
                const SizedBox(height: 20),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _buildContactField('Sales Contact Name', _salesContactNameCtrl, 'e.g. Sales Executive', 'Enter sales executive or secondary contact name')),
                  const SizedBox(width: 20),
                  Expanded(child: _buildContactField('Sales Phone Number', _salesPhoneCtrl, 'e.g. +91 98765 43211', 'Enter secondary contact number')),
                ]),
              ]),
        const SizedBox(height: 32),
        _buildFooterButtons(),
      ],
    );
  }

  Widget _buildStep2(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tabs
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              _buildTab('Auto Pincode', 0),
              _buildTab('Manual Address', 1),
              _buildTab('Map Picker', 2),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tab Content
        if (_locationTab == 0) _buildAutoPincodeTab(isMobile),
        if (_locationTab == 1) _buildManualAddressTab(isMobile),
        if (_locationTab == 2) _buildMapPickerTab(isMobile),

        const SizedBox(height: 32),
        _buildFooterButtons(),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _locationTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _locationTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoPincodeTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Shortcut Pincode', required: true),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _shortcutPincodeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 612901',
                  prefixIcon: const Icon(Icons.pin_drop_outlined, size: 18, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // Fetch Details Simulation
                setState(() {
                  _districtCtrl.text = 'Coimbatore';
                  _talukCtrl.text = 'Coimbatore South';
                  _cityCtrl.text = 'Peelamedu';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Fetch Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Pincode Data Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPincodeDataField('COUNTRY', _countryCtrl.text.isEmpty ? 'India' : _countryCtrl.text),
                    const SizedBox(height: 16),
                    _buildPincodeDataField('STATE', _stateCtrl.text.isEmpty ? 'Tamil Nadu' : _stateCtrl.text),
                    const SizedBox(height: 16),
                    _buildPincodeDataField('DISTRICT', _districtCtrl.text),
                    const SizedBox(height: 16),
                    _buildPincodeDataField('TALUK', _talukCtrl.text),
                    const SizedBox(height: 16),
                    _buildPincodeDataField('CITY / VILLAGE', _cityCtrl.text),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPincodeDataField('COUNTRY', _countryCtrl.text.isEmpty ? 'India' : _countryCtrl.text),
                          const SizedBox(height: 20),
                          _buildPincodeDataField('DISTRICT', _districtCtrl.text),
                          const SizedBox(height: 20),
                          _buildPincodeDataField('CITY / VILLAGE', _cityCtrl.text),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPincodeDataField('STATE', _stateCtrl.text.isEmpty ? 'Tamil Nadu' : _stateCtrl.text),
                          const SizedBox(height: 20),
                          _buildPincodeDataField('TALUK', _talukCtrl.text),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        
        _buildLabel('Shortcut Outlet Address', required: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _shortcutOutletAddressCtrl,
          decoration: InputDecoration(
            hintText: 'e.g. Peelamedu Education Hub, Coimbatore',
            prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6366F1)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildPincodeDataField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildManualAddressTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isMobile
            ? Column(
                children: [
                  _buildAddressField('Country', _countryCtrl, Icons.language, required: true),
                  const SizedBox(height: 16),
                  _buildAddressField('State', _stateCtrl, Icons.map_outlined, required: true),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildAddressField('Country', _countryCtrl, Icons.language, required: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAddressField('State', _stateCtrl, Icons.map_outlined, required: true)),
                ],
              ),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                children: [
                  _buildAddressField('District', _districtCtrl, Icons.location_city_outlined, required: true),
                  const SizedBox(height: 16),
                  _buildAddressField('Taluk', _talukCtrl, Icons.share_location_outlined, required: true),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _buildAddressField('District', _districtCtrl, Icons.location_city_outlined, required: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAddressField('Taluk', _talukCtrl, Icons.share_location_outlined, required: true)),
                ],
              ),
        const SizedBox(height: 16),
        _buildAddressField('City / Village', _cityCtrl, Icons.home_work_outlined, required: true),
        const SizedBox(height: 24),
        _buildLabel('Shortcut Outlet Address', required: true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _shortcutOutletAddressCtrl,
          decoration: InputDecoration(
            hintText: 'e.g. Peelamedu Education Hub, Coimbatore',
            prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField(String label, TextEditingController controller, IconData icon, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required: required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPickerTab(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Click on the map area below to pinpoint the store coordinates. The address details will resolve automatically.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _mapSearchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search for a city, street, or landmark...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Dummy Map Container
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            image: const DecorationImage(
              image: NetworkImage('https://maps.wikimedia.org/osm-intl/12/2928/1930.png'), // placeholder map image
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.location_on, color: Color(0xFF6366F1), size: 40),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    children: [
                      Text('Default (Carto)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildCoordinateChip('LATITUDE: 11.0143'),
            const SizedBox(width: 12),
            _buildCoordinateChip('LONGITUDE: 76.9611'),
          ],
        ),
      ],
    );
  }

  Widget _buildCoordinateChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildStep3(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Selection Section
        const Text('Business Selection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 16),
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Select Business', required: true),
                  const SizedBox(height: 8),
                  _buildCustomDropdown(
                    value: _selectedBusiness,
                    items: _businessList,
                    hint: 'Select a business...',
                    icon: Icons.business_center_outlined,
                    onChanged: (val) => setState(() => _selectedBusiness = val),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Business Type', required: true),
                  const SizedBox(height: 8),
                  _buildCustomDropdown(
                    value: _selectedBusinessType,
                    items: _businessTypes,
                    hint: 'Select business type...',
                    icon: Icons.layers_outlined,
                    onChanged: (val) => setState(() => _selectedBusinessType = val),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Select Business', required: true),
                        const SizedBox(height: 8),
                        _buildCustomDropdown(
                          value: _selectedBusiness,
                          items: _businessList,
                          hint: 'Select a business...',
                          icon: Icons.business_center_outlined,
                          onChanged: (val) => setState(() => _selectedBusiness = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Business Type', required: true),
                        const SizedBox(height: 8),
                        _buildCustomDropdown(
                          value: _selectedBusinessType,
                          items: _businessTypes,
                          hint: 'Select business type...',
                          icon: Icons.layers_outlined,
                          onChanged: (val) => setState(() => _selectedBusinessType = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 32),

        // Business Categories Section
        const Text('Business Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 4),
        const Text('Select the sector and categories that best describe your store activity.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 20),
        
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Sector Title', required: true),
                  const SizedBox(height: 8),
                  _buildSearchableDropdown(
                    value: _selectedSectorTitle,
                    items: _sectorTitles,
                    hint: 'Search & Select Sector Title',
                    onChanged: (val) => setState(() { _selectedSectorTitle = val; _selectedSector = null; _selectedSubSector = null; }),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Sector', required: true),
                  const SizedBox(height: 8),
                  _buildSearchableDropdown(
                    value: _selectedSector,
                    items: _sectors,
                    hint: 'Search & Select Sector',
                    onChanged: (val) => setState(() { _selectedSector = val; _selectedSubSector = null; }),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Sub Sector', required: true),
                  const SizedBox(height: 8),
                  _buildSearchableDropdown(
                    value: _selectedSubSector,
                    items: _subSectors,
                    hint: 'Search & Select Sub Sector',
                    onChanged: (val) => setState(() => _selectedSubSector = val),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Sector Title', required: true),
                        const SizedBox(height: 8),
                        _buildSearchableDropdown(
                          value: _selectedSectorTitle,
                          items: _sectorTitles,
                          hint: 'Search & Select Sector Title',
                          onChanged: (val) => setState(() { _selectedSectorTitle = val; _selectedSector = null; _selectedSubSector = null; }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Sector', required: true),
                        const SizedBox(height: 8),
                        _buildSearchableDropdown(
                          value: _selectedSector,
                          items: _sectors,
                          hint: 'Search & Select Sector',
                          onChanged: (val) => setState(() { _selectedSector = val; _selectedSubSector = null; }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Sub Sector', required: true),
                        const SizedBox(height: 8),
                        _buildSearchableDropdown(
                          value: _selectedSubSector,
                          items: _subSectors,
                          hint: 'Search & Select Sub Sector',
                          onChanged: (val) => setState(() => _selectedSubSector = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 16),
        
        // Info Box or Categories Grid
        if (_selectedSectorTitle != null && _selectedSector != null && _selectedSubSector != null)
          _buildCategoriesGrid(isMobile)
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
                  child: const Icon(Icons.info_outline, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Please select Sector Title → Sector → Sub Sector to load categories', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Save config action
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuration Saved'), backgroundColor: Color(0xFF6366F1)));
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Save This Configuration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 16),
        
        _buildFooterButtons(),
      ],
    );
  }

  Widget _buildCustomDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))))).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<String>(
          context: context,
          builder: (context) {
            return _SearchableDropdownDialog(items: items, hint: hint);
          },
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: value != null ? const Color(0xFF6366F1) : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value ?? hint, style: TextStyle(color: value != null ? const Color(0xFF1E293B) : Colors.grey.shade400, fontSize: 14)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.tune_outlined, 'Store Preferences', 'Set your store preferences and settings'),
        const SizedBox(height: 20),
        _buildLabel('Preferred Language', required: false),
        const SizedBox(height: 8),
        _buildDropdown(value: _preferredLanguage, items: _languages, hint: 'Select language', helperText: 'Select your preferred language', onChanged: (val) => setState(() => _preferredLanguage = val!)),
        const SizedBox(height: 20),
        _buildSwitchTile(title: 'Enable Notifications', subtitle: 'Receive alerts for new orders and updates', value: _enableNotifications, onChanged: (val) => setState(() => _enableNotifications = val)),
        const SizedBox(height: 12),
        _buildSwitchTile(title: 'Auto Backup', subtitle: 'Automatically backup your store data daily', value: _enableAutoBackup, onChanged: (val) => setState(() => _enableAutoBackup = val)),
        const SizedBox(height: 32),
        _buildFooterButtons(isLast: true),
      ],
    );
  }

  // ─────────── Reusable Widgets ───────────

  Widget _buildImageUploadBox() {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 160),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4), width: 2),
        ),
        child: _coverImageBytes != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(_coverImageBytes!, fit: BoxFit.cover, width: double.infinity, height: 200),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _coverImageBytes = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 52,
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 44, height: 36,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)),
                              child: const Icon(Icons.image_outlined, color: Colors.green, size: 22),
                            ),
                          ),
                          Positioned(
                            left: 0, top: 0,
                            child: Container(
                              width: 38, height: 30,
                              decoration: BoxDecoration(color: const Color(0xFFEDE9FE), borderRadius: BorderRadius.circular(6)),
                              child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF6366F1), size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Drag & drop your image here', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('or click to browse files', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: _pickCoverImage,
                      icon: const Icon(Icons.folder_open_outlined, size: 16),
                      label: const Text('Browse Files'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: const BoxDecoration(color: Color(0xFFEDE9FE), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
        children: required ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
          ),
        ),
        if (helperText != null && helperText.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(helperText, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
      ],
    );
  }

  Widget _buildStoreCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Store Code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        TextFormField(
          enabled: false,
          decoration: InputDecoration(
            hintText: 'Auto-generated',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
        Padding(padding: const EdgeInsets.only(top: 4), child: Text('This code will be generated automatically', style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
      ],
    );
  }

  Widget _buildBranchModelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: const TextSpan(text: 'Branch Management Model', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)), children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
        const SizedBox(height: 8),
        _buildDropdown(value: _branchManagementModel, items: _branchModels, hint: 'Select branch model', helperText: 'Select how you want to manage branches', onChanged: (val) => setState(() => _branchManagementModel = val!)),
      ],
    );
  }

  Widget _buildSalesTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: const TextSpan(text: 'Sales Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)), children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
        const SizedBox(height: 8),
        _buildDropdown(value: _salesType, items: _salesTypes, hint: 'Select sales type', helperText: 'Select your sales type', onChanged: (val) => setState(() => _salesType = val!)),
      ],
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required String hint, required String helperText, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis))).toList(),
        ),
        if (helperText.isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text(helperText, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
      ],
    );
  }

  Widget _buildContactField(String label, TextEditingController ctrl, String hint, String helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        _buildTextField(controller: ctrl, hint: hint, helperText: helper.isNotEmpty ? helper : null),
      ],
    );
  }

  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B), fontSize: 14)),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ])),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF6366F1)),
        ],
      ),
    );
  }

  Widget _buildFooterButtons({bool isLast = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_currentStep > 0) ...[
          OutlinedButton.icon(
            onPressed: _prevStep,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
        ],
        ElevatedButton.icon(
          onPressed: _nextStep,
          icon: Icon(isLast ? Icons.check_rounded : Icons.arrow_forward_rounded, size: 16),
          label: Text(isLast ? 'Create Store' : 'Next Step →'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(bool isMobile) {
    final primaryBox = _buildCategorySelectionBox(
      title: 'Primary Categories',
      subtitle: 'Main product categories in your system',
      icon: Icons.layers,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
      badgeText: '3 Available',
      badgeTextColor: const Color(0xFF8B5CF6),
      badgeBgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
      searchHint: 'Search categories...',
      selectAllValue: _selectAllPrimary,
      onSelectAllChanged: (val) {
        setState(() {
          _selectAllPrimary = val ?? false;
          if (_selectAllPrimary) {
            _selectedPrimary = List.from(_dummyPrimary);
          } else {
            _selectedPrimary.clear();
          }
          if (_selectedPrimary.isEmpty) {
             _selectedSub.clear(); _selectAllSub = false;
             _selectedBrands.clear(); _selectAllBrands = false;
             _selectedProducts.clear(); _selectAllProducts = false;
          }
        });
      },
      child: ListView(
        children: _dummyPrimary.map((e) => _buildCategoryGridItem(
          title: e,
          subtitle: 'Select this primary category',
          icon: Icons.local_offer,
          iconColor: const Color(0xFF8B5CF6),
          value: _selectedPrimary.contains(e),
          onChanged: (val) {
            setState(() {
              if (val == true) _selectedPrimary.add(e);
              else _selectedPrimary.remove(e);
              _selectAllPrimary = _selectedPrimary.length == _dummyPrimary.length;
              if (_selectedPrimary.isEmpty) {
                 _selectedSub.clear(); _selectAllSub = false;
                 _selectedBrands.clear(); _selectAllBrands = false;
                 _selectedProducts.clear(); _selectAllProducts = false;
              }
            });
          },
        )).toList(),
      ),
    );

    final subBox = _buildCategorySelectionBox(
      title: 'Sub Categories',
      subtitle: 'Browse and manage sub categories',
      icon: Icons.account_tree,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
      badgeText: _selectedPrimary.isEmpty ? '0 Showing' : '1 Showing',
      badgeTextColor: const Color(0xFF10B981),
      badgeBgColor: const Color(0xFF10B981).withOpacity(0.1),
      searchHint: 'Search sub categories...',
      selectAllValue: _selectAllSub,
      onSelectAllChanged: (val) {
        if (_selectedPrimary.isEmpty) return;
        setState(() {
          _selectAllSub = val ?? false;
          if (_selectAllSub) _selectedSub = List.from(_dummySub);
          else _selectedSub.clear();
        });
      },
      child: _selectedPrimary.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, color: Color(0xFF64748B), size: 24),
                SizedBox(height: 8),
                Text('Select a primary category to see its sub-categories', style: TextStyle(color: Color(0xFF64748B), fontSize: 12), textAlign: TextAlign.center),
              ],
            ),
          )
        : ListView(
            children: _dummySub.map((e) => _buildCategoryGridItem(
              title: e,
              subtitle: 'under ${_selectedPrimary.first}',
              icon: Icons.local_offer,
              iconColor: const Color(0xFF10B981),
              value: _selectedSub.contains(e),
              onChanged: (val) {
                setState(() {
                  if (val == true) _selectedSub.add(e);
                  else _selectedSub.remove(e);
                  _selectAllSub = _selectedSub.length == _dummySub.length;
                });
              },
            )).toList(),
          ),
    );

    final brandsBox = _buildCategorySelectionBox(
      title: 'Brands',
      subtitle: 'All registered brands',
      icon: Icons.shield,
      iconColor: const Color(0xFF3B82F6),
      iconBgColor: const Color(0xFF3B82F6).withOpacity(0.1),
      badgeText: _selectedSub.isEmpty ? '0 Available' : '1 Available',
      badgeTextColor: const Color(0xFF3B82F6),
      badgeBgColor: const Color(0xFF3B82F6).withOpacity(0.1),
      searchHint: 'Search brands...',
      selectAllValue: _selectAllBrands,
      onSelectAllChanged: (val) {
        if (_selectedSub.isEmpty) return;
        setState(() {
          _selectAllBrands = val ?? false;
          if (_selectAllBrands) _selectedBrands = List.from(_dummyBrands);
          else _selectedBrands.clear();
        });
      },
      child: _selectedSub.isEmpty
        ? const Center(
            child: Text('No brands match ""', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          )
        : ListView(
            children: _dummyBrands.map((e) => _buildCategoryGridItem(
              title: e,
              subtitle: 'Brand: $e',
              icon: Icons.branding_watermark,
              iconColor: const Color(0xFF3B82F6),
              value: _selectedBrands.contains(e),
              onChanged: (val) {
                setState(() {
                  if (val == true) _selectedBrands.add(e);
                  else _selectedBrands.remove(e);
                  _selectAllBrands = _selectedBrands.length == _dummyBrands.length;
                });
              },
            )).toList(),
          ),
    );

    final productsBox = _buildCategorySelectionBox(
      title: 'Products',
      subtitle: 'All available products',
      icon: Icons.shopping_bag,
      iconColor: const Color(0xFFF97316),
      iconBgColor: const Color(0xFFF97316).withOpacity(0.1),
      badgeText: _selectedBrands.isEmpty ? '0 Available' : '3 Available',
      badgeTextColor: const Color(0xFFF97316),
      badgeBgColor: const Color(0xFFF97316).withOpacity(0.1),
      searchHint: 'Search products...',
      selectAllValue: _selectAllProducts,
      onSelectAllChanged: (val) {
        if (_selectedBrands.isEmpty) return;
        setState(() {
          _selectAllProducts = val ?? false;
          if (_selectAllProducts) _selectedProducts = List.from(_dummyProducts);
          else _selectedProducts.clear();
        });
      },
      child: _selectedBrands.isEmpty
        ? const Center(
            child: Text('No products match ""', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          )
        : ListView(
            children: _dummyProducts.map((e) => _buildCategoryGridItem(
              title: e,
              subtitle: 'Product: $e',
              icon: Icons.shopping_bag_outlined,
              iconColor: const Color(0xFFF97316),
              value: _selectedProducts.contains(e),
              onChanged: (val) {
                setState(() {
                  if (val == true) _selectedProducts.add(e);
                  else _selectedProducts.remove(e);
                  _selectAllProducts = _selectedProducts.length == _dummyProducts.length;
                });
              },
            )).toList(),
          ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
            children: [
              SizedBox(height: 380, child: primaryBox),
              const SizedBox(height: 16),
              SizedBox(height: 380, child: subBox),
              const SizedBox(height: 16),
              SizedBox(height: 380, child: brandsBox),
              const SizedBox(height: 16),
              SizedBox(height: 380, child: productsBox),
            ],
          )
        else ...[
          Row(
            children: [
              Expanded(child: SizedBox(height: 380, child: primaryBox)),
              const SizedBox(width: 16),
              Expanded(child: SizedBox(height: 380, child: subBox)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SizedBox(height: 380, child: brandsBox)),
              const SizedBox(width: 16),
              Expanded(child: SizedBox(height: 380, child: productsBox)),
            ],
          ),
        ],
        const SizedBox(height: 32),
        // Selected Summary Section
        _buildSelectionSummary(),
      ],
    );
  }
  
  Widget _buildSelectionSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(Icons.check_circle, const Color(0xFF8B5CF6), 'Primary', _selectedPrimary),
          if (_selectedSub.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(Icons.check_circle, const Color(0xFF10B981), 'Sub', _selectedSub),
          ],
          if (_selectedBrands.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(Icons.check_circle, const Color(0xFF3B82F6), 'Brands', _selectedBrands),
          ],
          if (_selectedProducts.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(Icons.check_circle, const Color(0xFFF97316), 'Products', _selectedProducts),
          ],
          if (_selectedPrimary.isEmpty)
            const Text('No categories selected yet.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, Color color, String label, List<String> items) {
    if (items.isEmpty) return const SizedBox();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B), fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Icon(Icons.close, color: color, size: 12),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelectionBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String badgeText,
    required Color badgeTextColor,
    required Color badgeBgColor,
    required String searchHint,
    required bool selectAllValue,
    required void Function(bool?) onSelectAllChanged,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: selectAllValue,
                  onChanged: onSelectAllChanged,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: Colors.grey.shade300),
                  activeColor: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badgeBgColor, borderRadius: BorderRadius.circular(12)),
                child: Text(badgeText, style: TextStyle(color: badgeTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              hintText: searchHint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              suffixIcon: const Icon(Icons.filter_alt_outlined, color: Color(0xFF64748B), size: 18),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildCategoryGridItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: value ? iconColor : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          color: value ? iconColor.withOpacity(0.02) : Colors.white,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: Colors.grey.shade300),
                activeColor: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SearchableDropdownDialog extends StatefulWidget {
  final List<String> items;
  final String hint;

  const _SearchableDropdownDialog({required this.items, required this.hint});

  @override
  State<_SearchableDropdownDialog> createState() => _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<_SearchableDropdownDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchCtrl.addListener(() {
      setState(() {
        final query = _searchCtrl.text.toLowerCase();
        _filteredItems = widget.items.where((item) => item.toLowerCase().contains(query)).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 400),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1))),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
                    onTap: () => Navigator.pop(context, item),
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
