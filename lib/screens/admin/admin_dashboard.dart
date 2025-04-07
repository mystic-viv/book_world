import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE97F11),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService.logout();
              Get.offAllNamed(RouteNames.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome, Admin",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE97F11),
              ),
            ),
            const SizedBox(height: 20),
            _buildDashboardCard(
              title: "Manage Librarians",
              icon: Icons.people,
              onTap: () {
                Get.toNamed(RouteNames.manageLibrarians);
              },
            ),
            _buildDashboardCard(
              title: "Manage Books",
              icon: Icons.book,
              onTap: () {
                Get.toNamed(RouteNames.allBooks);
              },
            ),
            _buildDashboardCard(
              title: "User Statistics",
              icon: Icons.bar_chart,
              onTap: () {
                Get.toNamed(RouteNames.userStats);
              },
            ),
            _buildDashboardCard(
              title: "Book Transactions",
              icon: Icons.swap_horiz,
              onTap: () {
                Get.toNamed(RouteNames.bookTransactions);
              },
            ),
            _buildDashboardCard(
              title: "System Settings",
              icon: Icons.settings,
              onTap: () {
                Get.toNamed(RouteNames.systemSettings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE97F11).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFE97F11),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFE97F11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
