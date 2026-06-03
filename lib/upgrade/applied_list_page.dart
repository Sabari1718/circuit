import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../auth_service.dart';
import 'apply_job_page.dart';
import 'job_list_page.dart';

class ApplicationModel {
  final String initials;
  final Color avatarColor;
  final String company;
  final String jobTitle;
  final String location;
  final String type;
  final String appliedOn;
  final String status;
  final String department;
  final String salary;
  final String description;

  const ApplicationModel({
    required this.initials,
    required this.avatarColor,
    required this.company,
    required this.jobTitle,
    required this.location,
    required this.type,
    required this.appliedOn,
    required this.status,
    required this.department,
    required this.salary,
    required this.description,
  });
}

class AppliedListPage extends StatefulWidget {
  const AppliedListPage({super.key});

  @override
  State<AppliedListPage> createState() => _AppliedListPageState();
}

class _AppliedListPageState extends State<AppliedListPage> {
  bool _isApplyJobExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeFilter = 'All';
  int _showEntries = 5;
  String _searchQuery = '';

  final List<String> _filters = [
    'All', 'Pending', 'Reviewed', 'Shortlisted',
    'Interview', 'Job Offer', 'Approved', 'Rejected', 'Cancelled',
  ];

  final List<ApplicationModel> _applications = const [
    ApplicationModel(
      initials: 'FC',
      avatarColor: Color(0xFFF59E0B),
      company: 'FinCore Financial',
      jobTitle: 'Backend Engineer',
      location: 'New York, NY',
      type: 'Contract',
      appliedOn: 'Sep 28, 2026',
      status: 'Rejected',
      department: 'Engineering',
      salary: '\$130k - \$160k',
      description: 'Join our core infrastructure team to build robust, high-performance financial transaction systems.',
    ),
    ApplicationModel(
      initials: 'HS',
      avatarColor: Color(0xFFEF4444),
      company: 'HealthSync',
      jobTitle: 'React Native Developer',
      location: 'Boston, MA (Hybrid)',
      type: 'Full-time',
      appliedOn: 'Oct 14, 2026',
      status: 'Reviewed',
      department: 'Frontend',
      salary: '\$110k - \$140k',
      description: 'Looking for an experienced React Native developer to help build out our new healthcare application.',
    ),
    ApplicationModel(
      initials: 'TN',
      avatarColor: Color(0xFF4F46E5),
      company: 'TechNova Solutions',
      jobTitle: 'Senior Frontend Developer',
      location: 'San Francisco, CA (Remote)',
      type: 'Full-time',
      appliedOn: 'Oct 12, 2026',
      status: 'Interview',
      department: 'Engineering',
      salary: '\$140k - \$180k',
      description: 'Help lead our frontend team in building our next-generation cloud dashboard.',
    ),
    ApplicationModel(
      initials: 'ED',
      avatarColor: Color(0xFF10B981),
      company: 'EcoDrive Auto',
      jobTitle: 'Product Manager',
      location: 'Austin, TX',
      type: 'Full-time',
      appliedOn: 'Oct 05, 2026',
      status: 'Pending',
      department: 'Product',
      salary: '\$120k - \$150k',
      description: 'Drive the product roadmap for our upcoming electric vehicle software platform.',
    ),
  ];

  List<ApplicationModel> get _filtered {
    List<ApplicationModel> list = _applications;
    if (_activeFilter != 'All') {
      list = list.where((a) => a.status == _activeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((a) =>
          a.company.toLowerCase().contains(query) ||
          a.jobTitle.toLowerCase().contains(query)).toList();
    }
    return list.take(_showEntries).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Rejected':   return const Color(0xFFEF4444);
      case 'Reviewed':   return const Color(0xFF3B82F6);
      case 'Interview':  return const Color(0xFF8B5CF6);
      case 'Shortlisted': return const Color(0xFF06B6D4);
      case 'Job Offer':  return const Color(0xFF10B981);
      case 'Approved':   return const Color(0xFF10B981);
      case 'Cancelled':  return const Color(0xFF64748B);
      default:           return const Color(0xFFF59E0B); // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
          border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
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
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon:
                      Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Stack(clipBehavior: Clip.none, children: [
            const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF64748B), size: 24),
            Positioned(
              top: -2, right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: const Text('4',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              final isDarkNow = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
              debugPrint(isDarkNow ? "Dark Mode Enabled" : "Dark Mode Disabled");
            },
            child: Icon(Icons.dark_mode_outlined,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), size: 22),
          ),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onSelected: (value) async {
              if (value == 'users') {
                debugPrint("Users clicked");
              } else if (value == 'logout') {
                debugPrint("Logout clicked");
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'users',
                child: Row(
                  children: [
                    Icon(Icons.people_outline, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text('Users', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(Icons.person, color: Color(0xFF94A3B8), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('Admin',
                      style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), size: 16),
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
        Text('My Applications',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B))),
        const SizedBox(height: 4),
        Text("Track the status of the jobs you've applied for.",
            style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4F46E5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isActive
                          ? const Color(0xFF4F46E5)
                          : const Color(0xFFE2E8F0)),
                ),
                child: Text(f,
                    style: TextStyle(
                        color:
                            isActive ? Colors.white : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(bool isDesktop, bool isDark) {
    final rows = _filtered;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
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
                    Text('Show', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                    const SizedBox(width: 8),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _showEntries,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), size: 16),
                          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 13),
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
                              debugPrint("Entries changed: \$newValue");
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('entries', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                  ],
                ),
                // Search Box
                Container(
                  height: 36,
                  width: isDesktop ? 200 : double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      debugPrint("Search query: \$val");
                    },
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'Search jobs or companies...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
                  top: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                  bottom: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0))),
            ),
            child: isDesktop
                ? const Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: _HeaderCell('COMPANY')),
                      Expanded(
                          flex: 3,
                          child: _HeaderCell('JOB TITLE')),
                      Expanded(
                          flex: 3,
                          child: _HeaderCell('LOCATION / TYPE')),
                      Expanded(
                          flex: 2,
                          child: _HeaderCell('APPLIED ON')),
                      Expanded(
                          flex: 2,
                          child: _HeaderCell('STATUS')),
                      Expanded(
                          flex: 1,
                          child: _HeaderCell('ACTION')),
                    ],
                  )
                : const Row(
                    children: [
                      Expanded(flex: 2, child: _HeaderCell('JOB')),
                      Expanded(flex: 1, child: _HeaderCell('STATUS')),
                      Expanded(flex: 1, child: _HeaderCell('ACTION')),
                    ],
                  ),
          ),

          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text('No applications found.',
                  style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
            )
          else
            ...rows.map((app) => _buildRow(app, isDesktop, isDark)).toList(),

          // Footer
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Showing 1 to ${rows.length} of ${rows.length} entries',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(ApplicationModel app, bool isDesktop, bool isDark) {
    final statusColor = _statusColor(app.status);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (!isDesktop) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: borderColor))),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: app.avatarColor,
              child: Text(app.initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.company,
                      style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(app.jobTitle,
                      style: TextStyle(
                          fontSize: 12, color: textColor)),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(app.status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      icon: const Icon(Icons.visibility_outlined,
                          size: 18, color: Color(0xFF4F46E5)),
                      onPressed: () => _showJobDetails(app),
                      tooltip: 'View',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFFEF4444)),
                      onPressed: () {
                        debugPrint("Application cancelled");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Application cancelled."),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(
                                bottom: MediaQuery.of(context).size.height - 100,
                                left: isDesktop ? MediaQuery.of(context).size.width - 300 : 20,
                                right: 20),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      tooltip: 'Cancel Application',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: borderColor))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: app.avatarColor,
                  child: Text(app.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(app.company,
                      style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(app.jobTitle,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 12, color: mutedColor),
                  const SizedBox(width: 3),
                  Text(app.location,
                      style: TextStyle(
                          fontSize: 12,
                          color: mutedColor)),
                ]),
                const SizedBox(height: 2),
                Text(app.type,
                    style: TextStyle(
                        fontSize: 11, color: mutedColor)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(app.appliedOn,
                style: TextStyle(
                    fontSize: 13, color: mutedColor)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: statusColor.withOpacity(0.3)),
              ),
              child: Text(app.status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: const Icon(Icons.visibility_outlined,
                        size: 18, color: Color(0xFF4F46E5)),
                    onPressed: () => _showJobDetails(app),
                    tooltip: 'View',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFFEF4444)),
                    onPressed: () {
                      debugPrint("Application cancelled");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Application cancelled."),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 100,
                              left: isDesktop ? MediaQuery.of(context).size.width - 300 : 20,
                              right: 20),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    tooltip: 'Cancel Application',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
          child: const Text('1',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: enabled
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF94A3B8))),
      ),
    );
  }

  // ── Sidebar ─────────────────────────────────────────────────────────────────

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
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
                bottom: 24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Center(
                    child: Text('90×25',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.grid_view_rounded,
                    color: Color(0xFFE11D48), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sidebarItem(Icons.home_outlined, 'Dashboard', onTap: () {
            debugPrint('Dashboard clicked');
            if (isDrawer) Navigator.pop(context);
            Navigator.popUntil(context, (r) => r.isFirst);
          }),
          const SizedBox(height: 8),
          _sidebarItem(Icons.widgets_outlined, 'Switch Portal', onTap: () {
            debugPrint('Switch Portal clicked');
            if (isDrawer) Navigator.pop(context);
            Navigator.popUntil(context, (r) => r.isFirst);
          }),
          const SizedBox(height: 8),
          _buildApplyJobExpansion(context, isDrawer: isDrawer, pinkColor: pinkColor, activeItem: 'applied_list'),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title,
          {VoidCallback? onTap}) =>
      ListTile(
        leading: Icon(icon, color: Colors.white60, size: 20),
        title: Text(title,
            style: const TextStyle(color: Colors.white60, fontSize: 14)),
        onTap: onTap,
        dense: true,
      );

  Widget _sidebarSubItem(String title,
          {Color? textColor, VoidCallback? onTap}) =>
      ListTile(
        contentPadding: const EdgeInsets.only(left: 54),
        dense: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('–',
                style: TextStyle(color: Colors.white30, fontSize: 14)),
            const SizedBox(width: 12),
            Text(title,
                style: TextStyle(
                    color: textColor ?? Colors.white60, fontSize: 13)),
          ],
        ),
        onTap: onTap,
      );

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

  Widget _activeSubItem(String title, {Color? textColor, VoidCallback? onTap}) =>
      Container(
        margin: const EdgeInsets.only(left: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF334155),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
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

  void _showJobDetails(ApplicationModel app) {
    debugPrint("View Job Details clicked");
    debugPrint("Job Details popup opened");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    Text('Job Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        debugPrint("Job Details popup closed");
                      },
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: app.avatarColor,
                      child: Text(app.initials, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.jobTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                          Text(app.company, style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w500)),
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
                    _buildTag(Icons.work_outline, app.type, isDark),
                    _buildTag(Icons.location_on_outlined, app.location, isDark),
                    _buildTag(Icons.attach_money, app.salary, isDark),
                    _buildTag(Icons.business, app.department, isDark),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Job Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Text(app.description, style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      debugPrint("Job Details popup closed");
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          Icon(icon, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569))),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(label,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            letterSpacing: 0.5));
  }
}
