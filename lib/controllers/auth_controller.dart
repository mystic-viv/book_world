// ignore_for_file: avoid_print

import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/auth_service.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:book_world/utils/helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final storage = GetStorage();

  var name = ''.obs;
  var username = ''.obs;
  var mobileNumber = ''.obs;
  var dateOfBirth = DateTime.now().obs;
  var localAddress = ''.obs;
  var localPincode = ''.obs;
  var permanentAddress = ''.obs;
  var permanentPincode = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var signupLoading = false.obs;
  var loginLoading = false.obs;
  var librarianSignupLoading = false.obs;
  var librarianCheckLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Reset loading states
    signupLoading.value = false;
    loginLoading.value = false;
    librarianSignupLoading.value = false;
    librarianCheckLoading.value = false;
  }

  @override
  void onClose() {
    // Cancel any ongoing operations
    signupLoading.value = false;
    loginLoading.value = false;
    librarianSignupLoading.value = false;
    librarianCheckLoading.value = false;
    super.onClose();
  }

  // * Signup Function
  Future<void> signup(
    String email,
    String password,
    String username,
    String name,
    String mobileNumber,
    DateTime dateOfBirth,
    String localAddress,
    String permanentAddress,
  ) async {
    try {
      signupLoading.value = true;

      // Use the AuthService for signup
      final AuthResponse response = await AuthService.signUp(
        email: email,
        password: password,
        username: username,
        name: name,
        mobileNumber: mobileNumber,
        dateOfBirth: dateOfBirth,
        localAddress: localAddress,
        permanentAddress: permanentAddress,
      );

      signupLoading.value = false;
      
      if (response.user != null) {
        showSnackBar("Success", "Account created successfully!");
        Get.offAllNamed(RouteNames.login); // Navigate to login screen
      }
    } on AuthException catch (error) {
      signupLoading.value = false;
      showSnackBar("Error", error.message, isError: true); // Show error message
    } catch (error) {
      signupLoading.value = false;
      print("Signup error: $error");
      showSnackBar(
        "Error",
        "Something went wrong. Please try again.", isError: true
      ); // Handle unexpected errors
    }
  }
    // * Login Function
    Future<void> login(String input, String password) async {
      try {
        loginLoading.value = true;

        // Use the AuthService for login
        final AuthResponse response = await AuthService.login(input, password);
      
        loginLoading.value = false;

        if (response.user != null) {
          showSnackBar("Success", "Logged in successfully!", isError: true);
        
          // Check user role and navigate accordingly
          final userRole = AuthService.getUserRole();
          if (userRole == 'librarian') {
            Get.offAllNamed(RouteNames.librarianHome);
          } else {
            Get.offAllNamed(RouteNames.home);
          }
        }
      } on AuthException catch (error) {
        loginLoading.value = false;
        print("AuthException: ${error.message}");
        showSnackBar("Error", error.message, isError: true);
      } catch (error) {
        loginLoading.value = false;
        print("Login error: $error");
        showSnackBar("Error", "Something went wrong. Please try again.", isError: true);
      }
    }
  // * Logout Function
  Future<void> logout() async {
    try {
      await AuthService.logout();
      
      // Show success message
      showSnackBar("Success", "Logged out successfully!");

      // Navigate to login screen
      Get.offAllNamed(RouteNames.login);
    } catch (error) {
      print("Logout error: $error");
      showSnackBar("Error", "Something went wrong during logout.", isError: true);
    }
  }

  // * Check if email is registered as librarian
  Future<bool> checkLibrarianEmail(String email) async {
    try {
      librarianCheckLoading.value = true;
      final isLibrarian = await AuthService.isRegisteredLibrarian(email);
      librarianCheckLoading.value = false;
      
      if (!isLibrarian) {
        showSnackBar("Error", "Email not found in librarian records", isError: true);
      }
      
      return isLibrarian;
    } catch (error) {
      librarianCheckLoading.value = false;
      print("Librarian check error: $error");
      showSnackBar("Error", "Failed to verify librarian status",isError: true);
      return false;
    }
  }

  // * Librarian Signup Function
  Future<void> librarianSignup(String email, String password) async {
    try {
      librarianSignupLoading.value = true;

      // Use the AuthService for librarian signup
      final AuthResponse response = await AuthService.librarianSignUp(
        email: email,
        password: password,
      );

      librarianSignupLoading.value = false;
      
      if (response.user != null) {
        showSnackBar("Success", "Librarian account created successfully!");
        Get.offAllNamed(RouteNames.librarianHome); // Navigate to librarian dashboard
      }
    } on AuthException catch (error) {
      librarianSignupLoading.value = false;
      showSnackBar("Error", error.message, isError: true); // Show error message
    } catch (error) {
      librarianSignupLoading.value = false;
      print("Librarian signup error: $error");
      showSnackBar(
        "Error",
        "Something went wrong. Please try again.",
        isError: true
      ); // Handle unexpected errors
    }
  }

  // * Check if user is authenticated
  bool isAuthenticated() {
    return AuthService.isAuthenticated();
  }

  // * Get current user role
  String getUserRole() {
    return AuthService.getUserRole();
  }

  // * Check if user is librarian
  bool isLibrarian() {
    return AuthService.getUserRole() == 'librarian';
  }

  // * Get user custom ID
  String? getUserCustomId() {
    final session = StorageServices.userSession;
    return session != null ? session['custom_id'] : null;
  }

  
    // * Reset Password Function

    // Add this RxBool for loading state
    var resetPasswordLoading = false.obs;
    var confirmResetLoading = false.obs;

    // Add this method to handle password reset
    Future<void> resetPassword(String email) async {
      try {
        resetPasswordLoading.value = true;
      
        // Call the AuthService to handle the password reset
        await AuthService.resetPassword(email);
      
        resetPasswordLoading.value = false;
      
        // Show success message
        showSnackBar("Success", "Password reset link has been sent to your email");
      
        // Navigate back to login screen
        Get.back();
      } catch (error) {
        resetPasswordLoading.value = false;
        print("Password reset error: $error");
        showSnackBar("Error", "Failed to send password reset email. Please try again.", isError: true);
      }
    }

    // Add this method to handle password reset confirmation
    Future<void> confirmPasswordReset(String newPassword) async {
      try {
        confirmResetLoading.value = true;
      
        // Call the AuthService to update the password
        await AuthService.confirmPasswordReset(newPassword);
      
        confirmResetLoading.value = false;
      
        // Show success message
        showSnackBar("Success", "Your password has been reset successfully");
      
        // Navigate to login screen
        Get.offAllNamed(RouteNames.login);
      } catch (error) {
        confirmResetLoading.value = false;
        print("Password reset confirmation error: $error");
        showSnackBar("Error", "Failed to reset password. Please try again.", isError: true);
      }
    }
  }