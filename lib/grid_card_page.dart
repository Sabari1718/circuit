import 'package:flutter/material.dart';
import 'widgets/common_dashboard_app_bar.dart';
import 'sidebar_menu.dart';
import 'services/grid_card_service.dart';
import 'models/grid_card_model.dart';

class GridCardPage extends StatefulWidget {
  const GridCardPage({super.key});

  @override
  State<GridCardPage> createState() =>
      _GridCardPageState();
}

class _GridCardPageState
    extends State<GridCardPage> {
  late Future<GridCardModel>
  _gridCardFuture;

  @override
  void initState() {
    super.initState();

    _gridCardFuture =
        GridCardService().fetchGridCard();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.of(context).size.width <
            768;

    if (isMobile) {
      return Scaffold(
        backgroundColor:
        const Color(0xFFF8FAFC),

        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0F172A),
            ),

            onPressed: () =>
                Navigator.pop(context),
          ),

          title: const Text(
            "Security Grid Card",

            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontSize: 18,
            ),
          ),

          backgroundColor: Colors.white,

          elevation: 0,

          bottom: const PreferredSize(
            preferredSize:
            Size.fromHeight(1),

            child: Divider(
              height: 1,
              color: Color(0xFFE2E8F0),
            ),
          ),
        ),

        body: _buildBody(),
      );
    }

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8FAFC),

      appBar:
      const CommonDashboardAppBar(
        automaticallyImplyLeading: true,
      ),

      body: Row(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,

        children: [
          const SidebarMenu(
            activeItem: 'grid_card',
          ),

          const VerticalDivider(
            width: 1,
            thickness: 1,
            color: Color(0xFFE2E8F0),
          ),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<GridCardModel>(
      future: _gridCardFuture,

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
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),

                const SizedBox(height: 16),

                Text(
                  "Failed to load grid card data.\n${snapshot.error}",

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _gridCardFuture =
                          GridCardService()
                              .fetchGridCard(
                            forceRefresh: true,
                          );
                    });
                  },

                  child: const Text(
                    "Retry",
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData) {
          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(32),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                _buildGridCardContent(
                  snapshot.data!,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGridCardContent(
      GridCardModel grid,
      ) {
    final columns = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G'
    ];

    final rows = [1, 2, 3, 4, 5];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.02),

            blurRadius: 10,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,

        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),

            child: Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.all(8),

                  decoration:
                  const BoxDecoration(
                    color: Color(0xFFE11D48),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.grid_on_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                const Text(
                  "Security Grid Card",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE2E8F0),
          ),

          Padding(
            padding:
            const EdgeInsets.all(16),

            child: Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color:
                const Color(0xFF2E3B4E),

                borderRadius:
                BorderRadius.circular(
                  8,
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 20,
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "AUTHENTICATION GRID CARD",

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    width: 32,
                    height: 22,

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                          0xFFFBBF24),

                      borderRadius:
                      BorderRadius
                          .circular(
                        4,
                      ),
                    ),

                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceEvenly,

                      children: [
                        Container(
                          height: 1,
                          color:
                          Colors.black12,
                        ),

                        Container(
                          height: 1,
                          color:
                          Colors.black12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: SingleChildScrollView(
              scrollDirection:
              Axis.horizontal,

              child: Container(
                width: 520,

                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 8,
                ),

                child: Table(
                  border: TableBorder.all(
                    color:
                    const Color(
                        0xFFCBD5E1),

                    width: 1,

                    borderRadius:
                    BorderRadius
                        .circular(
                      8,
                    ),
                  ),

                  columnWidths: const {
                    0: FixedColumnWidth(50),
                  },

                  children: [
                    TableRow(
                      decoration:
                      const BoxDecoration(
                        color:
                        Color(0xFFF8FAFC),
                      ),

                      children: [
                        const TableCell(
                          child: SizedBox(
                            height: 45,

                            child: Center(
                              child: Text(""),
                            ),
                          ),
                        ),

                        ...columns.map(
                              (col) => TableCell(
                            child: SizedBox(
                              height: 45,

                              child: Center(
                                child: Text(
                                  col,

                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color: Color(
                                        0xFF2563EB),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ...rows.map(
                          (rowNum) => TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              height: 55,

                              color:
                              const Color(
                                  0xFFF8FAFC),

                              child: Center(
                                child: Text(
                                  rowNum
                                      .toString(),

                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color: Color(
                                        0xFF2563EB),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          ...columns.map(
                                (col) {
                              final cellVal =
                                  grid.gridData[
                                  '$col$rowNum'] ??
                                      '000';

                              return TableCell(
                                child: Padding(
                                  padding:
                                  const EdgeInsets
                                      .all(4),

                                  child: Container(
                                    height: 47,

                                    decoration:
                                    BoxDecoration(
                                      border:
                                      Border.all(
                                        color:
                                        const Color(
                                            0xFFE2E8F0),
                                      ),

                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                        6,
                                      ),
                                    ),

                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,

                                      children: [
                                        Text(
                                          '$col$rowNum',

                                          style:
                                          const TextStyle(
                                            fontSize:
                                            9,
                                            color: Color(
                                                0xFF94A3B8),
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                          ),
                                        ),

                                        const SizedBox(
                                            height:
                                            2),

                                        Text(
                                          cellVal,

                                          style:
                                          const TextStyle(
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                            color: Color(
                                                0xFF1E293B),
                                            fontSize:
                                            14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding:
            const EdgeInsets.all(16),

            decoration:
            const BoxDecoration(
              color: Color(0xFFF8FAFC),

              borderRadius:
              BorderRadius.only(
                bottomLeft:
                Radius.circular(16),

                bottomRight:
                Radius.circular(16),
              ),
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                const Text(
                  "SERIAL NUMBER",

                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight:
                    FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  grid.serialNumber,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF0F172A),
                    fontFamily:
                    'monospace',
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