import 'package:flutter/material.dart';
import 'verified_upgrade_intro_page.dart';

class UserUpgradePage extends StatelessWidget {
  const UserUpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Guest User Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D8D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You're currently a guest user. Choose any account type below to upgrade and unlock more features!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Desktop/Mobile Responsive Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = constraints.maxWidth > 900
                      ? 4
                      : (constraints.maxWidth > 600 ? 2 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return _buildUpgradeCard(context, index);
                    },
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
        "title": "BUSINESS",
        "icon": Icons.business_center_rounded,
        "description": "Access to business analytics & team management",
        "btnText": "Upgrade to BUSINESS",
        "route": "/business",
      },
      {
        "title": "REGISTERED",
        "icon": Icons.assignment_ind_rounded,
        "description": "Full access to standard features & profile management",
        "btnText": "Upgrade to REGISTERED",
      },
      {
        "title": "VERIFIED",
        "icon": Icons.verified_rounded,
        "description": "Verified badge & priority support",
        "btnText": "Upgrade to VERIFIED",
      },
      {
        "title": "PREMIUM",
        "icon": Icons.stars_rounded,
        "description": "All features + exclusive benefits",
        "btnText": "Upgrade to PREMIUM",
      },
    ];

    final item = data[index];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'], color: Colors.grey[600], size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            item['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1E293B),
            ),
          ),
          const Text(
            "USER",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item['description'],
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (item['title'] == "BUSINESS") {
                Navigator.pushNamed(context, '/business');
              } else if (item['title'] == "VERIFIED") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerifiedUpgradeIntroPage(),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              item['btnText'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
