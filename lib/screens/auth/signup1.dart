// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:book_world/controllers/auth_controller.dart';
import 'package:book_world/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Signup1 extends StatefulWidget {
  const Signup1({super.key});
  // Removed from here as it cannot be used in a const context

  @override
  State<StatefulWidget> createState() => _Signup();
}

class _Signup extends State<Signup1> {
  final _formKey = GlobalKey<FormState>();
  final AuthController signupController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            // Background with blur effect
            SizedBox.expand(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Image.asset(
                  'assets/images/bg-image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Dark overlay for better contrast
            Container(color: Colors.black.withOpacity(0.3)),

            // Main content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App logo or title
                      const Text(
                        "Book World",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Join our community of readers",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 40),

                      // Signup card
                      Container(
                        width: 340,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE0),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),

                                const Center(
                                  child: Text(
                                    "Step 1 of 3",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),
                                // Full Name field
                                const SizedBox(height: 8),
                                TextFormField(
                                  onChanged: (value) {
                                    signupController.name.value = value.trim();
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter your full name",
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: Colors.orange,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.orange,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your full name';
                                    }
                                    if (!RegExp(
                                      r'^[\p{L}][\p{L} ]*$',
                                      unicode: true,
                                    ).hasMatch(value)) {
                                      return 'Full name must not contain numbers or invalid characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Username field
                                const SizedBox(height: 8),
                                TextFormField(
                                  onChanged: (value) {
                                    signupController.username.value = value.trim();
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Create a username",
                                    prefixIcon: const Icon(
                                      Icons.alternate_email,
                                      color: Colors.orange,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.orange,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please create a username';
                                    }
                                    if (!RegExp(
                                      r'^[a-zA-Z_][a-zA-Z0-9._-]*$',
                                    ).hasMatch(value)) {
                                      return 'Username must start with an alphabet or underscore and can only contain alphabets, numbers, hyphens, dots, and underscores';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Contains alphabets, numbers, hyphen, dot or underscore",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Mobile Number field
                                const SizedBox(height: 8),
                                TextFormField(
                                  onChanged: (value) {
                                    signupController.mobileNumber.value = value.trim();
                                  },
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "Enter your mobile number",
                                    prefixIcon: const Icon(
                                      Icons.phone_android,
                                      color: Colors.orange,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.orange,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your mobile number';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 30),

                                // Navigation buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Back to Login button
                                    TextButton(
                                      onPressed:
                                          () => Get.toNamed(RouteNames.login),
                                      child: const Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    // Next button
                                    SizedBox(
                                      width: 120,
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            Get.toNamed(RouteNames.signup2);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Next",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
