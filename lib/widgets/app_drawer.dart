import 'package:flutter/material.dart';
import 'package:circuit/features/profile/profile_page.dart';
import 'package:circuit/features/employee/employee_page.dart';
import 'package:circuit/features/upgrade/business_created_page.dart';
import 'package:circuit/features/upgrade/business_upgrade_page.dart';
import 'package:circuit/core/services/api_service.dart';

import '../upgrade/business_created_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Sabari"),
            accountEmail: Text("sabari@example.com"),
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Text("S", style: TextStyle(color: Color(0xFFE11D48)))),
            decoration: BoxDecoration(color: Color(0xFFE11D48)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Home"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
          ListTile(
            leading: const Icon(Icons.business_center),
            title: const Text("My Businesses"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessCreatedPage())),
          ),
          ListTile(
            leading: const Icon(Icons.upgrade),
            title: const Text("Upgrade Business"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessUpgradePage())),
          ),
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text("Employee Portal"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmployeePage())),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => ApiService().logout().then((_) => Navigator.pushReplacementNamed(context, '/login')),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
