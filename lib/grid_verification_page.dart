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
      backgroundColor:
      const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),

          onPressed: () {

            Navigator.pop(
              context,
              true,
            );
          },
        ),

        title: const Text(
          "Grid Verification Demo",

          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: FutureBuilder<GridCardModel>(
        future: _future,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
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
            padding:
            const EdgeInsets.all(20),

            child: Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(20),

                border: Border.all(
                  color:
                  Colors.grey.shade300,
                ),
              ),

              child: Column(
                children: [

                  const SizedBox(height: 10),

                  Row(
                    children: [

                      Container(
                        width: 52,
                        height: 52,

                        decoration:
                        const BoxDecoration(
                          color:
                          Color(0xFFE11D48),

                          shape:
                          BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Text(
                          "Grid Verification Demo",

                          style: TextStyle(
                            fontSize: 28,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    width: double.infinity,

                    padding:
                    const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(
                          16),

                      border: Border.all(
                        color:
                        Colors.grey.shade300,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                          children: [

                            const Expanded(
                              child: Text(
                                "Security Coordinates Required",

                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),

                            TextButton.icon(
                              onPressed:
                              _generateNewChallenge,

                              icon: const Icon(
                                Icons.refresh,
                              ),

                              label: const Text(
                                "New Challenge",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Serial: ${_gridData!.serialNumber}",

                          style: TextStyle(
                            color:
                            Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "To complete this transaction, enter the corresponding 3-digit values from your static Security Grid Card below:",

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,

                    children: List.generate(
                      3,
                          (index) {

                        return Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),

                            child: Column(
                              children: [

                                Container(
                                  height: 52,

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                        0xFFE11D48),

                                    borderRadius:
                                    BorderRadius.circular(
                                        10),
                                  ),

                                  alignment:
                                  Alignment.center,

                                  child: Text(
                                    _challenges[index],

                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.white,

                                      fontWeight:
                                      FontWeight.bold,

                                      fontSize: 22,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                    height: 14),

                                Container(
                                  height: 65,

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(
                                        0xFF1E293B),

                                    borderRadius:
                                    BorderRadius.circular(
                                        12),
                                  ),

                                  child:
                                  TextField(

                                    key: ValueKey(
                                      "${_challenges[index]}_${DateTime.now().millisecondsSinceEpoch}",
                                    ),

                                    controller:
                                    _controllers[index],

                                    keyboardType:
                                    TextInputType.number,

                                    textAlign:
                                    TextAlign.center,

                                    maxLength: 3,

                                    style:
                                    const TextStyle(
                                      color:
                                      Colors.white,

                                      fontSize: 24,

                                      fontWeight:
                                      FontWeight.bold,
                                    ),

                                    decoration:
                                    const InputDecoration(
                                      border:
                                      InputBorder.none,

                                      counterText: "",
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

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 240,
                    height: 58,

                    child: ElevatedButton(
                      onPressed:
                      _verifyGrid,

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(
                            0xFF2563EB),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                              12),
                        ),
                      ),

                      child: const Text(
                        "Submit and Verify",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
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

class VerificationSuccessPage
    extends StatelessWidget {

  const VerificationSuccessPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FB),

      body: Center(
        child: Container(
          margin:
          const EdgeInsets.all(24),

          padding:
          const EdgeInsets.all(32),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(20),
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [

              Container(
                width: 100,
                height: 100,

                decoration:
                BoxDecoration(
                  color:
                  Colors.green.withOpacity(0.15),

                  shape:
                  BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 50,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Verification Success!",

                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Color(0xFFE11D48),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "All coordinates matched perfectly. You are authorized to complete the action.",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(

                onPressed: () {

                  Navigator.pop(
                    context,
                    true,
                  );
                },

                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),

                label: const Text(
                  "Verify Again",

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF2563EB),

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 16,
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