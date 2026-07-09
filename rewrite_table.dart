import 'dart:io';

void main() async {
  final file = File('c:\\Users\\sabar\\StudioProjects\\circuit\\lib\\upgrade\\posted_jobs_page.dart');
  String content = await file.readAsString();

  // We want to replace everything from `// Header Row` to the end of the `rows.map`
  final t1 = '''          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE2E8F0),
                ),
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: isDesktop
                ? Row(
                    children: [
                      const Expanded(flex: 2, child: _HeaderCell('JOB TITLE')),
                      const Expanded(flex: 2, child: _HeaderCell('COMPANY')),
                      const Expanded(flex: 2, child: _HeaderCell('DEPARTMENT')),
                      const Expanded(flex: 2, child: _HeaderCell('LOCATION')),
                      const Expanded(flex: 2, child: _HeaderCell('DEADLINE')),
                      const Expanded(flex: 1, child: _HeaderCell('STATUS')),
                      const Expanded(flex: 1, child: _HeaderCell('ACTIONS')),
                    ],
                  )
                : Row(
                    children: [
                      const Expanded(flex: 2, child: _HeaderCell('JOB')),
                      const Expanded(flex: 1, child: _HeaderCell('STATUS')),
                      const Expanded(flex: 1, child: _HeaderCell('ACTIONS')),
                    ],
                  ),
          ),

          // Table Body
          ...rows.map((job) => _buildRow(job, isDesktop, isDark)).toList(),''';

  final r1 = '''          // Horizontally Scrollable Table Data
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 900),
              child: Column(
                children: [
                  // Header Row
                  Container(
                    width: isDesktop ? null : 900,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFE2E8F0),
                        ),
                        bottom: BorderSide(
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 2, child: _HeaderCell('JOB TITLE')),
                        Expanded(flex: 2, child: _HeaderCell('COMPANY')),
                        Expanded(flex: 2, child: _HeaderCell('DEPARTMENT')),
                        Expanded(flex: 2, child: _HeaderCell('LOCATION')),
                        Expanded(flex: 2, child: _HeaderCell('DEADLINE')),
                        Expanded(flex: 1, child: _HeaderCell('STATUS')),
                        Expanded(flex: 1, child: _HeaderCell('ACTIONS')),
                      ],
                    ),
                  ),

                  // Table Body
                  ...rows.map((job) {
                    final statusColor = _statusColor(job.status);
                    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
                    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

                    return Container(
                      width: isDesktop ? null : 900,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.type.split(' ').isNotEmpty ? job.type.split(' ')[0] : job.type,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              job.company,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              job.department,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    job.location,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              job.deadline,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildStatusPill(job.status, statusColor),
                            ),
                          ),
                          Expanded(
                            flex: 1,
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

  content = content.replaceAll(t1, r1);

  // We also need to remove the `_buildRow` method since we moved it inline
  final startIdxRow = content.indexOf('  Widget _buildRow(PostedJobModel job, bool isDesktop, bool isDark) {');
  final endIdxRow = content.indexOf('  Widget _buildStatusPill(String status, Color color) {');

  if (startIdxRow != -1 && endIdxRow != -1) {
    content = content.replaceRange(startIdxRow, endIdxRow, '');
  }

  await file.writeAsString(content);
  print('Done!');
}
