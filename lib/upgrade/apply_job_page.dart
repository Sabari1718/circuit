import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'job_list_page.dart';
import 'applied_list_page.dart';

class PastExperience {
  final TextEditingController companyController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController rangeDetailsController = TextEditingController();
  String? drivingRange;
  final Key key = UniqueKey();

  void dispose() {
    companyController.dispose();
    vehicleController.dispose();
    rangeDetailsController.dispose();
  }
}

class ApplyJobPage extends StatefulWidget {
  const ApplyJobPage({super.key});

  @override
  State<ApplyJobPage> createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  bool _isApplyJobExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController(text: "Sabari");
  final TextEditingController _emailController = TextEditingController(text: "sabarishwaran1718@gmail.com");
  final TextEditingController _phoneController = TextEditingController(text: "8012107626");
  final TextEditingController _locationController = TextEditingController(text: "Coimbatore");
  final TextEditingController _dobController = TextEditingController();

  int _currentStep = 1;

  // Step 2 Controllers
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _licenseExpiryController = TextEditingController();

  String? _selectedGender;
  String? _selectedVehicleCategory;
  String? _selectedLicenseType;
  String? _selectedRangePreference;

  String? _selectedVehicleUsage;
  String? _selectedVehicleWeight;
  bool _hasExperience = false;

  final List<PastExperience> _pastExperiences = [PastExperience()];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Step 3 Variables
  String? _selectedEmploymentType;
  String? _selectedShiftPreference;
  String? _selectedRelocation;
  final TextEditingController _expectedSalaryController = TextEditingController();
  final TextEditingController _joiningAvailabilityController = TextEditingController();
  String? _resumeFileName;

  String? _certificateFileName;
  String? _licenseFileName;

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
    }
  }

  @override
  void initState() {
    super.initState();
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
      drawer: !isDesktop ? Drawer(elevation: 0, child: _buildSidebar(context, isDrawer: true)) : null,
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
                    hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B), size: 24),
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    child: const Text('4',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Icon(Icons.dark_mode_outlined, color: Color(0xFF64748B), size: 22),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(Icons.person, color: Color(0xFF94A3B8), size: 18),
                  ),
                  SizedBox(width: 6),
                  Text('Admin',
                      style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 16),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
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
        Expanded(flex: 3, child: _buildStep(1, "Personal Info", isActive: true, isCompleted: _currentStep > 1)),
        _buildStepLine(isActive: _currentStep >= 2),
        Expanded(flex: 3, child: _buildStep(2, "Driver Details", isActive: _currentStep >= 2, isCompleted: _currentStep > 2)),
        _buildStepLine(isActive: _currentStep >= 3),
        Expanded(flex: 3, child: _buildStep(3, "Preferences", isActive: _currentStep >= 3, isCompleted: _currentStep > 3)),
        _buildStepLine(isActive: _currentStep >= 4),
        Expanded(flex: 3, child: _buildStep(4, "Preview", isActive: _currentStep >= 4, isCompleted: _currentStep > 4)),
      ],
    );
  }

  Widget _buildStep(int step, String title, {required bool isActive, bool isCompleted = false}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4F46E5) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
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
      title = "Personal Information";
      icon = Icons.person;
    } else if (_currentStep == 2) {
      title = "Driver Details";
      icon = Icons.local_shipping;
    } else if (_currentStep == 3) {
      title = "Preferences & Upload";
      icon = Icons.upload_file;
    } else if (_currentStep == 4) {
      title = "Application Preview";
      icon = Icons.remove_red_eye;
    }

    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4F46E5),
          size: 20,
        ),
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
      return _buildStep1Fields(isDesktop);
    } else if (_currentStep == 2) {
      return _buildStep2Fields(isDesktop);
    } else if (_currentStep == 3) {
      return _buildStep3Fields(isDesktop);
    } else if (_currentStep == 4) {
      return _buildStep4Fields(isDesktop);
    }
    return const SizedBox();
  }

  Widget _buildStep1Fields(bool isDesktop) {
    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField("Full Name", _nameController, isRequired: true)),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField("Email Address", _emailController, isRequired: true)),
              const SizedBox(width: 24),
              Expanded(child: _buildTextField("Phone Number", _phoneController, isRequired: true)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDateField("Date of Birth", _dobController),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  "Gender", 
                  ["Male", "Female", "Other"], 
                  value: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val),
                  hintText: "Select Gender",
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTextField("Current Location", _locationController, isRequired: true),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildTextField("Full Name", _nameController, isRequired: true),
          const SizedBox(height: 16),
          _buildTextField("Email Address", _emailController, isRequired: true),
          const SizedBox(height: 16),
          _buildTextField("Phone Number", _phoneController, isRequired: true),
          const SizedBox(height: 16),
          _buildDateField("Date of Birth", _dobController),
          const SizedBox(height: 16),
          _buildDropdownField(
            "Gender", 
            ["Male", "Female", "Other"], 
            value: _selectedGender,
            onChanged: (val) => setState(() => _selectedGender = val),
            hintText: "Select Gender",
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField("Current Location", _locationController, isRequired: true),
        ],
      );
    }
  }

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
                  onChanged: (val) => setState(() => _selectedVehicleCategory = val),
                  hintText: "Select Category",
                  isRequired: true,
                ),
              ),
              if (_hasExperience) ...[
                const SizedBox(width: 24),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _hasExperience ? 1.0 : 0.0,
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
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: _hasExperience ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildDropdownField(
                      "Vehicle Weight", 
                      ["Light Vehicle", "Heavy Vehicle"], 
                      value: _selectedVehicleWeight,
                      onChanged: (val) => setState(() => _selectedVehicleWeight = val),
                      hintText: "Select Weight",
                      isRequired: true,
                    ),
                  ),
                ),
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
                child: _buildTextField("Total Experience (Years)", _experienceController, isRequired: true, hintText: "02"),
              ),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 24),
              const Expanded(child: SizedBox()),
            ],
          ),
          if (_hasExperience) ...[
            const SizedBox(height: 24),
            AnimatedOpacity(
              opacity: _hasExperience ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildPastExperiencesSection(true),
            ),
          ],
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
                child: _buildTextArea("Remarks (Optional)", _remarksController, hintText: "Any additional remarks..."),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField("License Number", _licenseNumberController, isRequired: true, hintText: "Enter License Number"),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDropdownField(
                  "License Type", 
                  ["LMV", "HMV", "Commercial", "Transport"], 
                  value: _selectedLicenseType,
                  onChanged: (val) => setState(() => _selectedLicenseType = val),
                  hintText: "Select License Type",
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildDateField("License Expiry Date", _licenseExpiryController, isRequired: true),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  "Driving Range Preference", 
                  ["Within City", "District to District", "State to State", "All Over India"], 
                  value: _selectedRangePreference,
                  onChanged: (val) => setState(() => _selectedRangePreference = val),
                  hintText: "Select Range Preference",
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(child: const SizedBox()),
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
          if (_hasExperience) ...[
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _hasExperience ? 1.0 : 0.0,
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
              opacity: _hasExperience ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildDropdownField(
                "Vehicle Weight", 
                ["Light Vehicle", "Heavy Vehicle"], 
                value: _selectedVehicleWeight,
                onChanged: (val) => setState(() => _selectedVehicleWeight = val),
                hintText: "Select Weight",
                isRequired: true,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildTextField("Total Experience (Years)", _experienceController, isRequired: true, hintText: "02"),
          if (_hasExperience) ...[
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _hasExperience ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildPastExperiencesSection(false),
            ),
          ],
          const SizedBox(height: 16),
          _buildUploadBox(
            "Experience Certificate (Optional)", 
            "Click to upload Certificate",
            fileName: _certificateFileName,
            onTap: () => _pickFile('certificate'),
          ),
          const SizedBox(height: 16),
          _buildTextArea("Remarks (Optional)", _remarksController, hintText: "Any additional remarks..."),
          const SizedBox(height: 16),
          _buildTextField("License Number", _licenseNumberController, isRequired: true, hintText: "Enter License Number"),
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
          _buildDateField("License Expiry Date", _licenseExpiryController, isRequired: true),
          const SizedBox(height: 16),
          _buildDropdownField(
            "Driving Range Preference", 
            ["Within City", "District to District", "State to State", "All Over India"], 
            value: _selectedRangePreference,
            onChanged: (val) => setState(() => _selectedRangePreference = val),
            hintText: "Select Range Preference",
            isRequired: true,
          ),
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
          onPressed: () {
            if (_currentStep < 4) {
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentStep == 4 ? "Submit Application" : "Next Step",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (_currentStep < 4) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false, String? hintText}) {
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
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool isRequired = false}) {
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
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
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
                        foregroundColor: const Color(0xFF10B981), // button text color
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
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, {bool isRequired = false, String? value, required Function(String?) onChanged, String? hintText}) {
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
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Text(
                hintText ?? "Select",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
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

  Widget _buildTextArea(String label, TextEditingController controller, {String? hintText}) {
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
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(String label, String actionText, {bool isRequired = false, String? fileName, VoidCallback? onTap}) {
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
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: fileName != null ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              ),
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
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 11,
                    ),
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
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                    ),
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
            padding: EdgeInsets.only(top: isDrawer ? 40 : 24, left: 24, right: 24, bottom: 24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                    child: Text(
                      "90×25",
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.grid_view_rounded, color: Color(0xFFE11D48), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sidebarItem(Icons.home_outlined, "Dashboard", onTap: () {
            debugPrint("Dashboard clicked");
            if (isDrawer) Navigator.pop(context);
            Navigator.popUntil(context, (r) => r.isFirst);
          }),
          const SizedBox(height: 8),
          _sidebarItem(Icons.widgets_outlined, "Switch Portal", onTap: () {
            debugPrint("Switch Portal clicked");
            if (isDrawer) Navigator.pop(context);
            Navigator.popUntil(context, (r) => r.isFirst);
          }),
          const SizedBox(height: 8),
          _buildApplyJobExpansion(context, isDrawer: isDrawer, pinkColor: pinkColor, activeItem: 'apply_for_job'),
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
                bottomLeft: Radius.circular(24)),
          ),
          child: ListTile(
            leading: const Icon(Icons.send_outlined,
                color: Color(0xFF1E293B), size: 20),
            title: const Text('Apply Job',
                style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimatedRotation(
                turns: _isApplyJobExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF1E293B), size: 20),
              ),
            ),
            dense: true,
            onTap: () {
              setState(() {
                _isApplyJobExpanded = !_isApplyJobExpanded;
                debugPrint(_isApplyJobExpanded
                    ? 'Apply Job menu expanded'
                    : 'Apply Job menu collapsed');
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
                  ? _activeSubItem('Job List', onTap: () {
                      debugPrint('Job List clicked');
                      if (isDrawer) Navigator.pop(context);
                    })
                  : _sidebarSubItem('Job List', onTap: () {
                      debugPrint('Job List clicked');
                      if (isDrawer) Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const JobListPage()));
                    }),
              // Applied List
              activeItem == 'applied_list'
                  ? _activeSubItem('Applied List', onTap: () {
                      debugPrint('Applied List clicked');
                      if (isDrawer) Navigator.pop(context);
                    })
                  : _sidebarSubItem('Applied List', onTap: () {
                      debugPrint('Applied List clicked');
                      if (isDrawer) Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AppliedListPage()));
                    }),
              // Apply for Job
              activeItem == 'apply_for_job'
                  ? _activeSubItem('Apply for Job',
                      textColor: pinkColor,
                      onTap: () {
                        debugPrint('Apply For Job clicked');
                        if (isDrawer) Navigator.pop(context);
                      })
                  : _sidebarSubItem('Apply for Job',
                      textColor: pinkColor,
                      onTap: () {
                        debugPrint('Apply For Job clicked');
                        if (isDrawer) Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ApplyJobPage()));
                      }),
            ],
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  /// Highlighted active sub-item
  Widget _activeSubItem(String title,
          {Color? textColor, VoidCallback? onTap}) =>
      Container(
        margin: const EdgeInsets.only(left: 12, right: 0),
        decoration: const BoxDecoration(
          color: Color(0xFF334155),
          borderRadius:
              BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 42),
          dense: true,
          title: Text(title,
              style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          onTap: onTap,
        ),
      );

  Widget _buildPastExperiencesSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Past Experiences",
          style: TextStyle(
            fontSize: 14,
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
            return _buildPastExperienceItem(_pastExperiences[index], index, animation, isDesktop);
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: isDesktop ? Alignment.centerRight : Alignment.center,
          child: InkWell(
            onTap: () {
              final newExp = PastExperience();
              _pastExperiences.add(newExp);
              _listKey.currentState?.insertItem(_pastExperiences.length - 1, duration: const Duration(milliseconds: 300));
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "Add Another",
                    style: TextStyle(
                      color: Colors.white,
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

  Widget _buildPastExperienceItem(PastExperience exp, int index, Animation<double> animation, bool isDesktop) {
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
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                ),
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(
                            child: _buildTextField("Company Name", exp.companyController, isRequired: true, hintText: "e.g. ABC Logistics"),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField("Vehicle Driven", exp.vehicleController, isRequired: true, hintText: "e.g. Ashok Leyland, Tata Ace"),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDropdownField(
                                  "Past Driving Range", 
                                  ["Within City", "District to District", "State to State", "All Over India", "Other"], 
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
                                                ? "e.g. T Nagar, Anna Nagar"
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
                        children: [
                          _buildTextField("Company Name", exp.companyController, isRequired: true, hintText: "e.g. ABC Logistics"),
                          const SizedBox(height: 16),
                          _buildTextField("Vehicle Driven", exp.vehicleController, isRequired: true, hintText: "e.g. Ashok Leyland, Tata Ace"),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            "Past Driving Range", 
                            ["Within City", "District to District", "State to State", "All Over India", "Other"], 
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
                                          ? "e.g. T Nagar, Anna Nagar"
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
                      final removedItem = _pastExperiences.removeAt(removedIndex);
                      _listKey.currentState?.removeItem(
                        removedIndex,
                        (context, animation) => _buildPastExperienceItem(removedItem, removedIndex, animation, isDesktop),
                        duration: const Duration(milliseconds: 300),
                      );
                      Future.delayed(const Duration(milliseconds: 350), () {
                        removedItem.dispose();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF64748B),
                      shape: BoxShape.circle,
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
                  onChanged: (val) => setState(() => _selectedEmploymentType = val),
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
                  onChanged: (val) => setState(() => _selectedShiftPreference = val),
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
                child: _buildTextField("Expected Salary", _expectedSalaryController, hintText: "e.g. ₹25,000 / month"),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTextField("Joining Availability", _joiningAvailabilityController, hintText: "e.g. Immediate, 15 Days"),
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
          _buildTextField("Expected Salary", _expectedSalaryController, hintText: "e.g. ₹25,000 / month"),
          const SizedBox(height: 16),
          _buildTextField("Joining Availability", _joiningAvailabilityController, hintText: "e.g. Immediate, 15 Days"),
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

  void _submitApplication() {
    if (_nameController.text.trim().isEmpty || _experienceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields"), backgroundColor: Colors.red),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Application Submitted Successfully"),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentStep = 1;
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _dobController.clear();
          _locationController.clear();
          _experienceController.clear();
          _remarksController.clear();
          _licenseNumberController.clear();
          _licenseExpiryController.clear();
          _expectedSalaryController.clear();
          _joiningAvailabilityController.clear();
          _selectedGender = null;
          _selectedVehicleCategory = null;
          _selectedLicenseType = null;
          _selectedRangePreference = null;
          _selectedVehicleUsage = null;
          _selectedVehicleWeight = null;
          _selectedEmploymentType = null;
          _selectedShiftPreference = null;
          _selectedRelocation = null;
          _hasExperience = false;
          _certificateFileName = null;
          _licenseFileName = null;
          _resumeFileName = null;
          for (var exp in _pastExperiences) {
            exp.dispose();
          }
          _pastExperiences.clear();
          _pastExperiences.add(PastExperience());
        });
      }
    });
  }

  Widget _buildStep4Fields(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewTitle("1. Personal Information"),
          const SizedBox(height: 16),
          _buildPreviewRow("Full Name", _nameController.text, "Email", _emailController.text, "Phone", _phoneController.text, isDesktop),
          const SizedBox(height: 12),
          _buildPreviewRow("DOB", _dobController.text, "Gender", _selectedGender ?? "N/A", "Location", _locationController.text, isDesktop),
          
          const SizedBox(height: 32),
          _buildPreviewTitle("2. Driver Details"),
          const SizedBox(height: 16),
          _buildPreviewRow("Category", _selectedVehicleCategory ?? "N/A", "Experience", _experienceController.text.isNotEmpty ? "${_experienceController.text} Years" : "N/A", "License No", _licenseNumberController.text, isDesktop),
          const SizedBox(height: 12),
          _buildPreviewRow("License Type", _selectedLicenseType ?? "N/A", "License Expiry", _licenseExpiryController.text, "Driving Range", _selectedRangePreference ?? "N/A", isDesktop),
          
          if (_hasExperience && _pastExperiences.any((e) => e.companyController.text.isNotEmpty)) ...[
            const SizedBox(height: 16),
            ..._pastExperiences.where((e) => e.companyController.text.isNotEmpty).map((exp) {
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPreviewItem("Company", exp.companyController.text)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildPreviewItem("Vehicle", exp.vehicleController.text)),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPreviewItem("Range", exp.drivingRange ?? "N/A"),
                              if (exp.drivingRange == "Within City" || exp.drivingRange == "District to District" || exp.drivingRange == "State to State")
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: _buildPreviewItem("Area", exp.rangeDetailsController.text),
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPreviewItem("Company", exp.companyController.text),
                        const SizedBox(height: 8),
                        _buildPreviewItem("Vehicle", exp.vehicleController.text),
                        const SizedBox(height: 8),
                        _buildPreviewItem("Range", exp.drivingRange ?? "N/A"),
                        if (exp.drivingRange == "Within City" || exp.drivingRange == "District to District" || exp.drivingRange == "State to State")
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildPreviewItem("Area", exp.rangeDetailsController.text),
                          ),
                      ],
                    ),
              );
            }).toList(),
          ],

          const SizedBox(height: 32),
          _buildPreviewTitle("3. Preferences & Uploads"),
          const SizedBox(height: 16),
          _buildPreviewRow("Employment Type", _selectedEmploymentType ?? "N/A", "Shift Preference", _selectedShiftPreference ?? "N/A", "Relocation Ready", _selectedRelocation ?? "N/A", isDesktop),
          const SizedBox(height: 12),
          _buildPreviewRow("Expected Salary", _expectedSalaryController.text, "Joining Availability", _joiningAvailabilityController.text, "", "", isDesktop),
          
          if (_licenseFileName != null || _resumeFileName != null || _certificateFileName != null) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(Icons.insert_drive_file, color: Color(0xFF3B82F6), size: 18),
                const SizedBox(width: 8),
                _buildPreviewTitle("Uploaded Documents:"),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              children: [
                if (_licenseFileName != null) _buildDocPreviewCard("Driving License"),
                if (_resumeFileName != null) _buildDocPreviewCard("Resume / CV"),
                if (_certificateFileName != null) _buildDocPreviewCard("Exp. Certificate"),
              ],
            ),
          ],

          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB57EDC), // Vibrant purple info box
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Please review your details before submitting. You can go back to edit any information.",
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3B82F6),
      ),
    );
  }

  Widget _buildPreviewRow(String title1, String value1, String title2, String value2, String title3, String value3, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildPreviewItem(title1, value1)),
          const SizedBox(width: 24),
          Expanded(child: _buildPreviewItem(title2, value2)),
          const SizedBox(width: 24),
          Expanded(child: title3.isNotEmpty ? _buildPreviewItem(title3, value3) : const SizedBox()),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewItem(title1, value1),
          if (title2.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPreviewItem(title2, value2),
          ],
          if (title3.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPreviewItem(title3, value3),
          ],
        ],
      );
    }
  }

  Widget _buildPreviewItem(String title, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        children: [
          TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value.trim().isEmpty ? "N/A" : value),
        ],
      ),
    );
  }

  Widget _buildDocPreviewCard(String title) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF94A3B8), size: 24),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
