import 'package:flutter/material.dart';

class TurboTheme {
  // Brand colors
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111728);
  static const Color surfaceElevated = Color(0xFF19223A);
  static const Color card = Color(0xFF141C30);

  // Neon accents
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonBlue = Color(0xFF4FACFE);
  static const Color neonPink = Color(0xFFF72585);
  static const Color neonPurple = Color(0xFF7209B7);
  static const Color neonGreen = Color(0xFF00FF87);
  static const Color neonGold = Color(0xFFFFB703);
  static const Color neonRed = Color(0xFFFF3366);

  // Text
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDim = Color(0xFF64748B);

  // Highway surface colors
  static const Color asphaltDark = Color(0xFF1A1E29);
  static const Color asphaltLight = Color(0xFF222836);
  static const Color rumbleRed = Color(0xFFE63946);
  static const Color rumbleWhite = Color(0xFFF1FAEE);
  static const Color laneMarker = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonCyan, neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nitroGradient = LinearGradient(
    colors: [neonPink, neonGold],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF151D33), Color(0xFF0E1424)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows / Glows
  static List<BoxShadow> cyanGlow({double blur = 16, double spread = 1}) => [
        BoxShadow(
          color: neonCyan.withValues(alpha: 0.35),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  static List<BoxShadow> pinkGlow({double blur = 16, double spread = 1}) => [
        BoxShadow(
          color: neonPink.withValues(alpha: 0.35),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  static List<BoxShadow> goldGlow({double blur = 16, double spread = 1}) => [
        BoxShadow(
          color: neonGold.withValues(alpha: 0.35),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];
}
