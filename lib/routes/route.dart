import 'package:book_world/controllers/pdf_controller.dart';
import 'package:book_world/middleware/auth_middleware.dart';
import 'package:book_world/middleware/role_middleware.dart';
import 'package:book_world/models/book_model.dart';
import 'package:book_world/routes/route_names.dart';
import 'package:book_world/screens/Users/Account/account_screen.dart';
import 'package:book_world/screens/Users/Account/personal_info_screen.dart';
import 'package:book_world/screens/Users/book_description_screen.dart';
import 'package:book_world/screens/Users/borrowed_books_screen.dart';
import 'package:book_world/screens/Users/Home/genre_books_screen.dart';
import 'package:book_world/screens/Users/Home/home_screen.dart';
import 'package:book_world/screens/Users/pdf_viewer_screen.dart';
import 'package:book_world/screens/Users/saved_books_screen.dart';
import 'package:book_world/screens/Users/Home/search_results_screen.dart';
import 'package:book_world/screens/auth/forgot_password.dart';
import 'package:book_world/screens/auth/librarian_email_verification.dart';
import 'package:book_world/screens/auth/librarian_password_setup.dart';
import 'package:book_world/screens/auth/reset_password_confirm.dart';
import 'package:book_world/screens/auth/signup1.dart';
import 'package:book_world/screens/auth/signup2.dart';
import 'package:book_world/screens/auth/signup3.dart';
import 'package:book_world/screens/librarians/add_book_screen.dart';
import 'package:book_world/screens/librarians/all_books_screen.dart';
import 'package:book_world/screens/librarians/all_users_screen.dart';
import 'package:book_world/screens/librarians/issue_return_screen.dart';
import 'package:book_world/screens/librarians/librarian_home_screen.dart';
import 'package:book_world/screens/splash_screen.dart';
import 'package:book_world/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

class Routes {
  static final pages = [
    // Public routes (no authentication required)
    GetPage(name: RouteNames.splash, page: () => const Splash()),
    GetPage(name: RouteNames.login, page: () => const Login()),
    GetPage(
      name: RouteNames.forgotPassword,
      page: () => const ForgotPassword(),
    ),
    GetPage(
      name: RouteNames.resetPasswordConfirm,
      page: () => const ResetPasswordConfirm(accessToken: ''),
    ),
    GetPage(name: RouteNames.signup1, page: () => const Signup1()),
    GetPage(name: RouteNames.signup2, page: () => const Signup2()),
    GetPage(name: RouteNames.signup3, page: () => const Signup3()),
    // Protected routes (authentication required)
    GetPage(
      name: RouteNames.home,
      page: () => const HomeScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: RouteNames.savedBooks,
      page: () => const SavedBooksScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: RouteNames.borrowedBooks,
      page: () => const BorrowedBooksScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: RouteNames.account,
      page: () => AccountScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: RouteNames.personalInfo,
    page: () => const PersonalInfoScreen(),
    middlewares: [AuthMiddleware()]),

    // Librarian routes
    GetPage(
      name: RouteNames.librarianEmailVerification,
      page: () => const LibrarianEmailVerification(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: RouteNames.librarianSignupPassword,
      page: () => const LibrarianPasswordSetup(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: RouteNames.librarianHome,
      page: () => LibrarianHomeScreen(),
      middlewares: [LibrarianMiddleware()],
    ),
    GetPage(
      name: RouteNames.allBooks,
      page: () => const AllBooksScreen(),
      middlewares: [LibrarianMiddleware()],
    ),
    GetPage(
      name: RouteNames.issueReturnBook,
      page: () => const IssueReturnScreen(),
      middlewares: [LibrarianMiddleware()],
    ),
    GetPage(
      name: RouteNames.allUsers,
      page: () => const AllUsersScreen(),
      middlewares: [LibrarianMiddleware()],
    ),
    GetPage(
      name: RouteNames.addBook,
      page: () => AddBookScreen(),
      middlewares: [LibrarianMiddleware()],
    ),

    //Dynamic routes that require Parameters
    GetPage(
      name: RouteNames.bookDescription,
      page: () {
        final BookModel book = Get.arguments;
        return BookDescriptionScreen(book: book);
      },
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: RouteNames.genreBooks,
      page: () {
        // Check if arguments is a String or a Map
        if (Get.arguments is String) {
          final String genre = Get.arguments;
          return GenreBooksScreen(genre: genre, icon: Icons.book, results: []);
        } else if (Get.arguments is Map) {
          final Map<String, dynamic> args = Get.arguments;
          return GenreBooksScreen(
            genre: args['genre'],
            icon: args['icon'] ?? Icons.book,
            results: args['results'] ?? [],
          );
        }
        // Default fallback
        return GenreBooksScreen(
          genre: 'Unknown',
          icon: Icons.book,
          results: [],
        );
      },
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: RouteNames.searchResults,
      page: () {
        final Map<String, dynamic> args = Get.arguments;
        final String query = args['query'];
        final List<BookModel> results = args['results'];
        return SearchResultsScreen(query: query, results: results);
      },
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: RouteNames.pdfViewer,
      page: () {
        final Map<String, dynamic> args = Get.arguments;
        final String bookId = args['bookId'];
        final String bookTitle = args['bookTitle'];
        final String? pdfUrl = args['pdfUrl'];

        // Register the controller
        Get.put(PDFController(bookId: bookId, pdfUrl: pdfUrl));

        return PDFViewerScreen(bookTitle: bookTitle);
      },
      middlewares: [AuthMiddleware()],
    ),
  ];

   // Helper method for PDF viewer navigation
  static void toPdfViewer({
    required String bookId,
    required String bookTitle,
    String? pdfUrl,
  }) {
    Get.toNamed(
      RouteNames.pdfViewer,
      arguments: {'bookId': bookId, 'bookTitle': bookTitle, 'pdfUrl': pdfUrl},
    );
  }

  // Helper method for navigation with arguments
  static void toBookDescription(BookModel book) {
    Get.toNamed(RouteNames.bookDescription, arguments: book);
  }

  static void toSearchResults(String query, List<BookModel> results) {
    Get.toNamed(
      RouteNames.searchResults,
      arguments: {'query': query, 'results': results},
    );
  }

  static void toGenreBooks(
    String genre, {
    IconData icon = Icons.book,
    List<BookModel> results = const [],
  }) {
    Get.toNamed(
      RouteNames.genreBooks,
      arguments: {'genre': genre, 'icon': icon, 'results': results},
    );
  }
}
