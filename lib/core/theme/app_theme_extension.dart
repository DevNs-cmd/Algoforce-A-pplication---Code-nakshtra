import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AlgoTheme extends ThemeExtension<AlgoTheme> {
  const AlgoTheme({
    required this.navy,
    required this.purple,
    required this.academy,
    required this.studio,
    required this.verified,
    required this.nexus,
    required this.bg,
    required this.surface,
    required this.border,
    required this.textMuted,
  });

  final Color navy;
  final Color purple;
  final Color academy;
  final Color studio;
  final Color verified;
  final Color nexus;
  final Color bg;
  final Color surface;
  final Color border;
  final Color textMuted;

  static const light = AlgoTheme(
    navy: AppColors.navy,
    purple: AppColors.purple,
    academy: AppColors.academy,
    studio: AppColors.studio,
    verified: AppColors.verified,
    nexus: AppColors.nexus,
    bg: AppColors.bg,
    surface: AppColors.white,
    border: AppColors.border,
    textMuted: AppColors.textMuted,
  );

  @override
  AlgoTheme copyWith({
    Color? navy,
    Color? purple,
    Color? academy,
    Color? studio,
    Color? verified,
    Color? nexus,
    Color? bg,
    Color? surface,
    Color? border,
    Color? textMuted,
  }) {
    return AlgoTheme(
      navy: navy ?? this.navy,
      purple: purple ?? this.purple,
      academy: academy ?? this.academy,
      studio: studio ?? this.studio,
      verified: verified ?? this.verified,
      nexus: nexus ?? this.nexus,
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      textMuted: textMuted ?? this.textMuted,
    );
  }

  @override
  AlgoTheme lerp(ThemeExtension<AlgoTheme>? other, double t) {
    if (other is! AlgoTheme) {
      return this;
    }
    return AlgoTheme(
      navy: Color.lerp(navy, other.navy, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      academy: Color.lerp(academy, other.academy, t)!,
      studio: Color.lerp(studio, other.studio, t)!,
      verified: Color.lerp(verified, other.verified, t)!,
      nexus: Color.lerp(nexus, other.nexus, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
    );
  }
}
