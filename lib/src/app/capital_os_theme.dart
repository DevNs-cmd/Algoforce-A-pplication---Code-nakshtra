import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CapitalColors {
  static const deepBlue = Color(0xFF0A2A43);
  static const purple = Color(0xFF9A4DFF);
  static const cyan = Color(0xFF16C8F7);
  static const green = Color(0xFF19B887);
  static const amber = Color(0xFFFFB547);
  static const red = Color(0xFFFF5A72);
  static const ink = Color(0xFF132236);
  static const muted = Color(0xFF67768A);
  static const surface = Color(0xFFF7FAFE);
  static const line = Color(0x1A0A2A43);
}

class CapitalOsTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CapitalColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: CapitalColors.purple,
        primary: CapitalColors.deepBlue,
        secondary: CapitalColors.purple,
        surface: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: CapitalColors.ink,
        displayColor: CapitalColors.deepBlue,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.76),
        labelStyle: const TextStyle(color: CapitalColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: CapitalColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: CapitalColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: CapitalColors.purple, width: 1.4),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: CapitalColors.purple,
        thumbColor: CapitalColors.deepBlue,
      ),
    );
  }
}
