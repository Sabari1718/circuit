import 'package:flutter/material.dart';
import 'package:sva_business_user/features/upgrade/business_user_model.dart';
import 'package:sva_business_user/features/upgrade/business_user_store.dart';
import 'package:sva_business_user/features/business/business_creation_flow_page.dart';

class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key});

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> {
  final BusinessUserStore _store = BusinessUserStore();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final businesses = _store.businesses;
        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          appBar: AppBar(
            title: const Text(
              "Your Businesses",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_business, color: Color(0xFFE11D48)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BusinessCreationFlowPage(),
                  ),
                ),
              ),
            ],
          ),
          body: businesses.isEmpty
              ? _buildEmptyState()
              : _buildBusinessList(businesses),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.business_center_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            "No businesses found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Add your first business to get started"),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BusinessCreationFlowPage(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
            ),
            child: const Text(
              "Add New Business",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessList(List<BusinessUser> businesses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: businesses.length,
      itemBuilder: (context, index) {
        final biz = businesses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              biz.businessName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("ID: ${biz.id} • ${biz.registrationType}"),
            leading: CircleAvatar(
              backgroundColor: _getColor(biz.registrationType),
              child: const Icon(Icons.business, color: Colors.white),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.email, biz.email),
                    _infoRow(Icons.phone, biz.phone),
                    _infoRow(Icons.location_on, "${biz.area}, ${biz.district}"),
                    _infoRow(Icons.vpn_key, "PAN: ${biz.panNumber}"),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text("Edit Details"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("View Full Overview"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );

  Color _getColor(String? type) {
    switch (type) {
      case 'Propagator':
        return const Color(0xFF8B5CF6);
      case 'Partner':
        return const Color(0xFF3B82F6);
      case 'Supplier':
        return const Color(0xFFE11D48);
      default:
        return Colors.grey;
    }
  }
}

