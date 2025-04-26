import 'package:flutter/material.dart';
import 'package:book_world/models/user_model.dart';
import 'package:book_world/services/user_service.dart';
import 'package:book_world/utils/helper.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _localAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  DateTime? _selectedDate;

  // Password change controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Email change controllers
  final _newEmailController = TextEditingController();
  final _passwordForEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _localAddressController.dispose();
    _permanentAddressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newEmailController.dispose();
    _passwordForEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.getCurrentUser();
      if (user != null) {
        setState(() {
          _user = user;
          _populateFormFields();
        });
      } else {
        // Handle the case where user is null
        showSnackBar(
          'Error',
          'Unable to load user data. Please log in again.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Error in _loadUserData: $e');
      showSnackBar(
        'Error',
        'Failed to load user data: ${e.toString()}',
        isError: true,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _populateFormFields() {
    _usernameController.text = _user?.username ?? '';
    _nameController.text = _user?.name ?? '';
    _mobileController.text = _user?.mobile ?? '';
    _localAddressController.text = _user?.localAddress ?? '';
    _permanentAddressController.text = _user?.permanentAddress ?? '';
    _selectedDate = _user?.dateOfBirth;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Create updated user model
      final updatedUser = UserModel(
        id: _user!.id,
        customId: _user!.customId,
        email: _user!.email,
        password: _user!.password,
        username: _usernameController.text,
        name: _nameController.text,
        mobile: _mobileController.text,
        dateOfBirth: _selectedDate,
        localAddress: _localAddressController.text,
        permanentAddress: _permanentAddressController.text,
        profilePictureUrl: _user!.profilePictureUrl,
        createdAt: _user!.createdAt,
        updatedAt: DateTime.now(), 
      );

      final success = await _userService.updateUserProfile(updatedUser);
      
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (success) {
        showSnackBar('Success', 'Profile updated successfully', isError: false);
        _loadUserData(); // Refresh data
      } else {
        showSnackBar('Error', 'Failed to update profile', isError: true);
      }
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_newPasswordController.text != _confirmPasswordController.text) {
                showSnackBar('Error', 'Passwords do not match', isError: true);
                return;
              }
              
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              
              final success = await _userService.updateUserPassword(
                _currentPasswordController.text,
                _newPasswordController.text,
              );
              
              setState(() {
                _isLoading = false;
              });
              
              // Clear password fields
              _currentPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newEmailController,
                decoration: const InputDecoration(labelText: 'New Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordForEmailController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              
              final success = await _userService.updateUserEmail(
                _newEmailController.text,
                _passwordForEmailController.text,
              );
              
              setState(() {
                _isLoading = false;
              });
              
              // Clear fields
              _newEmailController.clear();
              _passwordForEmailController.clear();
              
              if (success) {
                _loadUserData(); // Refresh data
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Unable to load user data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email section with change option
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Email',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(_user!.email),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showChangeEmailDialog,
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showChangePasswordDialog,
                                    child: const Text('Change'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Personal information form
                      Form(
                        key: _formKey,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: _isEditing,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a username';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: _isEditing,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _mobileController,
                                  decoration: const InputDecoration(
                                    labelText: 'Mobile Number',
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  onTap: _isEditing ? () => _selectDate(context) : null,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date of Birth',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _selectedDate == null
                                          ? 'Select Date'
                                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _localAddressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Local Address',
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: _isEditing,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _permanentAddressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Permanent Address',
                                    border: OutlineInputBorder(),
                                  ),
                                  enabled: _isEditing,
                                  maxLines: 2,
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