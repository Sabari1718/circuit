import 'package:flutter/material.dart';
import 'apply_job_page.dart';
import 'applied_list_page.dart';

class JobModel {
  final String initials;
  final Color avatarColor;
  final String title;
  final String company;
  final String type;
  final String description;
  final String location;
  final String salary;
  final String postedAgo;
  final bool isContract;

  const JobModel({
    required this.initials,
    required this.avatarColor,
    required this.title,
    required this.company,
    required this.type,
    required this.description,
    required this.location,
    required this.salary,
    required this.postedAgo,
    this.isContract = false,
  });
}

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  bool _isApplyJobExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<JobModel> _allJobs = const [
    JobModel(
      initials: 'TN',
      avatarColor: Color(0xFF4F46E5),
      title: 'Senior Frontend Engineer',
      company: 'TechNova Solutions',
      type: 'Full-time',
      description:
          'Looking for an experienced React developer to lead our frontend architecture and build scalable web applications.',
      location: 'San Francisco, CA',
      salary: '\$120k - \$150k',
      postedAgo: 'Posted 2 days ago',
    ),
    JobModel(
      initials: 'ED',
      avatarColor: Color(0xFF10B981),
      title: 'Backend Developer (Node.js)',
      company: 'EcoDrive Auto',
      type: 'Full-time',
      description:
          'Join our core team to build robust APIs and microservices powering next-generation automotive software.',
      location: 'Austin, TX',
      salary: '\$110k - \$140k',
      postedAgo: 'Posted 5 days ago',
    ),
    JobModel(
      initials: 'FC',
      avatarColor: Color(0xFFF59E0B),
      title: 'UI/UX Designer',
      company: 'FinCore Financial',
      type: 'Contract',
      description:
          'Design modern, intuitive interfaces for our fintech platforms. Must have strong portfolio with finance apps.',
      location: 'New York, NY',
      salary: '\$80k - \$100k',
      postedAgo: 'Posted 1 week ago',
      isContract: true,
    ),
    JobModel(
      initials: 'HS',
      avatarColor: Color(0xFFEF4444),
      title: 'Cloud Infrastructure Architect',
      company: 'HealthSync',
      type: 'Full-time',
      description:
          'Design and manage secure, HIPAA-compliant cloud infrastructure for our healthcare data platform.',
      location: 'Boston, MA',
      salary: '\$140k - \$180k',
      postedAgo: 'Posted 3 days ago',
    ),
    JobModel(
      initials: 'DL',
      avatarColor: Color(0xFF8B5CF6),
      title: 'Commercial Driver',
      company: 'DriveLine Logistics',
      type: 'Full-time',
      description:
          'Experienced HMV driver needed for inter-state freight transport. Valid commercial license required.',
      location: 'Chennai, TN',
      salary: '₹35k - ₹50k',
      postedAgo: 'Posted 1 day ago',
    ),
    JobModel(
      initials: 'RC',
      avatarColor: Color(0xFF0EA5E9),
      title: 'Fleet Driver',
      company: 'RapidCargo',
      type: 'Full-time',
      description:
          'Looking for reliable LMV drivers to join our growing fleet operations across Tamil Nadu.',
      location: 'Coimbatore, TN',
      salary: '₹20k - ₹28k',
      postedAgo: 'Posted 4 days ago',
    ),
  ];

  List<JobModel> get _filteredJobs {
    if (_searchQuery.isEmpty) return _allJobs;
    final q = _searchQuery.toLowerCase();
    return _allJobs
        .where((j) =>
            j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q) ||
            j.location.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToApply(JobModel job) {
    debugPrint('Apply Now clicked');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ApplyJobPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 1024;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
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
                        _buildPageHeader(),
                        const SizedBox(height: 24),
                        _buildJobGrid(isDesktop),
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
    return SafeArea(
      bottom: false,
      child: Container(
        height: isDesktop ? 70 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search jobs by title, company, or industry...',
                  hintStyle:
                      TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded,
                  color: Color(0xFF64748B), size: 24),
              Positioned(
                top: -2,
                right: -2,
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
            ],
          ),
          const SizedBox(width: 16),
          const Icon(Icons.dark_mode_outlined,
              color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFE2E8F0),
                  child: Icon(Icons.person,
                      color: Color(0xFF94A3B8), size: 18),
                ),
                SizedBox(width: 8),
                Text('Admin',
                    style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                        fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF64748B), size: 16),
                SizedBox(width: 4),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Jobs',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B)),
        ),
        SizedBox(height: 4),
        Text(
          'Discover and apply for your next great opportunity.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildJobGrid(bool isDesktop) {
    final jobs = _filteredJobs;
    if (jobs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Text('No jobs found.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
        ),
      );
    }

    if (isDesktop) {
      // 2-column grid for desktop
      final rows = <Widget>[];
      for (int i = 0; i < jobs.length; i += 2) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildJobCard(jobs[i])),
            const SizedBox(width: 16),
            i + 1 < jobs.length
                ? Expanded(child: _buildJobCard(jobs[i + 1]))
                : const Expanded(child: SizedBox()),
          ],
        ));
        rows.add(const SizedBox(height: 16));
      }
      return Column(children: rows);
    } else {
      return Column(
        children: jobs
            .map((j) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildJobCard(j),
                ))
            .toList(),
      );
    }
  }

  Widget _buildJobCard(JobModel job) {
    final typeColor =
        job.isContract ? const Color(0xFFF59E0B) : const Color(0xFF4F46E5);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: job.avatarColor,
                child: Text(
                  job.initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: typeColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: typeColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.type,
                            style: TextStyle(
                                color: typeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.visibility_outlined,
                  color: Color(0xFF94A3B8), size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            job.title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          Text(
            job.company,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Text(
            job.description,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF64748B), height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 4),
              Text(job.location,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(width: 16),
              const Icon(Icons.attach_money_rounded,
                  color: Color(0xFF94A3B8), size: 14),
              const SizedBox(width: 2),
              Text(job.salary,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: Color(0xFF94A3B8), size: 13),
              const SizedBox(width: 4),
              Text(job.postedAgo,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF94A3B8))),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _navigateToApply(job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Apply Now',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
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
                top: isDrawer ? 40 : 24, left: 24, right: 24, bottom: 24),
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
          _buildApplyJobExpansion(context, isDrawer: isDrawer, pinkColor: pinkColor, activeItem: 'job_list'),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title,
          {VoidCallback? onTap}) =>
      ListTile(
        leading: Icon(icon, color: Colors.white60, size: 20),
        title:
            Text(title, style: const TextStyle(color: Colors.white60, fontSize: 14)),
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
                    color: textColor ?? Colors.white60,
                    fontSize: 13)),
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
}
