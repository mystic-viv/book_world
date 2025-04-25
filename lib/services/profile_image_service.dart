import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:book_world/services/user_service.dart';
import 'package:book_world/utils/helper.dart';

class ProfileImageService {
  final UserService _userService = UserService();
  
  /// Handles the complete process of selecting and uploading a profile picture
  Future<String?> handleProfilePictureUpload(BuildContext context) async {
    try {
      // Initialize image picker
      final ImagePicker picker = ImagePicker();
      
      // Show options to user
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return null;
      
      // Pick image from selected source
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85, // Reduce quality slightly to optimize file size
      );
      
      if (image == null) return null;
      
      // Show loading indicator
      _showLoadingDialog(context);
      
      // Read image as bytes
      final Uint8List fileBytes = await image.readAsBytes();
      final String fileName = image.name;
      
      // Upload profile picture using the existing service method
      final String? imageUrl = await _userService.uploadProfilePicture(
        fileBytes, 
        fileName
      );
      
      // Hide loading indicator
      Navigator.of(context, rootNavigator: true).pop();
      
      if (imageUrl != null) {
        // Update user profile with the new image URL
        final bool success = await _userService.updateProfilePicture(imageUrl);
        
        if (success) {
          showSnackBar("Success", "Profile picture updated successfully", isError: false);
          return imageUrl;
        } else {
          showSnackBar("Error", "Failed to update profile picture", isError: true);
          return null;
        }
      } else {
        showSnackBar("Error", "Failed to upload image", isError: true);
        return null;
      }
    } catch (e) {
      // Hide loading indicator if visible
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      debugPrint('Error uploading profile picture: $e');
      showSnackBar("Error", "An error occurred: ${e.toString()}", isError: true);
      return null;
    }
  }
  
  /// Shows a dialog to let user choose between camera and gallery
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Take a picture'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Select from gallery'),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Shows a loading dialog
  void _showLoadingDialog(BuildContext context) {
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
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Uploading image..."),
              ],
            ),
          ),
        );
      },
    );
  }
}