import 'package:book_world/middleware/auth_middleware.dart';
import 'package:book_world/middleware/role_middleware.dart';
import 'package:book_world/routes/route_names.dart';
import 'package:book_world/screens/Users/account_screen.dart';
import 'package:book_world/screens/Users/borrowed_books_screen.dart';
import 'package:book_world/screens/Users/home_screen.dart';
import 'package:book_world/screens/Users/saved_books_screen.dart';
import 'package:book_world/screens/auth/librarian_email_verification.dart';
import 'package:book_world/screens/auth/librarian_password_setup.dart';
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
import 'package:get/route_manager.dart';

class Routes {
  static final pages = [
    // Public routes (no authentication required)
    GetPage(name: RouteNames.splash, page: () => const Splash()),
    GetPage(name: RouteNames.login, page: () => const Login()),
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
    ];
}
