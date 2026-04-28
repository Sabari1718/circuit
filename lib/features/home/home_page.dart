import 'package:flutter/material.dart';
import 'package:circuit/features/upgrade/business_welcome_page.dart';
import 'package:circuit/features/business/register_user_page.dart';
import 'package:circuit/features/upgrade/employee_upgrade_page.dart';
import 'package:circuit/core/services/user_service.dart';
import 'package:circuit/widgets/common_dashboard_app_bar.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUserName = widget.userName;
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    await UserService().loadSession();
    final data = await UserService().getUserData();
    if (mounted) {
      setState(() {
        _currentUserName = (data['name'] ?? widget.userName).trim().isEmpty
            ? widget.userName
            : data['name']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 24),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
              children: [
                _buildUpgradeCard(
                  "💼",
                  "BUSINESS",
                  "Analytics & Team tools",
                  const Color(0xFF8B5CF6),
                ),
                _buildUpgradeCard(
                  "📝",
                  "REGISTERED",
                  "Standard features",
                  const Color(0xFF3B82F6),
                ),
                _buildUpgradeCard(
                  "✅",
                  "VERIFIED",
                  "Priority support",
                  const Color(0xFF10B981),
                ),
                _buildUpgradeCard(
                  "⭐",
                  "PREMIUM",
                  "Exclusive benefits",
                  const Color(0xFFF59E0B),
                ),
              ],
            ),

            const SizedBox(height: 28),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
              children: [
                _buildUpgradeCard(
                  "🛕",
                  "KOVIL",
                  "TEMPLE",
                  const Color(0xFF7C3AED),
                ),
                _buildUpgradeCard(
                  "👥",
                  "SOCIAL",
                  "SOCIAL NETWORK",
                  const Color(0xFF3B82F6),
                ),
                _buildUpgradeCard(
                  "🏠",
                  "REAL ESTATE",
                  "PROPERTY",
                  const Color(0xFF10B981),
                ),
                _buildUpgradeCard(
                  "📋",
                  "EMPLOYEE",
                  "USER",
                  const Color(0xFF64748B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return ListenableBuilder(
      listenable: UserService(),
      builder: (context, _) {
        return FutureBuilder<Map<String, String>>(
          future: UserService().getUserData(),
          builder: (context, snapshot) {
            final savedName = snapshot.data?['name']?.trim() ?? '';
            final displayName = savedName.isNotEmpty ? savedName : _currentUserName;

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      const Text(
                        "🚀",
                        style: TextStyle(fontSize: 28),
                      ),
                      const Text(
                        "Welcome back,",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "$displayName!",
                        style: const TextStyle(
                          color: Color(0xFFFACC15),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      "✨ You're currently a guest user. Choose any account type below to upgrade and unlock more features!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpgradeCard(
      String emoji,
      String title,
      String desc,
      Color color, {
        String? buttonText,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (title == "BUSINESS") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BusinessWelcomePage(),
                    ),
                  );
                } else if (title == "REGISTERED") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterUserPage(),
                    ),
                  );
                } else if (title == "EMPLOYEE") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeeUpgradePage(),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                buttonText ?? "Upgrade to $title",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}