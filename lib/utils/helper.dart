import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void showSnackBar(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green[300],
    colorText: Colors.white,
    borderRadius: 10,
    margin: const EdgeInsets.all(0.0),
    duration: const Duration(seconds: 2),
  );
}
