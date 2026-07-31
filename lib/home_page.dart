import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'upgrade/business_created_page.dart';
import 'upgrade/new_business_register_page.dart';
import 'features/employee/employee_dashboard_page.dart';
import 'upgrade/business_user_store.dart';
import 'upgrade/employee_user_store.dart';
import 'upgrade/job_categories_page.dart';
import 'upgrade/kovil_categories_page.dart';
import 'features/upgrade/verified_upgrade_intro_page.dart';
import 'upgrade/user_overview_page.dart';
import 'features/upgrade/verified_user_profile_page.dart';
import 'user_service.dart';
import 'widgets/common_dashboard_app_bar.dart';
import 'widgets/account_type_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upgrade/employee_upgrade_page.dart';

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
        id: "social",
        title: "SOCIAL",
        subtitle: "Media",
        description: "Social networking & community tools",
        icon: "👥",
        color: const Color(0xFF3B82F6),
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
        id: "voluntary",
        title: "VOLUNTARY",
        subtitle: "Service",
        description: "Join volunteer drives, community service & social impact",
        icon: "🤝",
        color: const Color(0xFFF59E0B),
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
        id: "job_career",
        title: "JOB MANAGEMENT",
        subtitle: "HIRING DESK",
        description: "Search for jobs, apply, and track your applications",
        icon: "💼",
        color: const Color(0xFF8B5CF6),
      ),
      ActivityCardData(
        id: "employee",
        title: "EMPLOYEE PORTAL",
        subtitle: "STAFF DIRECTORY",
        description: "Employee access to business features",
        icon: "👥",
        color: const Color(0xFF10B981),
      ),
      ActivityCardData(
        id: "business_career",
        title: "BUSINESS REGISTER",
        subtitle: "BI SUITE",
        description: "Access to business analytics & team management",
        icon: "📈",
        color: const Color(0xFFF59E0B),
      ),
      ActivityCardData(
        id: "business",
        title: "MY BUSINESS",
        subtitle: "ENTERPRISE",
        description: "Analytics & Team tools for businesses",
        icon: "🏢",
        color: const Color(0xFF8B5CF6),
      ),
      ActivityCardData(
        id: "trust",
        title: "TRUST",
        subtitle: "Organization",
        description: "Manage trust funds, charity & non-profit organizations",
        icon: "🏛️",
        color: const Color(0xFF94A3B8),
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

  bool _isMainBusinessRegistered = false;
  bool _isRegisteredUpgraded = false;
  bool _isVerified = false; // Add for testing verification flow

  Future<void> _loadUserSession() async {
    await UserService().loadSession();
    final data = await UserService().getUserData();
    final prefs = await SharedPreferences.getInstance();

    bool isVerified = false;
    bool isRegistered = false;
    final userMainId = data['user_main_id'];
    if (userMainId != null && userMainId.toString().isNotEmpty) {
      final uid = userMainId.toString();
      
      // Check 1: verified-user table (for VERIFIED users)
      final verificationDetails = await UserService().getVerificationDetails(uid);
      if (verificationDetails != null) {
        final userType = verificationDetails['user_type']?.toString().toLowerCase();
        if (userType == 'verified') {
          isVerified = true;
        }
      }
      
      // Check 2: user_register table (for REGISTERED users)
      isRegistered = await UserService().checkUserRegisterStatus(uid);
    }

    if (mounted) {
      setState(() {
        _currentUserName = (data['name'] ?? widget.userName).trim().isEmpty
            ? widget.userName
            : data['name']!;
        _accountType = data['accountType'] ?? widget.accountType;
        _isMainBusinessRegistered =
            prefs.getBool('is_main_business_registered') ?? false;
        _isRegisteredUpgraded = isRegistered;
        _isVerified = isVerified;

        // Initialize dropdown from store if business exists
        if (BusinessUserStore().businesses.isNotEmpty &&
            BusinessUserStore().businesses.first.businessTypes.isNotEmpty) {
          _selectedBusinessScale =
              BusinessUserStore().businesses.first.businessTypes.first;
        }
      });
    }
  }

  bool _checkCompletion(String moduleId) {
    if (moduleId == "business_career") {
      return true;
    }
    if (moduleId == "business") {
      return _isMainBusinessRegistered ||
          BusinessUserStore().businesses.isNotEmpty;
    }
    if (moduleId == "employee") {
      return EmployeeUserStore().hasData;
    }
    if (moduleId == "registered") {
      return _isRegisteredUpgraded;
    }
    if (moduleId == "verified") {
      return _isVerified;
    }
    return false;
  }

  void _handleNavigation(String moduleId, String title) {
    final isCompleted = _checkCompletion(moduleId);

    if (moduleId == "registered") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UserOverviewPage(initialPage: isCompleted ? 0 : 1),
        ),
      ).then((_) => _loadUserSession());
      return;
    }

    if (isCompleted) {
      if (moduleId == "business" || moduleId == "business_career") {
        openBusinessViewPage(context);
      } else if (moduleId == "employee") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmployeeDashboardPage(),
          ),
        );
      } else if (moduleId == "verified") {
        // Verified user already upgraded — show their overview (view mode)
        Navigator.push(
          context,
          MaterialPageRoute(
<<<<<<< HEAD
            builder: (context) => const UserOverviewPage(initialPage: 0),
=======
            builder: (context) => const VerifiedUserProfilePage(),
>>>>>>> 46759b2 (update)
          ),
        ).then((_) => _loadUserSession());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Opening $title Dashboard")));
      }
    } else {
      if (moduleId == "business") {
        if (_isVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewBusinessRegisterPage(),
            ),
          ).then((_) => setState(() {}));
        } else {
          _showVerificationDialog(context);
        }
      } else if (moduleId == "employee") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmployeeUpgradePage()),
        ).then((_) => setState(() {}));
      } else if (moduleId == "job_career") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JobCategoriesPage()),
        );
      } else if (moduleId == "kovil") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KovilCategoriesPage()),
        );
      } else if (moduleId == "verified") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifiedUpgradeIntroPage(),
          ),
        ).then((_) => _loadUserSession());
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$title Upgrade coming soon!")));
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

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  color: Color(0xFFD97706),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Verification Required",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "To register as a Business User, you must first complete your Verified User Registration (Identity & PAN verification).\nPlease verify your identity before accessing the Business portal.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerifiedUpgradeIntroPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Go to Verified User Registration",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: const Text(
                  "Back to Dashboard",
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterActivities,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: "Search activities & modules...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF3B82F6), size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _filterActivities("");
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    final title = _selectedSection == DashboardSection.activities
        ? "Explore Modules"
        : "User Privileges";
    final subtitle = _selectedSection == DashboardSection.activities
        ? "Discover and manage your access levels"
        : "Manage your active roles & permissions";
    final icon = _selectedSection == DashboardSection.activities
        ? Icons.explore_rounded
        : Icons.shield_rounded;
    final iconColor = _selectedSection == DashboardSection.activities
        ? const Color(0xFF3B82F6)
        : const Color(0xFF7C3AED);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withOpacity(0.1)),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 0.65, // Give more height to prevent bottom overflow
      onReorder: (oldIndex, newIndex) {
        setState(() {
          final element = _filteredActivities.removeAt(oldIndex);
          _filteredActivities.insert(newIndex, element);

          if (_searchController.text.isEmpty) {
            final aElement = _activities.removeAt(oldIndex);
            _activities.insert(newIndex, aElement);
          }
        });
      },
      children: _filteredActivities
          .map((card) => _buildActivityCard(card))
          .toList(),
    );
  }

  Widget _buildActivityCard(ActivityCardData card) {
    return KeyedSubtree(
      key: ValueKey(card.id),
      child: ListenableBuilder(
        listenable: Listenable.merge([
          BusinessUserStore(),
          EmployeeUserStore(),
        ]),
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
            customDescriptionWidget: (card.id == "business" && isCompleted)
                ? _buildBusinessDropdown(context)
                : null,
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
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 0.65,
      children: [
        AccountTypeCard(
          title: "Registered",
          subtitle: "User",
          description: "Full access to standard features & profile management",
          icon: "👤",
          color: const Color(0xFF3B82F6),
          isCompleted: _checkCompletion("registered"),
          primaryButtonText: _checkCompletion("registered")
              ? "VIEW"
              : "UPGRADE",
          onPrimaryTap: () => _handleNavigation("registered", "Registered"),
          onReadMoreTap: () => _showReadMore("Registered"),
        ),
        AccountTypeCard(
          title: "Business",
          subtitle: "User",
          description: "Access to business analytics & team management",
          icon: "💼",
          color: const Color(0xFF8B5CF6),
          isCompleted: _checkCompletion("business"),
          primaryButtonText: _checkCompletion("business") ? "VIEW" : "UPGRADE",
          onPrimaryTap: () => _handleNavigation("business", "Business"),
          onReadMoreTap: () => _showReadMore("Business"),
        ),
        AccountTypeCard(
          title: "Verified",
          subtitle: "User",
          description: "Verified badge & priority support",
          icon: "✅",
          color: const Color(0xFF10B981),
          isCompleted: _checkCompletion("verified"),
          primaryButtonText: _checkCompletion("verified")
              ? "VIEW"
              : "Upgrade to VERIFIED",
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "This module provides comprehensive tools for $module management. Upgrade to unlock all features including advanced analytics, team collaboration, and priority support.",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "CLOSE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.5),
          width: 1,
        ),
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
                items:
                    [
                      "Cottage Industry",
                      "Small Scale",
                      "Medium Scale",
                      "Large Scale",
                    ].map((String value) {
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
              child: const Icon(
                Icons.visibility_outlined,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Dropdown Arrow
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}
