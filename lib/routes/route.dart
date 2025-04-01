import 'package:book_world/routes/route_names.dart';
import 'package:book_world/screens/Users/account_screen.dart';
import 'package:book_world/screens/Users/borrowed_books_screen.dart';
import 'package:book_world/screens/Users/home_screen.dart';
import 'package:book_world/screens/Users/saved_books_screen.dart';
import 'package:book_world/screens/auth/signup1.dart';
import 'package:book_world/screens/auth/signup2.dart';
import 'package:book_world/screens/auth/signup3.dart';

import 'package:book_world/screens/splash.dart';
import 'package:book_world/screens/auth/login.dart';
import 'package:get/route_manager.dart';

class Routes {
  static final pages = [
    GetPage(name: RouteNames.splash, page: () => const Splash()),
    GetPage(name: RouteNames.login, page: () => const Login()),
    GetPage(name: RouteNames.signup1, page: () => const Signup1()),
    GetPage(name: RouteNames.signup2, page: () => const Signup2()),
    GetPage(name: RouteNames.signup3, page: () => const Signup3()),
    GetPage(name: RouteNames.home, page: () => const HomeScreen()),
    GetPage(name: RouteNames.savedBooks, page: () => const SavedBooksScreen()),
    GetPage(
      name: RouteNames.borrowedBooks,
      page: () => const BorrowedBooksScreen(),
    ),
    GetPage(name: RouteNames.account, page: () => const AccountScreen()),
  ];
}
