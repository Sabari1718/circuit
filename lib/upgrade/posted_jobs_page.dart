import 'package:flutter/material.dart';

class PostedJobsPage extends StatefulWidget {
  const PostedJobsPage({super.key});

  @override
  State<PostedJobsPage> createState() => _PostedJobsPageState();
}

class _PostedJobsPageState extends State<PostedJobsPage> {
  final List<Map<String, dynamic>> jobs = [
    {
      "id": "1",
      "title": "Senior Full Stack Developer",
      "company": "Circuit point",
      "applied": 12,
      "status": "VERIFIED",
      "statusColor": Colors.green,
      "isActive": true,
    },
    {
      "id": "2",
      "title": "Digital Marketing Specialist",
      "company": "Circuit point",
      "applied": 45,
      "status": "PENDING REVIEW",
      "statusColor": Colors.orange,
      "isActive": false,
    },
    {
      "id": "3",
      "title": "UI/UX Designer",
      "company": "Circuit point",
      "applied": 8,
      "status": "IDENTIFIED FAKE",
      "statusColor": Colors.red,
      "isActive": true,
    },
  ];

  int get totalListings => jobs.length;
  int get activeListings => jobs.where((job) => job["isActive"] == true).length;
  int get pausedListings => jobs.where((job) => job["isActive"] == false).length;

  void toggleJobStatus(int index, bool value) {
    setState(() {
      jobs[index]["isActive"] = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? "${jobs[index]["title"]} is now ACTIVE"
              : "${jobs[index]["title"]} is now INACTIVE",
        ),
      ),
    );
  }

  void deleteJob(int index) {
    final deletedTitle = jobs[index]["title"];

    setState(() {
      jobs.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$deletedTitle deleted successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Posted Jobs",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hiring Dashboard",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Monitor and verify job listings to ensure marketplace quality",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            isDesktop
                ? Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.work_outline_rounded,
                    title: "Total Listings",
                    value: totalListings.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: "Marketplace Active",
                    value: activeListings.toString(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.pause_circle_outline_rounded,
                    title: "Marketplace Paused",
                    value: pausedListings.toString(),
                  ),
                ),
              ],
            )
                : Column(
              children: [
                _buildStatCard(
                  icon: Icons.work_outline_rounded,
                  title: "Total Listings",
                  value: totalListings.toString(),
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.check_circle_outline_rounded,
                  title: "Marketplace Active",
                  value: activeListings.toString(),
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  icon: Icons.pause_circle_outline_rounded,
                  title: "Marketplace Paused",
                  value: pausedListings.toString(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _buildJobCard(job, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Icon(icon, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFEFF6FF),
                child: const Icon(Icons.work_rounded, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job["title"],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job["company"],
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (job["statusColor"] as Color).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job["status"],
                  style: TextStyle(
                    color: job["statusColor"],
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.groups_2_outlined,
                size: 18,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              const Text(
                "Applied Candidates: ",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${job["applied"]}",
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                job["isActive"] ? "ACTIVE" : "INACTIVE",
                style: TextStyle(
                  color: job["isActive"] ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: job["isActive"],
                onChanged: (value) => toggleJobStatus(index, value),
              ),
              const Spacer(),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Viewing ${job["title"]}"),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text("Delete Job"),
                        content: Text(
                          "Are you sure you want to delete '${job["title"]}'?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              deleteJob(index);
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}