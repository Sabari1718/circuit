import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/grid_card_service.dart';
import 'models/grid_card_model.dart';

class GridVerificationPage extends StatefulWidget {
  const GridVerificationPage({super.key});

  @override
  State<GridVerificationPage> createState() =>
      _GridVerificationPageState();
}

class _GridVerificationPageState
    extends State<GridVerificationPage> {

  late Future<GridCardModel> _future;

  GridCardModel? _gridData;

  List<String> _challenges = [];

  late List<TextEditingController> _controllers;

  static const String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTIsImVtYWlsIjoic2FiYXJpc2h3YXJhbjE3MThAZ21haWwuY29tIiwidXNlcl9tYWluX2lkIjoiOTUwODM4MzAyNyIsInVzZXJfbmFtZSI6IlNhYmFyaSAiLCJ1c2VyX3R5cGUiOiJndWVzdCIsImlhdCI6MTc3OTMzNjA2MywiZXhwIjoxNzc5NDIyNDYzfQ.ap94YHeX4xZnNbrkInhDNPEVaPwb473TWCPQZ23G1qc';

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
          (_) => TextEditingController(),
    );

    _future =
        GridCardService()
            .fetchGridCard()
            .then((value) {

          _gridData = value;

          _generateNewChallenge();

          return value;
        });
  }

  @override
  void dispose() {

    for (var c in _controllers) {
      c.dispose();
    }

    super.dispose();
  }

  void _generateNewChallenge() {

    if (_gridData == null) return;

    final rand = Random();

    final List<String> temp = [];

    while (temp.length < 3) {

      final col = _gridData!.columns[
      rand.nextInt(
          _gridData!.columns.length)];

      final row = _gridData!.rows[
      rand.nextInt(
          _gridData!.rows.length)];

      final key = '$col$row';

      if (!temp.contains(key)) {
        temp.add(key);
      }
    }

    setState(() {

      _challenges = temp;

      for (var c in _controllers) {
        c.clear();
      }
    });
  }

  Future<void> _verifyGrid() async {

    if (_gridData == null) {
      return;
    }

    bool valid = true;

    for (int i = 0; i < 3; i++) {

      final entered =
      _controllers[i].text.trim();

      final actual =
          _gridData!.gridData[
          _challenges[i]] ??
              '';

      print(
        "CHECK => ${_challenges[i]} : entered=$entered actual=$actual",
      );

      if (entered != actual) {

        valid = false;
        break;
      }
    }

    if (!valid) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "❌ Verification Failed",
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    try {

      final response = await http.post(
        Uri.parse(
          "https://user.jobes24x7.com/verify",
        ),

        headers: {

          "Authorization":
          "Bearer $token",

          "Content-Type":
          "application/json",

          "Accept":
          "application/json",
        },

        body: jsonEncode({

          "user_main_id":
          "9508383027",

          "coordinates":
          _challenges,

          "values": [

            _controllers[0]
                .text
                .trim(),

            _controllers[1]
                .text
                .trim(),

            _controllers[2]
                .text
                .trim(),
          ],

          "status": "success",
        }),
      );

      print(
        "VERIFY STATUS => ${response.statusCode}",
      );

      print(
        "VERIFY RESPONSE => ${response.body}",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final result =
        await Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) =>
            const VerificationSuccessPage(),
          ),
        );

        if (result == true) {

          setState(() {

            _controllers = List.generate(
              3,
                  (_) =>
                  TextEditingController(),
            );

            _challenges = [];
          });

          await Future.delayed(
            const Duration(
              milliseconds: 100,
            ),
          );

          _generateNewChallenge();
        }

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "API Failed : ${response.statusCode}",
            ),
          ),
        );
      }

    } catch (e) {

      print("VERIFY ERROR => $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text("API ERROR : $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0xFF2563EB).withOpacity(0.04),
        scrolledUnderElevation: 4,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              true,
            );
          },
        ),
        title: const Text(
          "Grid Verification",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<GridCardModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.2),
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
                children: [
                  Row(
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
                            BoxShadow(color: const Color(0xFF10B981).withOpacity(0.5), blurRadius: 15)
                          ],
                        ),
                        child: const Icon(
                          Icons.grid_on_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Text(
                          "Grid Challenge",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.shield_rounded,
                                      color: Color(0xFF60A5FA),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      "AUTHENTICATION",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _generateNewChallenge,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.4), blurRadius: 8)
                                    ],
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "Refresh",
                                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.qr_code_rounded, color: Colors.white.withOpacity(0.6), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Serial: ${_gridData!.serialNumber}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    letterSpacing: 1.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Enter the 3-digit values from your Grid Card",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _challenges[index],
                                    style: const TextStyle(
                                      color: Color(0xFF60A5FA),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: TextField(
                                      key: ValueKey(
                                        "${_challenges[index]}_${DateTime.now().millisecondsSinceEpoch}",
                                      ),
                                      controller: _controllers[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      maxLength: 3,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 4.0,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        counterText: "",
                                        hintText: "•••",
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.2),
                                          letterSpacing: 4.0,
                                        )
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _verifyGrid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF10B981).withOpacity(0.5),
                      ),
                      child: const Text(
                        "SUBMIT AND VERIFY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VerificationSuccessPage extends StatelessWidget {
  const VerificationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Verification Success!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "All coordinates matched perfectly. You are authorized to complete the action.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text(
                    "VERIFY AGAIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 1.0,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}