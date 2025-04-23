import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:book_world/services/book_service.dart';
import 'package:book_world/services/supabase_service.dart';
import 'package:book_world/models/pdf_bookmark_model.dart';
import 'package:uuid/uuid.dart';

class PDFService {
  final StorageServices _storageService = StorageServices();
  final BookService _bookService = BookService();
  
  // Use the SupabaseService to get the client
  get _supabase => SupabaseService.client;

  // Fetch PDF URL from Supabase if not provided
  Future<String?> getPdfUrl(String bookId, [String? providedUrl]) async {
    if (providedUrl != null && providedUrl.isNotEmpty) {
      return providedUrl;
    }

    try {
      // Fetch book details from Supabase to get PDF URL
      final book = await _bookService.getBookById(bookId);
      return book.pdfUrl;
    } catch (e) {
      print('Error fetching PDF URL: $e');
      return null;
    }
  }

  // Download and cache PDF
  Future<String?> downloadAndCachePdf(String bookId, String pdfUrl) async {
    try {
      // Check if PDF is already cached
      final cachedPath = StorageServices.getCachedPdfPath(bookId);
      if (cachedPath != null) {
        final cachedFile = File(cachedPath);
        if (await cachedFile.exists()) {
          // Record download in database (if not already recorded)
          _recordPdfDownload(bookId);
          return cachedPath;
        }
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      // Download PDF
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }

      // Save to local storage
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/pdfs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final file = File('${pdfDir.path}/$bookId.pdf');
      await file.writeAsBytes(response.bodyBytes);

      // Save path to storage service
      await StorageServices.saveCachedPdfPath(bookId, file.path);

      // Record download in database
      _recordPdfDownload(bookId);

      return file.path;
    } catch (e) {
      print('Error downloading PDF: $e');
      return null;
    }
  }

  // Record PDF download in the database
  Future<void> _recordPdfDownload(String bookId) async {
    try {
      if (_supabase == null) return;
      
      await _supabase.from('pdf_downloads').insert({
        'id': const Uuid().v4(),
        'user_id': _supabase.auth.currentUser!.id,
        'book_id': bookId,
        'device_info': 'Flutter App',
      });
    } catch (e) {
      // Just log the error, don't fail the download
      print('Error recording PDF download: $e');
    }
  }

  // Get reading progress from database
  Future<PDFReadingProgress?> getReadingProgress(String bookId) async {
    try {
      if (_supabase == null) return null;
      
      final response = await _supabase
          .from('reading_progress')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('book_id', bookId)
          .single();

      if (response == null) {
        return null;
      }

      return PDFReadingProgress(
        bookId: response['book_id'],
        lastReadPage: response['last_read_page'],
        lastReadTime: DateTime.parse(response['last_read_time']),
      );
    } catch (e) {
      print('Error fetching reading progress: $e');
      // Fall back to local storage if database fails
      return StorageServices.getReadingProgress(bookId);
    }
  }

  // Save reading progress to database
  Future<void> saveReadingProgress(PDFReadingProgress progress) async {
    try {
      if (_supabase == null) return;
      
      // Try to update first
      await _supabase.from('reading_progress').upsert({
        'user_id': _supabase.auth.currentUser!.id,
        'book_id': progress.bookId,
        'last_read_page': progress.lastReadPage,
        'last_read_time': progress.lastReadTime.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Also save to local storage as backup
      await StorageServices.saveReadingProgress(progress);
    } catch (e) {
      print('Error saving reading progress to database: $e');
      // Fall back to local storage if database fails
      await StorageServices.saveReadingProgress(progress);
    }
  }

  // Get bookmarks from database
  Future<List<PDFBookmark>> getBookmarks(String bookId) async {
    try {
      if (_supabase == null) return [];
      
      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('book_id', bookId)
          .order('created_at');

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((json) => PDFBookmark(
                id: json['id'],
                bookId: json['book_id'],
                pageNumber: json['page_number'],
                title: json['title'],
                createdAt: DateTime.parse(json['created_at']),
              ))
          .toList();
    } catch (e) {
      print('Error fetching bookmarks: $e');
      // Fall back to local storage if database fails
      return StorageServices.getBookmarks(bookId);
    }
  }

  // Save bookmark to database
  Future<PDFBookmark> saveBookmark(PDFBookmark bookmark) async {
    try {
      if (_supabase == null) {
        await StorageServices.saveBookmark(bookmark);
        return bookmark;
      }
      
      final String bookmarkId = bookmark.id ?? const Uuid().v4();

      await _supabase.from('bookmarks').insert({
        'id': bookmarkId,
        'user_id': _supabase.auth.currentUser!.id,
        'book_id': bookmark.bookId,
        'page_number': bookmark.pageNumber,
        'title': bookmark.title,
        'created_at': bookmark.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Also save to local storage as backup
      final updatedBookmark = PDFBookmark(
        id: bookmarkId,
        bookId: bookmark.bookId,
        pageNumber: bookmark.pageNumber,
        title: bookmark.title,
        createdAt: bookmark.createdAt,
      );

      await StorageServices.saveBookmark(updatedBookmark);
      return updatedBookmark;
    } catch (e) {
      print('Error saving bookmark to database: $e');
      // Fall back to local storage if database fails
      await StorageServices.saveBookmark(bookmark);
      return bookmark;
    }
  }

  // Delete bookmark from database
  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      if (_supabase == null) {
        await StorageServices.deleteBookmark(bookmarkId);
        return;
      }
      
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('id', bookmarkId)
          .eq('user_id', _supabase.auth.currentUser!.id);

      // Also delete from local storage
      await StorageServices.deleteBookmark(bookmarkId);
    } catch (e) {
      print('Error deleting bookmark from database: $e');
      // Fall back to local storage if database fails
      await StorageServices.deleteBookmark(bookmarkId);
    }
  }
}
