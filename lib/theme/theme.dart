import 'package:flutter/material.dart';

final ThemeData theme = ThemeData(
  useMaterial3: true,
  primarySwatch: Colors.orange,
  scaffoldBackgroundColor: const Color(0xFFFFE8C6),
  fontFamily: 'Sanchez',
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.orange, // Cursor color
    selectionColor: Colors.orange.withOpacity(
      0.4,
    ), // Background when selecting text
    selectionHandleColor: Colors.orange, // Handles when dragging text
  ),
);
