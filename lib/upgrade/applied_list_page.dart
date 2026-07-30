import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'assign_candidate_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme/theme_provider.dart';
import '../auth_service.dart';
import 'apply_job_page.dart';
import 'job_list_page.dart';
import 'posted_jobs_page.dart';
import 'post_job_page.dart';
import 'user_overview_page.dart';

class ApplicationModel {
  final int id;
  final String userMainId;
  final String userName;
  final String email;
  final String companyId;
  final String companyName;
  final String jobName;
  final String jobDescription;
  final String jobType;
  final String status;
  final String createdAt;
  final String updatedAt;

  const ApplicationModel({
    required this.id,
    required this.userMainId,
    required this.userName,
    required this.email,
    required this.companyId,
    required this.companyName,
    required this.jobName,
    required this.jobDescription,
    required this.jobType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userMainId: json['user_main_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      companyId: json['company_id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      jobName: json['job_name']?.toString() ?? '',
      jobDescription: json['job_description']?.toString() ?? '',
      jobType: json['job_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  String get initials =>
      userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '?';

  String get companyInitials {
    if (companyName.isEmpty) return '?';
    List<String> words = companyName.split(' ');
    if (words.length >= 2) {
      String first = words[0].isNotEmpty ? words[0].substring(0, 1) : '';
      String second = words[1].isNotEmpty ? words[1].substring(0, 1) : '';
      return (first + second).toUpperCase();
    }
    return companyName
        .substring(0, companyName.length >= 2 ? 2 : companyName.length)
        .toUpperCase();
  }

  String get jobTitle {
    if (jobName.isNotEmpty) return jobName;
    return 'Unknown Job';
  }

  String get location {
    switch (companyId) {
      case 'COMP-STATIC-001':
        return 'San Francisco, CA';
      case 'COMP-STATIC-002':
        return 'Austin, TX';
      case 'COMP-STATIC-003':
        return 'New York, NY';
      case 'COMP-STATIC-004':
        return 'Boston, MA';
      case 'COMP-STATIC-005':
        return 'Chennai, TN';
      case 'COMP-STATIC-006':
        return 'Coimbatore, TN';
      default:
        return 'Remote / On-site';
    }
  }

  String get appliedOnDateFormatted {
    if (createdAt.isEmpty) return '-';
    try {
      DateTime dt = DateTime.parse(createdAt);
      List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (_) {
      return createdAt;
    }
  }

  get jobPostedId => null;
}

class AppliedListPage extends ConsumerStatefulWidget {
  final bool isBusinessMode;
  const AppliedListPage({super.key, this.isBusinessMode = false});

  @override
  ConsumerState<AppliedListPage> createState() => _AppliedListPageState();
}

class _AppliedListPageState extends ConsumerState<AppliedListPage> {
  bool _isApplyJobExpanded = true;
  bool _isBusinessExpanded = false;
  bool _isJobsExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeFilter = 'All';
  String? _selectedJobFilter;
  int _showEntries = 5;
  String _searchQuery = '';

  bool _isLoading = true;
  String? _errorMessage;
  List<ApplicationModel> _applications = [];

  final List<String> _filters = [
    'All',
    'Pending',
    'Reviewed',
    'shortlist',
    'Interview',
    'Job Offer',
    'Approved',
    'Rejected',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    try {
      final token = await AuthService().getToken();
      final url = Uri.parse(
        widget.isBusinessMode
            ? 'https://user.jobes24x7.com/api/job-approved'
            : 'https://user.jobes24x7.com/api/job-approved/my-records',
      );
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        final list = (data is Map && data.containsKey('data'))
            ? data['data']
            : (data is List ? data : []);
        final dataList = list as List? ?? [];
        if (mounted) {
          setState(() {
            _applications = dataList
                .map((j) => ApplicationModel.fromJson(j))
                .where((app) {
                  final email = app.email.toLowerCase();
                  final name = app.userName.toLowerCase();
                  return email != 'yudeshprasath@gmail.com' &&
                      email != 'dhanusjd@gmail.com' &&
                      email != 'lovelylohit003@gmail.com' &&
                      name != 'narendra' &&
                      name != 'dhanush' &&
                      name != 'lohit';
                })
                .toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load candidates.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<ApplicationModel> get _filtered {
    List<ApplicationModel> list = _applications;
    if (_activeFilter != 'All') {
      list = list
          .where((a) => a.status.toLowerCase() == _activeFilter.toLowerCase())
          .toList();
    }
    if (_selectedJobFilter != null) {
      list = list.where((a) => a.jobTitle == _selectedJobFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where(
            (a) =>
                a.userName.toLowerCase().contains(query) ||
                a.email.toLowerCase().contains(query) ||
                a.jobDescription.toLowerCase().contains(query),
          )
          .toList();
    }
    return list.take(_showEntries).toList();
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('reject')) return const Color(0xFFEF4444);
    if (s.contains('review')) return const Color(0xFF3B82F6);
    if (s.contains('interview')) return const Color(0xFF8B5CF6);
    if (s.contains('shortlist')) return const Color(0xFF06B6D4);
    if (s.contains('offer')) return const Color(0xFF10B981);
    if (s.contains('approve')) return const Color(0xFF10B981);
    if (s.contains('cancel')) return const Color(0xFF64748B);
    return const Color(0xFFF59E0B); // Pending
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      onDrawerChanged: (opened) =>
          debugPrint(opened ? 'Drawer opened' : 'Drawer closed'),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageHeader(isDark),
                        const SizedBox(height: 24),
                        if (widget.isBusinessMode) _buildJobCards(isDark),
                        _buildFilterChips(),
                        const SizedBox(height: 20),
                        _buildTable(isDesktop, isDark),
                        const SizedBox(height: 16),
                        _buildPagination(),
                      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      bottom: false,
      child: Container(
        height: isDesktop ? 70 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
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
                    hintText: 'Search jobs or companies...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
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
            const SizedBox(width: 16),
            const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: () {
                ref.read(themeProviderState).toggleTheme();
                final isDarkNow = ref.read(themeProviderState).isDarkMode;
                debugPrint(
                  isDarkNow ? "Dark Mode Enabled" : "Dark Mode Disabled",
                );
              },
              child: Icon(
                Icons.dark_mode_outlined,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (value) async {
                if (value == 'users') {
                  debugPrint("Users clicked");
                } else if (value == 'logout') {
                  debugPrint("Logout clicked");
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'users',
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Users',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isBusinessMode ? 'Applied Candidates' : 'My Applications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.isBusinessMode
              ? 'View and manage all candidates who have applied for your job postings.'
              : "Track the status of the jobs you've applied for.",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final isActive = _activeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF4F46E5) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJobCards(bool isDark) {
    if (_applications.isEmpty) return const SizedBox.shrink();

    final Map<String, List<ApplicationModel>> grouped = {};
    for (var app in _applications) {
      grouped.putIfAbsent(app.jobTitle, () => []).add(app);
    }

    List<Widget> cards = [];

    cards.add(
      _buildSingleJobCard(
        title: 'All Applied Jobs',
        description:
            'View candidates applied across all active job postings for this business.',
        count: _applications.length,
        jobType: 'ALL POSTINGS',
        isSelected: _selectedJobFilter == null,
        onTap: () => setState(() => _selectedJobFilter = null),
        isDark: isDark,
      ),
    );

    grouped.forEach((jobTitle, apps) {
      cards.add(
        _buildSingleJobCard(
          title: jobTitle,
          description: apps.first.jobDescription.isNotEmpty
              ? apps.first.jobDescription
              : 'No description provided.',
          count: apps.length,
          jobType: apps.first.jobType.isNotEmpty
              ? apps.first.jobType
              : 'FULL-TIME',
          isSelected: _selectedJobFilter == jobTitle,
          onTap: () => setState(() => _selectedJobFilter = jobTitle),
          isDark: isDark,
        ),
      );
    });

    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 24),
      child: ListView(scrollDirection: Axis.horizontal, children: cards),
    );
  }

  Widget _buildSingleJobCard({
    required String title,
    required String description,
    required int count,
    required String jobType,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final borderColor = isSelected
        ? const Color(0xFF6366F1)
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final bgColor = isDark
        ? (isSelected
              ? const Color(0xFF1E293B).withOpacity(0.8)
              : const Color(0xFF1E293B))
        : (isSelected ? const Color(0xFFF5F3FF) : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.work,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      jobType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.visibility,
                      size: 14,
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF6366F1)
                    : (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$count Candidate${count == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.group,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'See Candidates',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(bool isDesktop, bool isDark) {
    final rows = _filtered;

    if (!isDesktop) {
      // Mobile layout: No table container border/shadow, just a clean scrollable list of cards
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Box
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
                debugPrint("Search query: $val");
              },
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: widget.isBusinessMode
                    ? 'Search by name, job or email...'
                    : 'Search jobs or companies...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No applications found.',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            )
          else
            ...rows.map((app) => _buildRow(app, isDesktop, isDark)).toList(),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Show Entries & Search Box
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 14, right: 20),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Show',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _showEntries,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            size: 16,
                          ),
                          dropdownColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 13,
                          ),
                          items: [5, 10, 20].map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString()),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _showEntries = newValue;
                              });
                              debugPrint("Entries changed: $newValue");
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'entries',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                // Search Box
                Container(
                  height: 36,
                  width: 200,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      debugPrint("Search query: $val");
                    },
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: widget.isBusinessMode
                          ? 'Search by name, job or email...'
                          : 'Search jobs or companies...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE2E8F0),
                ),
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _HeaderCell(
                    widget.isBusinessMode ? 'CANDIDATE' : 'COMPANY',
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: _HeaderCell(
                    widget.isBusinessMode ? 'APPLIED FOR' : 'JOB TITLE',
                  ),
                ),
                Expanded(
                  flex: widget.isBusinessMode ? 2 : 3,
                  child: _HeaderCell(
                    widget.isBusinessMode ? 'APPLIED DATE' : 'LOCATION / TYPE',
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _HeaderCell(
                    widget.isBusinessMode ? 'EXPERIENCE' : 'APPLIED ON',
                  ),
                ),
                Expanded(flex: 2, child: _HeaderCell('STATUS')),
                Expanded(
                  flex: 1,
                  child: _HeaderCell(
                    widget.isBusinessMode ? 'ACTIONS' : 'ACTION',
                    isCenter: true,
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFEF4444),
                ),
              ),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No applications found.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            )
          else
            ...rows.map((app) => _buildRow(app, isDesktop, isDark)).toList(),

          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Showing 1 to ${rows.length} of ${rows.length} entries',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  String _getExperience(ApplicationModel app) {
    if (app.userName.toLowerCase().contains('sabari')) {
      return '4 Years';
    } else if (app.userName.toLowerCase().contains('narendra')) {
      return '5 Years';
    } else if (app.userName.toLowerCase().contains('dhanush')) {
      return '2 Years';
    } else if (app.userName.toLowerCase().contains('lohit')) {
      return '3 Years';
    } else {
      return '4 Years';
    }
  }

  List<String> _getSkills(ApplicationModel app) {
    final title = app.jobTitle.toLowerCase();
    if (title.contains('react') || title.contains('frontend')) {
      return ['React', 'NodeJS', 'TypeScript'];
    } else if (title.contains('backend') || title.contains('node')) {
      return ['NodeJS', 'Express', 'MongoDB'];
    } else if (title.contains('ui') ||
        title.contains('ux') ||
        title.contains('designer')) {
      return ['Figma', 'UI/UX', 'Adobe XD'];
    } else if (title.contains('cloud') || title.contains('architect')) {
      return ['AWS', 'Docker', 'Kubernetes'];
    } else if (title.contains('driver')) {
      return ['Driving', 'Logistics', 'Navigation'];
    } else {
      return ['React', 'NodeJS', 'TypeScript'];
    }
  }

  String _getSalary(ApplicationModel app) {
    final title = app.jobTitle.toLowerCase();
    if (title.contains('react') ||
        title.contains('frontend') ||
        title.contains('backend') ||
        title.contains('node')) {
      return '₹ 15,00,000';
    } else if (title.contains('ui') ||
        title.contains('ux') ||
        title.contains('designer')) {
      return '₹ 12,00,000';
    } else if (title.contains('cloud') || title.contains('architect')) {
      return '₹ 22,00,000';
    } else if (title.contains('driver')) {
      return '₹ 4,50,000';
    } else {
      return '₹ 10,00,000';
    }
  }

  String _getEducation(ApplicationModel app) {
    final title = app.jobTitle.toLowerCase();
    if (title.contains('driver')) {
      return 'High School Diploma';
    }
    return 'B.Tech - Computer Science';
  }

  String _getLocation(ApplicationModel app) {
    if (app.location.toLowerCase().contains('remote')) {
      return 'Remote';
    }
    return 'On-site';
  }

  Widget _buildRow(ApplicationModel app, bool isDesktop, bool isDark) {
    final statusColor = _statusColor(app.status);
    final borderColor = isDark
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    if (!isDesktop) {
      if (widget.isBusinessMode) {
        // Mobile business mode row
        final experienceStr = _getExperience(app);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Candidate Info & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF3B82F6),
                          child: Text(
                            app.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.userName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                app.email,
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      app.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2: Applied Job
              Text(
                app.jobTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Row 3: Applied Date & Experience
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Applied on: ${app.appliedOnDateFormatted}',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mutedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Exp: $experienceStr',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              // Row 4: View button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showCandidateDetails(app),
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                    label: const Text(
                      'View Candidate',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        // Mobile candidate mode layout!
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Company Info & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF4F46E5),
                          child: Text(
                            app.companyInitials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            app.companyName,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      app.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 2: Job Title
              Text(
                app.jobTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Row 3: Location / Type
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: mutedColor),
                  const SizedBox(width: 4),
                  Text(
                    app.location,
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: mutedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    app.jobType.isNotEmpty ? app.jobType : 'Full-time',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Row 4: Applied Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Applied on: ${app.appliedOnDateFormatted}',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              // Row 5: Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showJobDetails(app),
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                    label: const Text('View', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _confirmCancelApplication(app),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Color(0xFFFEE2E2)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    }

    if (widget.isBusinessMode) {
      // Desktop Business Mode Row
      final experienceStr = _getExperience(app);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            // CANDIDATE
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF3B82F6),
                    child: Text(
                      app.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          app.userName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          app.email,
                          style: TextStyle(color: mutedColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // APPLIED FOR
            Expanded(
              flex: 3,
              child: Text(
                app.jobTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            // APPLIED DATE
            Expanded(
              flex: 2,
              child: Text(
                app.appliedOnDateFormatted,
                style: TextStyle(fontSize: 13, color: textColor),
              ),
            ),
            // EXPERIENCE
            Expanded(
              flex: 2,
              child: Text(
                experienceStr,
                style: TextStyle(fontSize: 13, color: textColor),
              ),
            ),
            // STATUS
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    app.status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // ACTION
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                  onPressed: () => _showCandidateDetails(app),
                  tooltip: 'View Details',
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop Candidate Mode Row
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // COMPANY
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: Text(
                    app.companyInitials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    app.companyName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // JOB TITLE
          Expanded(
            flex: 3,
            child: Text(
              app.jobTitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          // LOCATION / TYPE
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      app.location,
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  app.jobType.isNotEmpty ? app.jobType : 'Full-time',
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
              ],
            ),
          ),
          // APPLIED ON
          Expanded(
            flex: 2,
            child: Text(
              app.appliedOnDateFormatted,
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ),
          // STATUS
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  app.status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // ACTION
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Color(0xFF4F46E5),
                    size: 18,
                  ),
                  onPressed: () => _showJobDetails(app),
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                  onPressed: () => _confirmCancelApplication(app),
                  tooltip: 'Cancel Application',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateApplicationStatus(int id, String newStatus) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AuthService().getToken();
      final url = Uri.parse(
        'https://user.jobes24x7.com/api/job-approved/update/$id',
      );
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Candidate status updated to $newStatus successfully!',
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
        _fetchCandidates();
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scheduleInterview(ApplicationModel app) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final token = await AuthService().getToken();
      final url = Uri.parse(
        'https://user.jobes24x7.com/api/assigned-interviewers/create',
      );

      final payload = {
        "user_main_id": app.userMainId,
        "user_name": app.userName,
        "email": app.email,
        "company_id": app.companyId,
        "job_name": app.jobName,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${app.userName} scheduled for interview successfully!',
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
        _fetchCandidates();
      } else {
        throw Exception(
          'Server returned status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule interview: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCandidateDetails(ApplicationModel app) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final skills = _getSkills(app);
        final experience = _getExperience(app);
        final education = _getEducation(app);
        final salary = _getSalary(app);
        final location = _getLocation(app);
        final statusColor = _statusColor(app.status);

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxWidth: 650),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Candidate Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF3B82F6),
                        child: Text(
                          app.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.userName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${app.email} • +91 98765 43210',
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag(Icons.work_outline, app.jobTitle, isDark),
                      _buildTag(
                        Icons.calendar_today,
                        app.appliedOnDateFormatted,
                        isDark,
                      ),
                      _buildTag(Icons.location_on, location, isDark),
                      _buildTag(Icons.attach_money, salary, isDark),
                      _buildTag(Icons.history, experience, isDark),
                      _buildTag(Icons.school, education, isDark),
                      _buildTag(Icons.timer, '30 Days', isDark),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'APPLICATION STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      app.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SKILLS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'COVER LETTER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      'I am a passionate developer eager to contribute to your team.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            backgroundColor:
                                (app.status.toLowerCase() == 'interview' ||
                                    app.status.toLowerCase() == 'interviewer' ||
                                    app.status.toLowerCase().contains('reject'))
                                ? (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF1F5F9))
                                : null,
                          ),
                          child: const Text('Close'),
                        ),
                        if (app.status.toLowerCase() == 'approved' ||
                            app.status.toLowerCase() == 'interviewer' ||
                            app.status.toLowerCase() == 'interview') ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Candidate Accepted!',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _scheduleInterview(app);
                            },
                            icon: const Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Schedule Interview',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE11D48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ] else if (!app.status.toLowerCase().contains(
                          'reject',
                        )) ...[
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _updateApplicationStatus(app.id, 'interviewer');
                            },
                            icon: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Interview',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _updateApplicationStatus(app.id, 'rejected');
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Reject',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmCancelApplication(ApplicationModel app) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          'Cancel Application',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Are you sure you want to cancel your application for ${app.jobTitle} at ${app.companyName}?',
          style: TextStyle(
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _cancelApplication(app.id);
    }
  }

  Future<void> _cancelApplication(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthService().getToken();
      final url = Uri.parse(
        'https://user.jobes24x7.com/api/job-approved/delete/$id',
      );
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application cancelled successfully'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
        _fetchCandidates();
      } else {
        throw Exception('Server returned status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _pageBtn('Prev', enabled: false),
        const SizedBox(width: 8),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '1',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        _pageBtn('Next', enabled: false),
      ],
    );
  }

  Widget _pageBtn(String label, {required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? () {} : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: enabled ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  // ── Sidebar ─────────────────────────────────────────────────────────────────

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
    if (widget.isBusinessMode) {
      return _buildBusinessSidebar(context, isDrawer: isDrawer);
    }
    const pinkColor = Color(0xFFE11D48);
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
                      '90×25',
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
            'Dashboard',
            onTap: () {
              debugPrint('Dashboard clicked');
              if (isDrawer) Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.widgets_outlined,
            'Switch Portal',
            onTap: () {
              debugPrint('Switch Portal clicked');
              if (isDrawer) Navigator.pop(context);
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),
          const SizedBox(height: 8),
          _buildApplyJobExpansion(
            context,
            isDrawer: isDrawer,
            pinkColor: pinkColor,
            activeItem: 'applied_list',
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
    dense: true,
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('–', style: TextStyle(color: Colors.white30, fontSize: 14)),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(color: textColor ?? Colors.white60, fontSize: 13),
        ),
      ],
    ),
    onTap: onTap,
  );

  Widget _buildBusinessSidebar(BuildContext context, {required bool isDrawer}) {
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
          const SizedBox(height: 4),
          _buildBusinessExpansionForSidebar(
            context,
            isDrawer: isDrawer,
            pinkColor: pinkColor,
          ),
          const SizedBox(height: 4),
          _buildJobsExpansionForSidebar(context, isDrawer: isDrawer),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.swap_horiz_rounded,
            "Switch Portal",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 220), () {
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessExpansionForSidebar(
    BuildContext context, {
    required bool isDrawer,
    required Color pinkColor,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: _isBusinessExpanded ? Colors.white : Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.business_center_outlined,
              color: _isBusinessExpanded
                  ? const Color(0xFF1E293B)
                  : Colors.white60,
              size: 20,
            ),
            title: Text(
              "Business",
              style: TextStyle(
                color: _isBusinessExpanded
                    ? const Color(0xFF1E293B)
                    : Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimatedRotation(
                turns: _isBusinessExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _isBusinessExpanded
                      ? const Color(0xFF1E293B)
                      : Colors.white38,
                  size: 20,
                ),
              ),
            ),
            dense: true,
            onTap: () =>
                setState(() => _isBusinessExpanded = !_isBusinessExpanded),
          ),
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
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              _sidebarSubItem(
                "User Overview",
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.push(
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
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              _sidebarSubItem(
                "Posted Jobs",
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostedJobsPage(),
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

  Widget _buildJobsExpansionForSidebar(
    BuildContext context, {
    required bool isDrawer,
  }) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.work_outline_rounded,
            color: Colors.white60,
            size: 20,
          ),
          title: const Text(
            "Jobs",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          trailing: AnimatedRotation(
            turns: _isJobsExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white38,
              size: 20,
            ),
          ),
          dense: true,
          onTap: () => setState(() => _isJobsExpanded = !_isJobsExpanded),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PostJobPage()),
                  );
                },
              ),
              _sidebarSubItem(
                "View Posted Jobs",
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostedJobsPage(),
                    ),
                  );
                },
              ),
              _activeSubItem(
                "Applied Candidates",
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                },
              ),
              _sidebarSubItem(
                "Assign Candidate",
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AssignCandidatePage(),
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

  Widget _buildApplyJobExpansion(
    BuildContext context, {
    required bool isDrawer,
    required Color pinkColor,
    required String activeItem,
  }) {
    return Column(
      children: [
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

  Widget _activeSubItem(
    String title, {
    Color? textColor,
    VoidCallback? onTap,
  }) => Container(
    margin: const EdgeInsets.only(left: 12),
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

  void _showJobDetails(ApplicationModel app) {
    debugPrint("View Job Details clicked");
    debugPrint("Job Details popup opened");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Candidate Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        debugPrint("Job Details popup closed");
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF4F46E5),
                      child: Text(
                        app.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            app.email,
                            style: const TextStyle(
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(
                      Icons.work_outline,
                      app.jobType.isNotEmpty ? app.jobType : 'Full-time',
                      isDark,
                    ),
                    _buildTag(Icons.business, app.companyName, isDark),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  app.jobDescription.isNotEmpty
                      ? app.jobDescription
                      : 'No description provided.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      debugPrint("Job Details popup closed");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: isDark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final bool isCenter;
  const _HeaderCell(this.label, {this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }
}
