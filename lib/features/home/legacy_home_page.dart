import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../employee/employee_page.dart';
import '../profile/legacy_profile_page.dart';
import '../upgrade/business_dashboard_page.dart';
import 'business_dashboard_page.dart';
import 'employee_page.dart';
import 'profile_page.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String email;
  const HomePage({super.key, required this.userName, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi, ${widget.userName}! 👋", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Welcome to your centralized portal", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _DashCard(title: "Business", icon: Icons.business_center, color: const Color(0xFFE11D48), onHover: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessDashboardPage()))),
                _DashCard(title: "Employee", icon: Icons.badge, color: const Color(0xFF3B82F6), onHover: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeePage()))),
                _DashCard(title: "Profile", icon: Icons.person, color: const Color(0xFF8B5CF6), onHover: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()))),
                _DashCard(title: "Settings", icon: Icons.settings, color: Colors.blueGrey, onHover: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onHover;
  const _DashCard({required this.title, required this.icon, required this.color, required this.onHover});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onHover,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
