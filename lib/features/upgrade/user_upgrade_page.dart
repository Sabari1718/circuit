import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'verified_upgrade_intro_page.dart';
import 'verified_user_profile_page.dart';
import 'package:sva_business_user/upgrade/business_step3_page.dart';
import '../../upgrade/user_overview_page.dart';
import '../../user_service.dart' as legacy;

class UserUpgradePage extends StatefulWidget {
  const UserUpgradePage({super.key});

  @override
  State<UserUpgradePage> createState() => _UserUpgradePageState();
}

class _UserUpgradePageState extends State<UserUpgradePage> {
  bool _isVerified = false;
  bool _isRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userMainId = prefs.getString('user_main_id') ?? '';
      if (userMainId.isNotEmpty) {
        // Fetch both VERIFIED and REGISTERED status from DB (cross-device sync)
        final results = await Future.wait([
          legacy.UserService().checkVerificationStatus(userMainId),
          legacy.UserService().checkUserRegisterStatus(userMainId),
        ]);
        if (mounted) {
          setState(() {
            _isVerified = results[0];
            _isRegistered = results[1];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "User Privilege",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _isVerified ? const Color(0xFF10B981) : const Color(0xFFFF4D8D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(_isVerified ? Icons.verified : Icons.auto_awesome, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isVerified
                                  ? "You're a Verified User! Enjoy priority support and verified badge benefits."
                                  : "You're currently a guest user. Choose any account type below to upgrade and unlock more features!",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Responsive Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 900
                            ? 4
                            : (constraints.maxWidth > 600 ? 2 : 2);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) => _buildUpgradeCard(context, index),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context, int index) {
    final List<Map<String, dynamic>> data = [
      {
        "title": "REGISTERED",
        "subtitle": "USER",
        "icon": Icons.assignment_ind_rounded,
        "iconColor": const Color(0xFF6366F1),
        "iconBg": const Color(0xFFEEF2FF),
        "description": "Full access to standard features & profile management",
        "btnText": "Upgrade to REGISTERED",
        "isActive": _isRegistered, // ← API-driven from DB
      },
      {
        "title": "BUSINESS",
        "subtitle": "USER",
        "icon": Icons.business_center_rounded,
        "iconColor": const Color(0xFF0EA5E9),
        "iconBg": const Color(0xFFE0F2FE),
        "description": "Access to business analytics & team management",
        "btnText": "Upgrade to BUSINESS",
        "isActive": false,
      },
      {
        "title": "VERIFIED",
        "subtitle": "USER",
        "icon": Icons.verified_rounded,
        "iconColor": const Color(0xFF10B981),
        "iconBg": const Color(0xFFD1FAE5),
        "description": "Verified badge & priority support",
        "btnText": "Upgrade to VERIFIED",
        "isActive": _isVerified,
      },
      {
        "title": "PREMIUM",
        "subtitle": "USER",
        "icon": Icons.stars_rounded,
        "iconColor": const Color(0xFFF59E0B),
        "iconBg": const Color(0xFFFEF3C7),
        "description": "All features + exclusive benefits",
        "btnText": "Upgrade to PREMIUM",
        "isActive": false,
      },
    ];

    final item = data[index];
    final bool isActive = item['isActive'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981).withOpacity(0.4) : Colors.grey.withOpacity(0.12),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(0xFF10B981).withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Active badge
          if (isActive)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          const SizedBox(height: 8),

          // Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: item['iconBg'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'] as IconData, color: item['iconColor'] as Color, size: 28),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            item['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
          ),
          Text(
            item['subtitle'] as String,
            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Description
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const Spacer(),

          // Buttons
          if (isActive)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  if (item['title'] == 'VERIFIED') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VerifiedUserProfilePage()),
                    );
                  } else if (item['title'] == 'REGISTERED') {
                    // View registered user data from DB
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserOverviewPage(initialPage: 0),
                      ),
                    ).then((_) => _loadVerificationStatus());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  if (item['title'] == "REGISTERED") {
                    // Navigate to upgrade flow for registered user
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserOverviewPage(initialPage: 1),
                      ),
                    ).then((_) => _loadVerificationStatus());
                  } else if (item['title'] == "VERIFIED") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VerifiedUpgradeIntroPage()),
                    ).then((_) => _loadVerificationStatus());
                  } else if (item['title'] == "BUSINESS") {
                    if (_isVerified) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BusinessStep3Page()),
                      );
                    } else {
                      _showVerificationDialog(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                  item['btnText'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Details', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
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
                decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                child: const Icon(Icons.shield, color: Color(0xFFD97706), size: 48),
              ),
              const SizedBox(height: 24),
              const Text("Verification Required",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              const Text(
                "To register as a Business User, you must first complete your Verified User Registration (Identity & PAN verification).\nPlease verify your identity before accessing the Business portal.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const VerifiedUpgradeIntroPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text("Go to Verified User Registration",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: const Text("Back to Dashboard",
                    style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
