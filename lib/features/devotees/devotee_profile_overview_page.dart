import 'package:flutter/material.dart';

class DevoteeProfileData {
  final String name;
  final String? gender;
  final String? age;
  final String? religion;
  final Set<String> categories;
  final String? community;
  final String? subCommunity;
  final String? kulam;

  final String? addressType;
  final String? propertyType;
  final String? doorNumber;
  final String? streetName;
  final String? buildingName;
  final String? landmark;
  final String? area;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;

  DevoteeProfileData({
    required this.name,
    this.gender,
    this.age,
    this.religion,
    required this.categories,
    this.community,
    this.subCommunity,
    this.kulam,
    this.addressType,
    this.propertyType,
    this.doorNumber,
    this.streetName,
    this.buildingName,
    this.landmark,
    this.area,
    this.city,
    this.state,
    this.pincode,
    this.country,
  });
}

class DevoteeProfileOverviewPage extends StatelessWidget {
  final DevoteeProfileData data;

  const DevoteeProfileOverviewPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "App name",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Devotee Profile Overview",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Your submitted devotee and spiritual onboarding details",
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text("Back to Portals", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Blue Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D4ED8), // Deep blue banner
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Active Spiritual Registration",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Status: Registered Devotee",
                            style: TextStyle(color: Colors.blue.shade100, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.clean_hands, color: Colors.white, size: 32),
                    ),
                  ],
                ),
              ),

              // The two main cards container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Stack vertically on mobile, side-by-side on desktop
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPersonalProfileCard()),
                          const SizedBox(width: 32),
                          Expanded(child: _buildAddressDetailsCard()),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPersonalProfileCard(),
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 32),
                          _buildAddressDetailsCard(),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalProfileCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.person_pin_outlined, color: Color(0xFF3B82F6), size: 20),
            SizedBox(width: 8),
            Text(
              "Spiritual & Personal Profile",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Full Name"),
        Text(data.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Gender"),
                  Text(data.gender ?? "-", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Age"),
                  Text("${data.age ?? "-"} Years", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Religion"),
        if (data.religion != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.religion!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          )
        else
          const Text("-"),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Devotee Tradition / Category"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: data.categories.isEmpty 
              ? [const Text("-")]
              : data.categories.map((cat) => _buildCategoryPill(cat)).toList(),
        ),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Community"),
        Text(data.community ?? "-", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Sub-Community"),
        Text(data.subCommunity ?? "-", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Kulam"),
        Text(data.kulam ?? "-", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildAddressDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.maps_home_work_outlined, color: Color(0xFF3B82F6), size: 20),
            SizedBox(width: 8),
            Text(
              "Registered Address Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Address Type"),
        Text(data.addressType ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Property Type"),
        if (data.propertyType != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4), // Cyan
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.propertyType!,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          )
        else
          const Text("-"),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        
        _buildSectionTitle("Full Address"),
        _buildDetailRow("Door No.:", data.doorNumber),
        _buildDetailRow("Street:", data.streetName),
        _buildDetailRow("Landmark:", data.landmark),
        _buildDetailRow("Area/Village:", data.area),
        _buildDetailRow("City/District:", data.city),
        _buildDetailRow("District:", data.city),
        _buildDetailRow("State:", data.state),
        _buildDetailRow("Country:", data.country),
        _buildDetailRow("Pincode:", data.pincode),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String category) {
    // Dynamic color mapping based on the category string (matching the screenshot styles)
    Color bgColor = Colors.orange.shade500;
    Color textColor = Colors.white;

    if (category.toLowerCase().contains("vaishnavam")) {
      bgColor = const Color(0xFF22C55E); // Green
    } else if (category.toLowerCase().contains("kaumaram")) {
      bgColor = const Color(0xFFA855F7); // Purple
    } else if (category.toLowerCase().contains("other")) {
      bgColor = const Color(0xFF3B82F6); // Blue
    } else if (category.toLowerCase().contains("siddha") || category.toLowerCase().contains("saivam")) {
      bgColor = const Color(0xFFD97706); // Dark Orange
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("🕉 ", style: TextStyle(fontSize: 12)),
          Text(
            category,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
