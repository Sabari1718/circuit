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

  Widget _buildGridCardContent(GridCardModel grid) {
    final columns = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    final rows = [1, 2, 3, 4, 5];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 2.0,
          colors: [Color(0xFF1E293B), Color(0xFF020617)],
        ),
      ),
      child: Stack(
        children: [
          // Glass shine overlay
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEAB308), Color(0xFFB45309)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFEAB308).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)
                        ],
                      ),
                      child: const Icon(Icons.grid_on_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        "SECURE GRID",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Hologram chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFCD34D), Color(0xFFD97706), Color(0xFFFDE68A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 10)
                        ],
                      ),
                      child: const Icon(Icons.sim_card_rounded, color: Colors.black54, size: 24),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Color(0xFF34D399), size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "AUTHENTICATION MATRIX",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFCD34D), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 8)
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(height: 2, width: double.infinity, color: Colors.black.withOpacity(0.2)),
                        Container(height: 2, width: double.infinity, color: Colors.black.withOpacity(0.2)),
                        Container(height: 2, width: double.infinity, color: Colors.black.withOpacity(0.2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: 580,
                padding: const EdgeInsets.only(bottom: 24),
                child: Table(
                  border: TableBorder.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  columnWidths: const {0: FixedColumnWidth(55)},
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      ),
                      children: [
                        const TableCell(child: SizedBox(height: 50, child: Center(child: Text("")))),
                        ...columns.map((col) => TableCell(
                              child: SizedBox(
                                height: 50,
                                child: Center(
                                  child: Text(
                                    col,
                                    style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF93C5FD), fontSize: 18),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ),
                    ...rows.map(
                      (rowNum) => TableRow(
                        children: [
                          TableCell(
                            child: Container(
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.03),
                                border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5)),
                              ),
                              child: Center(
                                child: Text(
                                  rowNum.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF93C5FD), fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                          ...columns.map((col) {
                            final cellVal = grid.gridData['$col$rowNum'] ?? '000';
                            return TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$col$rowNum',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white.withOpacity(0.5),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cellVal,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 16,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_rounded, color: Colors.white70, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SERIAL NUMBER",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        grid.serialNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'monospace',
                          letterSpacing: 2.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  ),
);
  }
}