import 'package:flutter/material.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  bool _isUpgrading = false;

  @override
  Widget build(BuildContext context) {
    if (_isUpgrading) {
      return _EmployeeUpgradeView(onComplete: () => setState(() => _isUpgrading = false));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Employee Portal"), actions: [
        IconButton(icon: const Icon(Icons.upgrade), onPressed: () => setState(() => _isUpgrading = true)),
      ]),
      body: const Center(child: Text("Employee Dashboard - All your work data in one place.")),
    );
  }
}

class _EmployeeUpgradeView extends StatelessWidget {
  final VoidCallback onComplete;
  const _EmployeeUpgradeView({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade Employee Profile"), leading: IconButton(icon: const Icon(Icons.close), onPressed: onComplete)),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text("This is the consolidated Employee Upgrade flow.", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: "Highest Qualification")),
            TextField(decoration: InputDecoration(labelText: "Year of Passing")),
          ],
        ),
      ),
    );
  }
}
