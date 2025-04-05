import 'package:flutter/material.dart';
import 'package:practice_app/librarian_screen/add_book_screen.dart';
import 'package:practice_app/librarian_screen/issue_return_screen.dart';
import 'package:practice_app/librarian_screen/all_students_screen.dart';
import 'package:practice_app/librarian_screen/all_books_screen.dart';

class LibrarianHomeScreen extends StatelessWidget {
  const LibrarianHomeScreen({super.key});

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

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
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.orange),
        onTap: onTap,
      ),
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
                'Hello! Admin',
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AllBooksScreen()),
                      );
                    },
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
                    onTap: () {},
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
                onTap: () => _navigateToScreen(context, const AddBookScreen()),
                child: _buildNavItem(icon: Icons.add_box, label: 'Add Book'),
              ),
              GestureDetector(
                onTap: () =>
                    _navigateToScreen(context, const IssueReturnScreen()),
                child: _buildNavItem(
                    icon: Icons.swap_horiz, label: 'Issue/Return'),
              ),
              GestureDetector(
                onTap: () =>
                    _navigateToScreen(context, const AllStudentsScreen()),
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
        Icon(
          icon,
          color: isSelected ? Colors.orange : Colors.grey,
        ),
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
