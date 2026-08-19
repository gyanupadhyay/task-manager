import 'package:flutter/material.dart';

/// Centralized color palette. Widgets should never hardcode a [Color].
abstract final class AppColors {
  static const Color primary = Color(0xFF3D5AFE);
  static const Color primaryDark = Color(0xFF2A3EB1);

  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFE0A93E);
  static const Color danger = Color(0xFFE0574C);

  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOutline = Color(0xFFE1E3EA);
  static const Color lightTextPrimary = Color(0xFF1B1D28);
  static const Color lightTextSecondary = Color(0xFF6B6F80);

  static const Color darkBackground = Color(0xFF13141C);
  static const Color darkSurface = Color(0xFF1D1F2B);
  static const Color darkOutline = Color(0xFF32354A);
  static const Color darkTextPrimary = Color(0xFFF1F2F8);
  static const Color darkTextSecondary = Color(0xFFA6A9BD);
}
