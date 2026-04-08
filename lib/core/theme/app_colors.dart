import 'package:flutter/material.dart';

/// Deep-space dark color palette for Milestone Pro.
/// Primary accent: Electric Violet #7C5CFC
/// Secondary accent: Cyan-Teal #4ECDC4 (streaks)
abstract final class AppColors {
  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0F1A);
  static const Color surface = Color(0xFF141728);
  static const Color card = Color(0xFF1C2033);
  static const Color cardElevated = Color(0xFF222640);

  // ── Brand Accents ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryLight = Color(0xFF9B82FD);
  static const Color primaryDark = Color(0xFF5A3BDB);
  static const Color secondary = Color(0xFF4ECDC4); // Streak / success accent
  static const Color secondaryLight = Color(0xFF7EDDD7);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color info = Color(0xFF4FC3F7);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFF8B90A0);
  static const Color textHint = Color(0xFF4A4F62);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color border = Color(0xFF252A3F);
  static const Color divider = Color(0xFF1E2235);

  // ── Goal Category Colors (colorIndex mapping) ──────────────────────────────
  static const List<Color> goalColors = [
    Color(0xFF7C5CFC), // 0 Violet
    Color(0xFF4ECDC4), // 1 Teal
    Color(0xFFFF6B6B), // 2 Coral
    Color(0xFFFFD166), // 3 Amber
    Color(0xFF06D6A0), // 4 Emerald
    Color(0xFF4FC3F7), // 5 Sky
    Color(0xFFFF9FF3), // 6 Rose
    Color(0xFFFF9F43), // 7 Orange
  ];

  // ── Priority Colors ────────────────────────────────────────────────────────
  static const List<Color> priorityColors = [
    Color(0xFF8B90A0), // 0 Low
    Color(0xFFFFD166), // 1 Medium
    Color(0xFFFF9F43), // 2 High
    Color(0xFFFF6B6B), // 3 Critical
  ];
}
