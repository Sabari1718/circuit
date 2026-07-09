import 'package:flutter/material.dart';
import 'kovil_list_page.dart';

class ReligionCategory {
  final String title;
  final String icon;
  final Color bgColor;

  ReligionCategory(this.title, this.icon, this.bgColor);
}

class KovilCategoriesPage extends StatelessWidget {
  const KovilCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ReligionCategory> categories = [
      ReligionCategory("Hindu", "🕉️", const Color(0xFFFEF2F2)),
      ReligionCategory("Muslim", "☪️", const Color(0xFFECFDF5)),
      ReligionCategory("Christian", "✝️", const Color(0xFFEFF6FF)),
      ReligionCategory("Sikh", "🪯", const Color(0xFFFEF3C7)),
      ReligionCategory("Buddhist", "☸️", const Color(0xFFFDF2F8)),
      ReligionCategory("Jain", "🛕", const Color(0xFFF3F4F6)),
      ReligionCategory("Other", "✨", const Color(0xFFF5F3FF)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grayish background
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
          "Religion Categories",
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KovilListPage(religion: category.title),
                          ),
                        );
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
