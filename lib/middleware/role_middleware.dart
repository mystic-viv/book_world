import 'package:book_world/routes/route_names.dart';
import 'package:book_world/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibrarianMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // First check if user is authenticated
    if (!AuthService.isAuthenticated()) {
      return RouteSettings(name: RouteNames.login);
    }
    
    // Then check if user is librarian
    if (AuthService.getUserRole() != 'librarian') {
      // Not a librarian, redirect to home
      return RouteSettings(name: RouteNames.home);
    }
    
    // User is librarian, allow access
    return null;
  }
}

class UserMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if user is authenticated
    if (!AuthService.isAuthenticated()) {
      return RouteSettings(name: RouteNames.login);
    }
    
    // User is authenticated, allow access
    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Check if user is already authenticated
    if (AuthService.isAuthenticated()) {
      // User is already logged in, redirect based on role
      final role = AuthService.getUserRole();
      
      if (role == 'librarian') {
        return RouteSettings(name: RouteNames.librarianHome);
      } else {
        return RouteSettings(name: RouteNames.home);
      }
    }
    
    // User is not authenticated, allow access to guest routes
    return null;
  }
}