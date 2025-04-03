import 'package:book_world/routes/route_names.dart';
import 'package:book_world/screens/Users/borrowed_books_screen.dart';
import 'package:book_world/screens/Users/home_screen.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:book_world/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  AccountScreen({super.key})
    : userName = StorageServices.userSession?['name']!,
      userEmail = StorageServices.userSession?['email']!;

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Log Out"),
              content: const Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    StorageServices.clearAll();
                    Get.offAllNamed(RouteNames.login);
                  },
                  child: const Text("Log Out"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget? screen,
  ) {
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
        onTap: () {
          if (title == 'Log Out') {
            StorageServices.setUserSession(null);
            _confirmLogout(context);
          } else if (screen != null) {
            Get.to(() => screen); // Navigate to the screen directly
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(
            color: Colors.orange,
            fontFamily: 'Sanchez',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Column(
                children: [
                  // Profile Image and Edit Button
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 65,
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
                  Text(
                    userName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(userEmail, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    'Personal Info',
                    Icons.person_outline,
                    null,
                  ),
                  _buildMenuItem(
                    context,
                    'Purchase History',
                    Icons.history,
                    null,
                  ),
                  _buildMenuItem(
                    context,
                    'Borrowed Books',
                    Icons.book,
                    const BorrowedBooksScreen(),
                  ),
                  _buildMenuItem(context, 'Settings', Icons.settings, null),
                  _buildMenuItem(
                    context,
                    'Invite a Friend',
                    Icons.person_add,
                    null,
                  ),
                  _buildMenuItem(
                    context,
                    'Help & Support',
                    Icons.help_outline,
                    null,
                  ),
                  _buildMenuItem(context, 'Log Out', Icons.logout, null),
                  /* ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.orange,
                    ),
                  ),
                  */
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to HomeScreen and remove all previous routes using Get
              Get.offAll(() => const HomeScreen());
              break;
            case 1:
              Get.toNamed(RouteNames.savedBooks);
              break;
            case 2:
              Get.toNamed(RouteNames.borrowedBooks);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Borrowed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
