import 'package:book_world/routes/route_names.dart';
import 'package:book_world/screens/Users/borrowed_books_screen.dart';
import 'package:book_world/screens/Users/Home/home_screen.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:book_world/services/user_service.dart';
import 'package:book_world/utils/helper.dart';
import 'package:book_world/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class AccountScreen extends StatefulWidget {
  AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = StorageServices.userSession?['name'] ?? "Guest";
  String userEmail =
      StorageServices.userSession?['email'] ?? "guest@example.com";
  String? profilePictureUrl =
      StorageServices.userSession?['profile_picture_url'];
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          userName = currentUser.name;
          userEmail = currentUser.email;
          profilePictureUrl = currentUser.profilePictureUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Fall back to session data if available
      setState(() {
        userName = StorageServices.userSession?['name'] ?? "Guest";
        userEmail = StorageServices.userSession?['email'] ?? "guest@example.com";
        profilePictureUrl = StorageServices.userSession?['profile_picture_url'];
      });
    }
  }

  String profileImgText() {
    // Check if userName is null or empty
    if (userName.isEmpty) {
      return "G"; // Default value for unknown user
    }

    // Trim and split the name
    List<String> nameParts = userName.trim().split(' ');

    // Filter out empty parts
    nameParts = nameParts.where((part) => part.isNotEmpty).toList();

    if (nameParts.isEmpty) {
      return "U"; // Default value if no valid parts after filtering
    }

    if (nameParts.length == 1) {
      // If only one name part, return its first letter
      return nameParts[0][0].toUpperCase();
    } else {
      // Get first letter of first name and first letter of last name
      String firstInitial = nameParts.first[0].toUpperCase();
      String lastInitial = nameParts.last[0].toUpperCase();
      return firstInitial + lastInitial;
    }
  }

  // ignore: non_constant_identifier_names
  String get profile_image_text => profileImgText();

  // Method to handle profile picture upload
  Future<void> _uploadProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show options dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.orange,
                  ),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.orange),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      // Pick image from selected source
      final XFile? image = await picker.pickImage(
        source: source,
      );

      if (image == null) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(width: 20),
                  Text("Uploading image..."),
                ],
              ),
            ),
          );
        },
      );

      try {
        // Read image as bytes
        final Uint8List fileBytes = await image.readAsBytes();
        final String fileName = image.name;

        // Upload profile picture
        final String? imageUrl = await _userService.uploadProfilePicture(
          fileBytes,
          fileName,
        );

        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        if (imageUrl != null) {
          // Update user profile with new image URL
          final bool success = await _userService.updateProfilePicture(
            imageUrl,
          );

          if (success) {
            // Update local state and storage
            setState(() {
              profilePictureUrl = imageUrl;
            });

            // Update session data
            final Map<String, dynamic> userData =
                StorageServices.userSession ?? {};
            userData['profile_picture_url'] = imageUrl;
            await StorageServices.saveUserSession(userData);

            showSnackBar(
              "Success",
              "Profile picture updated successfully",
              isError: false,
            );
          } else {
            showSnackBar(
              "Error",
              "Failed to update profile picture",
              isError: true,
            );
          }
        } else {
          showSnackBar("Error", "Failed to upload image", isError: true);
        }
      } catch (e) {
        // Close loading dialog if open
        if (Navigator.canPop(context)) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        showSnackBar(
          "Error",
          "An error occurred: ${e.toString()}",
          isError: true,
        );
        debugPrint("An error occurred: $e");
      }
    } catch (e) {
      showSnackBar(
        "Error",
        "An error occurred: ${e.toString()}",
        isError: true,
      );
      debugPrint("An error occurred: $e");
    }
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
            _confirmLogout(context);
          } else if (screen != null) {
            Get.to(() => screen); // Navigate to the screen directly
          }
        },
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
      appBar: CustomAppBar(title: "Account"),
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
                      // Profile image or text avatar
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.black,
                        backgroundImage:
                            profilePictureUrl != null &&
                                    profilePictureUrl!.isNotEmpty
                                ? NetworkImage(profilePictureUrl!)
                                : null,
                        child:
                            profilePictureUrl == null ||
                                    profilePictureUrl!.isEmpty
                                ? Text(
                                  profile_image_text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                  ),
                                )
                                : null,
                      ),
                      // Edit button
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _uploadProfilePicture,
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
