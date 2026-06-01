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
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(
          0xFFEEF0F8),

      appBar: AppBar(

        leading:
        IconButton(

          icon:
          const Icon(
            Icons.arrow_back,
            color:
            Color(
                0xFF0F172A),
          ),

          onPressed: (){
            Navigator.pop(
                context);
          },
        ),

        title:
        const Text(

          "S-Tab",

          style:
          TextStyle(
            fontWeight:
            FontWeight
                .bold,
            color:
            Color(
                0xFF0F172A),
          ),
        ),

        backgroundColor:
        Colors.white,
      ),

      body:
      SingleChildScrollView(

        padding:
        const EdgeInsets.all(
            16),

        child:
        Container(

          decoration:
          BoxDecoration(

            color:
            Colors.white,

            borderRadius:
            BorderRadius
                .circular(
                16),

            border:
            Border.all(
              color:
              const Color(
                  0xFFE2E8F0),
            ),
          ),

          child:
          Column(

            children: [

              Container(

                width:
                double.infinity,

                padding:
                const EdgeInsets
                    .all(
                    20),

                decoration:
                const BoxDecoration(

                  gradient:
                  LinearGradient(

                    colors: [

                      Color(
                          0xFF1B2B7A),

                      Color(
                          0xFF2E3D9A)

                    ],
                  ),

                  borderRadius:
                  BorderRadius.only(

                    topLeft:
                    Radius.circular(
                        16),

                    topRight:
                    Radius.circular(
                        16),
                  ),
                ),

                child:
                const Column(

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(

                      "App Authentication",

                      style:
                      TextStyle(

                        color:
                        Colors.white,

                        fontSize:
                        22,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(
                        height:
                        5),

                    Text(

                      "Your secure one-time session code",

                      style:
                      TextStyle(
                        color:
                        Colors.white70,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(
                  height:
                  25),

              Container(

                width:82,
                height:82,

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                      0xFF181F3A),

                  borderRadius:
                  BorderRadius
                      .circular(
                      12),
                ),

                child:
                Center(

                  child:
                  Text(

                    currentSessionCode==0
                        ? "..."
                        : currentSessionCode
                        .toString(),

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontSize:
                      38,

                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                  height:
                  25),

              Padding(

                padding:
                const EdgeInsets
                    .all(
                    16),

                child:
                Column(

                  children:[

                    Row(

                      children:[

                        Expanded(

                          child:
                          DropdownButtonFormField<int>(

                            value:
                            selectedNumber,
                            
                            hint: const Text("Select Number"),

                            isExpanded:
                            true,

                            items:
                            List.generate(

                              10,

                                  (i)=>
                                  DropdownMenuItem(

                                    value:
                                    i,

                                    child:
                                    Text(
                                        "${i}"),
                                  ),
                            ),

                            onChanged:
                                (v){

                              setState(() {

                                selectedNumber=
                                    v;
                              });

                            },
                          ),
                        ),

                        const SizedBox(
                            width:
                            10),

                        Expanded(

                          child:
                          Row(

                            children:[

                              Expanded(

                                child:
                                OutlinedButton(

                                  style:
                                  OutlinedButton.styleFrom(

                                    backgroundColor:
                                    selectedOperation=="plus"

                                        ? const Color(
                                        0xFF9B91E0)

                                        : Colors.white,
                                  ),

                                  onPressed:(){

                                    setState(() {

                                      selectedOperation=
                                      "plus";

                                    });
                                  },

                                  child:
                                  Text(
                                      "+"),
                                ),
                              ),

                              const SizedBox(
                                  width:
                                  8),

                              Expanded(

                                child:
                                OutlinedButton(

                                  style:
                                  OutlinedButton.styleFrom(

                                    backgroundColor:
                                    selectedOperation=="minus"

                                        ? const Color(
                                        0xFF9B91E0)

                                        : Colors.white,
                                  ),

                                  onPressed:(){

                                    setState(() {

                                      selectedOperation=
                                      "minus";

                                    });
                                  },

                                  child:
                                  Text(
                                      "-"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height:
                        20),

                    SizedBox(

                      width:
                      double.infinity,

                      height:
                      45,

                      child:
                      ElevatedButton(

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          const Color(
                              0xFF9B91E0),
                        ),

                        onPressed:
                            () async {
                          if (selectedNumber == null || selectedOperation == null) {
                            return;
                          }

                          try {

                            await stabService
                                .saveConfiguration(

                              authId:
                              authId,

                              selectedNumber:
                              selectedNumber!,

                              operation:
                              selectedOperation!,
                            );

                            if(mounted){

                              ScaffoldMessenger
                                  .of(
                                  context)
                                  .showSnackBar(

                                const SnackBar(

                                  behavior:
                                  SnackBarBehavior
                                      .floating,

                                  backgroundColor:
                                  Colors.green,

                                  content:
                                  Text(
                                    "Authentication configuration saved successfully!",
                                  ),
                                ),
                              );
                            }

                          } catch(e){

                            print(e);
                          }

                        },

                        child:
                        const Text(

                          "SAVE CONFIGURATION",

                          style:
                          TextStyle(
                            color:
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}