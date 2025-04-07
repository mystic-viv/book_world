import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageServices {
  static final session = GetStorage();
  
  // Get the current user session
  static dynamic get userSession => session.read('userSession');
  
  // Get user role from session
  static String get userRole => 
      userSession != null && userSession['role'] != null 
          ? userSession['role'] 
          : 'guest';
  
  // Check if user is authenticated
  static bool get isAuthenticated => userSession != null;
  
  // Check if user is admin
  static bool get isAdmin => userRole == 'admin';
  
  // Check if user is librarian
  static bool get isLibrarian => userRole == 'librarian' || isAdmin;
  
  // Check if user is a regular user
  static bool get isUser => userRole == 'user';

  static void setUserSession(dynamic sessionData) {
    if (sessionData == null) {
      session.erase(); // Remove session if null
    } else {
      session.write('userSession', sessionData); // Write session data
    }
  }

  // Modify this method to specifically clear user session
  static void clearUserSession() {
    session.remove('userSession'); // Remove only the userSession data
  }

  static void clearAll() {
    session.erase();
  }
  
  // Save reading progress for a book
  static void saveBookProgress(String bookId, int page) {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = 'book_progress_${userId}_$bookId';
      session.write(key, page);
    }
  }
  
  // Get reading progress for a book
  static int getBookProgress(String bookId) {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = 'book_progress_${userId}_$bookId';
      return session.read(key) ?? 0;
    }
    return 0;
  }
  
  // Save recently viewed books
  static void addToRecentBooks(String bookId) {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = 'recent_books_$userId';
      List<String> recentBooks = getRecentBooks();
      
      // Remove if already exists and add to the beginning
      if (recentBooks.contains(bookId)) {
        recentBooks.remove(bookId);
      }
      recentBooks.insert(0, bookId);
      
      // Keep only the last 10 books
      if (recentBooks.length > 10) {
        recentBooks = recentBooks.sublist(0, 10);
      }
      
      session.write(key, recentBooks);
    }
  }
  
  // Get recently viewed books
  static List<String> getRecentBooks() {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = 'recent_books_$userId';
      return (session.read(key) as List<dynamic>?)?.cast<String>() ?? [];
    }
    return [];
  }
}