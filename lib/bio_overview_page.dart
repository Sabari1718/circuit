import 'package:flutter/material.dart';
import 'widgets/common_dashboard_app_bar.dart';
import 'sidebar_menu.dart';
import 'user_service.dart';

class BioOverviewPage extends StatefulWidget {
  final String initialSection;
  final bool showMenuOnlyOnMobile;

  const BioOverviewPage({
    super.key,
    this.initialSection = 'bio_overview',
    this.showMenuOnlyOnMobile = true,
  });

  @override
  State<BioOverviewPage> createState() => _BioOverviewPageState();
}

class _BioOverviewPageState extends State<BioOverviewPage> {
  late String _currentSection;
  Map<String, String> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await UserService().loadSession();
    final data = await UserService().getUserData();
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  String _getSectionTitle(String section) {
    switch (section) {
      case 'bio_overview':
        return 'Bio Overview';
      case 'authentication':
        return 'Authentication';
      case 's_tab':
        return 'S-Tab Settings';
      case 'verify':
        return 'Security Verification Status';
      default:
        return 'Security Portal';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: CommonDashboardAppBar(automaticallyImplyLeading: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      if (widget.showMenuOnlyOnMobile) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
          body: SidebarMenu(
            activeItem: '',
            onSectionChanged: (section) {
              // Not used on mobile as SidebarMenu handles push navigation internally
            },
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _getSectionTitle(_currentSection),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 18),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildContent(_currentSection),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarMenu(
            activeItem: _currentSection,
            onSectionChanged: (section) {
              setState(() {
                _currentSection = section;
              });
            },
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(_currentSection),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String section) {
    switch (section) {
      case 'bio_overview':
        return _buildBioOverview();
      case 'authentication':
        return _buildAuthentication();
      case 's_tab':
        return _buildSTab();
      case 'verify':
        return _buildVerify();
      default:
        return _buildBioOverview();
    }
  }

  Widget _buildBioOverview() {
    return Container(
      key: const ValueKey('bio_overview'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bio Overview",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.person_outline_rounded, "Full Name", _userData['name'] ?? 'Sabari'),
          _buildDetailItem(Icons.email_outlined, "Email Address", _userData['email'] ?? 'sabari@example.com'),
          _buildDetailItem(Icons.phone_iphone_rounded, "Phone Number", _userData['phone'] ?? '8012107626'),
          _buildDetailItem(Icons.location_on_outlined, "Residential Address", _userData['address'] ?? 'Not Provided'),
        ],
      ),
    );
  }

  Widget _buildAuthentication() {
    return Container(
      key: const ValueKey('authentication'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Authentication",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.security_outlined, "Authentication Level", "2-Factor Authentication Active"),
          _buildDetailItem(Icons.fingerprint_rounded, "Biometrics Lock", "Face ID & Pin Configured"),
          _buildDetailItem(Icons.phonelink_setup_rounded, "Registered Device", "Android Device (Pixel 7 Pro)"),
          _buildDetailItem(Icons.history_rounded, "Last Security Sync", "Today at 11:45 AM"),
        ],
      ),
    );
  }

  Widget _buildSTab() {
    return Container(
      key: const ValueKey('s_tab'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "S-Tab Settings",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.vpn_key_outlined, "S-Tab Security Key", "STAB-9508-3830-27XX"),
          _buildDetailItem(Icons.swap_horiz_rounded, "Connection Protocol", "TLS 1.3 Encryption Active"),
          _buildDetailItem(Icons.dns_outlined, "Gateway Server", "Secure UserPortal Node 4"),
          _buildDetailItem(Icons.verified_user_outlined, "Token Integrity", "Signature matches valid authority"),
        ],
      ),
    );
  }

  Widget _buildVerify() {
    return Container(
      key: const ValueKey('verify'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Security Verification Status",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.verified_rounded, "Account Verification Status", "Level 3 - Fully Verified"),
          _buildDetailItem(Icons.gpp_good_outlined, "Grid Verification Status", "Active and Validated"),
          _buildDetailItem(Icons.published_with_changes_rounded, "Session Timestamp", "2026-05-21 12:10 UTC"),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
