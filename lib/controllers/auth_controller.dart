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

  @override
  void onInit() {
    super.onInit();
    // Reset loading states
    signupLoading.value = false;
    loginLoading.value = false;
  }

  @override
  void onClose() {
    // Cancel any ongoing operations
    signupLoading.value = false;
    loginLoading.value = false;
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
      showSnackBar("Error", error.message); // Show error message
    } catch (error) {
      signupLoading.value = false;
      print("Signup error: $error");
      showSnackBar(
        "Error",
        "Something went wrong. Please try again.",
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
        showSnackBar("Success", "Logged in successfully!");
        
        // Check user role and navigate accordingly
        final userRole = AuthService.getUserRole();
        if (userRole == 'librarian') {
          //Get.offAllNamed(RouteNames.librarianHome);
        } else {
          Get.offAllNamed(RouteNames.home);
        }
      }
    } on AuthException catch (error) {
      loginLoading.value = false;
      print("AuthException: ${error.message}");
      showSnackBar("Error", error.message);
    } catch (error) {
      loginLoading.value = false;
      print("Login error: $error");
      showSnackBar("Error", "Something went wrong. Please try again.");
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
      showSnackBar("Error", "Something went wrong during logout.");
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

  // * Check if user is admin
  bool isAdmin() {
    return AuthService.isAdmin();
  }

  // * Check if user is librarian
  bool isLibrarian() {
    return AuthService.isLibrarian();
  }

  // * Get user custom ID
  String? getUserCustomId() {
    final session = StorageServices.userSession;
    return session != null ? session['custom_id'] : null;
  }

  // * Mock login for testing (can be removed in production)
  Future<void> mockLogin(String email, String password) async {
    try {
      loginLoading.value = true;

      // Simulate a delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock user data
      final mockUserData = {
        'email': email,
        'username': 'test_user',
        'name': 'Test User',
        'id': 'mock-user-id',
        'custom_id': 'BWU-001',
        'role': 'user',
        'token': 'mock-token',
      };

      // Save the mock user session
      StorageServices.setUserSession(mockUserData);

      loginLoading.value = false;
      showSnackBar("Success", "Logged in successfully (Mock)!");
      Get.offAllNamed(RouteNames.home);
    } catch (error) {
      loginLoading.value = false;
      print("Mock login error: $error");
      showSnackBar("Error", "Something went wrong during mock login.");
    }
  }
}