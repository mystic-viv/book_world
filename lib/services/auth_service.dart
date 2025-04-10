// ignore_for_file: avoid_print
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
        // Check if email already exists
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
          data: {'role': 'user'}
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
            final userData = await client!
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
  // Create a new librarian (admin only)
  static Future<Map<String, dynamic>> createLibrarian({
    required String email,
    required String name,
    required String mobileNumber,
    required DateTime dateOfBirth,
    required String workAddress,
    required String homeAddress,
    required String libraryBranch,
    String? profilePictureUrl,
  }) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    try {
      // Check if current user is admin
      if (!isAdmin()) {
        throw Exception("Only admins can create librarians");
      }

      // Format date of birth
      final formattedDate = DateFormat('yyyy-MM-dd').format(dateOfBirth);

      // Create a record in the librarians table (custom_id will be generated by trigger)
      final response =
          await client!.from('librarians').insert({
            'email': email,
            'name': name,
            'mobile': mobileNumber,
            'date_of_birth': formattedDate,
            'work_address': workAddress,
            'home_address': homeAddress,
            'library_branch': libraryBranch,
            'profile_picture_url': profilePictureUrl,
            'is_active': true,
            'role': 'librarian',
          }).single();

      return {
        'success': true,
        'message': 'Librarian created successfully',
        'data': response,
      };
    } catch (e) {
      print("Error creating librarian: $e");
      return {
        'success': false,
        'message': 'Failed to create librarian: ${e.toString()}',
      };
    }
  }

  // Login with email/username and password
  static Future<AuthResponse> login(String input, String password) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    String email = input; // Default to input being an email

    // Check if the input is not an email (assume it's a username)
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(input)) {
      print(
        "Input is not an email, attempting to fetch email for username: $input",
      );

      // Query Supabase to get the email associated with the username
      final response =
          await client!
              .from('users')
              .select('email')
              .filter('username', 'eq', input)
              .maybeSingle();

      if (response == null || response['email'] == null) {
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
      // Fetch user data from the database
      final userData =
          await client!
              .from('users')
              .select('custom_id, role, username, name')
              .eq('id', response.user!.id)
              .single();

      final role = userData['role'];

      if (role == 'librarian') {
        // Get librarian-specific data
        final librarianData =
            await client!
                .from('librarians')
                .select('library_branch, profile_picture_url')
                .eq('id', response.user!.id)
                .maybeSingle();

        StorageServices.setUserSession({
          'id': response.user!.id,
          'custom_id': userData['custom_id'],
          'email': response.user!.email,
          'username': userData['username'],
          'name': userData['name'],
          'role': role,
          'library_branch': librarianData?['library_branch'],
          'profile_picture_url': librarianData?['profile_picture_url'],
          'token': response.session?.accessToken,
        });
      } else {
        // Regular user
        StorageServices.setUserSession({
          'id': response.user!.id,
          'custom_id': userData['custom_id'],
          'email': response.user!.email,
          'username': userData['username'],
          'name': userData['name'],
          'role': role,
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

  // Check if user is admin
  static bool isAdmin() {
    return getUserRole() == 'admin';
  }

  // Check if user is librarian
  static bool isLibrarian() {
    final role = getUserRole();
    return role == 'librarian' || role == 'admin';
  }

  // Get current user's custom ID
  static String? getUserCustomId() {
    final session = StorageServices.userSession;
    return session?['custom_id'];
  }

  // Get current user's library branch (for librarians)
  static String? getLibraryBranch() {
    final session = StorageServices.userSession;
    return session?['library_branch'];
  }

  // Refresh user session with latest data
  static Future<void> refreshSession(Session session) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }

    try {
      final user = session.user;

      // Fetch user data from users table
      final userData =
          await client!
              .from('users')
              .select('custom_id, role, username, name')
              .eq('id', user.id)
              .single();

      final role = userData['role'];

      if (role == 'librarian') {
        // Get librarian-specific data
        final librarianData =
            await client!
                .from('librarians')
                .select('library_branch, profile_picture_url')
                .eq('id', user.id)
                .maybeSingle();

        StorageServices.setUserSession({
          'id': user.id,
          'custom_id': userData['custom_id'],
          'email': user.email,
          'username': userData['username'],
          'name': userData['name'],
          'role': role,
          'library_branch': librarianData?['library_branch'],
          'profile_picture_url': librarianData?['profile_picture_url'],
          'token': session.accessToken,
        });
      } else {
        // Regular user
        StorageServices.setUserSession({
          'id': user.id,
          'custom_id': userData['custom_id'],
          'email': user.email,
          'username': userData['username'],
          'name': userData['name'],
          'role': role,
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
}
