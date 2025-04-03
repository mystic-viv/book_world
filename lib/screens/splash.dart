// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<StatefulWidget> createState() => _Splash();
}

class _Splash extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      // Wait for 3 seconds
      await Future.delayed(const Duration(seconds: 3));

      // Debugging: Print the user session
      debugPrint('User session: ${StorageServices.userSession}');

      // Ensure the widget is still mounted before navigating
      // if (!mounted) return;
      final userSession = StorageServices.userSession;
      debugPrint("Navigating to ${userSession == null ? 'login' : 'home'}");
      await Get.offAllNamed(
        userSession == null ? RouteNames.login : RouteNames.home,
      );
      // Navigate based on the session state
    } catch (error) {
      debugPrint('Error during navigation: $error');
      Get.offAllNamed(RouteNames.login); // Fallback to login screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 125),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),
            height: 235,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x99FBBA77),
                borderRadius: BorderRadius.circular(35),
              ),
              height: 235,
              padding: const EdgeInsets.fromLTRB(25, 45, 25, 0),
              child: Column(
                children: [
                  Image.asset("assets/images/purelogo-removebg 1.png"),
                  const Text(
                    "BOOK WORLD",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Sanchez',
                      color: Color(0xFFE97F11),
                    ),
                  ),
                  const Text(
                    "ONE PLACE FOR ALL TO STUDY",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'serif',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
