import 'package:flutter/material.dart';

/// Deep-space dark color palette for Milestone Pro.
/// Primary accent: Electric Violet #7C5CFC
/// Secondary accent: Cyan-Teal #4ECDC4 (streaks)
abstract final class AppColors {
  // ── Backgrounds & Glass ────────────────────────────────────────────────────
  static const Color background = Color(0xFF06070D); // Deeper black
  static const Color surface = Color(0xFF0F111A);
  static const Color card = Color(0xFF161926);
  static const Color glassFill = Color(0x1AFFFFFF); // Low opacity white
  static const Color glassBorder = Color(0x33FFFFFF); // Subtle white border
  static const Color glassSecondary = Color(0x0DFFFFFF);

  // ── Brand Accents (Vibrant) ────────────────────────────────────────────────
  static const Color primary = Color(0xFF8B6BFF); // More vibrant violet
  static const Color primaryLight = Color(0xFFA68FFF);
  static const Color primaryDark = Color(0xFF6B4EE0);
  static const Color secondary = Color(0xFF00F5FF); // Electric Cyan
  static const Color accent = Color(0xFFFF00D4); // Cyber Magenta

  // ── Status & Utility ───────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF00FFB2);
  static const Color warning = Color(0xFFFFD400);
  static const Color info = Color(0xFF00D1FF);

  // ── Text (Optimized for Dark) ─────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B3C1);
  static const Color textHint = Color(0xFF6B6E7B);
  static const Color divider = Color(0xFF222533);
  static const Color cardElevated = Color(0xFF1E2230);

  // ── Borders & Glows ───────────────────────────────────────────────────────
  static const Color border = Color(0xFF222533);
  static const Color glassShadow = Color(0x4D000000);

  // ── Goal Category Themes (Gradients) ───────────────────────────────────────
  static const List<Color> goalColors = [
    Color(0xFF8B6BFF), // 0 Violet
    Color(0xFF00F5FF), // 1 Electric Cyan
    Color(0xFFFF4D4D), // 2 Scarlet
    Color(0xFFFFD400), // 3 Gold
    Color(0xFF00FFB2), // 4 Spring Green
    Color(0xFFFF00D4), // 5 Magenta
    Color(0xFF60A5FA), // 6 Sky
    Color(0xFFFACC15), // 7 Yellow
  ];

  static const List<Color> priorityColors = [
    Color(0xFF6B6E7B), // 0 Low
    Color(0xFFFFD400), // 1 Medium
    Color(0xFFFF9F00), // 2 High
    Color(0xFFFF4D4D), // 3 Critical
  ];
}
