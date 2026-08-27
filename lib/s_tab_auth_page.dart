import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/stab_service.dart';

int globalSTabSessionCode = 58;
int globalSTabSelectedNumber = 2;
String globalSTabSelectedOperation = 'plus';

class STabAuthPage extends StatefulWidget {
  const STabAuthPage({super.key});

  @override
  State<STabAuthPage> createState() =>
      _STabAuthPageState();
}

class _STabAuthPageState
    extends State<STabAuthPage> {

  final stabService = StabService();

  int authId = 0;
  int currentSessionCode = 0;

  int? selectedNumber;
  String? selectedOperation;

  @override
  void initState() {
    super.initState();
    loadAuthApi();
  }

  void loadAuthApi() async {
    try {

      var data =
      await stabService
          .generateAuth();

      print(data);

      setState(() {

        authId =
        data["auth_id"];

        currentSessionCode =
        data["session_code"];

      });

    } catch (e) {

      print(
        "API ERROR : $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "S-Tab Security",
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Color(0xFF1E1B4B), Color(0xFF0B1120)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4338CA).withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 20)
                                    ],
                                  ),
                                  child: const Icon(Icons.security_rounded, color: Color(0xFFA5B4FC), size: 28),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  "App Authentication",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            Text(
                              "SESSION CODE",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)
                                ],
                                border: Border.all(color: const Color(0xFF818CF8), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  currentSessionCode == 0 ? "..." : currentSessionCode.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: selectedNumber,
                                        dropdownColor: const Color(0xFF1E1B4B),
                                        borderRadius: BorderRadius.circular(16),
                                        hint: const Text(
                                          "Num",
                                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                                        ),
                                        isExpanded: true,
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        items: List.generate(
                                          10,
                                          (i) => DropdownMenuItem(
                                            value: i,
                                            child: Text("$i", style: const TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                        onChanged: (v) {
                                          setState(() => selectedNumber = v);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => selectedOperation = "plus"),
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: selectedOperation == "plus" ? const Color(0xFF10B981) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: selectedOperation == "plus"
                                                    ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.5), blurRadius: 10)]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "+",
                                                  style: TextStyle(
                                                    color: selectedOperation == "plus" ? Colors.white : Colors.white54,
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => selectedOperation = "minus"),
                                            child: Container(
                                              margin: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: selectedOperation == "minus" ? const Color(0xFFF43F5E) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: selectedOperation == "minus"
                                                    ? [BoxShadow(color: const Color(0xFFF43F5E).withOpacity(0.5), blurRadius: 10)]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "-",
                                                  style: TextStyle(
                                                    color: selectedOperation == "minus" ? Colors.white : Colors.white54,
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (selectedNumber == null || selectedOperation == null) return;
                                  try {
                                    await stabService.saveConfiguration(
                                      authId: authId,
                                      selectedNumber: selectedNumber!,
                                      operation: selectedOperation!,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: const Color(0xFF10B981),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          content: const Row(
                                            children: [
                                              Icon(Icons.check_circle_rounded, color: Colors.white),
                                              SizedBox(width: 12),
                                              Text("Configuration saved successfully!", style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                  shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                                ),
                                child: const Text(
                                  "SAVE CONFIGURATION",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}