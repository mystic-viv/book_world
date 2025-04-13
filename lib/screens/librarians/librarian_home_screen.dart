import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class LibrarianHomeScreen extends StatelessWidget {
  const LibrarianHomeScreen({super.key});

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.chevron_right, color: Colors.orange),
        onTap: onTap,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Log Out",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.green),
              ),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();

                // Use a simpler approach that doesn't depend on Supabase
                StorageServices.clearAll();

                // Navigate to login screen
                Get.offAllNamed(RouteNames.login);
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE8C6),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 60),
              child: Text(
                'Hello! Librarian',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Image and Edit Button
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black,
                        child: Text(
                          'VS',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vivek Sharma',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'sharma.vivek@gmail.com',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  // Menu Items
                  _buildMenuItem(
                    title: 'Personal Info',
                    icon: Icons.person_outline,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: 'All Books in Library',
                    icon: Icons.library_books,
                    onTap: () => Get.toNamed(RouteNames.allBooks),
                  ),
                  _buildMenuItem(
                    title: 'All Issued Books',
                    icon: Icons.book,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: 'Delete a Book',
                    icon: Icons.delete_outline,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: 'Help & Support',
                    icon: Icons.help_outline,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    title: 'Log Out',
                    icon: Icons.logout,
                    onTap: () {_confirmLogout(context);},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home, label: 'Home', isSelected: true),
              GestureDetector(
                onTap: () => Get.toNamed(RouteNames.addBook),
                child: _buildNavItem(icon: Icons.add_box, label: 'Add Book'),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(RouteNames.issueReturnBook),
                child: _buildNavItem(
                  icon: Icons.swap_horiz,
                  label: 'Issue/Return',
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(RouteNames.allUsers),
                child: _buildNavItem(icon: Icons.people, label: 'All Students'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
