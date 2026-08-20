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

  Widget _buildBioOverview() {
    return Container(
      key: const ValueKey('bio_overview'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bio Overview",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.person_outline_rounded, "Full Name", _userData['name'] ?? 'Sabari'),
          _buildDetailItem(Icons.email_outlined, "Email Address", _userData['email'] ?? 'sabari@example.com'),
          _buildDetailItem(Icons.phone_iphone_rounded, "Phone Number", _userData['phone'] ?? '8012107626'),
          _buildDetailItem(Icons.location_on_outlined, "Residential Address", _userData['address'] ?? 'Not Provided'),
        ],
      ),
    );
  }

  Widget _buildAuthentication() {
    return Container(
      key: const ValueKey('authentication'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Authentication",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.security_outlined, "Authentication Level", "2-Factor Authentication Active"),
          _buildDetailItem(Icons.fingerprint_rounded, "Biometrics Lock", "Face ID & Pin Configured"),
          _buildDetailItem(Icons.phonelink_setup_rounded, "Registered Device", "Android Device (Pixel 7 Pro)"),
          _buildDetailItem(Icons.history_rounded, "Last Security Sync", "Today at 11:45 AM"),
        ],
      ),
    );
  }

  Widget _buildSTab() {
    return Container(
      key: const ValueKey('s_tab'),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "S-Tab Settings",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailItem(Icons.vpn_key_outlined, "S-Tab Security Key", "STAB-9508-3830-27XX"),
          _buildDetailItem(Icons.swap_horiz_rounded, "Connection Protocol", "TLS 1.3 Encryption Active"),
          _buildDetailItem(Icons.dns_outlined, "Gateway Server", "Secure UserPortal Node 4"),
          _buildDetailItem(Icons.verified_user_outlined, "Token Integrity", "Signature matches valid authority"),
        ],
      ),
    );
  }

  Widget _buildVerify() {
    return const _VerifySection(key: ValueKey('verify'));
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
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
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color:
          const Color(0xFFE2E8F0),
        ),
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              "Verification Step",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              "Select the correct answer below to test your authentication",
            ),

            const SizedBox(
              height: 25,
            ),

            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceEvenly,

              children:
              options.map((opt) {

                bool isSelected =
                    selectedAnswer ==
                        opt;

                return GestureDetector(

                  onTap: () {
                    selectAnswer(
                        opt);
                  },

                  child: Container(

                    width: 56,
                    height: 48,

                    decoration:
                    BoxDecoration(

                      color:
                      isSelected
                          ? const Color(
                          0xFF6B5FD6)
                          : Colors.white,

                      borderRadius:
                      BorderRadius
                          .circular(
                          8),

                      border:
                      Border.all(
                        color: const Color(
                            0xFFE2E8F0),
                      ),
                    ),

                    child: Center(
                      child: Text(
                        opt.toString(),

                        style:
                        TextStyle(

                          fontSize:
                          18,

                          fontWeight:
                          FontWeight
                              .bold,

                          color:
                          isSelected
                              ? Colors
                              .white
                              : Colors
                              .black,
                        ),
                      ),
                    ),
                  ),
                );

              }).toList(),
            ),

            if (showWrong)
              const Padding(
                padding:
                EdgeInsets.only(
                    top: 20),
                child: Text(
                  "Incorrect option selected!",
                  style: TextStyle(
                    color:
                    Colors.red,
                    fontWeight:
                    FontWeight
                        .bold,
                  ),
                ),
              ),

            if (showFormula)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Formula Verification",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedOpValue,
                                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
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
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Operation",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Center(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedNumberValue,
                                          icon: const SizedBox.shrink(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
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
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Number",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9086F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                if (selectedOpValue == '?' || selectedNumberValue == '1-9') {
                                  // Do nothing if not fully selected
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
                                "APPLY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showResult)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          isSuccess ? "Authentication Success" : "Authentication Failed",
                          style: TextStyle(
                            color: isSuccess ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
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


