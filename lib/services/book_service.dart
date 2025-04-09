import 'dart:io';
import 'package:book_world/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:book_world/services/id_service.dart';

class BookService {
  static final supabase = Supabase.instance.client;
  static final uuid = Uuid();
      // Get all books
      static Future<List<Map<String, dynamic>>> getAllBooks() async {
        try {
          // Check if user is authenticated
          if (!AuthService.isAuthenticated()) {
            throw Exception("Authentication required");
          }
      
          final response = await supabase
              .from('books')
              .select('*')
              .order('book_name');
      
          return (response as List).cast<Map<String, dynamic>>();
        } catch (e) {
          print('Error fetching books: $e');
          return [];
        }
      }
  // Get book details by ID
  static Future<Map<String, dynamic>?> getBookById(String bookId) async {
    try {
      final response = await supabase
          .from('books')
          .select('*')
          .eq('custom_id', bookId)  // Use custom_id instead of id
          .single();
      
      return response;
    } catch (e) {
      print('Error fetching book details: $e');
      return null;
    }
  }
  
  // Upload a new book (for librarians)
  static Future<Map<String, dynamic>> uploadBook({
    required String bookName,
    required String authorName,
    required String description,
    required int totalCopies,
    File? coverImage,
    File? ebookFile,
  }) async {
    try {
      // Generate a custom book ID with BWB prefix using the database function
      final bookId = await IDService.generateBookId(); // This will return something like BWB-001
      print("Generated custom book ID: $bookId");
      
      // Upload cover image if provided
      String? coverUrl;
      if (coverImage != null) {
        final fileExt = path.extension(coverImage.path);
        final fileName = '$bookId$fileExt';
        
        await supabase.storage
            .from('book_covers')
            .upload(fileName, coverImage);
        
        coverUrl = supabase.storage.from('book_covers').getPublicUrl(fileName);
      }
      
      // Upload ebook file if provided
      String? ebookUrl;
      if (ebookFile != null) {
        final fileExt = path.extension(ebookFile.path);
        final fileName = '$bookId$fileExt';
        
        await supabase.storage
            .from('ebooks')
            .upload(fileName, ebookFile);
        
        ebookUrl = supabase.storage.from('ebooks').getPublicUrl(fileName);
      }
      
      // For physical books, we track availability normally
      final availableCopies = totalCopies;
      
      // Generate a UUID for the internal ID
      final internalId = uuid.v4();
      
      // Insert book record with both internal ID and custom ID
      await supabase.from('books').insert({
        'id': internalId,  // Internal UUID for relationships
        'custom_id': bookId,  // Custom ID for display (BWB-001)
        'book_name': bookName,
        'author_name': authorName,
        'description': description,
        'cover_url': coverUrl,
        'ebook_url': ebookUrl,
        'total_copies': totalCopies,
        'available_copies': availableCopies,
        'is_ebook': ebookUrl != null, // Set is_ebook based on whether there's an ebook URL
      });
      
      return {
        'success': true,
        'bookId': bookId,
        'message': 'Book uploaded successfully!'
      };
    } catch (e) {
      print('Error uploading book: $e');
      return {
        'success': false,
        'message': 'Failed to upload book: ${e.toString()}'
      };
    }
  }
  
  // Issue a book (for librarians)
  static Future<Map<String, dynamic>> issueBook(String bookId, String userId) async {
    try {
      // Check if book exists and get its details
      final bookResponse = await supabase
          .from('books')
          .select('id, available_copies, book_name, is_ebook')
          .eq('custom_id', bookId)  // Use custom_id instead of id
          .single();
      
      final String internalBookId = bookResponse['id'];
      final bool isEbook = bookResponse['is_ebook'] as bool;
      final int availableCopies = bookResponse['available_copies'] as int;
      final String bookTitle = bookResponse['book_name'] as String;
      
      // For e-books, we don't need to check or update availability
      // For physical books, we need to check if copies are available
      if (!isEbook && availableCopies <= 0) {
        return {
          'success': false,
          'message': 'No copies of "$bookTitle" available for checkout.'
        };
      }
      
      // Only update available copies for physical books
      if (!isEbook) {
        await supabase
            .from('books')
            .update({'available_copies': availableCopies - 1})
            .eq('custom_id', bookId);  // Use custom_id instead of id
      }
      
      // Create transaction record
      final transactionId = uuid.v4();
      await supabase.from('book_transactions').insert({
        'id': transactionId,
        'book_id': internalBookId,  // Use internal ID for relationships
        'user_id': userId,
        'issued_at': DateTime.now().toIso8601String(),
        'due_at': isEbook ? null : DateTime.now().add(Duration(days: 14)).toIso8601String(),
        'status': isEbook ? 'accessed' : 'issued',
        'is_ebook': isEbook,
      });
      
      return {
        'success': true,
        'transactionId': transactionId,
        'message': isEbook 
            ? 'E-book "$bookTitle" access granted successfully!' 
            : 'Book "$bookTitle" issued successfully!'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to issue book: ${e.toString()}'
      };
    }
  }
  
  // Return a physical book (for librarians)
  static Future<Map<String, dynamic>> returnBook(String transactionId) async {
    try {
      // Get transaction details
      final transactionResponse = await supabase
          .from('book_transactions')
          .select('book_id, status, is_ebook, books(book_name, custom_id)')
          .eq('id', transactionId)
          .single();
      
      // If it's an e-book, we don't need to handle returns
      if (transactionResponse['is_ebook'] == true) {
        return {
          'success': false,
          'message': 'E-books do not need to be returned'
        };
      }
      
      if (transactionResponse['status'] != 'issued') {
        return {
          'success': false,
          'message': 'Book is not currently issued'
        };
      }
      
      final bookId = transactionResponse['books']['custom_id'] as String;
      final bookTitle = transactionResponse['books']['book_name'] as String;
      
      // Get current available copies
      final bookResponse = await supabase
          .from('books')
          .select('available_copies, total_copies')
          .eq('custom_id', bookId)
          .single();
      
      final availableCopies = bookResponse['available_copies'] as int;
      final totalCopies = bookResponse['total_copies'] as int;
      
      // Ensure we don't exceed total copies
      if (availableCopies >= totalCopies) {
        return {
          'success': false,
          'message': 'All copies are already available'
        };
      }
      
      // Update available copies
      await supabase
          .from('books')
          .update({'available_copies': availableCopies + 1})
          .eq('custom_id', bookId);
      
      // Update transaction record
      await supabase
          .from('book_transactions')
          .update({
            'returned_at': DateTime.now().toIso8601String(),
            'status': 'returned',
          })
          .eq('id', transactionId);
      
      return {
        'success': true,
        'message': 'Book "$bookTitle" returned successfully!'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to return book: ${e.toString()}'
      };
    }
  }
  
  // Get all transactions (for librarians)
  static Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      final response = await supabase
          .from('book_transactions')
          .select('*, books(*), users(*)')
          .order('issued_at', ascending: false);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }
  
  // Get user's borrowed books
  static Future<List<Map<String, dynamic>>> getUserBorrowedBooks(String userId) async {
    try {
      final response = await supabase
          .from('book_transactions')
          .select('*, books(*)')
          .eq('user_id', userId)
          .or('status.eq.issued,status.eq.accessed')
          .order('issued_at', ascending: false);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user borrowed books: $e');
      return [];
    }
  }
  
  // Get user's e-book access
  static Future<List<Map<String, dynamic>>> getUserEbooks(String userId) async {
    try {
      final response = await supabase
          .from('book_transactions')
          .select('*, books(*)')
          .eq('user_id', userId)
          .eq('is_ebook', true)
          .order('issued_at', ascending: false);
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching user e-books: $e');
      return [];
    }
  }
  
  // Search books by title, author, or description
  static Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    try {
      final response = await supabase
          .from('books')
          .select('*')
          .or('book_name.ilike.%$query%,description.ilike.%$query%')
          .order('book_name');
      
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error searching books: $e');
      return [];
    }
  }
}