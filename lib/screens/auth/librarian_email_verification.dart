import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_world/controllers/auth_controller.dart';
import 'package:book_world/routes/route_names.dart';
import 'package:book_world/utils/helper.dart';
import 'package:book_world/widgets/custom_button.dart';
import 'package:book_world/widgets/custom_text_field.dart';

class LibrarianEmailVerification extends StatefulWidget {
  const LibrarianEmailVerification({Key? key}) : super(key: key);

  @override
  State<LibrarianEmailVerification> createState() => _LibrarianEmailVerificationState();
}

class _LibrarianEmailVerificationState extends State<LibrarianEmailVerification> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final isLibrarian = await _authController.checkLibrarianEmail(email);
      
      if (isLibrarian) {
        Get.toNamed(
          RouteNames.librarianSignupPassword,
          arguments: {'email': email},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Librarian Signup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Logo or Image
                Center(
                  child: Image.asset(
                    'assets/images/BWAppLogo.png',
                    height: 120,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Title
                const Text(
                  'Librarian Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 10),
                
                // Description
                const Text(
                  'Please enter your librarian email address to verify your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your librarian email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Verify Button
                Obx(() => CustomButton(
                  text: 'Verify Email',
                  isLoading: _authController.librarianCheckLoading.value,
                  onPressed: _verifyEmail,
                )),
                
                const SizedBox(height: 20),
                
                // Back to Login
                TextButton(
                  onPressed: () => Get.offAllNamed(RouteNames.login),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
