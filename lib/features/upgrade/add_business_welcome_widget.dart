import 'package:flutter/material.dart';

class AddBusinessWelcomeWidget extends StatefulWidget {
  final Function(String) onRegistrationTypeSelected;

  const AddBusinessWelcomeWidget({
    super.key,
    required this.onRegistrationTypeSelected,
  });

  @override
  State<AddBusinessWelcomeWidget> createState() => _AddBusinessWelcomeWidgetState();
}

class _AddBusinessWelcomeWidgetState extends State<AddBusinessWelcomeWidget> {
  bool _showDropdown = false;
  String _selectedType = '-- Select Registration Type --';
  final List<String> _types = [
    '-- Select Registration Type --',
    'Propagator',
    'Partner',
    'Create Supplier'
  ];

  @override
  Widget build(BuildContext context) {
    if (_showDropdown) {
      return _buildDropdownCard();
    } else {
      return _buildWelcomeBanner();
    }
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1), // Indigo
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        "Welcome Back, !",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("👋", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // Light blue
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info_outline, size: 14, color: Color(0xFF2563EB)),
                        SizedBox(width: 6),
                        Text(
                          "Business ID: ---",
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showDropdown = true;
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Create Your First Business", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Red
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Registration Type",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showDropdown = false;
                        _selectedType = _types[0];
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose how you want to register your business",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedType,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                        items: _types.map((String type) {
                          bool isSelected = _selectedType == type;
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Container(
                              width: double.infinity,
                              color: isSelected ? Colors.grey.shade200 : Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                type,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null && val != _types[0]) {
                            setState(() {
                              _selectedType = val;
                            });
                            // Trigger callback
                            widget.onRegistrationTypeSelected(val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
