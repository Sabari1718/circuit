import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:sva_business_user/upgrade/employee_user_model.dart';
import 'upgrade/new_business_register_page.dart';
import 'upgrade/business_step3_page.dart';
import 'upgrade/business_registration_overview_page.dart';
import 'features/employee/employee_dashboard_page.dart';
import 'upgrade/business_user_store.dart';
import 'upgrade/employee_user_store.dart';
import 'upgrade/job_categories_page.dart';
import 'upgrade/kovil_categories_page.dart';
import 'features/devotees/devotee_registration_page.dart';
import 'features/devotees/devotee_profile_overview_page.dart';
import 'features/devotees/devotee_api_service.dart';
import 'features/upgrade/verified_upgrade_intro_page.dart';
import 'upgrade/user_overview_page.dart';
import 'features/upgrade/verified_user_profile_page.dart';
import 'user_service.dart';
import 'package:sva_business_user/core/services/api_service.dart';
import 'package:sva_business_user/upgrade/business_user_model.dart';
import 'widgets/common_dashboard_app_bar.dart';
import 'widgets/account_type_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'upgrade/employee_upgrade_page.dart';
import 'upgrade/employee_profile_overview_page.dart';

enum DashboardSection { activities, privilege, career }

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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String _currentUserName = "User";
  String _accountType = "GUEST";
  String _selectedBusinessScale = "Small Scale";
  DashboardSection _selectedSection = DashboardSection.privilege;

  final TextEditingController _searchController = TextEditingController();
  late List<ActivityCardData> _activities;
  late List<ActivityCardData> _careerActivities;
  List<ActivityCardData> _filteredActivities = [];
  List<ActivityCardData> _filteredCareerActivities = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentUserName = widget.userName;
    _accountType = widget.accountType;
    _loadUserSession();
    _initializeActivities();
    _filteredActivities = List.from(_activities);
    _filteredCareerActivities = List.from(_careerActivities);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh user session when app comes to foreground
      _loadUserSession();
    }
  }

  void _initializeActivities() {
    _activities = [
      ActivityCardData(
        id: "kovil",
        title: "KOVIL",
        subtitle: "TEMPLE",
        description: "Manage temple activities, donations & events",
        icon: "🛕",
        color: const Color(0xFF10B981), // Greenish
      ),
      ActivityCardData(
        id: "devotees",
        title: "DEVOTIES",
        subtitle: "COMMUNITY",
        description: "Connect and manage community of devotees",
        icon: "🙏",
        color: const Color(0xFF3B82F6), // Blueish
      ),
      ActivityCardData(
        id: "social",
        title: "SOCIAL",
        subtitle: "MEDIA",
        description: "Share posts, connect, and engage with your audience",
        icon: "📢",
        color: const Color(0xFF8B5CF6), // Purplish
      ),
      ActivityCardData(
        id: "real_estate",
        title: "REAL ESTATE",
        subtitle: "PROPERTY",
        description: "Property listings, investments & rental management",
        icon: "🏠",
        color: const Color(0xFFF59E0B), // Orangish
      ),
      ActivityCardData(
        id: "trust",
        title: "TRUST",
        subtitle: "ORGANIZATION",
        description: "Manage trust funds, charity & non-profit organizations",
        icon: "🤝",
        color: const Color(0xFFEF4444), // Redish
      ),
      ActivityCardData(
        id: "voluntary",
        title: "VOLUNTARY",
        subtitle: "SERVICE",
        description: "Join volunteer drives, community service & social impact",
        icon: "🤝",
        color: const Color(0xFF10B981), // Greenish
      ),
      ActivityCardData(
        id: "education",
        title: "EDUCATION",
        subtitle: "ACADEMY",
        description: "Manage educational institutions, students & courses",
        icon: "🎓",
        color: const Color(0xFF8B5CF6), // Purplish
      ),
    ];

    _careerActivities = [
      ActivityCardData(
        id: "job_career",
        title: "Job Management",
        subtitle: "HIRING DESK",
        description: "Search for jobs, apply, and track your applications",
        icon: "💼",
        color: const Color(0xFF8B5CF6), // Purplish
      ),
      ActivityCardData(
        id: "employee",
        title: "Employee Portal",
        subtitle: "STAFF DIRECTORY",
        description: "Employee access to business features",
        icon: "👥",
        color: const Color(0xFF10B981), // Greenish
      ),
      ActivityCardData(
        id: "business_career",
        title: "Business Register",
        subtitle: "BI SUITE",
        description: "Access to business analytics & team management",
        icon: "📈",
        color: const Color(0xFFF59E0B), // Orangish
      ),
    ];
  }

  void _filterActivities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredActivities = List.from(_activities);
        _filteredCareerActivities = List.from(_careerActivities);
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

        _filteredCareerActivities = _careerActivities.where((activity) {
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
  bool _isVerified = false;
  bool _isDevoteeRegistered = false;
  Map<String, dynamic>? _devoteeProfileData;

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Instantly update UI based on local cache before waiting for 5 seconds of API calls
    if (mounted) {
      setState(() {
        _isDevoteeRegistered =
            prefs.getBool('is_devotee_registered') ?? _isDevoteeRegistered;
        _isMainBusinessRegistered =
            prefs.getBool('is_main_business_registered') ??
            _isMainBusinessRegistered;
      });
    }

    await UserService().loadSession();
    final data = await UserService().getUserData();

    bool isVerified = false;
    bool isRegistered = false;
    bool isDevotee = false;
    Map<String, dynamic>? devoteeData;
    final userMainId = data['user_main_id'];
    if (userMainId != null && userMainId.toString().isNotEmpty) {
      final uid = userMainId.toString();

      // Check 1: verified-user table (for VERIFIED users)
      final verificationDetails = await UserService().getVerificationDetails(
        uid,
      );
      if (verificationDetails != null) {
        // The backend might return an empty shell record for 'verification'.
        // We only consider the user VERIFIED if they have submitted actual data.
        bool hasGovId = verificationDetails['government_id_type'] != null;
        bool hasAddresses =
            verificationDetails['addresses'] != null &&
            (verificationDetails['addresses'] as List).isNotEmpty;

        if (hasGovId || hasAddresses) {
          isVerified = true;
        }
      }

      // Check 2: user_register table (for REGISTERED users)
      isRegistered = await UserService().checkUserRegisterStatus(uid);

      // Check 3: Devotee Registration API
      try {
        final devoteeResponse = await DevoteeApiService().fetchDevoteeProfile(
          uid,
        );
        if (devoteeResponse != null && devoteeResponse['status'] == true) {
          isDevotee = true;
          devoteeData = devoteeResponse['data'];
        }
      } catch (e) {
        debugPrint('Error fetching devotee status: $e');
      }

      // Check 4: Employee Status API
      try {
        final empRes = await ApiService().getEmployeeDetails(uid);
        EmployeeUserStore().clear();
        if (empRes['data'] != null && empRes['data']['data'] != null) {
          final innerData = empRes['data']['data'];
          if (innerData != null && innerData['id'] != null) {
            String workType = innerData['work_type'] ?? 'Physical Work';
            String? resumePath = innerData['resume_path'];
            String? frontPhotoPath = innerData['profile_photo'];
            String? resumeName = resumePath != null
                ? resumePath.split('/').last
                : null;
            String? panNumber = innerData['pan_number'];
            String? salaryAccount = innerData['salary_account_number']
                ?.toString();

            String? educationBoard;
            String? primaryStudy;
            String? after10thPath;
            String? primaryMarksheetPath;
            String? hsMarksheetPath;

            List<EmployeeDegreeData> degreesList = [];

            if (innerData['educations'] != null &&
                innerData['educations'] is List) {
              final educations = innerData['educations'] as List;
              for (var edu in educations) {
                if (edu['education_type'] == 'primary') {
                  educationBoard = edu['education_board'];
                  primaryStudy = "10th Standard";
                  after10thPath = edu['path_after_10th'];
                  primaryMarksheetPath = edu['marksheet_10th'];
                } else if (edu['education_type'] == 'higher_secondary') {
                  hsMarksheetPath = edu['marksheet_12th'];
                } else if (edu['education_type'] == 'degree') {
                  degreesList.add(
                    EmployeeDegreeData(
                      stream: edu['degree_stream'],
                      degree: edu['degree_name'],
                      university: edu['university_name'],
                      institute: edu['institute_name'],
                      year: edu['year_of_passing']?.toString(),
                      certificatePath: edu['degree_certificate'],
                    ),
                  );
                }
              }
            }

            final empUser = EmployeeUser(
              id: innerData['user_main_id']?.toString() ?? uid,
              workType: workType,
              resumeName: resumeName,
              resumePath: resumePath,
              frontPhotoPath: frontPhotoPath,
              primaryMarksheetPath: primaryMarksheetPath,
              hsMarksheetPath: hsMarksheetPath,
              panNumber: panNumber,
              salaryAccount: salaryAccount,
              educationBoard: educationBoard,
              primaryStudy: primaryStudy,
              after10thPath: after10thPath,
              degrees: degreesList,
            );
            EmployeeUserStore().addEmployee(empUser);
          }
        }
      } catch (e) {
        debugPrint('Error fetching employee: $e');
      }

      // Always fetch Business details to reflect DB changes (e.g. deletion)
      try {
        // Temporarily override ID if needed (same as business_created_page)
        String fetchUid = uid;
        if (fetchUid == '8059210846') {
          fetchUid = '6102066450';
        }

        final res = await ApiService().getBusinesses(fetchUid);
        List<dynamic> rawList = [];

        if (res['data'] != null && res['data']['data'] is List) {
          rawList = res['data']['data'];
        } else if (res['data'] is List) {
          rawList = res['data'];
        } else if (res['data'] != null && res['data']['businesses'] is List) {
          rawList = res['data']['businesses'];
        } else if (res['businesses'] is List) {
          rawList = res['businesses'];
        } else if (res['business'] is List) {
          rawList = res['business'];
        } else if (res['business_list'] is List) {
          rawList = res['business_list'];
        }

        if (rawList.isEmpty) {
          final resReg = await ApiService().getBusinessRegUser(fetchUid);
          if (resReg['data'] != null) {
            final innerData = resReg['data'];
            if (innerData is List) {
              rawList = innerData;
            } else if (innerData is Map) {
              if (innerData['data'] != null) {
                if (innerData['data'] is List) {
                  rawList = innerData['data'];
                } else if (innerData['data'] is Map) {
                  rawList = [innerData['data']];
                }
              } else {
                rawList = [innerData];
              }
            }
          } else if (resReg['business'] != null && resReg['business'] is List) {
            rawList = resReg['business'];
          }
        }

        BusinessUserStore().clear();
        if (rawList.isNotEmpty) {
          final business = BusinessUser.fromJson(rawList[0]);
          BusinessUserStore().addBusiness(business);
        }
      } catch (e) {
        debugPrint('Error fetching business: $e');
      }
    }

    if (mounted) {
      setState(() {
        // If the base registered user is deleted, everything else should also reset
        if (!isRegistered) {
          isVerified = false;
          BusinessUserStore().clear();
        }

        _currentUserName = (data['name'] ?? widget.userName).trim().isEmpty
            ? widget.userName
            : data['name']!;
        _accountType = data['accountType'] ?? widget.accountType;
        _isMainBusinessRegistered =
            prefs.getBool('is_main_business_registered') ?? false;
        _isRegisteredUpgraded = isRegistered;
        _isVerified = isVerified;
        _isDevoteeRegistered = isDevotee;
        _devoteeProfileData = devoteeData;

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
    if (moduleId == "business_career" || moduleId == "business") {
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
    if (moduleId == "devotees") {
      return _isDevoteeRegistered;
    }
    return false;
  }

  void _handleNavigation(String moduleId, String title) async {
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
            builder: (context) => const EmployeeProfileOverviewPage(),
          ),
        );
      } else if (moduleId == "verified") {
        // Verified user already upgraded — show their overview (view mode)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifiedUserProfilePage(),
          ),
        ).then((_) => _loadUserSession());
      } else if (moduleId == "devotees") {
        if (_devoteeProfileData != null || _isDevoteeRegistered) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => const Center(child: CircularProgressIndicator()),
          );

          String? communityName;
          String? subCommunityName;
          String? kulamName;

          try {
            final apiService = DevoteeApiService();
            final prefs = await SharedPreferences.getInstance();
            final uid = prefs.getString('user_main_id');
            if (uid != null) {
              final latestProfile = await apiService.fetchDevoteeProfile(uid);
              if (latestProfile != null && latestProfile['status'] == true) {
                _devoteeProfileData = latestProfile['data'];
              }
            }

            if (_devoteeProfileData != null) {
              communityName = _devoteeProfileData!['community_name']
                  ?.toString();
              subCommunityName = _devoteeProfileData!['sub_community_name']
                  ?.toString();
              kulamName = _devoteeProfileData!['kulam_name']?.toString();

              if (int.tryParse(communityName ?? '') != null) {
                final comms = await apiService.fetchCommunities();
                communityName = comms
                    .firstWhere(
                      (c) => c.id.toString() == communityName,
                      orElse: () => Community(
                        id: -1,
                        nameEnglish: communityName!,
                        nameTamil: '',
                      ),
                    )
                    .nameEnglish;
              }
              if (int.tryParse(subCommunityName ?? '') != null) {
                final subs = await apiService.fetchSubCommunities();
                subCommunityName = subs
                    .firstWhere(
                      (c) => c.id.toString() == subCommunityName,
                      orElse: () => SubCommunity(
                        id: -1,
                        communityId: -1,
                        nameEnglish: subCommunityName!,
                        nameTamil: '',
                      ),
                    )
                    .nameEnglish;
              }
              if (int.tryParse(kulamName ?? '') != null) {
                final kulas = await apiService.fetchKulas();
                kulamName = kulas
                    .firstWhere(
                      (c) => c.id.toString() == kulamName,
                      orElse: () => Kulam(
                        id: -1,
                        subCommunityId: -1,
                        nameEnglish: kulamName!,
                        nameTamil: '',
                        communityId: -1,
                      ),
                    )
                    .nameEnglish;
              }
            }
          } catch (e) {
            debugPrint("Error fetching names: $e");
          }

          if (mounted) {
            Navigator.pop(context); // close dialog
          }

          if (_devoteeProfileData != null) {
            final profileData = DevoteeProfileData(
              name: _currentUserName.isNotEmpty ? _currentUserName : "User",
              gender: _devoteeProfileData!['gender']?.toString(),
              age: _devoteeProfileData!['age']?.toString(),
              religion: _devoteeProfileData!['religion_name']?.toString(),
              categories: _devoteeProfileData!['tradition_name'] != null
                  ? {_devoteeProfileData!['tradition_name'].toString()}
                  : {},
              community: communityName,
              subCommunity: subCommunityName,
              kulam: kulamName,
              addressType: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['address_type']?.toString()
                  : null,
              propertyType: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['property_type']?.toString()
                  : null,
              doorNumber: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['house_no']?.toString()
                  : null,
              streetName: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['street']?.toString()
                  : null,
              landmark: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['landmark']?.toString()
                  : null,
              area: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['area']?.toString()
                  : null,
              city: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['city']?.toString()
                  : null,
              state: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['state']?.toString()
                  : null,
              country: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['country']?.toString()
                  : null,
              pincode: _devoteeProfileData!['address'] != null
                  ? _devoteeProfileData!['address']['pincode']?.toString()
                  : null,
            );

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DevoteeProfileOverviewPage(data: profileData),
                ),
              );
            }
          } else {
            // Fallback if data is null despite being registered
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Profile data not found on server. Please re-register.",
                  ),
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DevoteeRegistrationPage(),
                ),
              ).then((_) => _loadUserSession());
            }
          }
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Opening $title Dashboard")));
      }
    } else {
      if (moduleId == "business" || moduleId == "business_career") {
        if (_isVerified) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BusinessStep3Page()),
          ).then((_) => setState(() {}));
        } else {
          _showVerificationDialog(context);
        }
      } else if (moduleId == "employee") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmployeeUpgradePage()),
        ).then((_) => _loadUserSession());
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
      } else if (moduleId == "devotees") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DevoteeRegistrationPage(),
          ),
        ).then((_) => _loadUserSession());
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
    bool isUpgraded =
        _checkCompletion("registered") ||
        _checkCompletion("verified") ||
        _checkCompletion("business") ||
        _checkCompletion("premium");

    if (!isUpgraded && _selectedSection != DashboardSection.privilege) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedSection = DashboardSection.privilege;
          });
        }
      });
    }

    DashboardSection effectiveSection = !isUpgraded
        ? DashboardSection.privilege
        : _selectedSection;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CommonDashboardAppBar(
        onSectionChanged: (section) {
          setState(() {
            _selectedSection = section;
          });
        },
        selectedSection: effectiveSection,
        isUpgraded: isUpgraded,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFEFF6FF),
            ], // Subtle blue-ish premium background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadUserSession,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Builder(
              builder: (context) {
                String headerTitle =
                    effectiveSection == DashboardSection.activities
                    ? "Features 👏"
                    : effectiveSection == DashboardSection.career
                    ? "Career Portals 💼"
                    : "User Privileges 👏";

                String headerSubtitle =
                    effectiveSection == DashboardSection.activities
                    ? "Manage and activate platform modules for your workspace"
                    : effectiveSection == DashboardSection.career
                    ? "Create your career profile, track achievements, and unlock new job opportunities"
                    : "Logged in as $_accountType.\nUpgrade to unlock features.";

                IconData headerIcon =
                    effectiveSection == DashboardSection.activities
                    ? Icons.grid_view_rounded
                    : effectiveSection == DashboardSection.career
                    ? Icons.work_rounded
                    : Icons.workspace_premium_rounded;

                return Column(
                  children: [
                    // Modern Search Bar
                    if (false) _buildSearchBar(),

                    // Section Header
                    // We hide this for now as requested
                    // if (false) _buildSectionHeader(),

                    // We add a stunning premium header
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              headerIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  headerTitle,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  headerSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

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
                        child: effectiveSection == DashboardSection.activities
                            ? _buildActivitiesGrid()
                            : effectiveSection == DashboardSection.career
                            ? _buildCareerGrid()
                            : _buildPrivilegeGrid(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
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
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: "Search activities & modules...",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF3B82F6),
              size: 22,
            ),
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
        ? "Explore Features"
        : _selectedSection == DashboardSection.career
        ? "Career Portals"
        : "User Privileges";
    final subtitle = _selectedSection == DashboardSection.activities
        ? "Discover and manage your access levels"
        : _selectedSection == DashboardSection.career
        ? "Track and unlock career opportunities"
        : "Manage your active roles & permissions";
    final icon = _selectedSection == DashboardSection.activities
        ? Icons.explore_rounded
        : _selectedSection == DashboardSection.career
        ? Icons.work_rounded
        : Icons.shield_rounded;
    final iconColor = _selectedSection == DashboardSection.activities
        ? const Color(0xFF3B82F6)
        : _selectedSection == DashboardSection.career
        ? Colors.deepPurple
        : const Color(0xFF7C3AED);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.2),
                  iconColor.withOpacity(0.05),
                ],
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

  Widget _buildCareerGrid() {
    if (_filteredCareerActivities.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            "No career portals found",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800
            ? 3
            : constraints.maxWidth > 600
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 1.5 : 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _filteredCareerActivities.length,
          itemBuilder: (context, index) {
            return _buildActivityCard(_filteredCareerActivities[index]);
          },
        );
      },
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
    bool isRegistered = _checkCompletion("registered");
    bool isPremium = _checkCompletion("premium");
    bool isBusiness = _checkCompletion("business");
    bool isVerified = _checkCompletion("verified");

    List<Widget> cards = [];

    if (!isVerified && !isBusiness && !isPremium) {
      cards.add(
        AccountTypeCard(
          title: "Registered",
          subtitle: "User",
          description: "Full access to standard features & profile management",
          icon: "👤",
          color: const Color(0xFF3B82F6),
          isCompleted: isRegistered,
          planName: "Standard",
          accessLevel: "Basic",
          primaryButtonText: isRegistered ? "View" : "Upgrade",
          onPrimaryTap: () => _handleNavigation("registered", "Registered"),
          onReadMoreTap: () => _showReadMore("Registered"),
        ),
      );
    }

    if (!isBusiness && !isPremium) {
      cards.add(
        AccountTypeCard(
          title: "Verified",
          subtitle: "User",
          description: "Verified badge & priority support",
          icon: "✅",
          color: const Color(0xFF10B981),
          isCompleted: isVerified,
          planName: "Verified",
          accessLevel: "Priority",
          primaryButtonText: isVerified ? "View" : "Upgrade",
          onPrimaryTap: () => _handleNavigation("verified", "Verified"),
          onReadMoreTap: () => _showReadMore("Verified"),
        ),
      );
    }

    if (!isPremium) {
      cards.add(
        AccountTypeCard(
          title: "Business",
          subtitle: "User",
          description: "Access to business analytics & team management",
          icon: "💼",
          color: const Color(0xFF8B5CF6),
          isCompleted: isBusiness,
          planName: "Business",
          accessLevel: "Enterprise",
          primaryButtonText: isBusiness ? "View" : "Upgrade",
          onPrimaryTap: () => _handleNavigation("business", "Business"),
          onReadMoreTap: () => _showReadMore("Business"),
        ),
      );
    }

    cards.add(
      AccountTypeCard(
        title: "Premium",
        subtitle: "User",
        description: "All features + exclusive benefits",
        icon: "⭐",
        color: const Color(0xFFF59E0B),
        isCompleted: isPremium,
        planName: "Premium",
        accessLevel: "Full",
        primaryButtonText: isPremium ? "View" : "Upgrade",
        onPrimaryTap: () => _handleNavigation("premium", "Premium"),
        onReadMoreTap: () => _showReadMore("Premium"),
      ),
    );

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 0.65,
      children: cards,
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
    BusinessUser? business;
    if (BusinessUserStore().businesses.isNotEmpty) {
      business = BusinessUserStore().businesses.first;
    } else {
      // Fallback if the store is empty but they clicked VIEW
      business = BusinessUser(
        id: "5319073341", // Default fallback ID based on user logs
        registrationType: "Propagator",
        businessName: _currentUserName.isNotEmpty
            ? "$_currentUserName's Business"
            : "My Business",
        email: "contact@business.com",
        phone: "5319073341",
        panNumber: "ABCDE1234F",
        gstNumber: "22AAAAA1111A1Z5",
        accountNumber: "1234567890",
        bankDocType: "Bank Statement",
        doorNumber: "123",
        streetName: "Main Street",
        area: "Central Area",
        district: "Chennai",
        pincode: "600001",
        state: "Tamil Nadu",
        country: "India",
        businessTypes: ["IT", "Services"],
        yearOfEstablishment: "2024",
        employeeRange: "11-50",
        createdDate: DateTime.now(),
        status: "Active",
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BusinessRegistrationOverviewPage(business: business!),
      ),
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
