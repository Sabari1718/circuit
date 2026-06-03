import 'package:flutter/material.dart';
import 'apply_job_page.dart';

class JobCategory {
  final String title;
  final String icon;
  final Color bgColor;

  JobCategory(this.title, this.icon, this.bgColor);
}

class JobCategoriesPage extends StatelessWidget {
  const JobCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<JobCategory> categories = [
      JobCategory("Marketing", "📈", const Color(0xFFF3F4F6)),
      JobCategory("Sales", "🛒", const Color(0xFFECFDF5)),
      JobCategory("Driving", "🚗", const Color(0xFFFEF2F2)),
      JobCategory("IT & Software", "💻", const Color(0xFFEFF6FF)),
      JobCategory("Healthcare", "⚕️", const Color(0xFFFDF2F8)),
      JobCategory("Finance", "💰", const Color(0xFFFEF3C7)),
      JobCategory("Engineering", "⚙️", const Color(0xFFF1F5F9)),
      JobCategory("Customer Service", "🎧", const Color(0xFFF5F3FF)),
      JobCategory("Human Resources", "👥", const Color(0xFFFFF7ED)),
      JobCategory("Education", "🎓", const Color(0xFFE0F2FE)),
      JobCategory("Construction", "🏗️", const Color(0xFFFFEDD5)),
      JobCategory("Hospitality", "🏨", const Color(0xFFFCE7F3)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grayish background matching typical admin panels
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 16, color: Color(0xFF475569)),
                  SizedBox(width: 4),
                  Text(
                    "Back",
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        title: const Text(
          "Job Categories",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth > 1200) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 500) {
              crossAxisCount = 2;
            }

            return GridView.builder(
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 80, // Fixed height for cards
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (category.title == "Driving") {
                          debugPrint("Driving category selected");
                          debugPrint("Navigating directly to Apply For A Job page");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApplyJobPage(),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: category.bgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                category.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                category.title,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
