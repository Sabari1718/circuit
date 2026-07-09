import 'package:flutter/material.dart';
import 'business_user_model.dart';
import 'business_user_store.dart';
import 'business_registration_overview_page.dart';
import 'create_business_user_page.dart';
import 'business_upgrade_page.dart';
import 'assign_candidate_page.dart';
import 'select_registration_type_page.dart';
import 'create_partner_business_page.dart';
import 'create_supplier_business_page.dart';
import 'user_overview_page.dart';

import '../user_service.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'posted_jobs_page.dart';
import 'post_job_page.dart';
import 'applied_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/api_service.dart';

class BusinessCreatedPage extends ConsumerStatefulWidget {
  final bool showSelection;
  const BusinessCreatedPage({super.key, this.showSelection = false});

  @override
  ConsumerState<BusinessCreatedPage> createState() => _BusinessCreatedPageState();
}

class _BusinessCreatedPageState extends ConsumerState<BusinessCreatedPage> {
  bool _showRegTypeSelection = false;
  String? _selectedRegType;
  bool _isBusinessExpanded = true;
  bool _isJobsExpanded = false;
  
  bool _isLoadingBusinesses = true;
  List<BusinessUser> _apiBusinesses = [];
  String _userMainId = '';
  bool _isMainBusinessRegistered = false;

  @override
  void initState() {
    super.initState();
    _showRegTypeSelection = widget.showSelection;
    _fetchApiBusinesses();
  }

  Future<void> _fetchApiBusinesses() async {
    setState(() => _isLoadingBusinesses = true);
    final prefs = await SharedPreferences.getInstance();
    String userMainId = prefs.getString('user_main_id') ?? '';
    
    // 🚨 TEMP FIX: Override ghost user ID to fetch the correct dashboard data
    if (userMainId == '8059210846') {
      userMainId = '6102066450';
    }

    _userMainId = userMainId;
    _isMainBusinessRegistered = prefs.getBool('is_main_business_registered') ?? false;
    
    if (userMainId.isNotEmpty) {
      final res = await ApiService().getBusinesses(userMainId);
      if (mounted) {
        List<BusinessUser> loaded = [];
        List<dynamic> rawList = [];
        
        if (res is List) {
          rawList = res as List<dynamic>;
        } else if (res['data'] is List) {
          rawList = res['data'];
        } else if (res['data'] != null && res['data']['data'] is List) {
          rawList = res['data']['data'];
        } else if (res['data'] != null && res['data']['businesses'] is List) {
          rawList = res['data']['businesses'];
        } else if (res['businesses'] is List) {
          rawList = res['businesses'];
        } else if (res['business'] is List) {
          rawList = res['business'];
        } else if (res['business_list'] is List) {
          rawList = res['business_list'];
        }

        if (rawList.isNotEmpty) {
          for (var item in rawList) {
            try {
              loaded.add(BusinessUser.fromJson(item));
            } catch (e) {
              debugPrint('Error parsing business item: $e');
            }
          }
          debugPrint('[BusinessCreatedPage] rawList size: ${rawList.length}, parsed size: ${loaded.length}');
        } else {
          debugPrint('[BusinessCreatedPage] No data found in response: $res');
        }
        setState(() {
          _apiBusinesses = loaded;
        });
      }
    }
    if (mounted) {
      setState(() => _isLoadingBusinesses = false);
    }
  }

  Future<void> _handleDelete(BusinessUser biz) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business'),
        content: Text('Are you sure you want to delete ${biz.businessName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (mounted) setState(() => _isLoadingBusinesses = true);
    final res = await ApiService().deleteBusiness(biz.id);
    if (res['status'] == 'error') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to delete')),
        );
        setState(() => _isLoadingBusinesses = false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business deleted successfully')),
        );
        _fetchApiBusinesses();
      }
    }
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
        _fetchApiBusinesses();
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
        _fetchApiBusinesses();
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
        _fetchApiBusinesses();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final businesses = _apiBusinesses;
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
                          if (_isLoadingBusinesses)
                            const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (!_isMainBusinessRegistered && businesses.isEmpty)
                            _buildEmptyState(context, isDesktop)
                          else ...[
                            _buildHeaderSection(context, isDesktop),
                            const SizedBox(height: 24),
                            _buildVerificationBanner(),
                            const SizedBox(height: 24),
                            _buildAddNewBusinessCard(context),
                          ],
                          if (_showRegTypeSelection && !_isLoadingBusinesses) ...[
                            const SizedBox(height: 16),
                            _buildRegistrationTypeSelector(context),
                          ],
                          if (!_isLoadingBusinesses && businesses.isNotEmpty) ...[
                            if (businesses.isNotEmpty) ...[
                              const SizedBox(height: 32),
                              _buildYourBusinessesHeader(
                                "Your Businesses",
                                businesses.length,
                              ),
                              const SizedBox(height: 24),
                            ],
                          
                          if (businesses.any((b) => b.registrationType == 'Supplier')) ...[
                            _buildCategoryHeader(
                              context,
                              "Supplier Businesses",
                              businesses.where((b) => b.registrationType == 'Supplier').length,
                            ),
                            const SizedBox(height: 16),
                            ...businesses
                                .where((b) => b.registrationType == 'Supplier')
                                .map((biz) => _buildBusinessCard(context, biz, isDesktop))
                                .toList(),
                            const SizedBox(height: 24),
                          ],

                          if (businesses.any((b) => b.registrationType == 'Partner')) ...[
                            _buildCategoryHeader(
                              context,
                              "Partner Businesses",
                              businesses.where((b) => b.registrationType == 'Partner').length,
                            ),
                            const SizedBox(height: 16),
                            ...businesses
                                .where((b) => b.registrationType == 'Partner')
                                .map((biz) => _buildBusinessCard(context, biz, isDesktop))
                                .toList(),
                            const SizedBox(height: 24),
                          ],

                          if (businesses.any((b) => b.registrationType == 'Propagator' || b.registrationType == null)) ...[
                            _buildCategoryHeader(
                              context,
                              "Proprietor / Propagator Businesses",
                              businesses.where((b) => b.registrationType == 'Propagator' || b.registrationType == null).length,
                            ),
                            const SizedBox(height: 16),
                            ...businesses
                                .where((b) => b.registrationType == 'Propagator' || b.registrationType == null)
                                .map((biz) => _buildBusinessCard(context, biz, isDesktop))
                                .toList(),
                          ],
                          ], // Close else block
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

  Widget _buildEmptyState(BuildContext context, bool isDesktop) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<Map<String, String>>(
        future: UserService().getUserData(),
        builder: (context, snapshot) {
          final name = snapshot.data?['name']?.split(' ').first ?? 'Sabari';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome Back, $name! 👋", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text("Create a new business user account", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: isDesktop ? 600 : double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1), style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE11D48),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.business_center_rounded, color: Colors.white, size: 32),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Create New Business User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      const Text(
                        "Click the button below to start the registration process.\nYou'll need to provide business details and required documents",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BusinessUpgradePage(),
                            ),
                          ).then((_) {
                            _fetchApiBusinesses();
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        label: const Text("Create Business User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, size: 14, color: Color(0xFF94A3B8)),
                  SizedBox(width: 8),
                  Text("All information is encrypted and securely stored", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          );
        }
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
              onPressed: () => ref.read(themeProviderState).toggleTheme(),
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

  Widget _buildCategoryHeader(BuildContext context, String label, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        "$label ($count)",
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
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
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          if (biz.registrationType == 'Supplier') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CreateSupplierBusinessPage(existingBusiness: biz)),
                            ).then((_) => _fetchApiBusinesses());
                          } else if (biz.registrationType == 'Propagator' || biz.registrationType == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CreateBusinessUserPage(existingBusiness: biz)),
                            ).then((_) => _fetchApiBusinesses());
                          } else if (biz.registrationType == 'Partner') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CreatePartnerBusinessPage(existingBusiness: biz)),
                            ).then((_) => _fetchApiBusinesses());
                          }
                        } else if (value == 'delete') {
                           _handleDelete(biz);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
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
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48),
                            shape: BoxShape.circle,
                            image: biz.companyLogoFileName != null && biz.companyLogoFileName!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(biz.companyLogoFileName!.startsWith('http') 
                                      ? biz.companyLogoFileName! 
                                      : 'https://user.jobes24x7.com/${biz.companyLogoFileName}'),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: biz.companyLogoFileName != null && biz.companyLogoFileName!.isNotEmpty
                              ? null
                              : const Center(
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
          // ── Logo Header ──────────────────────────────────────────────────
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

          // ── Dashboard ────────────────────────────────────────────────────
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
          const SizedBox(height: 4),

          // ── Business (toggleable expandable) ────────────────────────────
          _buildBusinessExpansion(context, isDrawer: isDrawer, pinkColor: pinkColor),
          const SizedBox(height: 4),

          // ── Jobs (expandable) ────────────────────────────────────────────
          _buildJobsExpansion(context, isDrawer: isDrawer),
          const SizedBox(height: 8),

          // ── Switch Portal ────────────────────────────────────────────────
          _sidebarItem(
            Icons.swap_horiz_rounded,
            "Switch Portal",
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              // Small delay so drawer closes cleanly before popping
              Future.delayed(const Duration(milliseconds: 220), () {
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  /// Toggleable Business section with sub-items
  Widget _buildBusinessExpansion(
    BuildContext context, {
    required bool isDrawer,
    required Color pinkColor,
  }) {
    return Column(
      children: [
        // ── Business header pill ─────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: _isBusinessExpanded ? Colors.white : Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.business_center_outlined,
              color: _isBusinessExpanded
                  ? const Color(0xFF1E293B)
                  : Colors.white60,
              size: 20,
            ),
            title: Text(
              "Business",
              style: TextStyle(
                color: _isBusinessExpanded
                    ? const Color(0xFF1E293B)
                    : Colors.white60,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimatedRotation(
                turns: _isBusinessExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _isBusinessExpanded
                      ? const Color(0xFF1E293B)
                      : Colors.white38,
                  size: 20,
                ),
              ),
            ),
            dense: true,
            onTap: () => setState(() => _isBusinessExpanded = !_isBusinessExpanded),
          ),
        ),

        // ── Sub-items (animated) ─────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          crossFadeState: _isBusinessExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              const SizedBox(height: 4),
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
                    MaterialPageRoute(
                        builder: (context) => const UserOverviewPage()),
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
            ],
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  /// Expandable Jobs section with Post Job / View Posted Jobs / Applied Candidates
  Widget _buildJobsExpansion(BuildContext context, {required bool isDrawer}) {
    return Column(
      children: [
        // ── Jobs header ──────────────────────────────────────────────
        ListTile(
          leading: const Icon(Icons.work_outline_rounded,
              color: Colors.white60, size: 20),
          title: const Text(
            "Jobs",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          trailing: AnimatedRotation(
            turns: _isJobsExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white38, size: 20),
          ),
          dense: true,
          onTap: () => setState(() => _isJobsExpanded = !_isJobsExpanded),
        ),

        // ── Sub-items (animated) ──────────────────────────────────────
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          firstCurve: Curves.easeInOut,
          secondCurve: Curves.easeInOut,
          crossFadeState: _isJobsExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            children: [
              const SizedBox(height: 2),

              _sidebarSubItem(
                "View Posted Jobs",
                onTap: () {
                  _openPostedJobs(context, isDrawer: isDrawer);
                },
              ),
              _sidebarSubItem(
                "Applied Candidates",
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 220), () {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AppliedListPage(isBusinessMode: true)),
                    );
                  });
                },
              ),
              _sidebarSubItem(
                "Assign Candidate",
                onTap: () {
                  if (isDrawer) Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 220), () {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AssignCandidatePage()),
                    );
                  });
                },
              ),
            ],
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
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