import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';
import 'business_user_model.dart';
import 'user_overview_page.dart';
import 'business_created_page.dart';
import 'applied_list_page.dart';
import 'posted_jobs_page.dart';
import '../widgets/business_sidebar_menu.dart';
import 'new_business_register_page.dart';
import 'post_job_page.dart';

class AssignCandidatePage extends StatefulWidget {
  const AssignCandidatePage({super.key});

  @override
  State<AssignCandidatePage> createState() => _AssignCandidatePageState();
}

class _AssignCandidatePageState extends State<AssignCandidatePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  List<BusinessUser> _businesses = [];
  bool _isBusinessExpanded = false;
  bool _isJobsExpanded = true; // Open by default as we are in Jobs section

  BusinessUser? _selectedBusiness;

  List<dynamic> _allJobsCache = [];
  List<dynamic> _postedJobs = [];
  bool _isLoadingJobs = false;
  Map<String, dynamic>? _selectedJob;

  List<ApplicationModel> _employees = [];
  bool _isLoadingEmployees = true;
  Set<int> _selectedEmployeeIds = {};

  @override
  void initState() {
    super.initState();
    _fetchBusinesses();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final res = await http.get(
        Uri.parse(
          'https://user.jobes24x7.com/api/assigned-interviewers',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          final listData = data['data'];
          final List list = (listData is Map && listData.containsKey('data'))
              ? listData['data']
              : (listData is List ? listData : []);

          setState(() {
            _employees = list.map((e) => ApplicationModel.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching employees: $e");
    } finally {
      if (mounted) setState(() => _isLoadingEmployees = false);
    }
  }

  Future<void> _fetchAllJobsForCache(String userMainId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final res = await http.get(
        Uri.parse(
          'https://managelogin.jobes24x7.com/api/outsideapis/job/employer-jobs/$userMainId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        if (data['success'] == true ||
            data['success'] == 'true' ||
            data['data'] != null) {
          if (mounted) {
            setState(() {
              _allJobsCache = List<dynamic>.from(data['data'] ?? []);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching all jobs for cache: $e");
    }
  }

  Future<void> _fetchJobs(String userMainId) async {
    setState(() => _isLoadingJobs = true);
    await _fetchAllJobsForCache(userMainId);

    if (mounted) {
      setState(() {
        if (_selectedBusiness != null) {
          _postedJobs = _allJobsCache
              .where(
                (j) =>
                    j['business_id']?.toString() == _selectedBusiness!.id ||
                    j['business_cre_id']?.toString() == _selectedBusiness!.id,
              )
              .toList();
        } else {
          _postedJobs = _allJobsCache;
        }
        _isLoadingJobs = false;
      });
    }
  }

  Future<void> _assignInterviewer() async {
    if (_selectedBusiness == null ||
        _selectedJob == null ||
        _selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a business, a job, and at least one employee.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      bool allSuccess = true;

      for (int empId in _selectedEmployeeIds) {
        final emp = _employees.firstWhere((e) => e.id == empId);

        final payload = {
          "user_main_id": emp.userMainId,
          "user_name": emp.userName,
          "email": emp.email,
          "company_id": _selectedBusiness!.id,
          "job_name": _selectedJob!['job_title']?.toString() ?? '',
        };

        debugPrint('Assigning payload for ${emp.userName}: $payload');

        final res = await http.post(
          Uri.parse(
            'https://user.jobes24x7.com/api/assigned-interviewers/create',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        );

        if (res.statusCode != 200 && res.statusCode != 201) {
          allSuccess = false;
          debugPrint(
            'Failed to assign ${emp.userName}: ${res.statusCode} ${res.body}',
          );
        }
      }

      if (mounted) {
        if (allSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Interviewer(s) assigned successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Some interviewer assignments failed. Check console.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _selectedEmployeeIds.clear();
        });
        _fetchEmployees();
      }
    } catch (e) {
      debugPrint("Error assigning: $e");
    }
  }

  Future<void> _fetchBusinesses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userMainId = prefs.getString('user_main_id') ?? '';

      if (userMainId == '8059210846') {
        userMainId = '6102066450';
      }

      if (userMainId.isEmpty) throw Exception('User Main ID not found');

      final token = prefs.getString('auth_token') ?? '';

      final url = Uri.parse(
        'https://managelogin.jobes24x7.com/api/business-cre/main/$userMainId',
      );
      final response = await http.get(
        url,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        if (res['status'] == 'success' || res.containsKey('data')) {
          final rawData = res['data'];
          final List<dynamic> data =
              rawData is Map && rawData.containsKey('data')
              ? rawData['data']
              : (rawData is List ? rawData : []);

          setState(() {
            _businesses = data.map((b) => BusinessUser.fromJson(b)).toList();
            _isLoading = false;
          });

          _fetchAllJobsForCache(userMainId);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching businesses: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF1F5F9),
      drawer: !isDesktop
          ? Drawer(
              elevation: 0,
              child: BusinessSidebarMenu(
                activeItem: 'assign_candidate',
                onSectionChanged: _onSectionChanged,
              ),
            )
          : null,
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              title: Text(
                "Assign Interviewer",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            SizedBox(
              width: 250,
              child: BusinessSidebarMenu(
                activeItem: 'assign_candidate',
                onSectionChanged: _onSectionChanged,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) ...[
                    Text(
                      "Assign Interviewer",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Select an employee to conduct the interview.",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  _buildContent(isDark, isDesktop),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSectionChanged(String newItem) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }

    if (newItem == 'post_job') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PostJobPage()),
      );
    } else if (newItem == 'view_posted_jobs') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PostedJobsPage()),
      );
    } else if (newItem == 'applied_candidates') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AppliedListPage(isBusinessMode: true),
        ),
      );
    } else if (newItem == 'add_business' ||
        newItem == 'create_store_category' ||
        newItem == 'create_store') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NewBusinessRegisterPage()),
      );
    }
  }

  Widget _buildContent(bool isDark, bool isDesktop) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBusinessSection(isDark, isDesktop),
        const SizedBox(height: 24),
        if (_selectedBusiness != null) _buildJobsSection(isDark, isDesktop),
        const SizedBox(height: 24),
        _buildEmployeeSection(isDark, isDesktop),
      ],
    );
  }

  Widget _buildBusinessSection(bool isDark, bool isDesktop) {
    int crossAxisCount = 1;
    if (isDesktop)
      crossAxisCount = 3;
    else if (MediaQuery.of(context).size.width > 600)
      crossAxisCount = 2;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Business",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          if (_businesses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  "No businesses found.",
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 220, // fixed height for card
              ),
              itemCount: _businesses.length,
              itemBuilder: (context, index) {
                final biz = _businesses[index];
                final isSelected = _selectedBusiness?.id == biz.id;
                return _buildBusinessCard(biz, isDark, isSelected);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(BusinessUser biz, bool isDark, bool isSelected) {
    final borderColor = isSelected
        ? const Color(0xFF3B82F6)
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return InkWell(
      onTap: () async {
        setState(() {
          _selectedBusiness = biz;
          _selectedJob = null; // reset job
        });
        final prefs = await SharedPreferences.getInstance();
        String userMainId = prefs.getString('user_main_id') ?? '';
        if (userMainId == '8059210846') userMainId = '6102066450';
        _fetchJobs(userMainId);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFF1E3A8A).withOpacity(0.3)
                    : const Color(0xFFEFF6FF))
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Logo + Name + Type
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                    image:
                        biz.companyLogoFileName != null &&
                            biz.companyLogoFileName!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              biz.companyLogoFileName!.startsWith('http')
                                  ? biz.companyLogoFileName!
                                  : 'https://user.jobes24x7.com/${biz.companyLogoFileName}',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      biz.companyLogoFileName != null &&
                          biz.companyLogoFileName!.isNotEmpty
                      ? null
                      : const Center(
                          child: Icon(
                            Icons.business,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        biz.businessName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        biz.registrationType?.toUpperCase() ?? 'BUSINESS',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Middle: Phone & Location
            _buildInfoRow(Icons.phone_outlined, biz.phone, mutedColor),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.location_on_outlined,
              [
                biz.doorNumber,
                biz.streetName,
                biz.area,
                biz.district,
              ].where((e) => e.isNotEmpty).join(', '),
              mutedColor,
            ),
            const Spacer(),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Bottom: Jobs Posted
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.work_outline, size: 14, color: mutedColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final bizJobs = _allJobsCache
                          .where(
                            (j) =>
                                j['business_id']?.toString() == biz.id ||
                                j['business_cre_id']?.toString() == biz.id,
                          )
                          .toList();

                      final jobCount = bizJobs.length;
                      final latestJobTitle = jobCount > 0
                          ? (bizJobs.first['job_title']?.toString() ??
                                'Job Title')
                          : "No jobs posted";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jobs Posted ($jobCount)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            latestJobTitle,
                            style: TextStyle(fontSize: 11, color: mutedColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isEmpty ? "N/A" : text,
            style: TextStyle(fontSize: 12, color: color),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildJobsSection(bool isDark, bool isDesktop) {
    int crossAxisCount = 1;
    if (isDesktop)
      crossAxisCount = 2;
    else if (MediaQuery.of(context).size.width > 600)
      crossAxisCount = 2;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Posted Jobs by ${_selectedBusiness?.businessName ?? 'Business'}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoadingJobs)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            )
          else if (_postedJobs.isEmpty)
            Text(
              "No jobs found for this business.",
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 160,
              ),
              itemCount: _postedJobs.length,
              itemBuilder: (context, index) {
                final job = _postedJobs[index];
                final isSelected =
                    _selectedJob?['job_posted_id'] == job['job_posted_id'];

                final jobPostedId = job['job_posted_id']?.toString() ?? '';
                final jobTitle = job['job_title']?.toString() ?? '';
                final candidatesCount = _employees
                    .where(
                      (e) =>
                          e.jobPostedId == jobPostedId || e.jobName == jobTitle,
                    )
                    .length;

                final openings =
                    job['openings']?.toString() ??
                    job['vacancies']?.toString() ??
                    '1';

                final selectedFlow = job['selected_flow'] is Map
                    ? job['selected_flow']
                    : {};
                final jobType =
                    selectedFlow['employmentType']?.toString() ??
                    job['job_type']?.toString() ??
                    'FULL-TIME';
                final description =
                    job['job_description']?.toString() ??
                    selectedFlow['sector']?.toString() ??
                    'No description available';

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedJob = job;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF1E3A8A).withOpacity(0.2)
                                : const Color(0xFFEFF6FF).withOpacity(0.5))
                          : (isDark ? const Color(0xFF0F172A) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.business_center,
                                size: 16,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                jobType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          jobTitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$candidatesCount Candidates",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_outlined,
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Openings: $openings",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSection(bool isDark, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32 : 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Employee List",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _assignInterviewer,
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text("Assign Interviewer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoadingEmployees)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            )
          else if (_employees.isEmpty)
            Text(
              "No employees found.",
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
            )
          else
            _buildEmployeeTable(isDark),
        ],
      ),
    );
  }

  Widget _buildEmployeeTable(bool isDark) {
    List<ApplicationModel> filteredEmployees = _employees;

    if (filteredEmployees.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            "No candidates have applied for this job.",
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        ),
        columns: const [
          DataColumn(label: Text('SELECT')),
          DataColumn(label: Text('NAME')),
          DataColumn(label: Text('ROLE')),
          DataColumn(label: Text('JOB NAME')),
          DataColumn(label: Text('DEPARTMENT')),
          DataColumn(label: Text('EMAIL')),
          DataColumn(label: Text('ASSIGNMENT')),
        ],
        rows: filteredEmployees.map((emp) {
          final isSelected = _selectedEmployeeIds.contains(emp.id);
          return DataRow(
            selected: isSelected,
            onSelectChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedEmployeeIds.add(emp.id);
                } else {
                  _selectedEmployeeIds.remove(emp.id);
                }
              });
            },
            cells: [
              DataCell(
                Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedEmployeeIds.add(emp.id);
                      } else {
                        _selectedEmployeeIds.remove(emp.id);
                      }
                    });
                  },
                ),
              ),
              DataCell(
                Text(
                  emp.userName,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    emp.status == 'interviewer'
                        ? 'Interviewer'
                        : 'Interviewer', // Matching screenshot where it shows Interviewer pill
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  emp.jobName.isNotEmpty ? emp.jobName : '-',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              DataCell(
                Text(
                  'Recruitment',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ), // Hardcoded in screenshot as Recruitment
              DataCell(
                Text(
                  emp.email,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              DataCell(
                emp.companyName.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Green assigned pill
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Assigned: ${emp.companyName}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const Text('-', style: TextStyle(color: Colors.grey)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------
  // Sidebar (Same as Applied Candidates Page)
  // ---------------------------------------------------------
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
              top: isDrawer ? 40 : 48,
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
                        fontSize: 8,
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
              if (isDrawer) Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          const SizedBox(height: 12),
          // Business Expandable Menu
          ListTile(
            leading: const Icon(
              Icons.business_center_outlined,
              color: Colors.white60,
              size: 20,
            ),
            title: const Text(
              "Business",
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            trailing: AnimatedRotation(
              turns: _isBusinessExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white38,
                size: 20,
              ),
            ),
            dense: true,
            onTap: () =>
                setState(() => _isBusinessExpanded = !_isBusinessExpanded),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            crossFadeState: _isBusinessExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 4),
                _sidebarSubItem(
                  "Business Overview",
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BusinessCreatedPage(showSelection: false),
                      ),
                    );
                  },
                ),
                _sidebarSubItem(
                  "User Overview",
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserOverviewPage(),
                      ),
                    );
                  },
                ),
                _sidebarSubItem(
                  "Add Business",
                  textColor: pinkColor,
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BusinessCreatedPage(showSelection: true),
                      ),
                    );
                  },
                ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
          // Jobs Expandable Menu
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
                Icons.work_outline_rounded,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              title: const Text(
                "Jobs",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: AnimatedRotation(
                turns: _isJobsExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
              dense: true,
              onTap: () => setState(() => _isJobsExpanded = !_isJobsExpanded),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            crossFadeState: _isJobsExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 2),
                _sidebarSubItem(
                  "Post Job",
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
                _sidebarSubItem(
                  "View Posted Jobs",
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostedJobsPage(),
                      ),
                    );
                  },
                ),
                _sidebarSubItem(
                  "Applied Candidates",
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AppliedListPage(isBusinessMode: true),
                      ),
                    );
                  },
                ),
                _activeSubItem(
                  "Assign Candidate",
                  onTap: () {
                    if (isDrawer) Navigator.pop(context);
                  },
                ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.widgets_outlined,
            "Switch Portal",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
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

  Widget _activeSubItem(String title, {VoidCallback? onTap}) => ListTile(
    contentPadding: const EdgeInsets.only(left: 54),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "-",
          style: TextStyle(
            color: Color(0xFFE11D48),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE11D48),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
    onTap: onTap,
    dense: true,
  );
}
