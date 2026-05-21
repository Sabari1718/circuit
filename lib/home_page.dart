import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'upgrade/business_welcome_page.dart';
import 'upgrade/business_created_page.dart';
import 'upgrade/register_user_page.dart';
import 'upgrade/employee_upgrade_page.dart';
import 'upgrade/business_user_store.dart';
import 'upgrade/employee_user_store.dart';
import 'upgrade/employee_application_preview_page.dart';
import 'user_service.dart';
import 'widgets/common_dashboard_app_bar.dart';
import 'widgets/account_type_card.dart';

enum DashboardSection { activities, privilege }

class ActivityCardData {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final Color color;
  final bool isCompleted;

  ActivityCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    this.isCompleted = false,
  });
}

class HomePage extends StatefulWidget {
  final String userName;
  final String email;
  final String userId;
  final String accountType;

  const HomePage({
    super.key,
    this.userName = "User",
    this.email = "user@example.com",
    this.userId = "9508383027",
    this.accountType = "GUEST",
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentUserName = "User";
  String _accountType = "GUEST";
  String _selectedBusinessScale = "Small Scale";
  DashboardSection _selectedSection = DashboardSection.activities;

  final TextEditingController _searchController = TextEditingController();
  late List<ActivityCardData> _activities;
  List<ActivityCardData> _filteredActivities = [];

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
    _accountType = widget.accountType;
    _loadUserSession();
    _initializeActivities();
    _filteredActivities = List.from(_activities);
  }

  void _initializeActivities() {
    _activities = [
      ActivityCardData(
        id: "job_career",
        title: "JOB",
        subtitle: "CAREER",
        description: "Employee access to business features",
        icon: "📝",
        color: const Color(0xFFF97316),
      ),
      ActivityCardData(
        id: "business_career",
        title: "BUSINESS",
        subtitle: "CAREER",
        description: "Access to business analytics & team management",
        icon: "💼",
        color: const Color(0xFF64748B),
      ),
      ActivityCardData(
        id: "business",
        title: "MY BUSINESS",
        subtitle: "Enterprise",
        description: "Analytics & Team tools for businesses",
        icon: "💼",
        color: const Color(0xFF8B5CF6),
      ),
      ActivityCardData(
        id: "employee",
        title: "EMPLOYEE",
        subtitle: "User",
        description: "Employee management & payroll features",
        icon: "📋",
        color: const Color(0xFF64748B),
      ),
      ActivityCardData(
        id: "kovil",
        title: "KOVIL",
        subtitle: "Temple",
        description: "Manage temple activities & donations",
        icon: "🛕",
        color: const Color(0xFF7C3AED),
      ),
      ActivityCardData(
        id: "real_estate",
        title: "REAL ESTATE",
        subtitle: "Property",
        description: "Property listings & management tools",
        icon: "🏠",
        color: const Color(0xFF10B981),
      ),
      ActivityCardData(
        id: "social",
        title: "SOCIAL",
        subtitle: "Media",
        description: "Social networking & community tools",
        icon: "👥",
        color: const Color(0xFF3B82F6),
      ),
      ActivityCardData(
        id: "trust",
        title: "TRUST",
        subtitle: "Organization",
        description: "Manage trust funds, charity & non-profit organizations",
        icon: "🏛️",
        color: const Color(0xFF94A3B8),
      ),
      ActivityCardData(
        id: "voluntary",
        title: "VOLUNTARY",
        subtitle: "Service",
        description: "Join volunteer drives, community service & social impact",
        icon: "🤝",
        color: const Color(0xFFF59E0B),
      ),
      ActivityCardData(
        id: "jobs",
        title: "MY JOBS",
        subtitle: "Portal",
        description: "Showcase your career, skills & professional achievements",
        icon: "👨‍💻",
        color: const Color(0xFF6366F1),
      ),
    ];
  }

  void _filterActivities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredActivities = List.from(_activities);
      } else {
        _filteredActivities = _activities.where((activity) {
          final title = activity.title.toLowerCase();
          final subtitle = activity.subtitle.toLowerCase();
          final description = activity.description.toLowerCase();
          final searchLower = query.toLowerCase();
          return title.contains(searchLower) ||
                 subtitle.contains(searchLower) ||
                 description.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _loadUserSession() async {
    await UserService().loadSession();
    final data = await UserService().getUserData();
    if (mounted) {
      setState(() {
        _currentUserName = (data['name'] ?? widget.userName).trim().isEmpty
            ? widget.userName
            : data['name']!;
        _accountType = data['accountType'] ?? widget.accountType;
        
        // Initialize dropdown from store if business exists
        if (BusinessUserStore().businesses.isNotEmpty && 
            BusinessUserStore().businesses.first.businessTypes.isNotEmpty) {
          _selectedBusinessScale = BusinessUserStore().businesses.first.businessTypes.first;
        }
      });
    }
  }

  bool _checkCompletion(String moduleId) {
    if (moduleId == "job_career" || moduleId == "business_career") {
      return true;
    }
    if (moduleId == "business") {
      return BusinessUserStore().businesses.isNotEmpty;
    }
    if (moduleId == "employee") {
      return EmployeeUserStore().hasData;
    }
    return false;
  }

  void _handleNavigation(String moduleId, String title) {
    final isCompleted = _checkCompletion(moduleId);
    
    if (isCompleted) {
      if (moduleId == "business" || moduleId == "business_career") {
        openBusinessViewPage(context);
      } else if (moduleId == "employee") {
        final data = EmployeeUserStore().employees.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeApplicationPreviewPage(
              workType: data.workType,
              resumeName: data.resumeName,
              resumeBytes: data.resumeBytes,
              noPanCard: data.noPanCard,
              panNumber: data.panNumber,
              addressProofType: data.addressProofType,
              addressProofName: data.addressProofName,
              addressProofBytes: null, // Bytes not stored for view
              salaryAccount: data.salaryAccount,
              educationBoard: data.educationBoard,
              primaryStudy: data.primaryStudy,
              primaryMarksheetName: null,
              primaryMarksheetBytes: null,
              after10thPath: data.after10thPath,
              higherSecondaryClass: null,
              hsMarksheetName: null,
              hsMarksheetBytes: null,
              itiCourse: null,
              itiCertificateName: null,
              itiCertificateBytes: null,
              degrees: data.degrees.map((d) => EmployeePreviewDegreeData(
                stream: d.stream,
                degree: d.degree,
                university: d.university,
                institute: d.institute,
                year: d.year,
              )).toList(),
              isViewOnly: true,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening $title Dashboard")),
        );
      }
    } else {
      if (moduleId == "business") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BusinessWelcomePage()),
        ).then((_) => setState(() {}));
      } else if (moduleId == "employee") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmployeeUpgradePage()),
        ).then((_) => setState(() {}));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title Upgrade coming soon!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CommonDashboardAppBar(
        onSectionChanged: (section) {
          setState(() {
            _selectedSection = section;
          });
        },
        selectedSection: _selectedSection,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Search Bar
            _buildSearchBar(),
            
            // Section Header
            _buildSectionHeader(),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _selectedSection == DashboardSection.activities
                    ? (_filteredActivities.isEmpty 
                        ? _buildEmptyState() 
                        : _buildActivitiesGrid())
                    : _buildPrivilegeGrid(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterActivities,
          decoration: InputDecoration(
            hintText: "Search activities...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
            suffixIcon: _searchController.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _filterActivities("");
                  },
                )
              : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    final title = _selectedSection == DashboardSection.activities ? "Activities" : "User Privilege";
    final subtitle = _selectedSection == DashboardSection.activities 
        ? "Manage user access levels" 
        : "Manage user roles & permissions";
    final icon = _selectedSection == DashboardSection.activities ? Icons.bolt : Icons.shield_outlined;
    final iconColor = _selectedSection == DashboardSection.activities ? Colors.blue : Colors.blue.shade700;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      key: const ValueKey('empty_state'),
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No activities found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try a different search term",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesGrid() {
    return ReorderableGridView.count(
      key: const ValueKey('activities_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final element = _filteredActivities.removeAt(oldIndex);
          _filteredActivities.insert(newIndex, element);
        });
      },
      children: _filteredActivities.map((card) => _buildActivityCard(card)).toList(),
    );
  }

  Widget _buildActivityCard(ActivityCardData card) {
    return KeyedSubtree(
      key: ValueKey(card.id),
      child: ListenableBuilder(
        listenable: Listenable.merge([BusinessUserStore(), EmployeeUserStore()]),
        builder: (context, _) {
          final isCompleted = _checkCompletion(card.id);
          
          return AccountTypeCard(
            title: card.title,
            subtitle: card.subtitle,
            description: card.description,
            icon: card.icon,
            color: card.color,
            isCompleted: isCompleted,
            primaryButtonText: isCompleted ? "VIEW" : "UPGRADE",
            customDescriptionWidget: (card.id == "business" && isCompleted) ? _buildBusinessDropdown(context) : null,
            // REMOVED: hidePrimaryButton so that VIEW button appears for Business
            hidePrimaryButton: false,
            onPrimaryTap: () => _handleNavigation(card.id, card.title),
            onReadMoreTap: () => _showReadMore(card.title),
          );
        },
      ),
    );
  }

  Widget _buildPrivilegeGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.75,
      children: [
        AccountTypeCard(
          title: "Registered",
          subtitle: "User",
          description: "Full access to standard features & profile management",
          icon: "👤",
          color: const Color(0xFF3B82F6),
          isCompleted: true,
          onPrimaryTap: () => _handleNavigation("registered", "Registered"),
          onReadMoreTap: () => _showReadMore("Registered"),
        ),
        AccountTypeCard(
          title: "Business",
          subtitle: "User",
          description: "Access to business analytics & team management",
          icon: "💼",
          color: const Color(0xFF8B5CF6),
          isCompleted: true,
          onPrimaryTap: () => _handleNavigation("business", "Business"),
          onReadMoreTap: () => _showReadMore("Business"),
        ),
        AccountTypeCard(
          title: "Verified",
          subtitle: "User",
          description: "Verified badge & priority support",
          icon: "✅",
          color: const Color(0xFF10B981),
          isCompleted: false,
          primaryButtonText: "Upgrade to VERIFIED",
          onPrimaryTap: () => _handleNavigation("verified", "Verified"),
          onReadMoreTap: () => _showReadMore("Verified"),
        ),
        AccountTypeCard(
          title: "Premium",
          subtitle: "User",
          description: "All features + exclusive benefits",
          icon: "⭐",
          color: const Color(0xFFF59E0B),
          isCompleted: false,
          primaryButtonText: "Upgrade to PREMIUM",
          onPrimaryTap: () => _handleNavigation("premium", "Premium"),
          onReadMoreTap: () => _showReadMore("Premium"),
        ),
      ],
    );
  }

  void _showReadMore(String module) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About $module",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "This module provides comprehensive tools for $module management. Upgrade to unlock all features including advanced analytics, team collaboration, and priority support.",
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openBusinessViewPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessCreatedPage()),
    );
  }

  Widget _buildBusinessDropdown(BuildContext context) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBusinessScale,
                icon: const SizedBox.shrink(), // Hide default icon
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6366F1),
                ),
                isExpanded: true,
                items: ["Cottage Industry", "Small Scale", "Medium Scale", "Large Scale"]
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBusinessScale = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Scale changed to $val")),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Eye Icon
          GestureDetector(
            onTap: () => openBusinessViewPage(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.visibility_outlined, size: 12, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          // Dropdown Arrow
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}