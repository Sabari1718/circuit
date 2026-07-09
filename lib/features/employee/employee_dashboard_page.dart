import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../upgrade/job_list_page.dart';
import '../../upgrade/applied_list_page.dart';

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sidebar state
  bool _isEmployeeExpanded = true;
  bool _isApplyJobExpanded = false;
  String _activeItem = 'apply_job';

  // Apply Job form state
  int _currentStep = 1;
  String? _selectedGender;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Step 2 state
  String? _vehicleCategory;
  String? _vehicleUsage;
  String? _vehicleWeight;
  String? _experience;
  final TextEditingController _remarksController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  String? _licenseType;
  final TextEditingController _licenseExpiryController = TextEditingController();
  String? _rangePreference;
  String? _preferredDistrict;
  List<String> _preferredDistricts = [];
  List<String> _preferredStates = [];
  final TextEditingController _specificAreasController = TextEditingController();
  String? _experienceCertificateName;
  String? _drivingLicenseName;

  bool _isDarkTheme = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _dobController.dispose();
    _searchController.dispose();
    _remarksController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _specificAreasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: const Color(0xFF1E293B),
              child: _buildSidebar(),
            ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildMainContent(isDesktop),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color(0xFF1E293B),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Logo area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'User Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF334155), thickness: 1),
            const SizedBox(height: 8),

            // Dashboard
            _sidebarItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              key: 'dashboard',
              onTap: () => setState(() => _activeItem = 'dashboard'),
            ),

            // Switch Portal
            _sidebarItem(
              icon: Icons.swap_horiz_rounded,
              label: 'Switch Portal',
              key: 'switch_portal',
              onTap: () => Navigator.pop(context),
            ),

            // Employee expandable
            _sidebarExpandable(
              icon: Icons.person_outline_rounded,
              label: 'Employee',
              isExpanded: _isEmployeeExpanded,
              onTap: () => setState(() => _isEmployeeExpanded = !_isEmployeeExpanded),
              children: [
                _sidebarSubItem(
                  label: 'Profile Overview',
                  key: 'profile_overview',
                  onTap: () => setState(() {
                    _activeItem = 'profile_overview';
                    _isApplyJobExpanded = false;
                  }),
                ),
                _sidebarSubItem(
                  label: 'My Jobs',
                  key: 'my_jobs',
                  onTap: () => setState(() {
                    _activeItem = 'my_jobs';
                    _isApplyJobExpanded = false;
                  }),
                ),
                // Apply Job expandable
                _sidebarApplyJobExpandable(),
              ],
            ),

            const Spacer(),
            const Divider(color: Color(0xFF334155)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF334155),
                    child: Icon(Icons.person, color: Colors.white60, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sabari',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white38, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required String key,
    required VoidCallback onTap,
  }) {
    final isActive = _activeItem == key;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF334155) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarExpandable({
    required IconData icon,
    required String label,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    final isAnyChildActive = _activeItem == 'profile_overview' ||
        _activeItem == 'my_jobs' ||
        _activeItem == 'job_list' ||
        _activeItem == 'applied_list' ||
        _activeItem == 'apply_job';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isAnyChildActive ? const Color(0xFF293548) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFF334155), width: 1.5),
                ),
              ),
              padding: const EdgeInsets.only(left: 12),
              child: Column(children: children),
            ),
          ),
      ],
    );
  }

  Widget _sidebarApplyJobExpandable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isApplyJobExpanded = !_isApplyJobExpanded),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isApplyJobExpanded ? const Color(0xFF293548) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.work_outline_rounded, color: Colors.white54, size: 18),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Apply Job',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                AnimatedRotation(
                  turns: _isApplyJobExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.chevron_right, color: Colors.white38, size: 16),
                ),
              ],
            ),
          ),
        ),
        if (_isApplyJobExpanded) ...[
          _sidebarSubSubItem(label: 'Job List', key: 'job_list', onTap: () {
            setState(() => _activeItem = 'job_list');
            Navigator.push(context, MaterialPageRoute(builder: (_) => const JobListPage()));
          }),
          _sidebarSubSubItem(label: 'Applied List', key: 'applied_list', onTap: () {
            setState(() => _activeItem = 'applied_list');
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AppliedListPage()));
          }),
          _sidebarSubSubItem(label: 'Apply for Job', key: 'apply_job', onTap: () {
            setState(() => _activeItem = 'apply_job');
          }),
        ],
      ],
    );
  }

  Widget _sidebarSubItem({
    required String label,
    required String key,
    required VoidCallback onTap,
  }) {
    final isActive = _activeItem == key;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF293548) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _sidebarSubSubItem({
    required String label,
    required String key,
    required VoidCallback onTap,
  }) {
    final isActive = _activeItem == key;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF293548) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.red.shade400 : Colors.white54,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
    return Container(
      color: _isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: Icon(Icons.menu_rounded, color: _isDarkTheme ? Colors.white : const Color(0xFF1E293B)),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: _isDarkTheme ? Colors.white : Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search Voxo ..',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.notifications_none_rounded, color: _isDarkTheme ? Colors.white70 : const Color(0xFF64748B), size: 22),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _isDarkTheme = !_isDarkTheme),
            child: Icon(
              _isDarkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: _isDarkTheme ? Colors.white70 : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 13,
                  backgroundColor: Color(0xFFE2E8F0),
                  child: Icon(Icons.person, color: Color(0xFF94A3B8), size: 16),
                ),
                const SizedBox(width: 6),
                Text('Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _isDarkTheme ? Colors.white : const Color(0xFF1E293B))),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, color: _isDarkTheme ? Colors.white70 : const Color(0xFF64748B), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    if (_activeItem == 'apply_job') {
      return _buildApplyJobForm(isDesktop);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '${_activeItem.replaceAll('_', ' ').toUpperCase()} Coming Soon',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyJobForm(bool isDesktop) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 860),
        decoration: BoxDecoration(
          color: _isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        padding: EdgeInsets.all(isDesktop ? 32 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send_rounded, color: Color(0xFF4F46E5), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply For A Job',
                        style: TextStyle(
                          fontSize: isDesktop ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: _isDarkTheme ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete your application in 3 simple steps.',
                        style: TextStyle(fontSize: 13, color: _isDarkTheme ? Colors.white70 : const Color(0xFF64748B)),
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Stepper
            _buildStepper(),
            const SizedBox(height: 28),
            // Section title
            Row(
              children: [
                Icon(
                  _currentStep == 1 ? Icons.person : Icons.local_shipping,
                  color: const Color(0xFF4F46E5),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentStep == 1 ? 'Personal Information' : 'Driver Details',
                  style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: _isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            const SizedBox(height: 20),
            // Form
            _currentStep == 1 ? _buildStep1(isDesktop) : _buildStep2(isDesktop),
            const SizedBox(height: 28),
            // Next button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep > 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: _isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text('Back', style: TextStyle(color: _isDarkTheme ? Colors.white70 : const Color(0xFF64748B))),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    }
                  },
                  icon: const Text('Next Step', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  label: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = ['Personal Info', 'Driver Details', 'Preferences', 'Preview'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 20),
              color: (i ~/ 2 + 1) < _currentStep ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            ),
          );
        }
        final step = i ~/ 2 + 1;
        final isActive = step == _currentStep;
        final isDone = step < _currentStep;
        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isDone ? const Color(0xFF4F46E5) : Colors.white,
                border: Border.all(
                  color: isActive || isDone ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                  width: 2,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '$step',
                        style: TextStyle(
                          color: isActive ? Colors.white : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[step - 1],
              style: TextStyle(
                color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStep1(bool isDesktop) {
    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('Full Name', _nameController, required: true)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('Email Address', _emailController, required: true)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('Phone Number', _phoneController, required: true)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDateField('Date of Birth', _dobController)),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdown('Gender', _selectedGender, ['Male', 'Female', 'Other'], (val) => setState(() => _selectedGender = val), hint: 'Select Gender', required: true)),
              const SizedBox(width: 20),
              Expanded(child: _buildTextField('Current Location', _locationController, required: true)),
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        _buildTextField('Full Name', _nameController, required: true),
        const SizedBox(height: 16),
        _buildTextField('Email Address', _emailController, required: true),
        const SizedBox(height: 16),
        _buildTextField('Phone Number', _phoneController, required: true),
        const SizedBox(height: 16),
        _buildDateField('Date of Birth', _dobController),
        const SizedBox(height: 16),
        _buildDropdown('Gender', _selectedGender, ['Male', 'Female', 'Other'], (val) => setState(() => _selectedGender = val), hint: 'Select Gender', required: true),
        const SizedBox(height: 16),
        _buildTextField('Current Location', _locationController, required: true),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isDarkTheme ? Colors.white70 : const Color(0xFF475569))),
            if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 14, color: _isDarkTheme ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _isDarkTheme ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4F46E5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isDarkTheme ? Colors.white70 : const Color(0xFF475569))),
            if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime(2050),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: _isDarkTheme ? const ColorScheme.dark(primary: Color(0xFF4F46E5)) : const ColorScheme.light(primary: Color(0xFF4F46E5)),
                  ),
                  child: child!,
                );
              },
            );
            if (d != null) {
              setState(() {
                controller.text = '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
              });
            }
          },
          style: TextStyle(fontSize: 14, color: _isDarkTheme ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'dd-mm-yyyy',
            hintStyle: TextStyle(color: _isDarkTheme ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            suffixIcon: Icon(Icons.calendar_today_outlined, size: 16, color: _isDarkTheme ? Colors.white54 : const Color(0xFF64748B)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {String hint = '', bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isDarkTheme ? Colors.white70 : const Color(0xFF475569))),
            if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _isDarkTheme ? Colors.white54 : const Color(0xFF64748B), size: 20),
              dropdownColor: _isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
              style: TextStyle(fontSize: 14, color: _isDarkTheme ? Colors.white : const Color(0xFF1E293B)),
              items: [
                if (hint.isNotEmpty)
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(hint, style: TextStyle(color: _isDarkTheme ? Colors.white38 : const Color(0xFF64748B), fontSize: 13)),
                  ),
                ...items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isDarkTheme ? Colors.white70 : const Color(0xFF475569))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 4,
          style: TextStyle(fontSize: 14, color: _isDarkTheme ? Colors.white : const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _isDarkTheme ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 13),
            filled: true,
            fillColor: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4F46E5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectDropdown(String label, List<String> selectedItems, List<String> allItems, Function(List<String>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isDarkTheme ? Colors.white70 : const Color(0xFF475569))),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final List<String>? result = await showDialog<List<String>>(
              context: context,
              builder: (context) {
                return _MultiSelectDialog(
                  allItems: allItems,
                  initialSelectedItems: selectedItems,
                  isDarkTheme: _isDarkTheme,
                );
              },
            );
            if (result != null) {
              onChanged(result);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty ? 'Search Districts...' : selectedItems.join(', '),
                    style: TextStyle(
                      color: selectedItems.isEmpty ? (_isDarkTheme ? Colors.white38 : const Color(0xFF64748B)) : (_isDarkTheme ? Colors.white : const Color(0xFF1E293B)),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: _isDarkTheme ? Colors.white54 : const Color(0xFF64748B), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUpload(String label, {bool required = false, String? fileName, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isDarkTheme ? Colors.white70 : const Color(0xFF475569))),
            if (required) const Text(' *', style: TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: _isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _isDarkTheme ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: fileName != null
                  ? [
                      const Icon(Icons.description, color: Color(0xFF4F46E5), size: 32),
                      const SizedBox(height: 12),
                      Text(fileName, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Click to change file', style: TextStyle(color: _isDarkTheme ? Colors.white54 : const Color(0xFF94A3B8), fontSize: 11)),
                    ]
                  : [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF64748B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 12),
                      const Text('Click to upload', style: TextStyle(color: Color(0xFF4F46E5), fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('PDF, JPG or PNG (max. 5MB)', style: TextStyle(color: _isDarkTheme ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 11)),
                    ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile(Function(String) onPicked) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          onPicked(result.files.first.name);
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Widget _buildStep2(bool isDesktop) {
    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDropdown('Vehicle Category', _vehicleCategory, ['Roadway', 'Airway', 'Waterway'], (val) => setState(() => _vehicleCategory = val), hint: 'Select Category', required: true)),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdown('Vehicle Usage', _vehicleUsage, ['Public (Passenger)', 'Carrier (Goods)'], (val) => setState(() {
                _vehicleUsage = val;
                _vehicleWeight = null; // reset weight on usage change
              }), hint: 'Select Usage', required: true)),
              const SizedBox(width: 20),
              Expanded(child: _vehicleUsage != null
                  ? _buildDropdown('Vehicle Weight', _vehicleWeight, ['Light Vehicle', 'Heavy Vehicle'], (val) => setState(() => _vehicleWeight = val), hint: 'Select Weight', required: true)
                  : const SizedBox()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDropdown('Total Experience (Years)', _experience, ['Fresher', '1-2 Years', '3-5 Years', '6-10 Years', '10+ Years'], (val) => setState(() => _experience = val), hint: 'Select Experience', required: true)),
              const SizedBox(width: 20),
              Expanded(child: const SizedBox()),
              const SizedBox(width: 20),
              Expanded(child: const SizedBox()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildFileUpload('Experience Certificate [Optional]', fileName: _experienceCertificateName, onTap: () => _pickFile((name) => _experienceCertificateName = name))),
              const SizedBox(width: 20),
              Expanded(child: _buildTextArea('Remarks (Optional)', _remarksController, hint: 'Any additional remarks...')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildTextField('License Number', _licenseNumberController, hint: 'Enter License Number', required: true)),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdown('License Type', _licenseType, ['LMV', 'HMV', 'Commercial', 'Transport'], (val) => setState(() => _licenseType = val), hint: 'Select License Type', required: true)),
              const SizedBox(width: 20),
              Expanded(child: _buildDateField('License Expiry Date', _licenseExpiryController, required: true)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDropdown('Driving Range Preference', _rangePreference, ['Within City', 'District to District', 'State to State', 'All Over India'], (val) {
                setState(() {
                  _rangePreference = val;
                  _preferredDistrict = null;
                  _preferredDistricts.clear();
                  _preferredStates.clear();
                  _specificAreasController.clear();
                });
              }, hint: 'Select Range Preference', required: true)),
              const SizedBox(width: 20),
              if (_rangePreference == 'Within City') ...[
                Expanded(child: _buildDropdown('Select Preferred District *', _preferredDistrict, ['Ramanathapuram', 'Alappuzha', 'Ariyalur', 'Bagalkot'], (val) => setState(() => _preferredDistrict = val), hint: 'Select District')),
                const SizedBox(width: 20),
                Expanded(child: _preferredDistrict != null 
                    ? _buildTextField('Specific Areas/Cities *', _specificAreasController, hint: 'e.g. Adyar, T Nagar')
                    : const SizedBox()),
              ] else if (_rangePreference == 'District to District') ...[
                Expanded(child: _buildMultiSelectDropdown('Select Preferred Districts *', _preferredDistricts, ['Ramanathapuram', 'Alappuzha', 'Ariyalur', 'Bagalkot'], (val) => setState(() => _preferredDistricts = val))),
                const SizedBox(width: 20),
                Expanded(child: const SizedBox()),
              ] else if (_rangePreference == 'State to State') ...[
                Expanded(child: _buildMultiSelectDropdown('Select Preferred States *', _preferredStates, ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Karnataka', 'Kerala', 'Tamil Nadu', 'Maharashtra'], (val) => setState(() => _preferredStates = val))),
                const SizedBox(width: 20),
                Expanded(child: const SizedBox()),
              ] else ...[
                Expanded(child: const SizedBox()),
                const SizedBox(width: 20),
                Expanded(child: const SizedBox()),
              ],
            ],
          ),
          const SizedBox(height: 20),
          _buildFileUpload('Driving License', required: true, fileName: _drivingLicenseName, onTap: () => _pickFile((name) => _drivingLicenseName = name)),
        ],
      );
    }
    return Column(
      children: [
        _buildDropdown('Vehicle Category', _vehicleCategory, ['Roadway', 'Airway', 'Waterway'], (val) => setState(() => _vehicleCategory = val), hint: 'Select Category', required: true),
        const SizedBox(height: 16),
        _buildDropdown('Vehicle Usage', _vehicleUsage, ['Public (Passenger)', 'Carrier (Goods)'], (val) => setState(() {
          _vehicleUsage = val;
          if (val == null) _vehicleWeight = null;
        }), hint: 'Select Usage', required: true),
        const SizedBox(height: 16),
        if (_vehicleUsage != null) ...[
          _buildDropdown('Vehicle Weight', _vehicleWeight, ['Light Vehicle', 'Heavy Vehicle'], (val) => setState(() => _vehicleWeight = val), hint: 'Select Weight', required: true),
          const SizedBox(height: 16),
        ],
        _buildDropdown('Total Experience (Years)', _experience, ['Fresher', '1-2 Years', '3-5 Years', '6-10 Years', '10+ Years'], (val) => setState(() => _experience = val), hint: 'Select Experience', required: true),
        const SizedBox(height: 16),
        _buildFileUpload('Experience Certificate [Optional]', fileName: _experienceCertificateName, onTap: () => _pickFile((name) => _experienceCertificateName = name)),
        const SizedBox(height: 16),
        _buildTextArea('Remarks (Optional)', _remarksController, hint: 'Any additional remarks...'),
        const SizedBox(height: 16),
        _buildTextField('License Number', _licenseNumberController, hint: 'Enter License Number', required: true),
        const SizedBox(height: 16),
        _buildDropdown('License Type', _licenseType, ['LMV', 'HMV', 'Commercial', 'Transport'], (val) => setState(() => _licenseType = val), hint: 'Select License Type', required: true),
        const SizedBox(height: 16),
        _buildDateField('License Expiry Date', _licenseExpiryController, required: true),
        const SizedBox(height: 16),
        _buildDropdown('Driving Range Preference', _rangePreference, ['Within City', 'District to District', 'State to State', 'All Over India'], (val) {
          setState(() {
            _rangePreference = val;
            _preferredDistrict = null;
            _preferredDistricts.clear();
            _preferredStates.clear();
            _specificAreasController.clear();
          });
        }, hint: 'Select Range Preference', required: true),
        const SizedBox(height: 16),
        if (_rangePreference == 'Within City') ...[
          _buildDropdown('Select Preferred District *', _preferredDistrict, ['Ramanathapuram', 'Alappuzha', 'Ariyalur', 'Bagalkot'], (val) => setState(() => _preferredDistrict = val), hint: 'Select District'),
          const SizedBox(height: 16),
          if (_preferredDistrict != null) ...[
            _buildTextField('Specific Areas/Cities *', _specificAreasController, hint: 'e.g. Adyar, T Nagar'),
            const SizedBox(height: 16),
          ],
        ] else if (_rangePreference == 'District to District') ...[
          _buildMultiSelectDropdown('Select Preferred Districts *', _preferredDistricts, ['Ramanathapuram', 'Alappuzha', 'Ariyalur', 'Bagalkot'], (val) => setState(() => _preferredDistricts = val)),
          const SizedBox(height: 16),
        ] else if (_rangePreference == 'State to State') ...[
          _buildMultiSelectDropdown('Select Preferred States *', _preferredStates, ['Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Karnataka', 'Kerala', 'Tamil Nadu', 'Maharashtra'], (val) => setState(() => _preferredStates = val)),
          const SizedBox(height: 16),
        ],
        _buildFileUpload('Driving License', required: true, fileName: _drivingLicenseName, onTap: () => _pickFile((name) => _drivingLicenseName = name)),
      ],
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final List<String> allItems;
  final List<String> initialSelectedItems;
  final bool isDarkTheme;

  const _MultiSelectDialog({required this.allItems, required this.initialSelectedItems, required this.isDarkTheme});

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<String> _selectedItems;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = widget.allItems.where((item) => item.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return AlertDialog(
      backgroundColor: widget.isDarkTheme ? const Color(0xFF1E293B) : Colors.white,
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Search Districts...',
          hintStyle: TextStyle(color: widget.isDarkTheme ? Colors.white38 : const Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: Icon(Icons.search, color: widget.isDarkTheme ? Colors.white54 : const Color(0xFF64748B), size: 20),
          filled: true,
          fillColor: widget.isDarkTheme ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
        style: TextStyle(color: widget.isDarkTheme ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
      contentPadding: const EdgeInsets.only(top: 10),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isSelected = _selectedItems.contains(item);
            return CheckboxListTile(
              title: Text(item, style: TextStyle(color: widget.isDarkTheme ? Colors.white : const Color(0xFF1E293B), fontSize: 14)),
              value: isSelected,
              activeColor: const Color(0xFF4F46E5),
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (bool? checked) {
                setState(() {
                  if (checked == true) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: widget.isDarkTheme ? Colors.white54 : const Color(0xFF64748B))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedItems),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
