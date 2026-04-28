import 'package:flutter/material.dart';
import 'package:circuit/core/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  final _nameCtrl = TextEditingController(text: "Sabari");
  final _emailCtrl = TextEditingController(text: "sabari@example.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("User Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? "Save" : "Edit", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFFE11D48), child: Text("S", style: TextStyle(fontSize: 32, color: Colors.white))),
            const SizedBox(height: 32),
            _profileField("Full Name", _nameCtrl, _isEditing),
            const SizedBox(height: 16),
            _profileField("Email Address", _emailCtrl, _isEditing),
            const SizedBox(height: 48),
            if (!_isEditing) ElevatedButton(
              onPressed: () => ApiService().logout().then((_) => Navigator.pushReplacementNamed(context, '/login')),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.red),
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileField(String label, TextEditingController ctrl, bool enabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: ctrl, enabled: enabled, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      ],
    );
  }
}
