import 'package:flutter/material.dart';

// ── Shared data model for all 3 steps ──
class JobDraftData {
  // Step 1
  final String jobTitle;
  final String companyName;
  final String jobCategory;
  final String department;
  final String jobType;
  final String workplaceType;
  final String jobLevel;
  final String workType;
  final String vacancies;
  final String location;
  final String genderPreference;
  final String workingDays;
  final String shiftTiming;
  final String jobDescription;

  // Step 2
  String payType;
  String currency;
  String payDetails;
  List<String> benefits;
  String education;
  String experience;
  String noticePeriod;
  String language;
  List<String> skills;

  JobDraftData({
    required this.jobTitle,
    required this.companyName,
    required this.jobCategory,
    required this.department,
    required this.jobType,
    required this.workplaceType,
    required this.jobLevel,
    required this.workType,
    required this.vacancies,
    required this.location,
    required this.genderPreference,
    required this.workingDays,
    required this.shiftTiming,
    required this.jobDescription,
    this.payType = '',
    this.currency = '',
    this.payDetails = '',
    this.benefits = const [],
    this.education = '',
    this.experience = '',
    this.noticePeriod = '',
    this.language = '',
    this.skills = const [],
  });
}

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});

  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _titleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _vacanciesController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _jobCategory;
  String? _jobType;
  String? _workplaceType;
  String? _jobLevel;
  String? _workType;
  String? _genderPreference;
  String? _workingDays;
  String? _shiftTiming;

  final List<String> _jobCategories = ['Software Engineering', 'Web Development', 'Mobile Development', 'Data Science', 'Marketing', 'Design', 'Sales', 'Human Resources', 'Finance', 'Operations', 'Support', 'Construction', 'Manufacturing', 'Delivery / Logistics', 'Hospitality', 'Healthcare', 'Education', 'Agriculture', 'Other'];
  final List<String> _jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship', 'Freelance', 'Temporary', 'Daily Wage'];
  final List<String> _workplaceTypes = ['On-site', 'Remote', 'Hybrid'];
  final List<String> _jobLevels = ['Entry Level', 'Fresher', 'Junior', 'Mid-Level', 'Senior', 'Lead', 'Manager', 'Supervisor'];
  final List<String> _workTypes = ['Technical', 'Non-Technical', 'Physical'];
  final List<String> _genderPreferences = ['Any', 'Male', 'Female', 'Male / Female'];
  final List<String> _workingDaysList = ['Monday - Friday', 'Monday - Saturday', '6 Days (Rotational Off)', 'Flexible', 'Custom'];
  final List<String> _shiftTimings = ['Day Shift', 'Night Shift', 'Rotational Shift', 'Morning Shift', 'Evening Shift', 'Flexible', 'US Shift', 'UK Shift'];

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    _departmentController.dispose();
    _vacanciesController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      final data = JobDraftData(
        jobTitle: _titleController.text.trim(),
        companyName: _companyController.text.trim(),
        jobCategory: _jobCategory ?? '',
        department: _departmentController.text.trim(),
        jobType: _jobType ?? '',
        workplaceType: _workplaceType ?? '',
        jobLevel: _jobLevel ?? '',
        workType: _workType ?? '',
        vacancies: _vacanciesController.text.trim(),
        location: _locationController.text.trim(),
        genderPreference: _genderPreference ?? '',
        workingDays: _workingDays ?? '',
        shiftTiming: _shiftTiming ?? '',
        jobDescription: _descriptionController.text.trim(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PayAndBenefitsPage(step1Data: data)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    
    int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Post Job",
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 32),
                  _buildStepper(isDark),
                  const SizedBox(height: 48),
                  
                  // Job Information Section
                  _buildSectionTitle("Job Information", Icons.work, isDark),
                  const SizedBox(height: 24),
                  _buildGrid(crossAxisCount, [
                    _buildTextField("Company Name *", "Enter company name", _companyController, isDark, required: true),
                    _buildTextField("Job Title *", "e.g. Senior React Developer", _titleController, isDark, required: true),
                    _buildSearchableDropdown("Job Category *", _jobCategory, _jobCategories, (val) => setState(() => _jobCategory = val), isDark, required: true),
                    
                    _buildTextField("Department", "e.g. Engineering", _departmentController, isDark, required: false),
                    _buildSearchableDropdown("Job Type *", _jobType, _jobTypes, (val) => setState(() => _jobType = val), isDark, required: true),
                    _buildSearchableDropdown("Workplace Type *", _workplaceType, _workplaceTypes, (val) => setState(() => _workplaceType = val), isDark, required: true),
                    
                    _buildSearchableDropdown("Job Level", _jobLevel, _jobLevels, (val) => setState(() => _jobLevel = val), isDark, required: false),
                    _buildSearchableDropdown("Work Type *", _workType, _workTypes, (val) => setState(() => _workType = val), isDark, required: true),
                    _buildTextField("Vacancies", "e.g. 3", _vacanciesController, isDark, required: false, isNumber: true),
                    
                    _buildTextField("Location *", "e.g. Bengaluru, India", _locationController, isDark, required: true),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  // Additional Details Section
                  _buildSectionTitle("Additional Details", Icons.info, isDark),
                  const SizedBox(height: 24),
                  _buildGrid(crossAxisCount, [
                    _buildSearchableDropdown("Gender Preference", _genderPreference, _genderPreferences, (val) => setState(() => _genderPreference = val), isDark, required: false),
                    _buildSearchableDropdown("Working Days", _workingDays, _workingDaysList, (val) => setState(() => _workingDays = val), isDark, required: false),
                    _buildSearchableDropdown("Shift Timing", _shiftTiming, _shiftTimings, (val) => setState(() => _shiftTiming = val), isDark, required: false),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  // Job Description Section
                  _buildSectionTitle("Job Description", Icons.description, isDark),
                  const SizedBox(height: 24),
                  _buildTextArea("Job Description *", "Describe the role, responsibilities, work environment...", _descriptionController, isDark, required: true),
                  
                  const SizedBox(height: 40),
                  
                  // Next Step Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Next Step", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.work, color: Color(0xFF6366F1), size: 24),
            ),
            const SizedBox(width: 12),
            Text("Post A New Job", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 8),
        Text("Fill in the details below to create a job listing.", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 14)),
      ],
    );
  }

  Widget _buildStepper(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator("1", "Job Details", true, isDark),
        _buildStepConnector(isDark),
        _buildStepIndicator("2", "Pay, Benefits & Requirements", false, isDark),
        _buildStepConnector(isDark),
        _buildStepIndicator("3", "Settings", false, isDark),
      ],
    );
  }

  Widget _buildStepIndicator(String step, String label, bool isActive, bool isDark) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            shape: BoxShape.circle,
          ),
          child: Text(step, style: TextStyle(color: isActive ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: isActive ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepConnector(bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 20),
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6366F1))),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ],
    );
  }

  Widget _buildGrid(int crossAxisCount, List<Widget> children) {
    if (crossAxisCount == 1) {
      return Column(
        children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 20), child: c)).toList(),
      );
    }
    
    List<Widget> rows = [];
    for (int i = 0; i < children.length; i += crossAxisCount) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < crossAxisCount; j++) {
        if (i + j < children.length) {
          rowChildren.add(Expanded(child: children[i + j]));
        } else {
          rowChildren.add(Expanded(child: Container()));
        }
        if (j < crossAxisCount - 1) rowChildren.add(const SizedBox(width: 24));
      }
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowChildren));
      rows.add(const SizedBox(height: 24));
    }
    return Column(children: rows);
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isDark, {bool required = false, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: required ? (v) => v == null || v.isEmpty ? 'This field is required' : null : null,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: _inputDecoration(hint, isDark),
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String hint, TextEditingController controller, bool isDark, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 6,
          validator: required ? (v) => v == null || v.isEmpty ? 'This field is required' : null : null,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: _inputDecoration(hint, isDark),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    bool hasAsterisk = label.contains('*');
    String text = label.replaceAll('*', '').trim();
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
        children: hasAsterisk ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSearchableDropdown(String label, String? selectedValue, List<String> items, Function(String) onSelected, bool isDark, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showSearchDialog(label, items, onSelected, isDark),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (required && selectedValue == null && _formKey.currentState?.validate() == false) 
                  ? Colors.red.shade700 
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedValue ?? "Select ${label.replaceAll('*', '').trim()}",
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedValue != null ? (isDark ? Colors.white : const Color(0xFF1E293B)) : const Color(0xFF94A3B8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), size: 20),
              ],
            ),
          ),
        ),
        if (required && selectedValue == null && _formKey.currentState?.validate() == false)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text('This field is required', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
          ),
      ],
    );
  }

  void _showSearchDialog(String label, List<String> items, Function(String) onSelected, bool isDark) {
    showDialog(
      context: context,
      builder: (context) {
        return SearchableDropdownDialog(
          title: label.replaceAll('*', '').trim(),
          items: items,
          onSelected: onSelected,
          isDark: isDark,
        );
      },
    );
  }
}

class SearchableDropdownDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(String) onSelected;
  final bool isDark;

  const SearchableDropdownDialog({
    super.key,
    required this.title,
    required this.items,
    required this.onSelected,
    required this.isDark,
  });

  @override
  State<SearchableDropdownDialog> createState() => _SearchableDropdownDialogState();
}

class _SearchableDropdownDialogState extends State<SearchableDropdownDialog> {
  String _searchQuery = '';
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Each item ~52px tall, header ~56px, max cap at 65% screen height
    final itemHeight = 52.0;
    final headerHeight = 56.0;
    final contentHeight = headerHeight + (_filteredItems.isEmpty ? 60.0 : _filteredItems.length * itemHeight);
    final dialogHeight = contentHeight.clamp(120.0, screenHeight * 0.65);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 400,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6366F1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      onChanged: _filterItems,
                      style: TextStyle(fontSize: 14, color: widget.isDark ? Colors.white : const Color(0xFF1E293B)),
                      decoration: InputDecoration(
                        hintText: "Search ${widget.title}...",
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // List Items — expands only as needed
            Flexible(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text("No results found",
                            style: TextStyle(color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isLast = index == _filteredItems.length - 1;
                        return InkWell(
                          onTap: () {
                            widget.onSelected(item);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              border: isLast ? null : Border(bottom: BorderSide(
                                color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                              )),
                            ),
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
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


// Step 2 — Pay, Benefits & Requirements
class PayAndBenefitsPage extends StatefulWidget {
  final JobDraftData step1Data;
  const PayAndBenefitsPage({super.key, required this.step1Data});

  @override
  State<PayAndBenefitsPage> createState() => _PayAndBenefitsPageState();
}

class _PayAndBenefitsPageState extends State<PayAndBenefitsPage> {
  final _formKey = GlobalKey<FormState>();

  // Pay
  String? _payType;
  String? _currency = 'INR';

  // Hourly
  final _hoursPerDayController = TextEditingController();
  final _perHourRateController = TextEditingController();

  // Project Based
  final _projectBudgetController = TextEditingController();
  String? _projectDuration;

  // Monthly
  final _minSalaryController = TextEditingController();
  final _maxSalaryController = TextEditingController();

  // Contract
  String? _contractDuration;
  final _totalContractController = TextEditingController();

  final List<String> _projectDurations = ['1 Month', '2 Months', '3 Months', '6 Months', '1 Year', '1+ Year', 'Ongoing'];
  final List<String> _contractDurations = ['3', '6', '9', '12', '18', '24'];

  // Benefits checkboxes
  final Map<String, bool> _benefits = {
    'Transport Allowance': false,
    'Insurance': false,
    'Loan Facility': false,
    'Paid Leave': false,
    'Food Allowance': false,
    'Accommodation': false,
    'PF (Provident Fund)': false,
    'Medical Insurance': false,
  };

  // Requirements
  String? _education;
  String? _experience;
  String? _noticePeriod;
  final _languageController = TextEditingController();

  // Skills chip input
  final _skillController = TextEditingController();
  final List<String> _skills = [];

  final List<String> _payTypes = ['Hourly', 'Project Based', 'Monthly', 'Contract'];
  final List<String> _currencies = ['INR', 'USD', 'EUR', 'GBP', 'AED', 'SGD', 'AUD', 'CAD', 'JPY'];
  final List<String> _educations = ['10th Pass', '12th Pass', 'Diploma', 'ITI', "Bachelor's Degree", "Master's Degree"];
  final List<String> _experiences = ['Fresher', '0-1 Years', '1-3 Years', '3-5 Years', '5-7 Years', '7-10 Years', '10+ Years'];
  final List<String> _noticePeriods = ['Immediate', '15 Days', '30 Days', '60 Days', '90 Days'];

  @override
  void dispose() {
    _hoursPerDayController.dispose();
    _perHourRateController.dispose();
    _projectBudgetController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _totalContractController.dispose();
    _languageController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill(String skill) {
    final trimmed = skill.trim().replaceAll(',', '').trim();
    if (trimmed.isNotEmpty && !_skills.contains(trimmed)) {
      setState(() {
        _skills.add(trimmed);
        _skillController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Post Job",
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(isDark),
                  const SizedBox(height: 32),

                  // Stepper
                  _buildStepper(isDark),
                  const SizedBox(height: 48),

                  // ── Shift & Pay Details ──
                  _buildSectionTitle("Shift & Pay Details", Icons.currency_exchange, isDark),
                  const SizedBox(height: 24),

                  // Pay Type + Currency row
                  _buildGrid(crossAxisCount, [
                    _buildSearchableDropdown(
                      "Pay Type *", _payType, _payTypes,
                      (val) => setState(() => _payType = val),
                      isDark, required: true,
                    ),
                    _buildSearchableDropdown(
                      "Currency", _currency, _currencies,
                      (val) => setState(() => _currency = val),
                      isDark, required: false,
                    ),
                  ]),

                  // ── Dynamic Pay Calculation Panel ──
                  if (_payType != null) ...[
                    const SizedBox(height: 20),
                    _buildPayCalculationSection(isDark),
                  ],

                  const SizedBox(height: 32),

                  // ── Benefits & Perks ──
                  _buildSectionTitle("Benefits & Perks", Icons.card_giftcard, isDark),
                  const SizedBox(height: 20),
                  _buildBenefitsGrid(isDark),

                  const SizedBox(height: 32),

                  // ── Requirements ──
                  _buildSectionTitle("Requirements", Icons.school, isDark),
                  const SizedBox(height: 16),

                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "On-site/Hybrid technical roles require at least 10th pass.",
                            style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildGrid(crossAxisCount, [
                    _buildSearchableDropdown(
                      "Education Required *", _education, _educations,
                      (val) => setState(() => _education = val),
                      isDark, required: true,
                    ),
                    _buildSearchableDropdown(
                      "Experience Required", _experience, _experiences,
                      (val) => setState(() => _experience = val),
                      isDark, required: false,
                    ),
                    _buildSearchableDropdown(
                      "Notice Period", _noticePeriod, _noticePeriods,
                      (val) => setState(() => _noticePeriod = val),
                      isDark, required: false,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Language Required
                  SizedBox(
                    width: isDesktop ? 320 : double.infinity,
                    child: _buildTextField("Language Required", "e.g. English, Hindi, Tamil", _languageController, isDark, required: false),
                  ),
                  const SizedBox(height: 24),

                  // Skills Required
                  _buildSkillsInput(isDark),

                  const SizedBox(height: 40),

                  // ── Navigation Buttons ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text("Previous"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Collect pay details string
                            String payDetails = '';
                            if (_payType == 'Hourly') {
                              payDetails = '${_currency ?? ''} ${_perHourRateController.text}/hr';
                            } else if (_payType == 'Project Based') {
                              payDetails = '${_currency ?? ''} ${_projectBudgetController.text} (${_projectDuration ?? ''})';
                            } else if (_payType == 'Monthly') {
                              payDetails = '${_currency ?? ''} ${_minSalaryController.text} - ${_maxSalaryController.text}/month';
                            } else if (_payType == 'Contract') {
                              payDetails = '${_currency ?? ''} ${_totalContractController.text} (${_contractDuration ?? ''} months)';
                            }

                            // Update step1Data with step2 info
                            final allData = widget.step1Data
                              ..payType = _payType ?? ''
                              ..currency = _currency ?? ''
                              ..payDetails = payDetails
                              ..benefits = _benefits.entries.where((e) => e.value).map((e) => e.key).toList()
                              ..education = _education ?? ''
                              ..experience = _experience ?? ''
                              ..noticePeriod = _noticePeriod ?? ''
                              ..language = _languageController.text.trim()
                              ..skills = List<String>.from(_skills);

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsPage(allData: allData)),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Next Step", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
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

  // ══ Dynamic Pay Calculation Panel ══
  Widget _buildPayCalculationSection(bool isDark) {
    Color accentColor;
    IconData accentIcon;
    String panelTitle;
    Widget content;

    switch (_payType) {
      case 'Hourly':
        accentColor = const Color(0xFF6366F1);
        accentIcon = Icons.access_time;
        panelTitle = 'HOURLY PAY CALCULATION';
        content = _buildHourlySection(isDark);
        break;
      case 'Project Based':
        accentColor = const Color(0xFF8B5CF6);
        accentIcon = Icons.folder_open;
        panelTitle = 'PROJECT-BASED PAY';
        content = _buildProjectSection(isDark);
        break;
      case 'Monthly':
        accentColor = const Color(0xFF0EA5E9);
        accentIcon = Icons.calendar_month;
        panelTitle = 'MONTHLY SALARY RANGE';
        content = _buildMonthlySection(isDark);
        break;
      case 'Contract':
        accentColor = const Color(0xFF10B981);
        accentIcon = Icons.description_outlined;
        panelTitle = 'CONTRACT PAY';
        content = _buildContractSection(isDark);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(accentIcon, size: 16, color: accentColor),
              const SizedBox(width: 8),
              Text(panelTitle,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildHourlySection(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    String estimatedEarnings = '';
    final hours = double.tryParse(_hoursPerDayController.text);
    final rate = double.tryParse(_perHourRateController.text);
    if (hours != null && rate != null && hours > 0 && rate > 0) {
      final monthly = hours * rate * 26;
      estimatedEarnings = '~${_currency ?? ''} ${monthly.toStringAsFixed(0)} / month';
    }

    if (isMobile) {
      return Column(children: [
        _buildNumberField("Hours Per Day", "e.g. 8", _hoursPerDayController, isDark),
        const SizedBox(height: 16),
        _buildNumberField("Per Hour Rate", "e.g. 750 (${_currency ?? 'INR'})", _perHourRateController, isDark),
        const SizedBox(height: 16),
        _buildReadonlyField("Estimated Earnings", estimatedEarnings, "Auto-calculated", isDark),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _buildNumberField("Hours Per Day", "e.g. 8", _hoursPerDayController, isDark)),
      const SizedBox(width: 20),
      Expanded(child: _buildNumberField("Per Hour Rate", "e.g. 750 (${_currency ?? 'INR'})", _perHourRateController, isDark)),
      const SizedBox(width: 20),
      Expanded(child: _buildReadonlyField("Estimated Earnings", estimatedEarnings, "Auto-calculated", isDark)),
    ]);
  }

  Widget _buildProjectSection(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    if (isMobile) {
      return Column(children: [
        _buildNumberField("Project Budget *", "Total in ${_currency ?? 'INR'}", _projectBudgetController, isDark),
        const SizedBox(height: 16),
        _buildSearchableDropdown("Project Duration", _projectDuration, _projectDurations,
            (val) => setState(() => _projectDuration = val), isDark, required: false),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _buildNumberField("Project Budget *", "Total in ${_currency ?? 'INR'}", _projectBudgetController, isDark)),
      const SizedBox(width: 20),
      Expanded(child: _buildSearchableDropdown("Project Duration", _projectDuration, _projectDurations,
          (val) => setState(() => _projectDuration = val), isDark, required: false)),
      const Expanded(child: SizedBox()),
    ]);
  }

  Widget _buildMonthlySection(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    if (isMobile) {
      return Column(children: [
        _buildNumberField("Minimum Salary *", "e.g. 25000", _minSalaryController, isDark),
        const SizedBox(height: 16),
        _buildNumberField("Maximum Salary *", "e.g. 45000", _maxSalaryController, isDark),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _buildNumberField("Minimum Salary *", "e.g. 25000", _minSalaryController, isDark)),
      const SizedBox(width: 20),
      Expanded(child: _buildNumberField("Maximum Salary *", "e.g. 45000", _maxSalaryController, isDark)),
      const Expanded(child: SizedBox()),
    ]);
  }

  Widget _buildContractSection(bool isDark) {
    final isMobile = MediaQuery.of(context).size.width <= 600;
    String perMonth = '';
    final total = double.tryParse(_totalContractController.text);
    final months = double.tryParse(_contractDuration ?? '');
    if (total != null && months != null && months > 0) {
      perMonth = '${_currency ?? ''} ${(total / months).toStringAsFixed(0)} / month';
    }
    if (isMobile) {
      return Column(children: [
        _buildSearchableDropdown("Contract Duration (months) *", _contractDuration, _contractDurations,
            (val) => setState(() => _contractDuration = val), isDark, required: true),
        const SizedBox(height: 16),
        _buildNumberField("Total Contract Amount *", "Total in ${_currency ?? 'INR'}", _totalContractController, isDark),
        const SizedBox(height: 16),
        _buildReadonlyField("Per Month Breakdown", perMonth, "Enter amount & duration", isDark),
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _buildSearchableDropdown("Contract Duration (months) *", _contractDuration, _contractDurations,
          (val) => setState(() => _contractDuration = val), isDark, required: true)),
      const SizedBox(width: 20),
      Expanded(child: _buildNumberField("Total Contract Amount *", "Total in ${_currency ?? 'INR'}", _totalContractController, isDark)),
      const SizedBox(width: 20),
      Expanded(child: _buildReadonlyField("Per Month Breakdown", perMonth, "Enter amount & duration", isDark)),
    ]);
  }

  Widget _buildNumberField(String label, String hint, TextEditingController ctrl, bool isDark) {
    bool hasAsterisk = label.contains('*');
    String text = label.replaceAll('*', '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: TextSpan(
          text: text,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          children: hasAsterisk ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
        )),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          validator: hasAsterisk ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: _inputDecoration(hint, isDark),
        ),
      ],
    );
  }

  Widget _buildReadonlyField(String label, String value, String placeholder, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            value.isNotEmpty ? value : placeholder,
            style: TextStyle(
              fontSize: 14,
              color: value.isNotEmpty ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              fontWeight: value.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsGrid(bool isDark) {

    final keys = _benefits.keys.toList();
    final int cols = MediaQuery.of(context).size.width > 600 ? 4 : 2;
    List<Widget> rows = [];
    for (int i = 0; i < keys.length; i += cols) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < cols; j++) {
        if (i + j < keys.length) {
          final key = keys[i + j];
          rowChildren.add(
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: _benefits[key],
                    activeColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _benefits[key] = val ?? false),
                  ),
                  Expanded(
                    child: Text(
                      key,
                      style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          rowChildren.add(Expanded(child: const SizedBox()));
        }
      }
      rows.add(Row(children: rowChildren));
      rows.add(const SizedBox(height: 4));
    }
    return Column(children: rows);
  }

  Widget _buildSkillsInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "Skills Required",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
            children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Existing skill chips
              if (_skills.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(skill, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _skills.remove(skill)),
                          child: const Icon(Icons.close, size: 14, color: Color(0xFF6366F1)),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
              ],
              // Text input
              TextField(
                controller: _skillController,
                onSubmitted: _addSkill,
                onChanged: (val) {
                  if (val.endsWith(',')) _addSkill(val);
                },
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: "e.g. React, Welding, Driving...",
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _skillController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF6366F1), size: 20),
                        onPressed: () => _addSkill(_skillController.text),
                      )
                    : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text("Press Enter or comma to add a skill", style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
      ],
    );
  }

  // ── Reused helpers (same as PostJobPage) ──

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.work, color: Color(0xFF6366F1), size: 24),
            ),
            const SizedBox(width: 12),
            Text("Post A New Job", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
          ],
        ),
        const SizedBox(height: 8),
        Text("Fill in the details below to create a job listing.", style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 14)),
      ],
    );
  }

  Widget _buildStepper(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator("1", "Job Details", false, isDark, isCompleted: true),
        _buildStepConnector(isDark),
        _buildStepIndicator("2", "Pay, Benefits & Requirements", true, isDark),
        _buildStepConnector(isDark),
        _buildStepIndicator("3", "Settings", false, isDark),
      ],
    );
  }

  Widget _buildStepIndicator(String step, String label, bool isActive, bool isDark, {bool isCompleted = false}) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFF10B981) : (isActive ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text(step, style: TextStyle(color: (isActive || isCompleted) ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 28),
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ],
    );
  }

  Widget _buildGrid(int crossAxisCount, List<Widget> children) {
    if (crossAxisCount == 1) {
      return Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 20), child: c)).toList());
    }
    List<Widget> rows = [];
    for (int i = 0; i < children.length; i += crossAxisCount) {
      List<Widget> row = [];
      for (int j = 0; j < crossAxisCount; j++) {
        row.add(Expanded(child: (i + j < children.length) ? children[i + j] : Container()));
        if (j < crossAxisCount - 1) row.add(const SizedBox(width: 24));
      }
      rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: row));
      rows.add(const SizedBox(height: 24));
    }
    return Column(children: rows);
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, bool isDark, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: required ? (v) => v == null || v.isEmpty ? 'This field is required' : null : null,
          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          decoration: _inputDecoration(hint, isDark),
        ),
      ],
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    bool hasAsterisk = label.contains('*');
    String text = label.replaceAll('*', '').trim();
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
        children: hasAsterisk ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSearchableDropdown(String label, String? selectedValue, List<String> items, Function(String) onSelected, bool isDark, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isDark),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => SearchableDropdownDialog(
                title: label.replaceAll('*', '').trim(),
                items: items,
                onSelected: onSelected,
                isDark: isDark,
              ),
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedValue ?? "Select ${label.replaceAll('*', '').trim()}",
                    style: TextStyle(fontSize: 14, color: selectedValue != null ? (isDark ? Colors.white : const Color(0xFF1E293B)) : const Color(0xFF94A3B8)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════
// Step 3 — Settings
// ══════════════════════════════════════════
class SettingsPage extends StatefulWidget {
  final JobDraftData allData;
  const SettingsPage({super.key, required this.allData});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DateTime? _deadline;
  bool _isUrgentHiring = false;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6366F1),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _publishJob() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 52),
              ),
              const SizedBox(height: 20),
              const Text('Job Posted Successfully!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              const Text('Your job listing is now live and visible to candidates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = widget.allData;
    final typeParts = [d.jobType, d.workplaceType, d.workType].where((s) => s.isNotEmpty).toList();

    final previewRows = <MapEntry<String, String>>[
      MapEntry('Job Title', d.jobTitle.isNotEmpty ? d.jobTitle : '—'),
      MapEntry('Company', d.companyName.isNotEmpty ? d.companyName : '—'),
      MapEntry('Category', d.jobCategory.isNotEmpty ? d.jobCategory : '—'),
      MapEntry('Type', typeParts.isNotEmpty ? typeParts.join(' • ') : '—'),
      MapEntry('Location', d.location.isNotEmpty ? d.location : '—'),
      MapEntry('Pay', d.payDetails.isNotEmpty ? d.payDetails : '—'),
      MapEntry('Education', d.education.isNotEmpty ? d.education : '—'),
      MapEntry('Experience', d.experience.isNotEmpty ? d.experience : '—'),
      MapEntry('Working Days', d.workingDays.isNotEmpty ? d.workingDays : '—'),
      MapEntry('Shift', d.shiftTiming.isNotEmpty ? d.shiftTiming : '—'),
      MapEntry('Skills', d.skills.isEmpty ? '—' : d.skills.join(', ')),
      MapEntry('Benefits', d.benefits.isEmpty ? '—' : d.benefits.map((b) => b.split(' ').first).join(', ')),
      MapEntry('Deadline', _deadline != null ? _formatDate(_deadline!) : '—'),
      if (_isUrgentHiring) const MapEntry('Priority', '⚡ Urgent Hiring'),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Post Job',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 32),
                _buildStepper(isDark),
                const SizedBox(height: 48),

                // ── Application Settings ──
                _buildSectionTitle('Application Settings', Icons.settings, isDark),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 24,
                  runSpacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    // Deadline picker
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280, minWidth: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(text: TextSpan(
                            text: 'Application Deadline',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                            children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
                          )),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickDeadline,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _deadline != null ? _formatDate(_deadline!) : 'dd-mm-yyyy',
                                    style: TextStyle(fontSize: 14, color: _deadline != null ? (isDark ? Colors.white : const Color(0xFF1E293B)) : const Color(0xFF94A3B8)),
                                  ),
                                  Icon(Icons.calendar_today, size: 18, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Job Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Job Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(6)),
                                child: const Text('Draft', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 10),
                              const Text('You can publish after review.', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Mark as Urgent Hiring
                InkWell(
                  onTap: () => setState(() => _isUrgentHiring = !_isUrgentHiring),
                  borderRadius: BorderRadius.circular(6),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Checkbox(
                      value: _isUrgentHiring,
                      activeColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (v) => setState(() => _isUrgentHiring = v ?? false),
                    ),
                    RichText(text: const TextSpan(
                      text: 'Mark as ',
                      style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                      children: [TextSpan(text: 'Urgent Hiring', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold))],
                    )),
                  ]),
                ),

                const SizedBox(height: 32),

                // ── Quick Preview ──
                _buildSectionTitle('Quick Preview', Icons.preview, isDark),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: previewRows.asMap().entries.map((entry) {
                      final e = entry.value;
                      final isLast = entry.key == previewRows.length - 1;
                      final isUrgent = e.key == 'Priority';
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          border: isLast ? null : Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                            Flexible(
                              child: Text(
                                e.value,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isUrgent ? const Color(0xFFF59E0B) : (isDark ? Colors.white : const Color(0xFF1E293B)),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Navigation Buttons ──
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _publishJob,
                      icon: const Icon(Icons.send, color: Colors.white, size: 16),
                      label: const Text('Publish Job', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildHeader(bool isDark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.work, color: Color(0xFF6366F1), size: 24),
        ),
        const SizedBox(width: 12),
        Text('Post A New Job', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
      ]),
      const SizedBox(height: 8),
      Text('Fill in the details below to create a job listing.', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 14)),
    ],
  );

  Widget _buildStepper(bool isDark) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildStep('1', 'Job Details', false, isDark, done: true),
      _buildConn(),
      _buildStep('2', 'Pay, Benefits & Requirements', false, isDark, done: true),
      _buildConn(),
      _buildStep('3', 'Settings', true, isDark),
    ],
  );

  Widget _buildStep(String n, String label, bool active, bool isDark, {bool done = false}) => Column(children: [
    Container(
      width: 32, height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? const Color(0xFF10B981) : (active ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
        shape: BoxShape.circle,
      ),
      child: done ? const Icon(Icons.check, color: Colors.white, size: 18) : Text(n, style: TextStyle(color: (active || done) ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), fontWeight: FontWeight.bold)),
    ),
    const SizedBox(height: 8),
    ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 100),
      child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: active ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
    ),
  ]);

  Widget _buildConn() => Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 28), color: const Color(0xFF10B981)));

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) => Column(children: [
    Row(children: [
      Icon(icon, size: 18, color: const Color(0xFF6366F1)),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
    ]),
    const SizedBox(height: 8),
    Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
  ]);
}



