import 'package:flutter/material.dart';
import 'package:circuit/widgets/common_dashboard_app_bar.dart';
import 'resume_model.dart';
import 'resume_preview_page.dart';

class VerifiedResumeBuilderPage extends StatefulWidget {
  final ResumeData? initialData;

  const VerifiedResumeBuilderPage({super.key, this.initialData});

  @override
  State<VerifiedResumeBuilderPage> createState() => _VerifiedResumeBuilderPageState();
}

class _VerifiedResumeBuilderPageState extends State<VerifiedResumeBuilderPage> {
  int _currentStep = 1;
  late ResumeData _resumeData;

  // Controllers for Step 1
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _summaryController;

  // Controllers for Education
  List<EducationControllers> _educationControllers = [];

  // Controllers for Experience
  List<ExperienceControllers> _experienceControllers = [];

  // Controllers for Skills
  List<TextEditingController> _skillControllers = [];

  // Controllers for Projects
  List<ProjectControllers> _projectControllers = [];

  @override
  void initState() {
    super.initState();
    _resumeData = widget.initialData != null 
        ? ResumeData.clone(widget.initialData!) 
        : ResumeData();

    _nameController = TextEditingController(text: _resumeData.fullName);
    _emailController = TextEditingController(text: _resumeData.email);
    _phoneController = TextEditingController(text: _resumeData.phone);
    _locationController = TextEditingController(text: _resumeData.location);
    _summaryController = TextEditingController(text: _resumeData.professionalSummary);

    for (var item in _resumeData.education) {
      _educationControllers.add(EducationControllers(item));
    }

    for (var item in _resumeData.experience) {
      _experienceControllers.add(ExperienceControllers(item));
    }

    for (var skill in _resumeData.skills) {
      _skillControllers.add(TextEditingController(text: skill));
    }

    for (var item in _resumeData.projects) {
      _projectControllers.add(ProjectControllers(item));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    for (var ec in _educationControllers) ec.dispose();
    for (var ex in _experienceControllers) ex.dispose();
    for (var sc in _skillControllers) sc.dispose();
    for (var pc in _projectControllers) pc.dispose();
    super.dispose();
  }

  void _saveData() {
    _resumeData.fullName = _nameController.text;
    _resumeData.email = _emailController.text;
    _resumeData.phone = _phoneController.text;
    _resumeData.location = _locationController.text;
    _resumeData.professionalSummary = _summaryController.text;

    _resumeData.education = _educationControllers.map((ec) {
      final item = EducationItem();
      item.institution = ec.institution.text;
      item.degree = ec.degree.text;
      item.duration = ec.duration.text;
      return item;
    }).toList();

    _resumeData.experience = _experienceControllers.map((ex) {
      final item = ExperienceItem();
      item.company = ex.company.text;
      item.position = ex.position.text;
      item.duration = ex.duration.text;
      item.responsibilities = ex.responsibilities.text;
      return item;
    }).toList();

    _resumeData.skills = _skillControllers.map((sc) => sc.text).toList();

    _resumeData.projects = _projectControllers.map((pc) {
      final item = ProjectItem();
      item.title = pc.title.text;
      item.link = pc.link.text;
      item.description = pc.description.text;
      return item;
    }).toList();
  }

  void _nextStep() async {
    if (_validateStep()) {
      _saveData();
      if (_currentStep < 4) {
        setState(() => _currentStep++);
      } else {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResumePreviewPage(resumeData: _resumeData),
          ),
        );
        if (result == true) {
          setState(() => _currentStep = 1);
        }
      }
    }
  }

  void _previousStep() {
    _saveData();
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  bool _validateStep() {
    if (_currentStep == 1) {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _locationController.text.isEmpty ||
          _summaryController.text.isEmpty) {
        _showSnackBar("Please fill all required fields");
        return false;
      }
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          _stepDot(1, "Personal", _currentStep >= 1),
          _stepLine(_currentStep >= 2),
          _stepDot(2, "Education", _currentStep >= 2),
          _stepLine(_currentStep >= 3),
          _stepDot(3, "Experience", _currentStep >= 3),
          _stepLine(_currentStep >= 4),
          _stepDot(4, "Skills", _currentStep >= 4),
        ],
      ),
    );
  }

  Widget _stepDot(int step, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF3B82F6) : Colors.white,
            border: Border.all(
              color: active ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              "$step",
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: active ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: active ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildPersonalInfo();
      case 2:
        return _buildEducation();
      case 3:
        return _buildExperience();
      case 4:
        return _buildSkillsAndProjects();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Personal Information", "Basic details for your professional profile"),
        const SizedBox(height: 24),
        _buildTextField("Full Name", _nameController, "e.g. John Doe"),
        _buildTextField("Email Address", _emailController, "e.g. john@example.com", keyboardType: TextInputType.emailAddress),
        _buildTextField("Phone Number", _phoneController, "e.g. +91 9876543210", keyboardType: TextInputType.phone),
        _buildTextField("Location", _locationController, "e.g. Mumbai, India"),
        _buildTextField("Professional Summary", _summaryController, "Briefly describe your professional background", maxLines: 4),
      ],
    );
  }

  Widget _buildEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Education", "Your academic qualifications"),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _educationControllers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            return _buildEducationBlock(index);
          },
        ),
        const SizedBox(height: 24),
        _buildAddButton("Add Another Education", () {
          setState(() => _educationControllers.add(EducationControllers(EducationItem())));
        }),
      ],
    );
  }

  Widget _buildEducationBlock(int index) {
    final controllers = _educationControllers[index];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _blockDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Education #${index + 1}", style: _blockTitleStyle()),
              if (_educationControllers.length > 1)
                IconButton(
                  onPressed: () => setState(() => _educationControllers.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField("Institution", controllers.institution, "University / School Name"),
          _buildTextField("Degree / Certification", controllers.degree, "e.g. Bachelor of Technology"),
          _buildTextField("Duration / Year", controllers.duration, "e.g. 2018 - 2022"),
        ],
      ),
    );
  }

  Widget _buildExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Experience", "Your professional work history"),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _experienceControllers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            return _buildExperienceBlock(index);
          },
        ),
        const SizedBox(height: 24),
        _buildAddButton("Add Another Experience", () {
          setState(() => _experienceControllers.add(ExperienceControllers(ExperienceItem())));
        }),
      ],
    );
  }

  Widget _buildExperienceBlock(int index) {
    final controllers = _experienceControllers[index];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _blockDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Experience #${index + 1}", style: _blockTitleStyle()),
              if (_experienceControllers.length > 1)
                IconButton(
                  onPressed: () => setState(() => _experienceControllers.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField("Company / Organization", controllers.company, "Company Name"),
          _buildTextField("Position / Role", controllers.position, "e.g. Software Engineer"),
          _buildTextField("Duration", controllers.duration, "e.g. Jan 2022 - Present"),
          _buildTextField("Key Responsibilities & Achievements", controllers.responsibilities, "Describe your role", maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildSkillsAndProjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader("Skills & Projects", "Technical skills and featured projects"),
        const SizedBox(height: 32),
        Text("CORE COMPETENCIES / SKILLS", style: _sectionHeaderStyle()),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(_skillControllers.length, (index) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 72) / 2,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillControllers[index],
                      decoration: _inputDecoration("Skill Name", null),
                    ),
                  ),
                  if (_skillControllers.length > 1)
                    IconButton(
                      onPressed: () => setState(() => _skillControllers.removeAt(index)),
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        _buildAddButton("Add Skill", () {
          setState(() => _skillControllers.add(TextEditingController()));
        }),
        const SizedBox(height: 40),
        Text("FEATURED PROJECTS", style: _sectionHeaderStyle()),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _projectControllers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            return _buildProjectBlock(index);
          },
        ),
        const SizedBox(height: 24),
        _buildAddButton("Add Another Project", () {
          setState(() => _projectControllers.add(ProjectControllers(ProjectItem())));
        }),
      ],
    );
  }

  Widget _buildProjectBlock(int index) {
    final controllers = _projectControllers[index];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _blockDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Project #${index + 1}", style: _blockTitleStyle()),
              if (_projectControllers.length > 1)
                IconButton(
                  onPressed: () => setState(() => _projectControllers.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField("Project Title", controllers.title, "Project Name"),
          _buildTextField("Project Link (optional)", controllers.link, "e.g. github.com/user/repo"),
          _buildTextField("Project Description", controllers.description, "Describe the project and your contribution", maxLines: 3),
        ],
      ),
    );
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint, null),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData? icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: const Color(0xFF94A3B8)) : null,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
    );
  }

  BoxDecoration _blockDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }

  TextStyle _blockTitleStyle() {
    return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B));
  }

  TextStyle _sectionHeaderStyle() {
    return const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1);
  }

  Widget _buildAddButton(String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF3B82F6),
        side: const BorderSide(color: Color(0xFF3B82F6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 1) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Text("Previous", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
          ] else ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Text("Cancel", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D8D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _currentStep == 4 ? "Generate Professional Resume" : "Continue",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EducationControllers {
  final TextEditingController institution;
  final TextEditingController degree;
  final TextEditingController duration;

  EducationControllers(EducationItem item)
      : institution = TextEditingController(text: item.institution),
        degree = TextEditingController(text: item.degree),
        duration = TextEditingController(text: item.duration);

  void dispose() {
    institution.dispose();
    degree.dispose();
    duration.dispose();
  }
}

class ExperienceControllers {
  final TextEditingController company;
  final TextEditingController position;
  final TextEditingController duration;
  final TextEditingController responsibilities;

  ExperienceControllers(ExperienceItem item)
      : company = TextEditingController(text: item.company),
        position = TextEditingController(text: item.position),
        duration = TextEditingController(text: item.duration),
        responsibilities = TextEditingController(text: item.responsibilities);

  void dispose() {
    company.dispose();
    position.dispose();
    duration.dispose();
    responsibilities.dispose();
  }
}

class ProjectControllers {
  final TextEditingController title;
  final TextEditingController link;
  final TextEditingController description;

  ProjectControllers(ProjectItem item)
      : title = TextEditingController(text: item.title),
        link = TextEditingController(text: item.link),
        description = TextEditingController(text: item.description);

  void dispose() {
    title.dispose();
    link.dispose();
    description.dispose();
  }
}
