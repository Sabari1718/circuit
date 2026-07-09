import 'dart:io';

void main() async {
  final file = File('c:\\Users\\sabar\\StudioProjects\\circuit\\lib\\upgrade\\posted_jobs_page.dart');
  String content = await file.readAsString();

  final t1 = '''          // Horizontally Scrollable Table Data
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: Column(
                children: [
                  // Header Row
                  Container(
                    width: isDesktop ? null : 900,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),''';

  final r1 = '''          // Horizontally Scrollable Table Data
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),''';

  final t2 = '''                    return Container(
                      width: isDesktop ? null : 900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),''';
  final r2 = '''                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),''';

  final t3 = '''                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: _buildViewDetailsBtn(job, isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),''';

  final r3 = '''                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: _buildViewDetailsBtn(job, isDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),''';

  if (!content.contains(t1)) {
    print('t1 not found');
    return;
  }
  content = content.replaceAll(t1, r1);
  content = content.replaceAll(t2, r2);
  content = content.replaceAll(t3, r3);

  await file.writeAsString(content);
  print('Done!');
}
