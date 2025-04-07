import 'package:book_world/services/supabase_service.dart';

class IDService {
  static final client = SupabaseService.client;

  // Prefix constants
  static const String USER_PREFIX = 'BWU-';
  static const String BOOK_PREFIX = 'BWB-';
  static const String LIBRARIAN_PREFIX = 'BWL-';

  // Generate a new user ID
  static Future<String> generateUserId() async {
    return await _generateNextId('users', USER_PREFIX);
  }

  // Generate a new book ID
  static Future<String> generateBookId() async {
    return await _generateNextId('books', BOOK_PREFIX);
  }

  // Generate a new librarian ID
  static Future<String> generateLibrarianId() async {
    return await _generateNextId('librarians', LIBRARIAN_PREFIX);
  }

  // Helper method to generate the next ID in sequence
  static Future<String> _generateNextId(String table, String prefix) async {
    if (client == null) {
      throw Exception("Supabase client is not initialized");
    }
    
    try {
      print("Calling database function to generate next ID for table: $table with prefix: $prefix");
      
      // Call the database function to generate the next ID
      final response = await client!.rpc(
        'generate_next_id',
        params: {
          'table_name': table,
          'id_prefix': prefix
        }
      );
      
      print("Generated ID from database function: $response");
      
      if (response == null) {
        throw Exception("Database function returned null");
      }
      
      return response;
    } catch (e) {
      print("Error calling generate_next_id: $e");
      // Fallback to a timestamp-based ID if the database function fails
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$prefix$timestamp';
    }
  }
  // Validate if a string is a valid user ID
  static bool isValidUserId(String id) {
    return RegExp('^$USER_PREFIX\\d{3}\$').hasMatch(id);
  }

  // Validate if a string is a valid book ID
  static bool isValidBookId(String id) {
    return RegExp('^$BOOK_PREFIX\\d{3}\$').hasMatch(id);
  }

  // Validate if a string is a valid librarian ID
  static bool isValidLibrarianId(String id) {
    return RegExp('^$LIBRARIAN_PREFIX\\d{3}\$').hasMatch(id);
  }
}
