import 'package:flutter/material.dart';
import 'business_user_model.dart';
import 'business_user_store.dart';
import 'business_registration_overview_page.dart';
import 'create_business_user_page.dart';
import 'select_registration_type_page.dart';
import 'create_partner_business_page.dart';
import 'create_supplier_business_page.dart';
import 'user_overview_page.dart';

import '../user_service.dart';
import '../theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'posted_jobs_page.dart';


class BusinessCreatedPage extends StatefulWidget {
  final bool showSelection;
  const BusinessCreatedPage({super.key, this.showSelection = false});

  @override
  State<BusinessCreatedPage> createState() => _BusinessCreatedPageState();
}

class _BusinessCreatedPageState extends State<BusinessCreatedPage> {
  bool _showRegTypeSelection = false;
  String? _selectedRegType;

  @override
  void initState() {
    super.initState();
    _showRegTypeSelection = widget.showSelection;
  }

  final List<Map<String, dynamic>> _regTypes = [
    {
      "title": "Propagator",
      "icon": Icons.hub_rounded,
      "color": const Color(0xFF8B5CF6)
    },
    {
      "title": "Partner",
      "icon": Icons.handshake_rounded,
      "color": const Color(0xFF3B82F6)
    },
    {
      "title": "Create Supplier",
      "icon": Icons.inventory_2_rounded,
      "color": const Color(0xFFE11D48)
    },
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.month}/${date.day}/${date.year}";
  }

  void _openDetails(BuildContext context, BusinessUser biz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessRegistrationOverviewPage(business: biz),
      ),
    );
  }

  void _openPostedJobs(BuildContext context, {required bool isDrawer}) {
    final navigator = Navigator.of(context);

    if (isDrawer) {
      navigator.pop();
    }

    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PostedJobsPage(),
        ),
      );
    });
  }

  void _startRegistration(BuildContext context, String type) {
    if (type == "Partner") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreatePartnerBusinessPage(),
        ),
      ).then((_) {
        setState(() {
          _showRegTypeSelection = false;
          _selectedRegType = null;
        });
      });
    } else if (type == "Propagator") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateBusinessUserPage(),
        ),
      ).then((_) {
        setState(() {
          _showRegTypeSelection = false;
          _selectedRegType = null;
        });
      });
    } else if (type == "Create Supplier") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateSupplierBusinessPage(),
        ),
      ).then((_) {
        setState(() {
          _showRegTypeSelection = false;
          _selectedRegType = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final businesses = BusinessUserStore().businesses;
    final bool isDesktop = MediaQuery.of(context).size.width > 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      drawer: !isDesktop
          ? Drawer(
        elevation: 0,
        child: _buildSidebar(context, isDrawer: true),
      )
          : null,
      body: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) _buildSidebar(context, isDrawer: false),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(context, isDesktop),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 32 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(context, isDesktop),
                          const SizedBox(height: 24),
                          _buildVerificationBanner(),
                          const SizedBox(height: 24),
                          _buildAddNewBusinessCard(context),
                          if (_showRegTypeSelection) ...[
                            const SizedBox(height: 16),
                            _buildRegistrationTypeSelector(context),
                          ],
                          if (businesses.any((b) =>
                          b.registrationType == 'Propagator' ||
                              b.registrationType == null)) ...[
                            const SizedBox(height: 32),
                            _buildYourBusinessesHeader(
                              "Your Businesses",
                              businesses
                                  .where((b) =>
                              b.registrationType == 'Propagator' ||
                                  b.registrationType == null)
                                  .length,
                            ),
                            const SizedBox(height: 20),
                            ...businesses
                                .where((b) =>
                            b.registrationType == 'Propagator' ||
                                b.registrationType == null)
                                .map((biz) =>
                                _buildBusinessCard(context, biz, isDesktop))
                                .toList(),
                          ],
                          if (businesses.any((b) => b.registrationType == 'Partner')) ...[
                            const SizedBox(height: 32),
                            _buildYourBusinessesHeader(
                              "Partner Businesses",
                              businesses
                                  .where((b) => b.registrationType == 'Partner')
                                  .length,
                            ),
                            const SizedBox(height: 20),
                            ...businesses
                                .where((b) => b.registrationType == 'Partner')
                                .map((biz) =>
                                _buildBusinessCard(context, biz, isDesktop))
                                .toList(),
                          ],
                          if (businesses.any((b) => b.registrationType == 'Supplier')) ...[
                            const SizedBox(height: 32),
                            _buildYourBusinessesHeader(
                              "Supplier Businesses",
                              businesses
                                  .where((b) => b.registrationType == 'Supplier')
                                  .length,
                            ),
                            const SizedBox(height: 20),
                            ...businesses
                                .where((b) => b.registrationType == 'Supplier')
                                .map((biz) =>
                                _buildBusinessCard(context, biz, isDesktop))
                                .toList(),
                          ],
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isDesktop ? 12 : topPadding + 6,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (buttonContext) => Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    size: 24,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  onPressed: () => Scaffold.of(buttonContext).openDrawer(),
                ),
              ),
            ),

          if (!isDesktop) const SizedBox(width: 10),
          if (isDesktop) const SizedBox(width: 8),

          Expanded(
            child: Container(
              height: 46,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: TextField(
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: "Search Voxo ..",
                  hintStyle: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          _topPlainIcon(
            Icons.notifications_none_outlined,
            isDark: isDark,
          ),

          const SizedBox(width: 6),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: isDark ? Colors.amber : const Color(0xFF1E293B),
                size: 22,
              ),
              onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
            ),
          ),

          const SizedBox(width: 8),
          _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Text(
          "S",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _topPlainIcon(
      IconData icon, {
        required bool isDark,
      }) =>
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          ),
        ),
        child: IconButton(
          icon: Icon(
            icon,
            size: 22,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          onPressed: () {},
        ),
      );

  Widget _buildHeaderSection(BuildContext context, bool isDesktop) {
    final biz =
    BusinessUserStore().businesses.isNotEmpty ? BusinessUserStore().businesses.first : null;

    return FutureBuilder<Map<String, String>>(
      future: UserService().getUserData(),
      builder: (context, snapshot) {
        final name = snapshot.data?['name'] ?? 'Sabari';

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "Welcome back, $name! 👋",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Your business will get a unique 10-digit ID: ",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              biz?.id ?? "9508383027",
                              style: const TextStyle(
                                color: Color(0xFF3B82F6),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final activeBiz = biz ?? BusinessUser(
                                  id: "9508383027",
                                  registrationType: "Propagator",
                                  businessName: "Sabari Voxo",
                                  email: "sabari@voxo.com",
                                  phone: "9508383027",
                                  panNumber: "ABCDE1234F",
                                  gstNumber: "22AAAAA1111A1Z5",
                                  accountNumber: "1234567890",
                                  bankDocType: "Bank Statement",
                                  doorNumber: "123",
                                  streetName: "Main Street",
                                  area: "Central Area",
                                  district: "Chennai",
                                  pincode: "600001",
                                  state: "Tamil Nadu",
                                  country: "India",
                                  businessTypes: ["IT", "Services"],
                                  yearOfEstablishment: "2024",
                                  employeeRange: "11-50",
                                  createdDate: DateTime.now(),
                                  status: "Active",
                                );
                                if (biz == null) {
                                  BusinessUserStore().addBusiness(activeBiz);
                                }
                                _openDetails(context, activeBiz);
                              },
                              child: const Text(
                                "(View/Edit Registration)",
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isDesktop)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: ElevatedButton(
                  onPressed: () => _startRegistration(context, 'propagator'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "# New Registration",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVerificationBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF9299D6).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  "Verification in Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Your business registration is under verify, so your business ID is still not created until then. You can create up to a maximum of 3 businesses.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewBusinessCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Ready to add a new business?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Click the button below to start the business registration process",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            width: 240,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showRegTypeSelection = !_showRegTypeSelection;
                });
              },
              icon: Icon(
                _showRegTypeSelection ? Icons.close : Icons.add_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                _showRegTypeSelection ? "Close Selection" : "Add New Business",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationTypeSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Registration Type",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Choose an option"),
                value: _selectedRegType,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _regTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                    value: type['title'],
                    child: Row(
                      children: [
                        Icon(type['icon'], color: type['color'], size: 20),
                        const SizedBox(width: 12),
                        Text(
                          type['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedRegType = val;
                  });
                  if (val != null) {
                    _startRegistration(context, val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourBusinessesHeader(String label, int count) {
    return Row(
      children: [
        const Icon(
          Icons.business_center_rounded,
          color: Color(0xFF3B82F6),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          "$label ($count)",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessCard(BuildContext context, BusinessUser biz, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 650;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Active",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "ID: ${biz.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE11D48),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                biz.businessName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: biz.businessTypes
                                    .map((t) => _buildTypeChip(t))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailsRows(biz, isSmall),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Added: ${_formatDate(biz.createdDate)}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _openDetails(context, biz),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE11D48)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                              color: Color(0xFFE11D48),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
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

  Widget _buildDetailsRows(BusinessUser biz, bool isSmall) {
    bool isPartner = biz.registrationType == 'Partner';

    final List<Widget> items = [
      _buildInfoLine(
        Icons.location_on_rounded,
        "${biz.doorNumber}, ${biz.streetName}, ${biz.area}",
      ),
      _buildInfoLine(Icons.email_rounded, biz.email),
      _buildInfoLine(Icons.phone_rounded, biz.phone),
      _buildInfoLine(
        Icons.history_rounded,
        "Est. ${biz.yearOfEstablishment} • ${biz.employeeRange} employees",
      ),
      _buildInfoLine(Icons.vpn_key_rounded, "PAN: ${biz.panNumber}"),
      _buildInfoLine(Icons.receipt_long_rounded, "GST: ${biz.gstNumber}"),
      if (isPartner)
        _buildInfoLine(Icons.groups_rounded, "Partners: ${biz.partnerCount}"),
    ];

    if (isSmall) {
      return Column(
        children: items
            .map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: w,
        ))
            .toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: items[0]),
            const SizedBox(width: 20),
            Expanded(child: items[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: items[2]),
            const SizedBox(width: 20),
            Expanded(child: items[3]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: items[4]),
            const SizedBox(width: 20),
            Expanded(child: items[5]),
          ],
        ),
        if (isPartner) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: items[6]),
              const SizedBox(width: 20),
              const Spacer(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoLine(IconData icon, String text) => Row(
    children: [
      Icon(
        icon,
        size: 13,
        color: const Color(0xFF94A3B8),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _buildTypeChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9).withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _buildSidebar(BuildContext context, {required bool isDrawer}) {
    final pinkColor = const Color(0xFFE11D48);
    return Container(
      width: 250,
      height: double.infinity,
      color: const Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: isDrawer ? 40 : 48,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      "90×25",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFFE11D48),
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.home_outlined,
            "Dashboard",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              setState(() {
                _showRegTypeSelection = false;
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.business_center_outlined,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              title: const Text(
                "Business",
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
              dense: true,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          _sidebarSubItem(
            "Business Overview",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              final businesses = BusinessUserStore().businesses;
              if (businesses.isNotEmpty) {
                _openDetails(context, businesses.first);
              }
            },
          ),
          _sidebarSubItem(
            "User Overview",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserOverviewPage()),
              );
            },
          ),
          _sidebarSubItem(
            "Add Business",
            textColor: pinkColor,
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              setState(() {
                _showRegTypeSelection = true;
              });
            },
          ),
          _sidebarSubItem(
            "Posted Jobs",
            onTap: () {
              _openPostedJobs(context, isDrawer: isDrawer);
            },
          ),
          const SizedBox(height: 8),
          _sidebarItem(
            Icons.widgets_outlined,
            "Switch Portal",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, {VoidCallback? onTap}) => ListTile(
        leading: Icon(icon, color: Colors.white60, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white60, fontSize: 14)),
        onTap: onTap,
        dense: true,
      );

  Widget _sidebarSubItem(String title, {Color? textColor, VoidCallback? onTap}) => ListTile(
        contentPadding: const EdgeInsets.only(left: 54),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "-",
              style: TextStyle(color: Colors.white30, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor ?? Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        onTap: onTap,
        dense: true,
      );

  Widget _topIcon(IconData icon, {String? badge}) => Stack(
    children: [
      IconButton(
        icon: Icon(icon, size: 22),
        onPressed: () {},
      ),
      if (badge != null)
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFE11D48),
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: const BoxConstraints(
              minWidth: 12,
              minHeight: 12,
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  );
}