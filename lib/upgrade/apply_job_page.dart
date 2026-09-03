import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../user_service.dart';
import 'job_list_page.dart';
import 'applied_list_page.dart';

// Removed PastExperience class

class ApplyJobPage extends StatefulWidget {
  const ApplyJobPage({super.key});

  @override
  State<ApplyJobPage> createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  bool _isApplyJobExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController(
    text: "Sabari",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "sabarishwaran1718@gmail.com",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "8012107626",
  );
  final TextEditingController _locationController = TextEditingController(
    text: "Coimbatore",
  );
  final TextEditingController _dobController = TextEditingController();

  int _currentStep = 1;

  // Step 2 Controllers
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _licenseExpiryController =
      TextEditingController();
  final TextEditingController _aircraftTypeController = TextEditingController();
  final TextEditingController _vesselTypeController = TextEditingController();

  String? _selectedGender;
  String? _selectedVehicleCategory;
  String? _selectedLicenseType;
  String? _selectedRangePreference;

  String? _selectedVehicleUsage;
  String? _selectedVehicleWeight;
  bool _hasExperience = false;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<PastExperience> _pastExperiences = [PastExperience()];
  List<String> _selectedDistricts = [];
  List<String> _selectedStates = [];
  
  final List<String> _districtsList = [
    "Ariyalur", "Chengalpattu", "Chennai", "Coimbatore", "Cuddalore",
    "Dharmapuri", "Dindigul", "Erode", "Kallakurichi", "Kanchipuram",
    "Kanyakumari", "Karur", "Krishnagiri", "Madurai", "Mayiladuthurai",
    "Nagapattinam", "Namakkal", "Nilgiris", "Perambalur", "Pudukkottai",
    "Ramanathapuram", "Ranipet", "Salem", "Sivaganga", "Tenkasi",
    "Thanjavur", "Theni", "Thoothukudi", "Tiruchirappalli", "Tirunelveli",
    "Tirupathur", "Tiruppur", "Tiruvallur", "Tiruvannamalai", "Tiruvarur",
    "Vellore", "Viluppuram", "Virudhunagar"
  ];
  
  final List<String> _statesList = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
    "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
    "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya",
    "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim",
    "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand",
    "West Bengal"
  ];

  // Step 3 Variables
  String? _selectedEmploymentType;
  String? _selectedShiftPreference;
  String? _selectedRelocation;
  final TextEditingController _expectedSalaryController =
      TextEditingController();
  final TextEditingController _joiningAvailabilityController =
      TextEditingController();
  String? _resumeFileName;
  String? _resumeFilePath;

  String? _certificateFileName;
  String? _certificateFilePath;

  String? _licenseFileName;
  String? _licenseFilePath;

  bool _isSubmitting = false;

  Future<void> _fetchStatesAndDistricts() async {
    try {
      final statesRes = await http.get(Uri.parse('https://localcity.jobes24x7.com/api/states/names'));
      if (statesRes.statusCode == 200) {
        final data = jsonDecode(statesRes.body);
        if (data['data'] != null && data['data']['data'] != null) {
          final List states = data['data']['data'];
          setState(() {
            _statesList.clear();
            _statesList.addAll(states.map((e) => e['name'].toString().trim()));
          });
        }
      }

      final districtsRes = await http.get(Uri.parse('https://localcity.jobes24x7.com/api/districts/names'));
      if (districtsRes.statusCode == 200) {
        final data = jsonDecode(districtsRes.body);
        if (data['data'] != null && data['data']['data'] != null) {
          final List districts = data['data']['data'];
          setState(() {
            _districtsList.clear();
            _districtsList.addAll(districts.map((e) => e['name'].toString().trim()));
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching states/districts: $e");
    }
  }

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      final file = result.files.first;
      final sizeInMb = file.size / (1024 * 1024);

      if (sizeInMb > 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("File size exceeds 5MB limit."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        if (type == 'certificate') {
          _certificateFileName = file.name;
        } else if (type == 'license') {
          _licenseFileName = file.name;
        } else if (type == 'resume') {
          _resumeFileName = file.name;
        }
      });

      // Upload base64
      final bytes = file.bytes;
      if (bytes != null) {
        final base64String = base64Encode(bytes);
        final extension = file.extension?.toLowerCase() ?? 'png';
        String mimeType = 'image/png';
        if (extension == 'jpg' || extension == 'jpeg') mimeType = 'image/jpeg';
        else if (extension == 'pdf') mimeType = 'application/pdf';
        
        final base64Data = 'data:$mimeType;base64,$base64String';
        
        try {
          final res = await http.post(
            Uri.parse('https://managelogin.jobes24x7.com/api/upload-base64'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'base64Data': base64Data,
              'folder': 'driver_docs'
            })
          );
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data['data'] != null && data['data']['path'] != null) {
              final path = data['data']['path'];
              setState(() {
                if (type == 'certificate') {
                  _certificateFilePath = path;
                } else if (type == 'license') {
                  _licenseFilePath = path;
                } else if (type == 'resume') {
                  _resumeFilePath = path;
                }
              });
            }
          }
        } catch (e) {
          debugPrint("Error uploading file: $e");
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStatesAndDistricts();
    _experienceController.addListener(() {
      final hasExp = _experienceController.text.trim().isNotEmpty;
      if (_hasExperience != hasExp) {
        setState(() {
          _hasExperience = hasExp;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var exp in _pastExperiences) {
      exp.dispose();
    }
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    _experienceController.dispose();
    _remarksController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _expectedSalaryController.dispose();
    _joiningAvailabilityController.dispose();
    _aircraftTypeController.dispose();
    _vesselTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          debugPrint("Drawer opened");
        } else {
          debugPrint("Drawer closed");
        }
      },
      drawer: !isDesktop
          ? Drawer(elevation: 0, child: _buildSidebar(context, isDrawer: true))
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop) _buildSidebar(context, isDrawer: false),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 900),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildStepper(),
                            const SizedBox(height: 32),
                            _buildSectionTitle(),
                            const SizedBox(height: 16),
                            // Custom dotted divider below
                            _buildDottedDivider(),
                            const SizedBox(height: 24),
                            _buildFormFields(isDesktop),
                            const SizedBox(height: 32),
                            _buildBottomButtons(),
                          ],
                        ),
                      ),
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

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: isDesktop ? 70 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          children: [
            if (!isDesktop)
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B)),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search Voxo ..",
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.dark_mode_outlined,
              color: Color(0xFF64748B),
              size: 22,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF), // Light indigo background
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.send_rounded,
            color: Color(0xFF4F46E5), // Indigo
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Apply For A Job",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Complete your application in 3 simple steps.",
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildStep(
            1,
            "Driver Details",
            isActive: true,
            isCompleted: _currentStep > 1,
          ),
        ),
        _buildStepLine(isActive: _currentStep >= 2),
        Expanded(
          flex: 3,
          child: _buildStep(
            2,
            "Preferences",
            isActive: _currentStep >= 2,
            isCompleted: _currentStep > 2,
          ),
        ),
        _buildStepLine(isActive: _currentStep >= 3),
        Expanded(
          flex: 3,
          child: _buildStep(
            3,
            "Preview",
            isActive: _currentStep >= 3,
            isCompleted: _currentStep > 3,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(
    int step,
    String title, {
    required bool isActive,
    bool isCompleted = false,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4F46E5) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      flex: 2,
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(top: 15, left: 4, right: 4),
        color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildSectionTitle() {
    String title = "";
    IconData icon = Icons.person;

    if (_currentStep == 1) {
      title = "Driver Details";
      icon = Icons.local_shipping;
    } else if (_currentStep == 2) {
      title = "Preferences & Upload";
      icon = Icons.upload_file;
    } else if (_currentStep == 3) {
      title = "Application Preview";
      icon = Icons.remove_red_eye;
    }

    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4F46E5), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF4F46E5),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDottedDivider() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }

  Widget _buildFormFields(bool isDesktop) {
    if (_currentStep == 1) {
      return _buildStep2Fields(isDesktop);
    } else if (_currentStep == 2) {
      return _buildStep3Fields(isDesktop);
    } else if (_currentStep == 3) {
      return _buildStep4Fields(isDesktop);
    } else if (_currentStep == 4) {
      return _buildSuccessView(isDesktop);
    }
    return const SizedBox();
  }

  // Removed _buildStep1Fields
  Widget _buildStep2Fields(bool isDesktop) {
    if (isDesktop) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Vehicle Category",
                  ["Roadway", "Airway", "Waterway"],
                  value: _selectedVehicleCategory,
                  onChanged: (val) =>
                      setState(() => _selectedVehicleCategory = val),
                  hintText: "Select Category",
                  isRequired: true,
                ),
              ),
              if (_selectedVehicleCategory == "Roadway") ...[
                const SizedBox(width: 24),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildDropdownField(
                      "Vehicle Usage",
                      ["Public (Passenger)", "Carrier (Goods)"],
                      value: _selectedVehicleUsage,
                      onChanged: (val) =>
                          setState(() => _selectedVehicleUsage = val),
                      hintText: "Select Usage",
                      isRequired: true,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildDropdownField(
                      "Vehicle Weight",
                      ["Light Vehicle", "Heavy Vehicle"],
                      value: _selectedVehicleWeight,
                      onChanged: (val) =>
                          setState(() => _selectedVehicleWeight = val),
                      hintText: "Select Weight",
                      isRequired: true,
                    ),
                  ),
                ),
              ] else if (_selectedVehicleCategory == "Airway") ...[
                const SizedBox(width: 24),
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _buildTextField(
                      "Aircraft Type",
                      _aircraftTypeController,
                      isRequired: true,
                      hintText: "e.g. Commercial Pilot",
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
              ] else if (_selectedVehicleCategory == "Waterway") ...[
                const SizedBox(width: 24),
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _buildTextField(
                      "Vessel Type",
                      _vesselTypeController,
                      isRequired: true,
                      hintText: "e.g. Cargo Ship Captain",
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
              ] else ...[
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
                const SizedBox(width: 24),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Total Experience (Years)",
                  _experienceController,
                  isRequired: true,
                  hintText: "02",
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox()),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _hasExperience
                ? Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: _buildPastExperiencesSection(isDesktop),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildUploadBox(
                  "Experience Certificate (Optional)",
                  "Click to upload Certificate",
                  fileName: _certificateFileName,
                  onTap: () => _pickFile('certificate'),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTextArea(
                  "Remarks (Optional)",
                  _remarksController,
                  hintText: "Any additional remarks...",
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "License Number",
                  _licenseNumberController,
                  isRequired: true,
                  hintText: "Enter License Number",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  "License Type",
                  ["LMV", "HMV", "Commercial", "Transport"],
                  value: _selectedLicenseType,
                  onChanged: (val) =>
                      setState(() => _selectedLicenseType = val),
                  hintText: "Select License Type",
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDateField(
                  "License Expiry Date",
                  _licenseExpiryController,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Driving Range Preference",
                  [
                    "Within City",
                    "District to District",
                    "State to State",
                    "All Over India",
                  ],
                  value: _selectedRangePreference,
                  onChanged: (val) =>
                      setState(() {
                        _selectedRangePreference = val;
                        _selectedDistricts.clear();
                        _selectedStates.clear();
                      }),
                  hintText: "Select Range Preference",
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: (_selectedRangePreference == "Within City" ||
                          _selectedRangePreference == "District to District")
                      ? SearchableMultiSelectDropdown(
                          label: "Select Preferred Districts",
                          items: _districtsList,
                          selectedItems: _selectedDistricts,
                          hintText: "Search Districts...",
                          isRequired: true,
                          onChanged: (val) {
                            setState(() {
                              _selectedDistricts = val;
                            });
                          },
                        )
                      : (_selectedRangePreference == "State to State")
                          ? SearchableMultiSelectDropdown(
                              label: "Select Preferred States",
                              items: _statesList,
                              selectedItems: _selectedStates,
                              hintText: "Search States...",
                              isRequired: true,
                              onChanged: (val) {
                                setState(() {
                                  _selectedStates = val;
                                });
                              },
                            )
                          : const SizedBox(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildUploadBox(
            "Driving License",
            "Click to upload Driving License",
            isRequired: true,
            fileName: _licenseFileName,
            onTap: () => _pickFile('license'),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildDropdownField(
            "Vehicle Category",
            ["Roadway", "Airway", "Waterway"],
            value: _selectedVehicleCategory,
            onChanged: (val) => setState(() => _selectedVehicleCategory = val),
            hintText: "Select Category",
            isRequired: true,
          ),
          if (_selectedVehicleCategory == "Roadway") ...[
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildDropdownField(
                "Vehicle Usage",
                ["Public (Passenger)", "Carrier (Goods)"],
                value: _selectedVehicleUsage,
                onChanged: (val) => setState(() => _selectedVehicleUsage = val),
                hintText: "Select Usage",
                isRequired: true,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildDropdownField(
                "Vehicle Weight",
                ["Light Vehicle", "Heavy Vehicle"],
                value: _selectedVehicleWeight,
                onChanged: (val) =>
                    setState(() => _selectedVehicleWeight = val),
                hintText: "Select Weight",
                isRequired: true,
              ),
            ),
          ] else if (_selectedVehicleCategory == "Airway") ...[
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _buildTextField(
                "Aircraft Type",
                _aircraftTypeController,
                isRequired: true,
                hintText: "e.g. Commercial Pilot",
              ),
            ),
          ] else if (_selectedVehicleCategory == "Waterway") ...[
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _buildTextField(
                "Vessel Type",
                _vesselTypeController,
                isRequired: true,
                hintText: "e.g. Cargo Ship Captain",
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildTextField(
            "Total Experience (Years)",
            _experienceController,
            isRequired: true,
            hintText: "02",
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _hasExperience
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: _buildPastExperiencesSection(isDesktop),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 16),
          _buildUploadBox(
            "Experience Certificate (Optional)",
            "Click to upload Certificate",
            fileName: _certificateFileName,
            onTap: () => _pickFile('certificate'),
          ),
          const SizedBox(height: 16),
          _buildTextArea(
            "Remarks (Optional)",
            _remarksController,
            hintText: "Any additional remarks...",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "License Number",
            _licenseNumberController,
            isRequired: true,
            hintText: "Enter License Number",
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            "License Type",
            ["LMV", "HMV", "Commercial", "Transport"],
            value: _selectedLicenseType,
            onChanged: (val) => setState(() => _selectedLicenseType = val),
            hintText: "Select License Type",
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            "License Expiry Date",
            _licenseExpiryController,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            "Driving Range Preference",
            [
              "Within City",
              "District to District",
              "State to State",
              "All Over India",
            ],
            value: _selectedRangePreference,
            onChanged: (val) => setState(() {
              _selectedRangePreference = val;
              _selectedDistricts.clear();
              _selectedStates.clear();
            }),
            hintText: "Select Range Preference",
            isRequired: true,
          ),
          if (_selectedRangePreference == "Within City" ||
              _selectedRangePreference == "District to District") ...[
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: SearchableMultiSelectDropdown(
                label: "Select Preferred Districts",
                items: _districtsList,
                selectedItems: _selectedDistricts,
                hintText: "Search Districts...",
                isRequired: true,
                onChanged: (val) {
                  setState(() {
                    _selectedDistricts = val;
                  });
                },
              ),
            ),
          ] else if (_selectedRangePreference == "State to State") ...[
            const SizedBox(height: 16),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: SearchableMultiSelectDropdown(
                label: "Select Preferred States",
                items: _statesList,
                selectedItems: _selectedStates,
                hintText: "Search States...",
                isRequired: true,
                onChanged: (val) {
                  setState(() {
                    _selectedStates = val;
                  });
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildUploadBox(
            "Driving License",
            "Click to upload Driving License",
            isRequired: true,
            fileName: _licenseFileName,
            onTap: () => _pickFile('license'),
          ),
        ],
      );
    }
  }

  Widget _buildBottomButtons() {
    if (_currentStep == 4) {
      return Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                 Navigator.of(context).pushAndRemoveUntil(
                   MaterialPageRoute(builder: (context) => const HomePage()),
                   (Route<dynamic> route) => false,
                 );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Back to Home",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_currentStep > 1) ...[
          OutlinedButton(
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Back",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  if (_currentStep < 3) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    _submitApplication();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: _isSubmitting 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentStep == 3 ? "Submit Application" : "Next Step",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (_currentStep < 3) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (isRequired)
              const Text(
                " *",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (isRequired)
              const Text(
                " *",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF10B981), // header background color
                        onPrimary: Colors.white, // header text color
                        onSurface: Color(0xFF1E293B), // body text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(
                            0xFF10B981,
                          ), // button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.day.toString().padLeft(2, '0')}-"
                    "${pickedDate.month.toString().padLeft(2, '0')}-"
                    "${pickedDate.year}";
                setState(() {
                  controller.text = formattedDate;
                });
              }
            },
            decoration: InputDecoration(
              hintText: "dd-mm-yyyy",
              hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF64748B),
                size: 18,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> options, {
    bool isRequired = false,
    String? value,
    required Function(String?) onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (isRequired)
              const Text(
                " *",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hintText ?? "Select",
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B),
              ),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E293B),
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

  Widget _buildTextArea(
    String label,
    TextEditingController controller, {
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(
    String label,
    String actionText, {
    bool isRequired = false,
    String? fileName,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (isRequired)
              const Text(
                " *",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: fileName != null
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (fileName != null) ...[
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF10B981),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      fileName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Click to change file",
                    style: TextStyle(color: Color(0xFF3B82F6), fontSize: 11),
                  ),
                ] else ...[
                  const Icon(
                    Icons.cloud_upload_rounded,
                    color: Color(0xFF64748B),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "PDF, JPG or PNG (max. 5MB)",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
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
              top: isDrawer ? 40 : 24,
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
                        fontSize: 10,
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
            onTap: () {
              debugPrint("Dashboard clicked");
              if (isDrawer) Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.widgets_outlined,
            "Switch Portal",
            onTap: () {
              debugPrint("Switch Portal clicked");
              if (isDrawer) Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
          const SizedBox(height: 8),
          _buildApplyJobExpansion(
            context,
            isDrawer: isDrawer,
            pinkColor: pinkColor,
            activeItem: 'apply_for_job',
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {VoidCallback? onTap}) =>
      ListTile(
        leading: Icon(icon, color: Colors.white60, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        onTap: onTap,
        dense: true,
      );

  Widget _sidebarSubItem(
    String title, {
    Color? textColor,
    VoidCallback? onTap,
  }) => ListTile(
    contentPadding: const EdgeInsets.only(left: 54),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "-",
          style: TextStyle(
            color: Colors.white30,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
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

  Widget _buildApplyJobExpansion(
    BuildContext context, {
    required bool isDrawer,
    required Color pinkColor,
    required String activeItem,
  }) {
    return Column(
      children: [
        // Header tile — always white pill style
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
              Icons.send_outlined,
              color: Color(0xFF1E293B),
              size: 20,
            ),
            title: const Text(
              'Apply Job',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimatedRotation(
                turns: _isApplyJobExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
            ),
            dense: true,
            onTap: () {
              setState(() {
                _isApplyJobExpanded = !_isApplyJobExpanded;
                debugPrint(
                  _isApplyJobExpanded
                      ? 'Apply Job menu expanded'
                      : 'Apply Job menu collapsed',
                );
              });
            },
          ),
        ),
        // Animated child items
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          crossFadeState: _isApplyJobExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              const SizedBox(height: 6),
              // Job List
              activeItem == 'job_list'
                  ? _activeSubItem(
                      'Job List',
                      onTap: () {
                        debugPrint('Job List clicked');
                        if (isDrawer) Navigator.pop(context);
                      },
                    )
                  : _sidebarSubItem(
                      'Job List',
                      onTap: () {
                        debugPrint('Job List clicked');
                        if (isDrawer) Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JobListPage(),
                          ),
                        );
                      },
                    ),
              // Applied List
              activeItem == 'applied_list'
                  ? _activeSubItem(
                      'Applied List',
                      onTap: () {
                        debugPrint('Applied List clicked');
                        if (isDrawer) Navigator.pop(context);
                      },
                    )
                  : _sidebarSubItem(
                      'Applied List',
                      onTap: () {
                        debugPrint('Applied List clicked');
                        if (isDrawer) Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppliedListPage(),
                          ),
                        );
                      },
                    ),
              // Apply for Job
              activeItem == 'apply_for_job'
                  ? _activeSubItem(
                      'Apply for Job',
                      textColor: pinkColor,
                      onTap: () {
                        debugPrint('Apply For Job clicked');
                        if (isDrawer) Navigator.pop(context);
                      },
                    )
                  : _sidebarSubItem(
                      'Apply for Job',
                      textColor: pinkColor,
                      onTap: () {
                        debugPrint('Apply For Job clicked');
                        if (isDrawer) Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ApplyJobPage(),
                          ),
                        );
                      },
                    ),
            ],
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  /// Highlighted active sub-item
  Widget _activeSubItem(
    String title, {
    Color? textColor,
    VoidCallback? onTap,
  }) => Container(
    margin: const EdgeInsets.only(left: 12, right: 0),
    decoration: const BoxDecoration(
      color: Color(0xFF334155),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
      ),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.only(left: 42),
      dense: true,
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    ),
  );

  // Removed _buildPastExperiencesSection and _buildPastExperienceItem

  Widget _buildPastExperiencesSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Past Experiences",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: _pastExperiences.length,
          itemBuilder: (context, index, animation) {
            return _buildPastExperienceItem(
              _pastExperiences[index],
              index,
              animation,
              isDesktop,
            );
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: isDesktop ? Alignment.centerRight : Alignment.center,
          child: InkWell(
            onTap: () {
              final newExp = PastExperience();
              _pastExperiences.add(newExp);
              _listKey.currentState?.insertItem(
                _pastExperiences.length - 1,
                duration: const Duration(milliseconds: 300),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF3B82F6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Color(0xFF3B82F6), size: 16),
                  SizedBox(width: 8),
                  Text(
                    "Add Another",
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPastExperienceItem(
    PastExperience exp,
    int index,
    Animation<double> animation,
    bool isDesktop,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              "Company Name",
                              exp.companyController,
                              isRequired: true,
                              hintText: "e.g. ABC Logistics",
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              "Vehicle Driven",
                              exp.vehicleController,
                              isRequired: true,
                              hintText: "e.g. Ashok Leyland, Tata Ace",
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDropdownField(
                                  "Past Driving Range",
                                  [
                                    "Within City",
                                    "District to District",
                                    "State to State",
                                    "All Over India",
                                    "Other",
                                  ],
                                  value: exp.drivingRange,
                                  onChanged: (val) {
                                    setState(() {
                                      exp.drivingRange = val;
                                    });
                                  },
                                  hintText: "Select Range",
                                  isRequired: true,
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  child: (exp.drivingRange == "Within City" ||
                                          exp.drivingRange == "District to District" ||
                                          exp.drivingRange == "State to State")
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16.0,
                                          ),
                                          child: _buildTextField(
                                            "City/District & Area",
                                            exp.rangeDetailsController,
                                            isRequired: true,
                                            hintText: exp.drivingRange == "Within City"
                                                ? "e.g. Chennai, T Nagar"
                                                : exp.drivingRange == "District to District"
                                                    ? "e.g. Coimbatore to Erode"
                                                    : "e.g. Tamil Nadu to Kerala",
                                          ),
                                        )
                                      : const SizedBox(width: double.infinity),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            "Company Name",
                            exp.companyController,
                            isRequired: true,
                            hintText: "e.g. ABC Logistics",
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            "Vehicle Driven",
                            exp.vehicleController,
                            isRequired: true,
                            hintText: "e.g. Ashok Leyland, Tata Ace",
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            "Past Driving Range",
                            [
                              "Within City",
                              "District to District",
                              "State to State",
                              "All Over India",
                              "Other",
                            ],
                            value: exp.drivingRange,
                            onChanged: (val) {
                              setState(() {
                                exp.drivingRange = val;
                              });
                            },
                            hintText: "Select Range",
                            isRequired: true,
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: (exp.drivingRange == "Within City" ||
                                    exp.drivingRange == "District to District" ||
                                    exp.drivingRange == "State to State")
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: _buildTextField(
                                      "City/District & Area",
                                      exp.rangeDetailsController,
                                      isRequired: true,
                                      hintText: exp.drivingRange == "Within City"
                                          ? "e.g. Chennai, T Nagar"
                                          : exp.drivingRange == "District to District"
                                              ? "e.g. Coimbatore to Erode"
                                              : "e.g. Tamil Nadu to Kerala",
                                    ),
                                  )
                                : const SizedBox(width: double.infinity),
                          ),
                        ],
                      ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: InkWell(
                  onTap: () {
                    final removedIndex = _pastExperiences.indexOf(exp);
                    if (removedIndex != -1) {
                      final removedItem = _pastExperiences.removeAt(
                        removedIndex,
                      );
                      _listKey.currentState?.removeItem(
                        removedIndex,
                        (context, animation) => _buildPastExperienceItem(
                          removedItem,
                          removedIndex,
                          animation,
                          isDesktop,
                        ),
                        duration: const Duration(milliseconds: 300),
                      );
                      Future.delayed(const Duration(milliseconds: 350), () {
                        removedItem.dispose();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStep3Fields(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDesktop) ...[
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Employment Type",
                  ["Full Time", "Part Time", "Contract", "Permanent"],
                  value: _selectedEmploymentType,
                  onChanged: (val) =>
                      setState(() => _selectedEmploymentType = val),
                  hintText: "Select Type",
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  "Shift Preference",
                  ["Day Shift", "Night Shift", "Flexible"],
                  value: _selectedShiftPreference,
                  onChanged: (val) =>
                      setState(() => _selectedShiftPreference = val),
                  hintText: "Select Shift",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  "Relocation Ready? (Yes/No)",
                  ["Yes", "No"],
                  value: _selectedRelocation,
                  onChanged: (val) => setState(() => _selectedRelocation = val),
                  hintText: "Select",
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  "Expected Salary",
                  _expectedSalaryController,
                  hintText: "e.g. ₹25,000 / month",
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDateField(
                  "Joining Availability",
                  _joiningAvailabilityController,
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox()),
            ],
          ),
        ] else ...[
          _buildDropdownField(
            "Employment Type",
            ["Full Time", "Part Time", "Contract", "Permanent"],
            value: _selectedEmploymentType,
            onChanged: (val) => setState(() => _selectedEmploymentType = val),
            hintText: "Select Type",
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            "Shift Preference",
            ["Day Shift", "Night Shift", "Flexible"],
            value: _selectedShiftPreference,
            onChanged: (val) => setState(() => _selectedShiftPreference = val),
            hintText: "Select Shift",
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            "Relocation Ready? (Yes/No)",
            ["Yes", "No"],
            value: _selectedRelocation,
            onChanged: (val) => setState(() => _selectedRelocation = val),
            hintText: "Select",
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "Expected Salary",
            _expectedSalaryController,
            hintText: "e.g. ₹25,000 / month",
          ),
          const SizedBox(height: 16),
          _buildDateField(
            "Joining Availability",
            _joiningAvailabilityController,
          ),
        ],
        const SizedBox(height: 32),
        const Text(
          "Document Uploads (PDF/JPG/PNG)",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),
        _buildUploadBox(
          "Resume / CV (Optional)",
          "Click to upload Resume / CV",
          fileName: _resumeFileName,
          onTap: () => _pickFile('resume'),
        ),
      ],
    );
  }

  void _submitApplication() async {
    if (_nameController.text.trim().isEmpty ||
        _experienceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userData = await UserService().getUserData();
      final userMainId = userData['user_main_id']?.toString() ?? "";

      if (userMainId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found!"), backgroundColor: Colors.red),
          );
        }
        setState(() { _isSubmitting = false; });
        return;
      }

      String? formatToYMD(String? ddmmyyyy) {
        if (ddmmyyyy == null || ddmmyyyy.isEmpty) return null;
        final parts = ddmmyyyy.split('-');
        if (parts.length == 3) {
          return '${parts[2]}-${parts[1]}-${parts[0]}';
        }
        return ddmmyyyy;
      }

      String parseUsage(String? usage) {
        if (usage == "Carrier (Goods)") return "carrier";
        return "public";
      }

      String parseWeight(String? weight) {
        if (weight == "Heavy Vehicle") return "heavy";
        return "light";
      }

      final createPayload = {
        "user_main_id": userMainId,
        "vehicle_category": _selectedVehicleCategory?.toLowerCase().replaceAll(' ', '') ?? "roadway",
        "vehicle_usage": parseUsage(_selectedVehicleUsage),
        "airway_type": _aircraftTypeController.text.isNotEmpty ? _aircraftTypeController.text : null,
        "driving_license_upload": _licenseFilePath,
        "driving_range_preference": _selectedRangePreference?.toLowerCase().replaceAll(' ', '') ?? "",
        "employee_type": _selectedEmploymentType?.toLowerCase().replaceAll(' ', '_') ?? "",
        "expected_salary": int.tryParse(_expectedSalaryController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        "experience_certificate": _certificateFilePath,
        "joining_availability": _joiningAvailabilityController.text.isNotEmpty ? formatToYMD(_joiningAvailabilityController.text) : null,
        "license_expiry_date": formatToYMD(_licenseExpiryController.text),
        "license_number": _licenseNumberController.text,
        "license_type": _selectedLicenseType?.toLowerCase() ?? "",
        "relocation": _selectedRelocation?.toLowerCase() ?? "",
        "remarks": _remarksController.text.isNotEmpty ? _remarksController.text : null,
        "resume_upload": _resumeFilePath,
        "shift_preference": _selectedShiftPreference?.toLowerCase().replaceAll(' ', '_') ?? "",
        "total_experience": int.tryParse(_experienceController.text),
        "vehicle_weight": parseWeight(_selectedVehicleWeight),
        "vessel_type": _vesselTypeController.text.isNotEmpty ? _vesselTypeController.text : null,
      };

      // Remove null values to avoid backend validation errors on optional fields
      createPayload.removeWhere((key, value) => value == null || value == "");

      debugPrint("=== SUBMIT DRIVER PAYLOAD ===");
      debugPrint(jsonEncode(createPayload));

      final createRes = await http.post(
        Uri.parse('https://managelogin.jobes24x7.com/api/driver/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(createPayload),
      );

      debugPrint("=== SUBMIT DRIVER RESPONSE [${createRes.statusCode}] ===");
      debugPrint(createRes.body);

      if (createRes.statusCode == 200 || createRes.statusCode == 201) {
        final data = jsonDecode(createRes.body);
        int? driverDetailId;
        if (data['data'] != null && data['data']['data'] != null) {
          driverDetailId = data['data']['data']['id'];
        }

        if (driverDetailId != null) {
          // Add past experiences
          for (var exp in _pastExperiences) {
            final expPayload = {
              "user_main_id": userMainId,
              "driver_detail_id": driverDetailId,
              "company_name": exp.companyController.text,
              "vehicle_driven": exp.vehicleController.text,
              "city": null,
              "district": null,
              "experience_years": null,
              "past_driving_range": exp.drivingRange?.toLowerCase().replaceAll(' ', '_') ?? "",
              "state": null
            };
            
            if (exp.drivingRange == "State to State") {
              expPayload["state"] = exp.rangeDetailsController.text;
            } else if (exp.drivingRange == "Within City" || exp.drivingRange == "District to District") {
              expPayload["city"] = exp.rangeDetailsController.text;
            }

            debugPrint("=== SUBMIT EXPERIENCE PAYLOAD ===");
            debugPrint(jsonEncode(expPayload));
            
            final expRes = await http.post(
              Uri.parse('https://managelogin.jobes24x7.com/api/driver/experience/add'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(expPayload),
            );
            
            debugPrint("=== EXPERIENCE RESPONSE [${expRes.statusCode}] ===");
            debugPrint(expRes.body);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Application Submitted Successfully"),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          
          setState(() {
            _currentStep = 4; // Move to preview/success step
          });
        }
      } else {
        if (mounted) {
          String errorMsg = "Failed to submit application";
          try {
            final errData = jsonDecode(createRes.body);
            if (errData['data'] != null && errData['data']['message'] != null) {
              errorMsg = errData['data']['message'];
            } else if (errData['message'] != null) {
              errorMsg = errData['message'];
            } else if (errData['error'] != null) {
              errorMsg = errData['error'].toString();
            }
          } catch (_) {}
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Submit error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred during submission"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildSuccessView(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 64),
          ),
          const SizedBox(height: 24),
          const Text(
            "Application Submitted Successfully!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "Your driver profile has been created. Here is a summary of the details you submitted.",
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildStep4Fields(isDesktop, isSuccess: true),
        ],
      ),
    );
  }

  Widget _buildStep4Fields(bool isDesktop, {bool isSuccess = false}) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSuccess) ...[
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Light blueish/greyish
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.remove_red_eye, color: Color(0xFF3B82F6), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Review Your Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Please review all the information before submitting",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDesktop)
                    const Icon(Icons.assignment_turned_in, size: 64, color: Color(0xFFCBD5E1)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // 1. Driver Details
          _buildPreviewSection(
            icon: Icons.directions_car,
            iconColor: const Color(0xFF10B981), // Green
            iconBgColor: const Color(0xFFD1FAE5),
            title: "1  Driver Details",
            isLast: false,
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildPreviewRow(
                    "Category:",
                    _selectedVehicleCategory ?? "N/A",
                    "Experience:",
                    _experienceController.text.isNotEmpty
                        ? "${_experienceController.text} Years"
                        : "N/A",
                    "License No:",
                    _licenseNumberController.text,
                    isDesktop,
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewRow(
                    "License Type:",
                    _selectedLicenseType ?? "N/A",
                    "License Expiry:",
                    _licenseExpiryController.text,
                    "Driving Range:",
                    _selectedRangePreference ?? "N/A",
                    isDesktop,
                  ),
                ],
              ),
            ),
          ),

          // 2. Preferences & Uploads
          _buildPreviewSection(
            icon: Icons.settings,
            iconColor: const Color(0xFFC084FC), // Purple
            iconBgColor: const Color(0xFFF3E8FF),
            title: "2  Preferences & Uploads",
            isLast: true,
            child: Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewRow(
                    "Employment Type:",
                    _selectedEmploymentType ?? "N/A",
                    "Shift Preference:",
                    _selectedShiftPreference ?? "N/A",
                    "Relocation Ready:",
                    _selectedRelocation ?? "N/A",
                    isDesktop,
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewRow(
                    "Expected Salary:",
                    _expectedSalaryController.text,
                    "Joining Availability:",
                    _joiningAvailabilityController.text,
                    "",
                    "",
                    isDesktop,
                  ),
                  if (_licenseFileName != null ||
                      _resumeFileName != null ||
                      _certificateFileName != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(color: Color(0xFFE2E8F0)),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: Color(0xFFC084FC),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Uploaded Documents",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (_licenseFileName != null)
                          _buildDocPreviewCard("Driving License", _licenseFilePath),
                        if (_resumeFileName != null)
                          _buildDocPreviewCard("Resume / CV", _resumeFilePath),
                        if (_certificateFileName != null)
                          _buildDocPreviewCard("Exp. Certificate", _certificateFilePath),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Info Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE), // Light blue
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Color(0xFF0284C7)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Please review your details before submitting.",
                        style: TextStyle(
                          color: Color(0xFF0369A1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "You can go back to edit any information.",
                        style: TextStyle(
                          color: Color(0xFF0284C7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required Widget child,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(
    String title1,
    String value1,
    String title2,
    String value2,
    String title3,
    String value3,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildPreviewItem(title1, value1)),
          const SizedBox(width: 24),
          Expanded(child: _buildPreviewItem(title2, value2)),
          const SizedBox(width: 24),
          Expanded(
            child: title3.isNotEmpty
                ? _buildPreviewItem(title3, value3)
                : const SizedBox(),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPreviewItem(title1, value1)),
              const SizedBox(width: 12),
              if (title2.isNotEmpty)
                Expanded(child: _buildPreviewItem(title2, value2))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
          if (title3.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPreviewItem(title3, value3)),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ],
      );
    }
  }

  Widget _buildPreviewItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.trim().isEmpty ? "N/A" : value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDocPreviewCard(String title, String? filePath) {
    return InkWell(
      onTap: () {
        if (filePath != null) {
          showDialog(
            context: context,
            builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  if (filePath.toLowerCase().endsWith('.pdf'))
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      color: Colors.white,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 64, color: Colors.redAccent),
                          SizedBox(height: 16),
                          Text("PDF Document Uploaded", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text("Preview not supported for PDF in app.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )
                  else
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: InteractiveViewer(
                        child: Image.network(
                          filePath.startsWith('http') ? filePath : 'https://managelogin.jobes24x7.com/api/$filePath',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(40),
                            color: Colors.white,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text("Could not load image", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.02),
               blurRadius: 4,
               offset: const Offset(0,2)
             ),
          ]
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SearchableMultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedItems;
  final String hintText;
  final bool isRequired;
  final Function(List<String>) onChanged;

  const SearchableMultiSelectDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.hintText,
    this.isRequired = false,
    required this.onChanged,
  });

  @override
  State<SearchableMultiSelectDropdown> createState() =>
      _SearchableMultiSelectDropdownState();
}

class _SearchableMultiSelectDropdownState
    extends State<SearchableMultiSelectDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_overlayEntry != null) return;
    _searchController.clear();
    _searchQuery = '';
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _toggleSelection(String item) {
    final List<String> updatedSelection = List.from(widget.selectedItems);
    if (updatedSelection.contains(item)) {
      updatedSelection.remove(item);
    } else {
      updatedSelection.add(item);
    }
    widget.onChanged(updatedSelection);
    _overlayEntry?.markNeedsBuild();
    setState(() {});
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            shadowColor: Colors.black26,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                        ),
                      ),
                      onChanged: (val) {
                        _searchQuery = val;
                        _overlayEntry?.markNeedsBuild();
                      },
                    ),
                  ),
                  Flexible(
                    child: StatefulBuilder(
                      builder: (context, setStateOverlay) {
                        final filteredItems = widget.items
                            .where((item) => item.toLowerCase().contains(_searchQuery.toLowerCase()))
                            .toList();

                        if (filteredItems.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "No items found",
                              style: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final isSelected = widget.selectedItems.contains(item);
                            return InkWell(
                              onTap: () {
                                _toggleSelection(item);
                                setStateOverlay(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                color: isSelected ? const Color(0xFFEFF6FF) : null,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                                          width: 2,
                                        ),
                                        color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (widget.isRequired)
              const Text(
                " *",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
          ],
        ),
        const SizedBox(height: 8),
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            onTap: _toggleDropdown,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isOpen ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedItems.isEmpty
                          ? widget.hintText
                          : widget.selectedItems.join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.selectedItems.isEmpty
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PastExperience {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  String? drivingRange;
  final TextEditingController rangeDetailsController = TextEditingController();

  void dispose() {
    companyController.dispose();
    vehicleController.dispose();
    rangeDetailsController.dispose();
  }
}

