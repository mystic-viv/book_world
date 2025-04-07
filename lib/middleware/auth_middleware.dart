import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if user is authenticated
    if (!AuthService.isAuthenticated()) {
      // If not authenticated, redirect to login page
      return RouteSettings(name: RouteNames.login);
    }
    
    // User is authenticated, allow access to the requested route
    return null;
  }
}
