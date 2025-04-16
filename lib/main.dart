import 'package:book_world/controllers/auth_controller.dart';
import 'package:book_world/routes/route.dart';
import 'package:book_world/routes/route_names.dart';
import 'package:book_world/screens/Users/account_screen.dart';
import 'package:book_world/screens/Users/borrowed_books_screen.dart';
import 'package:book_world/screens/Users/home_screen.dart';
import 'package:book_world/screens/Users/saved_books_screen.dart';
import 'package:book_world/services/auth_service.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:book_world/services/supabase_service.dart';
import 'package:book_world/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Set up auth state change listener
  SupabaseService.client?.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;

    if (event == AuthChangeEvent.signedOut) {
       // User signed out, redirect to login screen
      Get.offAllNamed(RouteNames.login);
    } else if (event == AuthChangeEvent.signedIn) {
      // User signed in, update session
      if (data.session != null) {
         // Refresh user session data
        AuthService.refreshSession(data.session!);
      }
    } else if (event == AuthChangeEvent.passwordRecovery) {
      // Handle password recovery event
      Get.toNamed(RouteNames.resetPasswordConfirm);
    }
  });

  // Initialize GetStorage
  await GetStorage.init();
  debugPrint("GetStorage initialized");

  // Check session state
  final userSession = StorageServices.userSession;
  debugPrint("User session: $userSession");

  // Register services lazily
  Get.lazyPut(() => SupabaseService());
  Get.lazyPut(() => AuthController(), fenix: true); // Recreate if disposed

  // Run the app
  runApp(const BookWorldApp());
}


class BookWorldApp extends StatelessWidget {
  const BookWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    String initialRoute = RouteNames.splash;

    return GetMaterialApp(
      title: 'Book World',
      debugShowCheckedModeBanner: false,
      theme: theme,
      getPages: Routes.pages,
      initialRoute: initialRoute,
      defaultTransition: Transition.noTransition,
    );
  }
}
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();
}

class ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    hasError = false;
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      hasError = false;
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }

  void catchError(Object error, StackTrace stackTrace) {
    setState(() {
      hasError = true;
    });
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SavedBooksScreen(),
    const BorrowedBooksScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Borrowed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}