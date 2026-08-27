import 'dart:math' as math;
import 'dart:ui';
import 'package:sva_business_user/services/stab_service.dart';
import 'package:flutter/material.dart';
import 'widgets/common_dashboard_app_bar.dart';
import 'sidebar_menu.dart';
import 'user_service.dart';
import 's_tab_auth_page.dart';
import 'stab_service.dart';

class BioOverviewPage extends StatefulWidget {
  final String initialSection;
  final bool showMenuOnlyOnMobile;

  const BioOverviewPage({
    super.key,
    this.initialSection = 'bio_overview',
    this.showMenuOnlyOnMobile = true,
  });

  @override
  State<BioOverviewPage> createState() => _BioOverviewPageState();
}

class _BioOverviewPageState extends State<BioOverviewPage> {
  late String _currentSection;
  Map<String, String> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await UserService().loadSession();
    final data = await UserService().getUserData();
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }
  }

  String _getSectionTitle(String section) {
    switch (section) {
      case 'bio_overview':
        return 'Bio Overview';
      case 'authentication':
        return 'Authentication';
      case 's_tab':
        return 'S-Tab Settings';
      case 'verify':
        return 'Security Verification Status';
      default:
        return 'Security Portal';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: CommonDashboardAppBar(automaticallyImplyLeading: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      if (widget.showMenuOnlyOnMobile) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
          body: SidebarMenu(
            activeItem: '',
            onSectionChanged: (section) {
              // Not used on mobile as SidebarMenu handles push navigation internally
            },
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _getSectionTitle(_currentSection),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 18),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildContent(_currentSection),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SidebarMenu(
            activeItem: _currentSection,
            onSectionChanged: (section) {
              setState(() {
                _currentSection = section;
              });
            },
          ),
          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(_currentSection),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String section) {
    switch (section) {
      case 'bio_overview':
        return _buildBioOverview();
      case 'authentication':
        return _buildAuthentication();
      case 's_tab':
        return _buildSTab();
      case 'verify':
        return _buildVerify();
      default:
        return _buildBioOverview();
    }
  }

  Widget _buildPremiumCard({required Key key, required String title, required IconData titleIcon, required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      key: key,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : const Color(0xFF2563EB).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: isDark ? const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(titleIcon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 18),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF1F5F9), thickness: 1.5),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBioOverview() {
    return _buildPremiumCard(
      key: const ValueKey('bio_overview'),
      title: "Bio Overview",
      titleIcon: Icons.badge_rounded,
      children: [
        _buildDetailItem(Icons.person_rounded, "Full Name", _userData['name'] ?? 'Sabari'),
        _buildDetailItem(Icons.email_rounded, "Email Address", _userData['email'] ?? 'sabari@example.com'),
        _buildDetailItem(Icons.phone_iphone_rounded, "Phone Number", _userData['phone'] ?? '8012107626'),
        _buildDetailItem(Icons.location_on_rounded, "Residential Address", _userData['address'] ?? 'Not Provided'),
      ],
    );
  }

  Widget _buildAuthentication() {
    return _buildPremiumCard(
      key: const ValueKey('authentication'),
      title: "Authentication",
      titleIcon: Icons.shield_rounded,
      children: [
        _buildDetailItem(Icons.security_rounded, "Authentication Level", "2-Factor Authentication Active"),
        _buildDetailItem(Icons.fingerprint_rounded, "Biometrics Lock", "Face ID & Pin Configured"),
        _buildDetailItem(Icons.phonelink_setup_rounded, "Registered Device", "Android Device (Pixel 7 Pro)"),
        _buildDetailItem(Icons.history_rounded, "Last Security Sync", "Today at 11:45 AM"),
      ],
    );
  }

  Widget _buildSTab() {
    return _buildPremiumCard(
      key: const ValueKey('s_tab'),
      title: "S-Tab Settings",
      titleIcon: Icons.settings_rounded,
      children: [
        _buildDetailItem(Icons.vpn_key_rounded, "S-Tab Security Key", "STAB-9508-3830-27XX"),
        _buildDetailItem(Icons.swap_horiz_rounded, "Connection Protocol", "TLS 1.3 Encryption Active"),
        _buildDetailItem(Icons.dns_rounded, "Gateway Server", "Secure UserPortal Node 4"),
        _buildDetailItem(Icons.verified_user_rounded, "Token Integrity", "Signature matches valid authority"),
      ],
    );
  }

  Widget _buildVerify() {
    return const _VerifySection(key: ValueKey('verify'));
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0).withOpacity(0.6)),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
                    : [Colors.white, const Color(0xFFF1F5F9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Icon(icon, size: 24, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
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
}

class _VerifySection extends StatefulWidget {
  const _VerifySection({super.key});

  @override
  State<_VerifySection> createState() => _VerifySectionState();
}

class _VerifySectionState extends State<_VerifySection> {
  List<int> options = [];
  int? selectedAnswer;

  bool showFormula = false;
  bool showWrong = false;
  bool isSuccess = false;
  bool isFailed = false;
  bool showResult = false;
  bool isLoading = true;

  int correctAnswer = 0;

  String selectedOpValue = '?';
  String selectedNumberValue = '1-9';

  @override
  void initState() {
    super.initState();
    loadVerification();
  }

  Future<void> loadVerification() async {
    try {

      final data =
      await StabService()
          .getVerificationOptions(StabService.savedAuthId);

      setState(() {

        options =
        List<int>.from(
            data["options"] ?? []);

        // use saved correct answer from save-auth-config
        correctAnswer =
            StabService.savedCorrectAnswer;

        print(
            "Correct Answer : $correctAnswer");

        selectedAnswer = null;
        showFormula = false;
        showWrong = false;
        isSuccess = false;
        isFailed = false;
        showResult = false;

        isLoading = false;
      });

    } catch (e) {

      print(
          "Verification Error : $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> selectAnswer(int value) async {
    int currentAuthId = StabService.savedAuthId;

    setState(() {

      selectedAnswer = value;

      if (value == correctAnswer) {

        showWrong = false;
        showFormula = true;
        showResult = false;
        isSuccess = false;
        isFailed = false;
        selectedOpValue = '?';
        selectedNumberValue = '1-9';

      } else {

        showWrong = true;
        showFormula = false;
        showResult = false;
        isSuccess = false;
        isFailed = false;
        StabService.clearSession();
      }
    });

    try {
      await StabService().verifyOption(
        authId: currentAuthId,
        clickedOption: value,
      );
    } catch (e) {
      print("Verify Option API Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 15)
                    ],
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                const Text(
                  "Verification Step",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1), thickness: 1.5, height: 1),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select the correct answer below to test your authentication",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: options.map((opt) {
                    bool isSelected = selectedAnswer == opt;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          selectAnswer(opt);
                        },
                        child: AnimatedContainer(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF10B981) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF34D399) : Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              opt.toString(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (showWrong)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline_rounded, color: Color(0xFFF87171), size: 24),
                          SizedBox(width: 12),
                          Text(
                            "Incorrect option selected!",
                            style: TextStyle(
                              color: Color(0xFFFCA5A5),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (showFormula)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.functions_rounded, color: Color(0xFF3B82F6), size: 24),
                              SizedBox(width: 12),
                              Text(
                                "Formula Verification",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedOpValue,
                                          dropdownColor: const Color(0xFF1E293B),
                                          borderRadius: BorderRadius.circular(16),
                                          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white54),
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedOpValue = newValue;
                                              });
                                            }
                                          },
                                          items: <String>['?', '+', '-'].map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Operation",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 32),
                              Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedNumberValue,
                                          dropdownColor: const Color(0xFF1E293B),
                                          borderRadius: BorderRadius.circular(16),
                                          icon: const SizedBox.shrink(),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedNumberValue = newValue;
                                              });
                                            }
                                          },
                                          items: <String>['1-9', '1', '2', '3', '4', '5', '6', '7', '8', '9']
                                              .map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Number",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                                shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                              ),
                              onPressed: () async {
                                if (selectedOpValue == '?' || selectedNumberValue == '1-9') {
                                  return;
                                }
                                int calculatedResult = 0;
                                int userNum = int.parse(selectedNumberValue);
                                if (selectedOpValue == '+') {
                                  calculatedResult = correctAnswer + userNum;
                                } else if (selectedOpValue == '-') {
                                  calculatedResult = correctAnswer - userNum;
                                }
                                int currentAuthId = StabService.savedAuthId;
                                setState(() {
                                  showResult = true;
                                  if (calculatedResult == StabService.savedSessionCode) {
                                    isSuccess = true;
                                    isFailed = false;
                                  } else {
                                    isSuccess = false;
                                    isFailed = true;
                                    StabService.clearSession();
                                  }
                                });
                                try {
                                  await StabService().verifyAuth(
                                    authId: currentAuthId,
                                    selectedAnswer: calculatedResult,
                                    selectedNumber: userNum,
                                    selectedOperation: selectedOpValue == '+' ? 'plus' : 'minus',
                                  );
                                } catch (e) {
                                  print("Verify Auth API Error: $e");
                                }
                              },
                              child: const Text(
                                "APPLY CONFIGURATION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (showResult)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSuccess ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSuccess ? const Color(0xFF10B981).withOpacity(0.3) : const Color(0xFFEF4444).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isSuccess ? const Color(0xFF34D399) : const Color(0xFFF87171),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            isSuccess ? "Authentication Success" : "Authentication Failed",
                            style: TextStyle(
                              color: isSuccess ? const Color(0xFF34D399) : const Color(0xFFF87171),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(8)));

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
  bool shouldRepaint(CustomPainter oldDelegate) => false;


