import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Show a snackbar with title and message
void showSnackBar(String title, String message, {bool isError = false}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
    colorText: isError ? Colors.red.shade800 : Colors.green.shade800,
    margin: const EdgeInsets.all(16),
    borderRadius: 8,
    duration: const Duration(seconds: 3),
    icon: Icon(
      isError ? Icons.error : Icons.check_circle,
      color: isError ? Colors.red.shade800 : Colors.green.shade800,
    ),
  );
}

// Format date to readable string
String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

// Format currency
String formatCurrency(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
}

// Validate email
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(email);
}

// Validate phone number (10 digits)
bool isValidPhone(String phone) {
  return RegExp(r'^[0-9]{10}').hasMatch(phone);
}

// Get initials from name
String getInitials(String name) {
  List<String> nameParts = name.split(' ');
  String initials = '';
  
  if (nameParts.isNotEmpty) {
    initials += nameParts[0][0];
    
    if (nameParts.length > 1) {
      initials += nameParts[nameParts.length - 1][0];
    }
  }
  
  return initials.toUpperCase();
}