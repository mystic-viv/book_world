// ignore_for_file: avoid_print
import 'package:book_world/utils/helper.dart';
import 'package:intl/intl.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:book_world/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Get the Supabase client instance
  static final client = SupabaseService.client;

  // Sign up a new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
    required String mobileNumber,
    required DateTime dateOfBirth,
    required String localAddress,
    required String permanentAddress,
  }) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }
    try {
      // Check if email already exists in users table
      final existingUser =
          await client!
              .from('users')
              .select('email')
              .eq('email', email)
              .maybeSingle();

      if (existingUser != null) {
        throw Exception("Email already registered");
      }

      // Check if username already exists
      final existingUsername =
          await client!
              .from('users')
              .select('username')
              .eq('username', username)
              .maybeSingle();

      if (existingUsername != null) {
        throw Exception("Username already taken");
      }

      // Call Supabase signup API
      final AuthResponse response = await client!.auth.signUp(
        email: email,
        password: password,
        data: {'role': 'user'},
      );

      // If signup successful, store user data
      if (response.user != null) {
        //Converting date of birth format
        final formattedDate = DateFormat('yyyy-MM-dd').format(dateOfBirth);

        try {
          // Insert user data into the 'users' table with custom_id explicitly set to null
          await client!.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'username': username,
            'name': name,
            'mobile': mobileNumber,
            'date_of_birth': formattedDate,
            'local_address': localAddress,
            'permanent_address': permanentAddress,
            'role': 'user',
            'custom_id': null, // Explicitly set to null to trigger generation
          }).single();

          // Wait a moment for the custom_id trigger to complete
          await Future.delayed(Duration(milliseconds: 500));

          // Fetch the generated custom_id
          final userData =
              await client!
                  .from('users')
                  .select('custom_id, role')
                  .eq('id', response.user!.id)
                  .maybeSingle();

          if (userData != null) {
            StorageServices.setUserSession({
              'id': response.user!.id,
              'custom_id': userData['custom_id'],
              'email': response.user!.email,
              'username': username,
              'name': name,
              'role': userData['role'],
              'token': response.session?.accessToken,
            });
          } else {
            print("Warning: User data not found after creation");
            StorageServices.setUserSession({
              'id': response.user!.id,
              'custom_id': 'pending',
              'email': response.user!.email,
              'username': username,
              'name': name,
              'role': 'user',
              'token': response.session?.accessToken,
            });
          }
        } catch (e) {
          print("Error creating user profile: $e");
          StorageServices.setUserSession({
            'id': response.user!.id,
            'custom_id': 'pending',
            'email': response.user!.email,
            'username': username,
            'name': name,
            'role': 'user',
            'token': response.session?.accessToken,
          });
        }
      }

      return response;
    } catch (e) {
      print("Error during signup: $e");
      rethrow;
    }
  }

  // Login with email/username and password
  static Future<AuthResponse> login(String input, String password) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    String email = input; // Default to input being an email
    bool isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);
    // Check if the input is not an email (assume it's a username)
    if (!isEmail) {
      print(
        "Input is not an email, attempting to fetch email for username: $input",
      );

      // Query Supabase to get the email associated with the username
      final response =
          await client!
              .from('users')
              .select('email')
              .eq('username', input.trim())
              .maybeSingle();

      if (response == null || response['email'] == null) {
        print("No email found for username: $input");
        throw AuthException('Invalid username or email address');
      }

      email = response['email']; // Use the retrieved email
    }

    print("Proceeding with login using email: $email");

    // Proceed with login using the email
    final AuthResponse response = await client!.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // If login successful, store user session
    if (response.user != null) {
      // First check if this is a librarian
      final librarianData =
          await client!
              .from('librarians')
              .select('custom_id, name, library_branch')
              .eq('id', response.user!.id)
              .maybeSingle();

      if (librarianData != null) {
        // This is a librarian
        StorageServices.setUserSession({
          'id': response.user!.id,
          'custom_id': librarianData['custom_id'],
          'email': response.user!.email,
          'name': librarianData['name'],
          'role': 'librarian',
          'library_branch': librarianData['library_branch'],
          'token': response.session?.accessToken,
        });
        return response;
      }

      // If not a librarian, check regular users
      final userData =
          await client!
              .from('users')
              .select('custom_id, role, username, name, profile_picture_url')
              .eq('id', response.user!.id)
              .maybeSingle();

      if (userData != null) {
        // Store user session data
        StorageServices.setUserSession({
          'id': response.user!.id,
          'custom_id': userData['custom_id'],
          'email': response.user!.email,
          'username': userData['username'],
          'name': userData['name'],
          'profile_picture_url': userData['profile_picture_url'],
          'role': userData['role'],
          'token': response.session?.accessToken,
        });
      } else {
        // No user record found - store minimal session data
        print("Warning: No user record found for ID: ${response.user!.id}");
        StorageServices.setUserSession({
          'id': response.user!.id,
          'email': response.user!.email,
          'role': 'guest',
          'token': response.session?.accessToken,
        });
      }
    }

    return response;
  }

  // Logout the current user
  static Future<void> logout() async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    // Sign out from Supabase
    await client!.auth.signOut();

    // Clear the user session data
    StorageServices.clearAll();
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return StorageServices.userSession != null;
  }

  // Get current user role
  static String getUserRole() {
    final session = StorageServices.userSession;
    if (session != null && session['role'] != null) {
      return session['role'];
    }
    return 'guest';
  }

  // Get current user's custom ID
  static String? getUserCustomId() {
    final session = StorageServices.userSession;
    return session?['custom_id'];
  }

  // Refresh user session with latest data
  static Future<void> refreshSession(Session session) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    try {
      final user = session.user;

      // First check if this is a librarian
      final librarianData =
          await client!
              .from('librarians')
              .select('custom_id, name, library_branch')
              .eq('id', user.id)
              .maybeSingle(); // Use maybeSingle instead of single

      if (librarianData != null) {
        // This is a librarian
        StorageServices.setUserSession({
          'id': user.id,
          'custom_id': librarianData['custom_id'],
          'email': user.email,
          'name': librarianData['name'],
          'role': 'librarian',
          'library_branch': librarianData['library_branch'],
          'token': session.accessToken,
        });
        return;
      }

      // If not a librarian, check regular users
      final userData =
          await client!
              .from('users')
              .select('custom_id, role, username, name, profile_picture_url')
              .eq('id', user.id)
              .maybeSingle(); // Use maybeSingle instead of single

      if (userData != null) {
        // Regular user found
        StorageServices.setUserSession({
          'id': user.id,
          'custom_id': userData['custom_id'],
          'email': user.email,
          'username': userData['username'],
          'name': userData['name'],
          'profile_picture_url': userData['profile_picture_url'],
          'role': userData['role'],
          'token': session.accessToken,
        });
      } else {
        // No user record found - store minimal session data
        print("Warning: No user record found for ID: ${user.id}");
        StorageServices.setUserSession({
          'id': user.id,
          'email': user.email,
          'role': 'guest',
          'token': session.accessToken,
        });
      }
    } catch (e) {
      print("Error refreshing session: $e");
    }
  }

  // Get user session data
  static Map<String, dynamic>? getUserSession() {
    return StorageServices.userSession;
  }

  // Check if an email is registered as a librarian
  static Future<bool> isRegisteredLibrarian(String email) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    try {
      final librarianData =
          await client!
              .from('librarians')
              .select('email')
              .eq('email', email)
              .maybeSingle();

      return librarianData != null;
    } catch (e) {
      print("Error checking librarian status: $e");
      return false;
    }
  }

  // Librarian signup with email and password
  static Future<AuthResponse> librarianSignUp({
    required String email,
    required String password,
  }) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    try {
      // Check if email exists in librarians table
      final librarianData =
          await client!
              .from('librarians')
              .select('email, name, custom_id, library_branch')
              .eq('email', email)
              .maybeSingle();

      if (librarianData == null) {
        throw Exception("You are not registered as a librarian");
      }

      // Check if email already exists in auth users
      final existingUser =
          await client!
              .from('users')
              .select('email')
              .eq('email', email)
              .maybeSingle();

      if (existingUser != null) {
        throw Exception("Account already exists. Please login instead.");
      }

      // Call Supabase signup API
      final AuthResponse response = await client!.auth.signUp(
        email: email,
        password: password,
        data: {'role': 'librarian'},
      );

      // If signup successful, update librarian record
      if (response.user != null) {
        try {
          // Update the librarian record with auth user ID
          await client!.rpc(
            'link_librarian_to_auth_user',
            params: {
              'auth_user_id': response.user!.id,
              'librarian_email': email,
            },
          );

          // Store session data
          StorageServices.setUserSession({
            'id': response.user!.id,
            'custom_id': librarianData['custom_id'],
            'email': email,
            'name': librarianData['name'],
            'role': 'librarian',
            'library_branch': librarianData['library_branch'],
            'token': response.session?.accessToken,
          });
        } catch (e) {
          print("Error updating librarian record: $e");
          // Still store basic session data
          StorageServices.setUserSession({
            'id': response.user!.id,
            'email': email,
            'name': librarianData['name'],
            'role': 'librarian',
            'token': response.session?.accessToken,
          });
        }
      }

      return response;
    } catch (e) {
      print("Error during librarian signup: $e");
      rethrow;
    }
  }

  // * Reset Password

  static Future<void> resetPassword(String email) async {
    try {
      // Using Supabase to send password reset email
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.book_world://reset-password-callback',
      );
      showSnackBar("Success", "Password reset link has been sent to your email");
    } catch (error) {
      print("AuthService resetPassword error: $error");
      rethrow; // Rethrow to be caught by the controller
    }
  }
  // Add this method to your AuthService class
  static Future<void> confirmPasswordReset(
    String newPassword,
    String accessToken,
  ) async {
    try {
      // final response = await Supabase.instance.client;
      await Supabase.instance.client.auth.setSession(accessToken);
      // Update the user's password using Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (error) {
      print("AuthService confirmPasswordReset error: $error");
      rethrow; // Rethrow to be caught by the controller
    }
  }
}