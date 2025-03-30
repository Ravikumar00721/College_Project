import 'package:flutter/material.dart';

class AppColors {
  // Light theme colors
  static const Color primary = Color(0xFF3674B5);
  static const Color secondary = Color(0xFF578FCA);
  static const Color background = Color(0xFFA1E3F9);
  static const Color accent = Color(0xFFD1F8EF);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black87;

  // Dark theme variants
  static Color get darkPrimary => Colors.blueGrey[800]!;
  static Color get darkSecondary => Colors.blueGrey[600]!;
  static Color get darkBackground => Colors.grey[900]!;
  static Color get darkAccent => Colors.blueGrey[700]!;
  static Color get darkTextPrimary => Colors.white;
  static Color get darkTextSecondary => Colors.white70;
}
