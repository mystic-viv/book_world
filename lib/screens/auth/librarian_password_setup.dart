import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_world/controllers/auth_controller.dart';
import 'package:book_world/utils/helper.dart';
import 'package:book_world/widgets/custom_button.dart';
import 'package:book_world/widgets/custom_text_field.dart';

class LibrarianPasswordSetup extends StatefulWidget {
  const LibrarianPasswordSetup({Key? key}) : super(key: key);

  @override
  State<LibrarianPasswordSetup> createState() => _LibrarianPasswordSetupState();
}

class _LibrarianPasswordSetupState extends State<LibrarianPasswordSetup> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  late String _email;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Get email from arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _email = args['email'] ?? '';
    } else {
      _email = '';
      // If no email provided, go back to email verification
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBar('Error', 'Email not provided');
        Get.back();
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      await _authController.librarianSignup(
        _email,
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Password'),
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
                  'Set Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 10),
                
                // Email display
                Text(
                  'Email: $_email',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Create Account Button
                Obx(() => CustomButton(
                  text: 'Create Account',
                  isLoading: _authController.librarianSignupLoading.value,
                  onPressed: _createAccount,
                )),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
