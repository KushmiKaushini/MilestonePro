import 'package:flutter/material.dart';

class AppColors {
  // Dark Backgrounds
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B);    // Slate 800
  static const Color card = Color(0xFF334155);       // Slate 700

  // Brand Colors (Vibrant Gradients)
  static const Color primary = Color(0xFF6366F1);    // Indigo 500
  static const Color secondary = Color(0xFFEC4899);  // Pink 500
  static const Color accent = Color(0xFF8B5CF6);     // Violet 500

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);   // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiary = Color(0xFF64748B);  // Slate 500

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444);   // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white12,
      Colors.white10,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
