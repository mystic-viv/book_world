import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:book_world/models/user_model.dart';
import 'package:book_world/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:book_world/utils/helper.dart';

class UserService {
  // Get Supabase client from the service
  final _supabase = SupabaseService.client;

  // Get current user ID
  String? get currentUserId => _supabase!.auth.currentUser?.id;

  // Check if user is logged in
  bool get isLoggedIn => currentUserId != null;

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      if (!isLoggedIn || currentUserId == null) return null;

      final response = await _supabase
          ?.from('users')
          .select()
          .eq('id', currentUserId!)
          .maybeSingle(); // Use maybeSingle instead of single to avoid errors if no record is found

      if (response == null) return null;

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response =
          await _supabase!.from('users').select().eq('id', userId).single();

      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      if (!isLoggedIn) return false;

      // Ensure we're updating the current user
      if (updatedUser.id != currentUserId) {
        throw Exception('You can only update your own profile');
      }

      // Get profile update data (excludes sensitive fields)
      // Alternative for line 66
      final updateData = {
        'username': updatedUser.username,
        'name': updatedUser.name,
        'mobile': updatedUser.mobile,
        'date_of_birth':
            updatedUser.dateOfBirth?.toIso8601String().split('T').first,
        'local_address': updatedUser.localAddress,
        'permanent_address': updatedUser.permanentAddress,
        'profile_picture_url': updatedUser.profilePictureUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add updated_at timestamp
      updateData['updated_at'] = DateTime.now().toIso8601String();

      // Update user in the database
      await _supabase!
          .from('users')
          .update(updateData)
          .eq('id', currentUserId!);

      return true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Update user password
  Future<bool> updateUserPassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (!isLoggedIn) return false;

      // First verify the current password
      final user = await _supabase!.auth.currentUser;
      if (user == null) return false;

      // Update the password using Supabase Auth API
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));

      // Show success message
      showSnackBar("Success", "Password updated successfully", isError: false);

      return true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      showSnackBar(
        "Error",
        "Failed to update password: ${e.toString()}",
        isError: true,
      );
      return false;
    }
  }

  // Update user email
  Future<bool> updateUserEmail(String newEmail, String password) async {
    try {
      if (!isLoggedIn) return false;

      // Update email in auth
      await _supabase!.auth.updateUser(UserAttributes(email: newEmail));

      // Update email in users table
      await _supabase
          .from('users')
          .update({
            'email': newEmail,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUserId!);

      showSnackBar(
        "Success",
        "Email updated successfully. Please verify your new email.",
        isError: false,
      );
      return true;
    } catch (e) {
      debugPrint('Error updating email: $e');
      showSnackBar(
        "Error",
        "Failed to update email: ${e.toString()}",
        isError: true,
      );
      return false;
    }
  }

  // Update user profile picture
  Future<bool> updateProfilePicture(String imageUrl) async {
    try {
      if (!isLoggedIn) return false;

      await _supabase!
          .from('users')
          .update({
            'profile_picture_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUserId!);

      return true;
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      return false;
    }
  }

  // Upload profile picture to storage and get URL
  Future<void> selectAndUploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Read the image as bytes
      final Uint8List fileBytes = await image.readAsBytes();

      // Get the file name from the path
      final String fileName = image.name;

      // Use the existing service method to upload
      final UserService userService = UserService();
      final String? imageUrl = await userService.uploadProfilePicture(
        fileBytes,
        fileName,
      );

      if (imageUrl != null) {
        // Update the user's profile with the new image URL
        await userService.updateProfilePicture(imageUrl);
        // Show success message
        showSnackBar(
          "Success",
          "Profile picture updated successfully",
          isError: false,
        );
      } else {
        // Show error message
        showSnackBar(
          "Error",
          "Failed to upload profile picture",
          isError: true,
        );
      }
    }
  }

  // Delete user account
  Future<bool> deleteUserAccount(String password) async {
    try {
      if (!isLoggedIn) return false;

      // Verify password first (for security)
      final response = await _supabase!.auth.signInWithPassword(
        email: _supabase.auth.currentUser!.email!,
        password: password,
      );

      if (response.user == null) {
        showSnackBar("Error", "Incorrect password", isError: true);
        return false;
      }

      // Delete user from the database
      // Note: You might want to use a cascade delete trigger in your database
      // or handle related data deletion here
      await _supabase.from('users').delete().eq('id', currentUserId!);

      // Delete user from auth
      await _supabase.auth.admin.deleteUser(currentUserId!);

      showSnackBar("Success", "Your account has been deleted", isError: false);
      return true;
    } catch (e) {
      debugPrint('Error deleting user account: $e');
      showSnackBar(
        "Error",
        "Failed to delete account: ${e.toString()}",
        isError: true,
      );
      return false;
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response =
          await _supabase!
              .from('users')
              .select('username')
              .eq('username', username)
              .maybeSingle();

      // If response is null, username is available
      return response == null;
    } catch (e) {
      debugPrint('Error checking username availability: $e');
      return false;
    }
  }

  // Check if mobile number is available
  Future<bool> isMobileAvailable(String mobile) async {
    try {
      final response =
          await _supabase!
              .from('users')
              .select('mobile')
              .eq('mobile', mobile)
              .maybeSingle();

      // If response is null, mobile is available
      return response == null;
    } catch (e) {
      debugPrint('Error checking mobile availability: $e');
      return false;
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      if (!isLoggedIn) return null;

      final response =
          await _supabase!
              .from('users')
              .select('role')
              .eq('id', currentUserId!)
              .single();

      return response['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // Check if user is librarian
  Future<bool> isLibrarian() async {
    final role = await getUserRole();
    return role == 'librarian';
  }

  // Upload profile picture to storage and get URL
  Future<String?> uploadProfilePicture(
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      if (!isLoggedIn) return null;

      // Create a unique file path
      final filePath =
          'profile_pictures/$currentUserId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    
      // Determine content type based on file extension
      String contentType = 'image/jpeg'; // Default
      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      }

      // Upload the file
      await _supabase!.storage
          .from('user-profiles')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(contentType: contentType), // Dynamic content type
          );

      // Get the public URL
      final imageUrl = _supabase.storage
          .from('user-profiles')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }
}
