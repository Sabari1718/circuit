import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'devotee_profile_overview_page.dart';
import 'devotee_api_service.dart';

class DevoteeRegistrationPage extends StatefulWidget {
  const DevoteeRegistrationPage({super.key});

  @override
  State<DevoteeRegistrationPage> createState() => _DevoteeRegistrationPageState();
}

class _DevoteeRegistrationPageState extends State<DevoteeRegistrationPage> {
  int _currentStep = 1;
  String? _selectedReligion;
  Set<String> _selectedDenominations = {};

  // Form State
  final _ageController = TextEditingController();
  final _addressTypeController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _doorNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _buildingNameController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  String? _selectedCommunity;
  String? _selectedSubCommunity;
  String? _selectedKulam;
  String? _selectedGender;
  String? _selectedPropertyType;

  int? _selectedCommunityId;
  int? _selectedSubCommunityId;
  int? _selectedKulamId;

  bool _isAgreedToTerms = false;
  
  final DevoteeApiService _apiService = DevoteeApiService();
  
  List<Community> _apiCommunities = [];
  List<SubCommunity> _apiSubCommunities = [];
  List<Kulam> _apiKulas = [];
  
  bool _isLoadingInitialData = false;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _verifiedUser;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingInitialData = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userMainId = prefs.getString('user_main_id');
    
    // Fetch dropdown data
    final communities = await _apiService.fetchCommunities();
    final subCommunities = await _apiService.fetchSubCommunities();
    final kulas = await _apiService.fetchKulas();

    // Fetch user data
    if (userMainId != null) {
      _userProfile = await _apiService.fetchUserProfile(userMainId);
      _verifiedUser = await _apiService.fetchVerifiedUser(userMainId);
    }

    if (mounted) {
      setState(() {
        _apiCommunities = communities;
        _apiSubCommunities = subCommunities;
        _apiKulas = kulas;
        
        // Auto-fill gender
        if (_verifiedUser != null && _verifiedUser!['verification'] != null) {
          final g = _verifiedUser!['verification']['gender'];
          if (g != null) _selectedGender = g;
        } else if (_userProfile != null) {
          final g = _userProfile!['gender'];
          if (g != null) _selectedGender = g;
        }

        // Auto-fill address if available
        if (_verifiedUser != null && _verifiedUser!['addresses'] != null) {
          final List addresses = _verifiedUser!['addresses'];
          if (addresses.isNotEmpty) {
            final addr = addresses.first;
            _addressTypeController.text = addr['address_type']?.toString() ?? '';
            _selectedPropertyType = addr['property_type']?.toString();
            _doorNumberController.text = addr['house_no']?.toString() ?? '';
            _buildingNameController.text = addr['block']?.toString() ?? '';
            _streetNameController.text = addr['street']?.toString() ?? '';
            _areaController.text = addr['area']?.toString() ?? '';
            _landmarkController.text = addr['landmark']?.toString() ?? '';
            _cityController.text = addr['city']?.toString() ?? '';
            _stateController.text = addr['state']?.toString() ?? '';
            _countryController.text = addr['country']?.toString() ?? 'India';
            _pincodeController.text = addr['pincode']?.toString() ?? '';
          }
        }

        _isLoadingInitialData = false;
      });
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _addressTypeController.dispose();
    _pincodeController.dispose();
    _doorNumberController.dispose();
    _streetNameController.dispose();
    _buildingNameController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, "Religion", isActive: _currentStep >= 1),
          _buildStepDivider(),
          _buildStep(2, "Details", isActive: _currentStep >= 2),
          _buildStepDivider(),
          _buildStep(3, "Preview", isActive: _currentStep >= 3),
        ],
      ),
    );
  }

  Widget _buildStep(int stepNumber, String label, {required bool isActive}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3B82F6) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
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
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF3B82F6) : Colors.grey.shade500,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 40,
      height: 2,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildReligionCard({
    required String title,
    required String icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReligion = title;
        });
      },
      child: Container(
        width: double.infinity,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Top gradient (acting as image placeholder)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 70,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.4),
                        color.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Selection circle
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: _selectedReligion == title
                        ? color
                        : Colors.transparent,
                  ),
                  child: _selectedReligion == title
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              // Content
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        icon,
                        style: TextStyle(
                          fontSize: 24,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReligionSelectionView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _buildReligionCard(
            title: "Hindu",
            icon: "🕉️",
            color: const Color(0xFFF97316),
          ),
          _buildReligionCard(
            title: "Christian",
            icon: "✝️",
            color: const Color(0xFF3B82F6),
          ),
          _buildReligionCard(
            title: "Muslim",
            icon: "☪️",
            color: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSubDenominationCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
  }) {
    final isSelected = _selectedDenominations.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedDenominations.contains(title)) {
            _selectedDenominations.remove(title);
          } else {
            _selectedDenominations.add(title);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  color: isSelected ? color : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    icon,
                    style: TextStyle(
                      fontSize: 32,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
             ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHinduSubDenominationsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected religion indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                "🕉️",
                style: TextStyle(fontSize: 28, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RELIGION SELECTED",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Hindu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedReligion = null;
                    _selectedDenominations.clear();
                  });
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Change"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid of sub-denominations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildSubDenominationCard(
                title: "Saivam",
                subtitle: "சைவம்",
                icon: "🕉️",
                color: const Color(0xFFF97316),
              ),
              _buildSubDenominationCard(
                title: "Vaishnavam",
                subtitle: "வைணவம்",
                icon: "🕉️",
                color: const Color(0xFF22C55E),
              ),
              _buildSubDenominationCard(
                title: "Kaumaram",
                subtitle: "கௌமாரம்",
                icon: "🙏",
                color: const Color(0xFFA855F7),
              ),
              _buildSubDenominationCard(
                title: "Siddha Devotees",
                subtitle: "சித்த தெய்வங்கள்",
                icon: "🕉️",
                color: const Color(0xFFEAB308),
              ),
              _buildSubDenominationCard(
                title: "Other Devotees",
                subtitle: "கிராம தெய்வங்கள்",
                icon: "👐",
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChristianSubDenominationsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected religion indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                "✝️",
                style: TextStyle(fontSize: 28, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RELIGION SELECTED",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Christian",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedReligion = null;
                    _selectedDenominations.clear();
                  });
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Change"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid of sub-denominations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildSubDenominationCard(
                title: "Jesus Christ",
                subtitle: "இயேசு கிறிஸ்து",
                icon: "✝️",
                color: const Color(0xFFFCA5A5), // Light Red
              ),
              _buildSubDenominationCard(
                title: "Mother Mary",
                subtitle: "அன்னை மரியா",
                icon: "✝️",
                color: const Color(0xFF93C5FD), // Light Blue
              ),
              _buildSubDenominationCard(
                title: "St. Antony",
                subtitle: "புனித அந்தோணியார்",
                icon: "✝️",
                color: const Color(0xFF86EFAC), // Light Green
              ),
              _buildSubDenominationCard(
                title: "St. Joseph",
                subtitle: "புனித சூசையப்பர்",
                icon: "✝️",
                color: const Color(0xFFD8B4FE), // Light Purple
              ),
              _buildSubDenominationCard(
                title: "St. Michael",
                subtitle: "புனித மைக்கேல்",
                icon: "✝️",
                color: const Color(0xFFFDBA74), // Light Orange
              ),
              _buildSubDenominationCard(
                title: "Other Saints",
                subtitle: "பிற புனிதர்கள்",
                icon: "✝️",
                color: const Color(0xFFCBD5E1), // Slate
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMuslimSubDenominationsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected religion indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Text(
                "☪️",
                style: TextStyle(fontSize: 28, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RELIGION SELECTED",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Muslim",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedReligion = null;
                    _selectedDenominations.clear();
                  });
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Change"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid of sub-denominations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _buildSubDenominationCard(
                title: "Sunni",
                subtitle: "சுன்னி",
                icon: "☪️",
                color: const Color(0xFF86EFAC), // Light Green
              ),
              _buildSubDenominationCard(
                title: "Shia",
                subtitle: "ஷியா",
                icon: "☪️",
                color: const Color(0xFF93C5FD), // Light Blue
              ),
              _buildSubDenominationCard(
                title: "Sufi",
                subtitle: "சூஃபி",
                icon: "☪️",
                color: const Color(0xFFD8B4FE), // Light Purple
              ),
              _buildSubDenominationCard(
                title: "Other Islamic Traditions",
                subtitle: "பிற மரபுகள்",
                icon: "☪️",
                color: const Color(0xFFCBD5E1), // Slate
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, {Widget? suffix, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
            children: const [
              TextSpan(text: " *", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String hint, {
    List<String> items = const [],
    String? value,
    ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStepView() {
    if (_isLoadingInitialData) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
      );
    }
    
    // Compute current dropdown lists based on selections
    List<String> communityNames = _apiCommunities.map((c) => c.nameEnglish).toList();
    
    List<SubCommunity> filteredSub = _selectedCommunityId == null 
        ? [] 
        : _apiSubCommunities.where((sc) => sc.communityId == _selectedCommunityId).toList();
    List<String> subCommunityNames = filteredSub.map((sc) => sc.nameEnglish).toList();

    List<Kulam> filteredKulas = _selectedSubCommunityId == null 
        ? [] 
        : _apiKulas.where((k) => k.subCommunityId == _selectedSubCommunityId).toList();
    List<String> kulamNames = filteredKulas.map((k) => k.nameEnglish).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Text(
                  "Additional Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                SizedBox(height: 4),
                Text(
                  "Please provide the following information",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Row 1
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Community", 
                  "Select Community",
                  items: communityNames.isNotEmpty ? communityNames : ["No data"],
                  value: _selectedCommunity,
                  onChanged: (val) {
                    setState(() {
                      _selectedCommunity = val;
                      final selectedC = _apiCommunities.firstWhere((c) => c.nameEnglish == val);
                      _selectedCommunityId = selectedC.id;
                      
                      // Reset child dropdowns
                      _selectedSubCommunity = null;
                      _selectedSubCommunityId = null;
                      _selectedKulam = null;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  "Sub-Community", 
                  "Select Sub-Community",
                  items: subCommunityNames.isNotEmpty ? subCommunityNames : [],
                  value: _selectedSubCommunity,
                  onChanged: (val) {
                    setState(() {
                      _selectedSubCommunity = val;
                      final selectedSc = filteredSub.firstWhere((sc) => sc.nameEnglish == val);
                      _selectedSubCommunityId = selectedSc.id;
                      
                      // Reset child dropdown
                      _selectedKulam = null;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 2
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Kulam", 
                  "Select Kulam",
                  items: kulamNames.isNotEmpty ? kulamNames : [],
                  value: _selectedKulam,
                  onChanged: (val) {
                    setState(() {
                      _selectedKulam = val;
                      final selectedK = filteredKulas.firstWhere((k) => k.nameEnglish == val);
                      _selectedKulamId = selectedK.id;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  "Gender", 
                  "Select Gender",
                  items: ["Male", "Female", "Other"],
                  value: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 3
          Row(
            children: [
              Expanded(child: _buildTextField("Age", "Enter age", controller: _ageController)),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()), // Placeholder for alignment
            ],
          ),
          
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          
          // Address Header
          Row(
            children: [
              const Icon(Icons.maps_home_work_outlined, color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              const Text(
                "Address Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.near_me, size: 16),
                label: const Text("Fetch Address", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Row 4
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _buildTextField("Address Type", "Permanent, Rental...", controller: _addressTypeController)),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  "Property Type", 
                  "Select...",
                  items: ["Apartment / Flat", "Independent House", if (_selectedPropertyType != null && _selectedPropertyType != "Apartment / Flat" && _selectedPropertyType != "Independent House") _selectedPropertyType!],
                  value: _selectedPropertyType,
                  onChanged: (val) => setState(() => _selectedPropertyType = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 5
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 2, child: _buildTextField("Pincode", "Enter Pincode", controller: _pincodeController)),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Fetch", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 6
          Row(
            children: [
              Expanded(child: _buildTextField("Door Number", "e.g. 12A", controller: _doorNumberController)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Street Name", "e.g. Main St", controller: _streetNameController)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 7
          Row(
            children: [
              Expanded(child: _buildTextField("Building Name", "Skyline Apts", controller: _buildingNameController)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Landmark", "Near Park", controller: _landmarkController)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 8
          Row(
            children: [
              Expanded(child: _buildTextField("Area / Village", "Downtown", controller: _areaController)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("City / District", "Chennai", controller: _cityController)),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 9
          Row(
            children: [
              Expanded(child: _buildTextField("State", "Tamil Nadu", controller: _stateController)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Country", "India", controller: _countryController)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStepView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Column(
              children: [
                Text(
                  "REVIEW YOUR APPLICATION",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                SizedBox(height: 4),
                Text(
                  "Verify all entered details before submission",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Devotee Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_outline, color: Color(0xFF475569), size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Devotee Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                _buildPreviewRow("Religion:", _selectedReligion ?? "-"),
                if (_selectedDenominations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            "Category:",
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedDenominations.map((denom) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Text(
                                  denom,
                                  style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildPreviewRow("Gender:", _selectedGender ?? "-"),
                _buildPreviewRow("Age:", _ageController.text),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                _buildPreviewRow("Community:", _selectedCommunity ?? "-"),
                _buildPreviewRow("Sub-Community:", _selectedSubCommunity ?? "-"),
                _buildPreviewRow("Kulam:", _selectedKulam ?? "-"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Address Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Color(0xFF475569), size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Address Details",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                _buildPreviewRow("Address Type:", _addressTypeController.text),
                _buildPreviewRow("Property Type:", _selectedPropertyType ?? "-"),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                _buildPreviewRow("Door/Unit No:", _doorNumberController.text),
                _buildPreviewRow("Building Name:", _buildingNameController.text),
                _buildPreviewRow("Street:", _streetNameController.text),
                _buildPreviewRow("Landmark:", _landmarkController.text),
                _buildPreviewRow("Area:", _areaController.text),
                _buildPreviewRow("City:", _cityController.text),
                _buildPreviewRow("State:", _stateController.text),
                _buildPreviewRow("Pincode:", _pincodeController.text),
                _buildPreviewRow("Country:", _countryController.text),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Declaration
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Declaration: I hereby confirm that all the information provided is true and correct.",
                    style: TextStyle(color: Color(0xFF92400E), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isAgreedToTerms,
                onChanged: (val) {
                  setState(() {
                    _isAgreedToTerms = val ?? false;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  "I agree to the terms and conditions and confirm accuracy.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Devotees",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  // Main Header
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text("🙏", style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome, Devotee! 🙏",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Complete your devotee registration profile",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  _buildStepper(),

                  if (_currentStep == 1) ...[
                    if (_selectedReligion == null)
                      _buildReligionSelectionView()
                    else if (_selectedReligion == "Hindu")
                      _buildHinduSubDenominationsView()
                    else if (_selectedReligion == "Christian")
                      _buildChristianSubDenominationsView()
                    else if (_selectedReligion == "Muslim")
                      _buildMuslimSubDenominationsView()
                    else
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "$_selectedReligion registration flow coming soon.",
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                  ] else if (_currentStep == 2) ...[
                    _buildDetailsStepView()
                  ] else if (_currentStep == 3) ...[
                    _buildPreviewStepView()
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (_currentStep == 2 || _currentStep == 3) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text("Back"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ] else ...[
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedReligion = null;
                            _selectedDenominations.clear();
                            _currentStep = 1;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: const Text("Reset"),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ],
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentStep == 1) {
                      if (_selectedReligion != null) {
                        setState(() {
                          _currentStep = 2;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a religion first."),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } else if (_currentStep == 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Proceeding to Preview..."),
                        ),
                      );
                      setState(() {
                        _currentStep = 3;
                      });
                    } else if (_currentStep == 3) {
                      if (_isAgreedToTerms) {
                        final prefs = await SharedPreferences.getInstance();
                        final userMainId = prefs.getString('user_main_id');
                        
                        String tradition = _selectedDenominations.isNotEmpty ? _selectedDenominations.first : "";

                        Map<String, dynamic> payload = {
                          "user_main_id": userMainId ?? "2146610213",
                          "religion_name": _selectedReligion ?? "",
                          "tradition": tradition,
                          "tradition_name": tradition,
                          "address": {
                            "address_type": _addressTypeController.text,
                            "property_type": _selectedPropertyType ?? "",
                            "pincode": _pincodeController.text,
                            "house_no": _doorNumberController.text,
                            "flat_no": _doorNumberController.text,
                            "street": _streetNameController.text,
                            "block": _buildingNameController.text,
                            "landmark": _landmarkController.text,
                            "area": _areaController.text,
                            "city": _cityController.text,
                            "district": _cityController.text,
                            "state": _stateController.text,
                            "country": _countryController.text,
                          },
                          "age": int.tryParse(_ageController.text) ?? 0,
                          "community_name": _selectedCommunityId ?? 0,
                          "gender": _selectedGender ?? "",
                          "kulam_name": _selectedKulamId ?? 0,
                          "sub_community_name": _selectedSubCommunityId ?? 0
                        };
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Submitting Registration..."), duration: Duration(seconds: 1)),
                        );

                        final response = await _apiService.submitDevoteeRegistration(payload);
                        
                        if (!mounted) return;

                        if (response['status'] == true) {
                          await prefs.setBool('is_devotee_registered', true);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Registration Submitted Successfully!"), backgroundColor: Colors.green),
                          );
                          
                          final profileData = DevoteeProfileData(
                            name: _userProfile?['name']?.toString() ?? "User", 
                            gender: _selectedGender,
                            age: _ageController.text,
                            religion: _selectedReligion,
                            categories: tradition.isNotEmpty ? {tradition} : {},
                            community: _selectedCommunity,
                            subCommunity: _selectedSubCommunity,
                            kulam: _selectedKulam,
                            addressType: _addressTypeController.text,
                            propertyType: _selectedPropertyType,
                            doorNumber: _doorNumberController.text,
                            streetName: _streetNameController.text,
                            buildingName: _buildingNameController.text,
                            landmark: _landmarkController.text,
                            area: _areaController.text,
                            city: _cityController.text,
                            state: _stateController.text,
                            pincode: _pincodeController.text,
                            country: _countryController.text,
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DevoteeProfileOverviewPage(data: profileData),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message'] ?? "Error submitting registration"), 
                              backgroundColor: Colors.red
                            ),
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Action Required", style: TextStyle(color: Colors.red)),
                            content: const Text("Please check the 'I agree to the terms and conditions' box before submitting your registration."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _currentStep == 3 ? "Submit Registration" : "Next",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentStep == 3 ? Icons.check : Icons.arrow_forward, 
                        size: 16, 
                        color: Colors.white
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
}
