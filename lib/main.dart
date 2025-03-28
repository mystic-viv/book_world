import 'package:book_world/screens/splash.dart';
import 'package:flutter/material.dart';
// Import the HomeScreen

void main() {
  runApp(const BookWorldApp());
}

class BookWorldApp extends StatelessWidget {
  const BookWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book World',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Sanchez',
        scaffoldBackgroundColor: const Color(0xFFFFECE0),
      ),
      home: const Splash(), // Set HomeScreen as the starting screen
    );
  }
}
