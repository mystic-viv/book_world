import 'package:get_storage/get_storage.dart';
import 'package:book_world/models/pdf_bookmark_model.dart';
import 'dart:convert';

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
  
  // PDF VIEWER RELATED METHODS
  
  // Keys for PDF-related storage
  static const String _bookmarksKey = 'pdf_bookmarks';
  static const String _readingProgressKey = 'pdf_reading_progress';
  static const String _cachedPdfsKey = 'cached_pdfs';
  
  // Get bookmarks for a specific book
  static List<PDFBookmark> getBookmarks(String bookId) {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = '${_bookmarksKey}_${userId}_$bookId';
      final List<dynamic> bookmarksJson = session.read(key) ?? [];
      
      return bookmarksJson
          .map((json) => PDFBookmark.fromJson(json is String ? jsonDecode(json) : json))
          .toList();
    }
    return [];
  }
  
  // Save a bookmark
  static Future<void> saveBookmark(PDFBookmark bookmark) async {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = '${_bookmarksKey}_${userId}_${bookmark.bookId}';
      
      // Get existing bookmarks
      List<PDFBookmark> bookmarks = getBookmarks(bookmark.bookId);
      
      // Remove if exists with same ID
      bookmarks.removeWhere((b) => b.id == bookmark.id);
      
      // Add new bookmark
      bookmarks.add(bookmark);
      
      // Save back to storage
      await session.write(key, bookmarks.map((b) => b.toJson()).toList());
    }
  }
  
  // Delete a bookmark
  static Future<void> deleteBookmark(String bookmarkId) async {
    if (userSession != null) {
      final userId = userSession['id'];
      
      // We need to check all books since we don't know which book this bookmark belongs to
      final allKeys = session.getKeys();
      
      for (final key in allKeys) {
        if (key.startsWith('${_bookmarksKey}_$userId')) {
          final List<dynamic> bookmarksJson = session.read(key) ?? [];
          final List<PDFBookmark> bookmarks = bookmarksJson
              .map((json) => PDFBookmark.fromJson(json is String ? jsonDecode(json) : json))
              .toList();
          
          final originalLength = bookmarks.length;
          bookmarks.removeWhere((b) => b.id == bookmarkId);
          
          // If we removed something, save the updated list
          if (bookmarks.length < originalLength) {
            await session.write(key, bookmarks.map((b) => b.toJson()).toList());
            break;
          }
        }
      }
    }
  }
  
  // Get reading progress for PDF
  static PDFReadingProgress? getReadingProgress(String bookId) {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = '${_readingProgressKey}_${userId}_$bookId';
      
      final dynamic data = session.read(key);
      if (data != null) {
        final Map<String, dynamic> jsonData = 
            data is String ? jsonDecode(data) : data;
        return PDFReadingProgress.fromJson(jsonData);
      }
    }
    return null;
  }
  
  // Save reading progress for PDF
  static Future<void> saveReadingProgress(PDFReadingProgress progress) async {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = '${_readingProgressKey}_${userId}_${progress.bookId}';
      
      // Save to storage
      await session.write(key, progress.toJson());
    }
  }
  
  // Get cached PDF path
  static String? getCachedPdfPath(String bookId) {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = '${_cachedPdfsKey}_${userId}_$bookId';
      return session.read(key);
    }
    return null;
  }
  
  // Save cached PDF path
  static Future<void> saveCachedPdfPath(String bookId, String localPath) async {
    if (userSession != null) {
      final userId = userSession['id'];
      final key = '${_cachedPdfsKey}_${userId}_$bookId';
      
      // Save to storage
      await session.write(key, localPath);
    }
  }
}