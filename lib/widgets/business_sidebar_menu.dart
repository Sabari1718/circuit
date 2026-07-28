import 'package:flutter/material.dart';
import '../upgrade/posted_jobs_page.dart';
import '../upgrade/applied_list_page.dart';
import '../upgrade/assign_candidate_page.dart';

class BusinessSidebarMenu extends StatefulWidget {
  final String activeItem;
  final Function(String)? onSectionChanged;

  const BusinessSidebarMenu({
    super.key,
    required this.activeItem,
    this.onSectionChanged,
  });

  @override
  State<BusinessSidebarMenu> createState() => _BusinessSidebarMenuState();
}

class _BusinessSidebarMenuState extends State<BusinessSidebarMenu> with TickerProviderStateMixin {
  late AnimationController _businessAnimCtrl;
  late AnimationController _storeAnimCtrl;
  late AnimationController _jobsAnimCtrl;

  late Animation<double> _businessAnim;
  late Animation<double> _storeAnim;
  late Animation<double> _jobsAnim;

  bool _isBusinessExpanded = false;
  bool _isStoreExpanded = false;
  bool _isJobsExpanded = false;

  @override
  void initState() {
    super.initState();
    _businessAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _storeAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _jobsAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));

    _businessAnim = CurvedAnimation(parent: _businessAnimCtrl, curve: Curves.easeInOut);
    _storeAnim = CurvedAnimation(parent: _storeAnimCtrl, curve: Curves.easeInOut);
    _jobsAnim = CurvedAnimation(parent: _jobsAnimCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _businessAnimCtrl.dispose();
    _storeAnimCtrl.dispose();
    _jobsAnimCtrl.dispose();
    super.dispose();
  }

  void _toggleSection(String section) {
    setState(() {
      if (section == 'business') {
        _isBusinessExpanded = !_isBusinessExpanded;
        _isBusinessExpanded ? _businessAnimCtrl.forward() : _businessAnimCtrl.reverse();
      } else if (section == 'store') {
        _isStoreExpanded = !_isStoreExpanded;
        _isStoreExpanded ? _storeAnimCtrl.forward() : _storeAnimCtrl.reverse();
      } else if (section == 'jobs') {
        _isJobsExpanded = !_isJobsExpanded;
        _isJobsExpanded ? _jobsAnimCtrl.forward() : _jobsAnimCtrl.reverse();
      }
    });
  }

  void _handleItemTap(String item) {
    if (widget.onSectionChanged != null) {
      widget.onSectionChanged!(item);
    } else {
      // Default navigation
      if (item == 'view_posted_jobs') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PostedJobsPage()));
      } else if (item == 'applied_candidates') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppliedListPage()));
      } else if (item == 'assign_candidate') {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignCandidatePage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2563EB);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: isMobile ? double.infinity : 250,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App name / header area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.grid_view_rounded, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "App name",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Switch Portal Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  // dash pattern not natively supported in border without custom painter, simple border is fine
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view_outlined, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Switch Portal",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              children: [
                _buildExpandableSection(
                  title: "Business",
                  icon: Icons.business_center_outlined,
                  isExpanded: _isBusinessExpanded,
                  animation: _businessAnim,
                  animationCtrl: _businessAnimCtrl,
                  onToggle: () => _toggleSection('business'),
                  children: [
                    _buildSubMenuItem(title: "Business Overview", id: "business_overview", isActive: widget.activeItem == 'business_overview'),
                    _buildSubMenuItem(title: "Add Business", id: "add_business", isActive: widget.activeItem == 'add_business'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildExpandableSection(
                  title: "Store",
                  icon: Icons.storefront_outlined,
                  isExpanded: _isStoreExpanded,
                  animation: _storeAnim,
                  animationCtrl: _storeAnimCtrl,
                  onToggle: () => _toggleSection('store'),
                  children: [
                    _buildSubMenuItem(title: "Create Store Category", id: "create_store_category", isActive: widget.activeItem == 'create_store_category'),
                    _buildSubMenuItem(title: "Create Store", id: "create_store", isActive: widget.activeItem == 'create_store'),
                  ],
                ),
                const SizedBox(height: 8),
                _buildExpandableSection(
                  title: "Business Jobs",
                  icon: Icons.work_outline_rounded,
                  isExpanded: _isJobsExpanded,
                  animation: _jobsAnim,
                  animationCtrl: _jobsAnimCtrl,
                  onToggle: () => _toggleSection('jobs'),
                  children: [
                    _buildSubMenuItem(title: "Post Job", id: "post_job", isActive: widget.activeItem == 'post_job'),
                    _buildSubMenuItem(title: "View Posted Jobs", id: "view_posted_jobs", isActive: widget.activeItem == 'view_posted_jobs'),
                    _buildSubMenuItem(title: "Applied Candidates", id: "applied_candidates", isActive: widget.activeItem == 'applied_candidates'),
                    _buildSubMenuItem(title: "Assign Candidate", id: "assign_candidate", isActive: widget.activeItem == 'assign_candidate'),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Bottom Logout
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required Animation<double> animation,
    required AnimationController animationCtrl,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.grey[600], size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 0.25).animate(animationCtrl),
                  child: const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: animation,
          child: Padding(
            padding: const EdgeInsets.only(left: 22, top: 4, bottom: 4),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
              ),
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubMenuItem({
    required String title,
    required String id,
    required bool isActive,
  }) {
    final Color itemColor = isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B);
    return InkWell(
      onTap: () => _handleItemTap(id),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB).withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
