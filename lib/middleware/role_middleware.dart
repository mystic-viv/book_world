import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // First check if user is authenticated
    if (!AuthService.isAuthenticated()) {
      return RouteSettings(name: RouteNames.login);
    }
    
    // Then check if user is admin
    if (!AuthService.isAdmin()) {
      // Not an admin, redirect to home
      return RouteSettings(name: RouteNames.home);
    }
    
    // User is admin, allow access
    return null;
  }
}

class LibrarianMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // First check if user is authenticated
    if (!AuthService.isAuthenticated()) {
      return RouteSettings(name: RouteNames.login);
    }
    
    // Then check if user is librarian or admin
    if (!AuthService.isLibrarian()) {
      // Not a librarian, redirect to home
      return RouteSettings(name: RouteNames.home);
    }
    
    // User is librarian or admin, allow access
    return null;
  }
}
