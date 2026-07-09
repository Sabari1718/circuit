import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PostedJobModel {
  final String title;
  final String company;
  final String department;
  final String location;
  final String deadline;
  final String status;
  final String salaryRange;
  final String vacancies;
  final String category;
  final String type;
  final String experience;
  final String postedDate;
  final String description;
  final List<String> skills;

  const PostedJobModel({
    required this.title,
    required this.company,
    required this.department,
    required this.location,
    required this.deadline,
    required this.status,
    required this.salaryRange,
    required this.vacancies,
    required this.category,
    required this.type,
    required this.experience,
    required this.postedDate,
    required this.description,
    required this.skills,
  });
}

class PostedJobsPage extends StatefulWidget {
  const PostedJobsPage({super.key});

  @override
  State<PostedJobsPage> createState() => _PostedJobsPageState();
}

class _PostedJobsPageState extends State<PostedJobsPage> {
  int _showEntries = 5;
  int _currentPage = 1;

  List<PostedJobModel> _jobs = [];
  bool _isLoading = true;

  String _getFirstValid(List<dynamic> values, String fallback) {
    for (var val in values) {
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _fetchPostedJobs();   
  }

  Future<void> _fetchPostedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userMainId = prefs.getString('user_main_id') ?? '';

      // Temporary override for testing as per dashboard logic
      if (userMainId == '8059210846') {
        userMainId = '6102066450';
      }

      if (userMainId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final url = Uri.parse(
        'https://user.jobes24x7.com/api/outsideapis/job/employer-jobs/$userMainId',
      );
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final List<dynamic> data = decoded['data'];

          List<PostedJobModel> loadedJobs = [];
          for (var item in data) {
            final selectedFlow = item['selected_flow'] is Map
                ? item['selected_flow']
                : {};

            String dist = item['district']?.toString() ?? '';
            String state = item['state']?.toString() ?? '';
            String loc = dist.isNotEmpty
                ? (state.isNotEmpty ? '$dist, $state' : dist)
                : 'Not Specified';

            String salary = item['monthly_salary']?.toString() ?? '';
            String salaryRange = salary.isNotEmpty
                ? '$salary INR'
                : 'Not Specified';

            List<String> parsedSkills = [];
            if (item['skills'] != null && item['skills'] is List) {
              parsedSkills = List<String>.from(
                item['skills'].map((e) => e.toString()),
              );
            }

            loadedJobs.add(
              PostedJobModel(
                title: _getFirstValid([
                  item['job_title'],
                  item['job_role'],
                  selectedFlow['category'],
                ], 'Job Title'),
                company: _getFirstValid([item['organization_name']], 'Unknown'),
                department: _getFirstValid([
                  item['sector'],
                  selectedFlow['sector'],
                ], 'Not Specified'),
                location: loc,
                deadline: _getFirstValid([
                  item['deadline'],
                  item['application_deadline'],
                ], 'Not Specified'),
                status: _getFirstValid([item['status']], 'Active'),
                salaryRange: salaryRange,
                vacancies: _getFirstValid([
                  item['openings'],
                  item['vacancies'],
                ], '1 Opening'),
                category: _getFirstValid([
                  item['primary_category_name'],
                  selectedFlow['category'],
                ], 'Not Specified'),
                type: _getFirstValid([
                  item['job_type'],
                  selectedFlow['employmentType'],
                ], 'Full-time'),
                experience: _getFirstValid([
                  item['experience'],
                ], 'Not Specified'),
                postedDate:
                    item['created_at']?.toString().split('T').first ??
                    'Not Specified',
                description: _getFirstValid([
                  item['job_description'],
                ], 'No description available'),
                skills: parsedSkills,
              ),
            );
          }

          if (mounted) {
            setState(() {
              _jobs = loadedJobs;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching posted jobs: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _totalPages => (_jobs.length / _showEntries).ceil();

  List<PostedJobModel> get _paginatedJobs {
    final startIndex = (_currentPage - 1) * _showEntries;
    final endIndex = startIndex + _showEntries;
    if (startIndex >= _jobs.length) return [];
    return _jobs.sublist(
      startIndex,
      endIndex > _jobs.length ? _jobs.length : endIndex,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Draft':
        return const Color(0xFFF59E0B);
      case 'Published':
        return const Color(0xFF10B981);
      case 'Closed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 768;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        title: Text(
          "Posted Jobs",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(isDark),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _jobs.isEmpty
                ? _buildEmptyState(isDark)
                : _buildTable(isDesktop, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              "No Posted Jobs",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't posted any jobs yet.",
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey[500],
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
          'Posted Jobs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage and view all your created job listings.",
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildTable(bool isDesktop, bool isDark) {
    final rows = _paginatedJobs;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show Entries Row
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: 16,
            ),
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
                              ? const Color(0xFF475569)
                              : const Color(0xFF8B5CF6),
                        ),
                        borderRadius: BorderRadius.circular(6),
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
                            fontWeight: FontWeight.w600,
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
                                _currentPage =
                                    1; // Reset to page 1 on limit change
                              });
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
                Container(
                  width: 200,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search jobs...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontally Scrollable Table Data
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < 900
                  ? 900.0
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.white,
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
                          children: const [
                            Expanded(flex: 2, child: _HeaderCell('JOB TITLE')),
                            Expanded(flex: 2, child: _HeaderCell('COMPANY')),
                            Expanded(flex: 2, child: _HeaderCell('DEPARTMENT')),
                            Expanded(flex: 2, child: _HeaderCell('LOCATION')),
                            Expanded(flex: 2, child: _HeaderCell('DEADLINE')),
                            Expanded(flex: 1, child: _HeaderCell('STATUS')),
                            Expanded(flex: 1, child: _HeaderCell('ACTIONS')),
                          ],
                        ),
                      ),

                      // Table Body
                      ...rows.map((job) {
                        final statusColor = _statusColor(job.status);
                        final borderColor = isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9);
                        final textColor = isDark
                            ? Colors.white
                            : const Color(0xFF1E293B);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: borderColor),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      job.type.split(' ').isNotEmpty
                                          ? job.type.split(' ')[0]
                                          : job.type,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  job.company,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  job.department,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        job.location,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  job.deadline,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _buildStatusPill(
                                    job.status,
                                    statusColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: _buildViewDetailsBtn(job, isDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Text(
                  'Showing ${rows.isEmpty ? 0 : (_currentPage - 1) * _showEntries + 1} to ${(_currentPage - 1) * _showEntries + rows.length} of ${_jobs.length} entries',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                _buildPagination(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildViewDetailsBtn(PostedJobModel job, bool isDark) {
    return InkWell(
      onTap: () => _showJobDetails(job),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E7FF), // light indigo
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye, size: 14, color: Color(0xFF4F46E5)),
            SizedBox(width: 4),
            Text(
              'View',
              style: TextStyle(
                color: Color(0xFF4F46E5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    List<Widget> pageButtons = [];

    // Prev Button
    pageButtons.add(
      _pageBtn(
        'Prev',
        enabled: _currentPage > 1,
        onTap: () {
          if (_currentPage > 1) {
            setState(() => _currentPage--);
          }
        },
      ),
    );
    pageButtons.add(const SizedBox(width: 4));

    // Page Numbers
    for (int i = 1; i <= _totalPages; i++) {
      bool isSelected = i == _currentPage;
      pageButtons.add(
        InkWell(
          onTap: () {
            setState(() => _currentPage = i);
          },
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              i.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
      pageButtons.add(const SizedBox(width: 4));
    }

    // Next Button
    pageButtons.add(
      _pageBtn(
        'Next',
        enabled: _currentPage < _totalPages,
        onTap: () {
          if (_currentPage < _totalPages) {
            setState(() => _currentPage++);
          }
        },
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: pageButtons,
    );
  }

  Widget _pageBtn(String label, {required bool enabled, VoidCallback? onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: enabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
    );
  }

  void _showJobDetails(PostedJobModel job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Container(
            width: 700,
            constraints: const BoxConstraints(maxHeight: 800),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Title "Job Details"
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 16,
                    top: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Job Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.black12,
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Subtitle Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.work,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${job.department} • ${job.location}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Wrap of Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoPill(
                              job.status,
                              null,
                              textColor: Colors.green,
                            ),
                            _buildInfoPill(
                              'Deadline: ${job.deadline}',
                              Icons.access_time,
                            ),
                            _buildInfoPill(
                              job.salaryRange,
                              Icons.monetization_on_outlined,
                            ),
                            _buildInfoPill(
                              '${job.vacancies}',
                              Icons.people_outline,
                            ),
                            _buildInfoPill(
                              job.category,
                              Icons.category_outlined,
                            ),
                            _buildInfoPill(job.type, Icons.work_outline),
                            _buildInfoPill(
                              'Exp: ${job.experience}',
                              Icons.school_outlined,
                            ),
                            _buildInfoPill(
                              'Posted: ${job.postedDate}',
                              Icons.calendar_today_outlined,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Job Description Section
                        Row(
                          children: [
                            const Icon(
                              Icons.description,
                              size: 18,
                              color: Color(0xFF4F46E5),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Job Description",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            job.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Required Skills Section
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Color(0xFF4F46E5),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Required Skills",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (job.skills.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: job.skills
                                .map(
                                  (skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E7FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      skill,
                                      style: const TextStyle(
                                        color: Color(0xFF4F46E5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        else
                          Text(
                            "No specific skills mentioned",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Edit Job',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoPill(String text, IconData? icon, {Color? textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  textColor ??
                  (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569)),
            ),
          ),
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
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }
}
