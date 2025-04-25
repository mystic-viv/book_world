import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:book_world/services/user_service.dart';
import 'package:book_world/utils/helper.dart';

class ImagePickerService {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the gallery and uploads it as a profile picture
  /// Returns the URL of the uploaded image if successful, null otherwise
  Future<String?> pickAndUploadProfilePicture(BuildContext context) async {
    try {
      // Pick an image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Reduce quality to optimize upload size
      );

      if (image == null) {
        // User canceled the picker
        return null;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        // Read image as bytes
        final Uint8List fileBytes = await image.readAsBytes();
        final String fileName = image.name;

        // Upload the image to Supabase storage
        final String? imageUrl = await _userService.uploadProfilePicture(
          fileBytes,
          fileName,
        );

        // If upload successful, update user profile with new image URL
        if (imageUrl != null) {
          await _userService.updateProfilePicture(imageUrl);
          showSnackBar(
            "Success",
            "Profile picture updated successfully",
            isError: false,
          );
        } else {
          showSnackBar(
            "Error",
            "Failed to upload profile picture",
            isError: true,
          );
        }

        return imageUrl;
      } finally {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      debugPrint('Error picking/uploading image: $e');
      showSnackBar(
        "Error",
        "Failed to process image: ${e.toString()}",
        isError: true,
      );
      return null;
    }
  }

  /// Picks an image from the camera and uploads it as a profile picture
  /// Returns the URL of the uploaded image if successful, null otherwise
  Future<String?> captureAndUploadProfilePicture(BuildContext context) async {
    try {
      // Capture an image from camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) {
        // User canceled the capture
        return null;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        // Read image as bytes
        final Uint8List fileBytes = await image.readAsBytes();
        final String fileName = image.name;

        // Upload the image to Supabase storage
        final String? imageUrl = await _userService.uploadProfilePicture(
          fileBytes,
          fileName,
        );

        // If upload successful, update user profile with new image URL
        if (imageUrl != null) {
          await _userService.updateProfilePicture(imageUrl);
          showSnackBar(
            "Success",
            "Profile picture updated successfully",
            isError: false,
          );
        } else {
          showSnackBar(
            "Error",
            "Failed to upload profile picture",
            isError: true,
          );
        }

        return imageUrl;
      } finally {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      debugPrint('Error capturing/uploading image: $e');
      showSnackBar(
        "Error",
        "Failed to process image: ${e.toString()}",
        isError: true,
      );
      return null;
    }
  }

  /// Shows a bottom sheet with options to pick an image from gallery or camera
  Future<String?> showImageSourceOptions(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return null;
    }

    if (source == ImageSource.gallery) {
      return pickAndUploadProfilePicture(context);
    } else {
      return captureAndUploadProfilePicture(context);
    }
  }
}
