import 'package:flutter/material.dart';
import 'package:circuit/features/business/create_business_user_page.dart';
import 'package:circuit/features/upgrade/create_partner_business_page.dart';
import 'package:circuit/features/upgrade/create_supplier_business_page.dart';

class SelectRegistrationTypePage extends StatefulWidget {
  const SelectRegistrationTypePage({super.key});

  @override
  State<SelectRegistrationTypePage> createState() => _SelectRegistrationTypePageState();
}

class _SelectRegistrationTypePageState extends State<SelectRegistrationTypePage> {
  String? _selectedType;

  final List<Map<String, dynamic>> _types = [
    {
      "title": "Propagator",
      "description": "Register as a business propagator to manage multiple sub-entities.",
      "icon": Icons.hub_rounded,
      "color": const Color(0xFF8B5CF6),
    },
    {
      "title": "Partner",
      "description": "Collaborate as a business partner with shared access.",
      "icon": Icons.handshake_rounded,
      "color": const Color(0xFF3B82F6),
    },
    {
      "title": "Create Supplier",
      "description": "Register as a supplier to provide goods or services.",
      "icon": Icons.inventory_2_rounded,
      "color": const Color(0xFFE11D48),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          "Select Registration Type",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose Business Type",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Select the type of business user you want to register as to continue.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Dropdown fallback if user wants it, but cards are better for premium UI.
                // However, user specifically mentioned "Dropdown options must include..."
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Select Registration Type"),
                      value: _selectedType,
                      items: _types.map((type) => DropdownMenuItem<String>(
                        value: type['title'],
                        child: Row(
                          children: [
                            Icon(type['icon'], color: type['color'], size: 20),
                            const SizedBox(width: 12),
                            Text(type['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) {
                        setState(() => _selectedType = val);
                        if (val == "Propagator") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateBusinessUserPage()),
                          );
                        } else if (val == "Partner") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CreatePartnerBusinessPage()),
                          );
                        } else if (val == "Create Supplier") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateSupplierBusinessPage()),
                          );
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Card based selection (Visual reinforcement)
                ..._types.map((type) => _buildTypeCard(type)).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(Map<String, dynamic> type) {
    bool isSelected = _selectedType == type['title'];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type['title']);
        if (type['title'] == "Propagator") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CreateBusinessUserPage()),
          );
        } else if (type['title'] == "Partner") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CreatePartnerBusinessPage()),
          );
        } else if (type['title'] == "Create Supplier") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CreateSupplierBusinessPage()),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? type['color'] : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? [BoxShadow(color: type['color'].withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: type['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(type['icon'], color: type['color'], size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? type['color'] : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['description'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isSelected ? type['color'] : const Color(0xFFCBD5E1),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
