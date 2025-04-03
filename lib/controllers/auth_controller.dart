// ignore_for_file: avoid_print

import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:book_world/services/supabase_service.dart';
import 'package:book_world/utils/helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final storage = GetStorage();

  var name = ''.obs;
  var username = ''.obs;
  var mobileNumber = ''.obs;
  var dateOfBirth = DateTime.now().obs; // Reactive nullable DateTime
  var localAddress = ''.obs;
  var localPincode = ''.obs;
  var permanentAddress = ''.obs;
  var permanentPincode = ''.obs;
  var email = ''.obs;
  var password = ''.obs;

  //Save user data to local storage
  void saveUserData() {
    storage.write('name', name.value);
    storage.write('username', username.value);
    storage.write('mobileNumber', mobileNumber.value);
    storage.write('dateOfBirth', dateOfBirth.value.toIso8601String());
    storage.write('localAdress', localAddress.value);
    storage.write('localPincode', localPincode.value);
    storage.write('permanentAddress', permanentAddress.value);
    storage.write('permanentPincode', permanentPincode.value);
    storage.write('email', email.value);
    storage.write('password', password.value);
  }

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
    //String localPincode,
    String permanentAddress,
    //String permanentPincode,
  ) async {
    try {
      signupLoading.value = true;

      // Check if client is available
      final client = SupabaseService.client;
      if (client == null) {
        throw Exception("Supabase client is not initialized");
      }

      // Call Supabase signup API
      final AuthResponse data = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'name': name,
          'mobileNumber': mobileNumber,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'localAddress': localAddress,
          // 'localPincode': localPincode,
          'permanentAddress': permanentAddress,
          // 'permanentPincode': permanentPincode,
        },
      );
      signupLoading.value = false;
      if (data.user != null) {
        // Save user data to local storage
        StorageServices.setUserSession({
          'email': data.user!.email,
          'username': data.user!.userMetadata!['username'],
          'name': data.user!.userMetadata!['name'],
          'token': data.session?.accessToken,
        });

        showSnackBar("Success", "Account created successfully!");
        Get.offAllNamed(RouteNames.login); // Navigate to login screen
      }
    } on AuthException catch (error) {
      signupLoading.value = false;
      showSnackBar("Error", error.message); // Show error message
    } catch (error) {
      signupLoading.value = false;
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

      // Check if client is available
      final client = SupabaseService.client;
      if (client == null) {
        throw Exception("Supabase client is not initialized");
      }

      String email = input; // Default to input being an email

      // Check if the input is not an email (assume it's a username)
      // Fix the regex pattern by removing the backticks
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input)) {
        print(
          "Input is not an email, attempting to fetch email for username: $input",
        );
        // Query Supabase to get the email associated with the username
        final response =
            await client
                .from('users') // Ensure 'users' is the correct table name
                .select(
                  'email, metadata->>username',
                ) // Extract 'username' from 'metadata'
                .eq(
                  'metadata->>username',
                  input,
                ) // Match the username in metadata
                .maybeSingle();

        if (response == null || response['email'] == null) {
          throw AuthException('Invalid username or email address');
        }

        email = response['email']; // Use the retrieved email
      }

      print("Proceeding with login using email: $email");

      // Proceed with login using the email
      final AuthResponse response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      loginLoading.value = false;

      if (response.user != null) {
        // Save the user session
        StorageServices.setUserSession({
          'email': response.user!.email,
          'username': response.user!.userMetadata!['username'],
          'name': response.user!.userMetadata!['name'],
          'id': response.user!.id,
          'token': response.session?.accessToken,
        });
        showSnackBar("Success", "Logged in successfully!");
        Get.offAllNamed(RouteNames.home);
      }
    } on AuthException catch (error) {
      loginLoading.value = false;
      print("AuthException: ${error.message}");
      showSnackBar("Error", error.message);
    } catch (error) {
      loginLoading.value = false;
      print("Unexpected error: $error");
      showSnackBar("Error", "Something went wrong. Please try again.");
    }
  }

  // * Logout Function
  Future<void> logout() async {
    try {
      // Check if client is available
      final client = SupabaseService.client;
      if (client != null) {
        // Sign out from Supabase
        await client.auth.signOut();
      }

      // Clear the user session data
      StorageServices.clearAll();

      // Show success message
      showSnackBar("Success", "Logged out successfully!");

      // Navigate to login screen
      Get.offAllNamed(RouteNames.login);
    } catch (error) {
      print("Logout error: $error");
      showSnackBar("Error", "Something went wrong during logout.");
    }
  }

  // Add this method to your AuthController class
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
