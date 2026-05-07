import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import '../responsive/responsive_layout.dart';

class AppText {
  const AppText._();

  static TextStyle display({double size = 32, Color color = AppColors.navy3}) {
    return GoogleFonts.syne(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 0,
      height: 1.04,
    );
  }

  static TextStyle heading({double size = 20, Color color = AppColors.navy3}) {
    return GoogleFonts.syne(
      fontSize: size,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 0,
      height: 1.15,
    );
  }

  static TextStyle body({
    double size = 13,
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.45,
      letterSpacing: 0,
    );
  }

  static TextStyle mono({
    double size = 13,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.dmMono(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      letterSpacing: 0,
    );
  }

  static double headingSize(BuildContext context) {
    return ResponsiveValue.of<double>(
      context,
      mobile: 20,
      tablet: 22,
      desktop: 24,
    );
  }

  static double bodySize(BuildContext context) {
    return ResponsiveValue.of<double>(context, mobile: 13, desktop: 14);
  }
}
