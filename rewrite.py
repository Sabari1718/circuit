import re
import sys

def main():
    file_path = r'c:\Users\sabar\StudioProjects\circuit\lib\upgrade\posted_jobs_page.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update salaryRange and skills parsing
    target1 = """            String salary = item['monthly_salary']?.toString() ?? '';
            String salaryRange = salary.isNotEmpty
                ? '$salary USD'
                : 'Not Specified';"""
    replacement1 = """            String salary = item['monthly_salary']?.toString() ?? '';
            String salaryRange = salary.isNotEmpty
                ? '$salary INR'
                : 'Not Specified';
            
            List<String> parsedSkills = [];
            if (item['skills'] != null && item['skills'] is List) {
              parsedSkills = List<String>.from(item['skills'].map((e) => e.toString()));
            }"""
    content = content.replace(target1, replacement1)

    target2 = """                description: _getFirstValid(
                  [item['job_description']],
                  'No description available',
                ),
                skills: [],"""
    replacement2 = """                description: _getFirstValid(
                  [item['job_description']],
                  'No description available',
                ),
                skills: parsedSkills,"""
    content = content.replace(target2, replacement2)

    # 2. Update _buildViewDetailsBtn
    target3 = """  Widget _buildViewDetailsBtn(PostedJobModel job, bool isDark) {
    return InkWell(
      onTap: () => _showJobDetails(job),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye, size: 14, color: Color(0xFF8B5CF6)),
            SizedBox(width: 4),
            Text(
              'View Details',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }"""
    replacement3 = """  Widget _buildViewDetailsBtn(PostedJobModel job, bool isDark) {
    return InkWell(
      onTap: () => _showJobDetails(job),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E7FF), // light indigo
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye, size: 14, color: Color(0xFF4F46E5)),
            SizedBox(width: 4),
            Text(
              'View',
              style: TextStyle(
                color: Color(0xFF4F46E5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }"""
    content = content.replace(target3, replacement3)

    # 3. Completely replace _showJobDetails and its helpers
    dialog_start_idx = content.find('  void _showJobDetails(PostedJobModel job) {')
    dialog_end_idx = content.find('  Widget _buildPagination() {')

    if dialog_start_idx == -1 or dialog_end_idx == -1:
        print("Could not find dialog methods.")
        return

    new_dialog = """  void _showJobDetails(PostedJobModel job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: 700,
            constraints: const BoxConstraints(maxHeight: 800),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Title "Job Details"
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Job Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Subtitle Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.work, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${job.department} • ${job.location}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF3B82F6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Wrap of Pills
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInfoPill(job.status, null, textColor: Colors.green),
                            _buildInfoPill('Deadline: ${job.deadline}', Icons.access_time),
                            _buildInfoPill(job.salaryRange, Icons.monetization_on_outlined),
                            _buildInfoPill('${job.vacancies}', Icons.people_outline),
                            _buildInfoPill(job.category, Icons.category_outlined),
                            _buildInfoPill(job.type, Icons.work_outline),
                            _buildInfoPill('Exp: ${job.experience}', Icons.school_outlined),
                            _buildInfoPill('Posted: ${job.postedDate}', Icons.calendar_today_outlined),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Job Description Section
                        Row(
                          children: [
                            Icon(Icons.description, size: 18, color: const Color(0xFF4F46E5)),
                            const SizedBox(width: 8),
                            Text(
                              "Job Description",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            job.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Required Skills Section
                        Row(
                          children: [
                            Icon(Icons.star, size: 18, color: const Color(0xFF4F46E5)),
                            const SizedBox(width: 8),
                            Text(
                              "Required Skills",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (job.skills.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: job.skills.map((skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  color: Color(0xFF4F46E5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          )
                        else
                          Text(
                            "No specific skills mentioned",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Close'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                        label: const Text('Edit Job', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoPill(String text, IconData? icon, {Color? textColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569)),
            ),
          ),
        ],
      ),
    );
  }

"""
    content = content[:dialog_start_idx] + new_dialog + content[dialog_end_idx:]

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Successfully replaced dialog UI and list item Action UI.")

if __name__ == '__main__':
    main()
