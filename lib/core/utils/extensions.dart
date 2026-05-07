import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import 'breakpoints.dart';

extension BuildContextX on BuildContext {
  AlgoTheme get algo =>
      Theme.of(this).extension<AlgoTheme>() ?? AlgoTheme.light;
  bool get isMobile => MediaQuery.sizeOf(this).width < Breakpoints.mobile;
  bool get isTablet {
    final width = MediaQuery.sizeOf(this).width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  bool get isDesktop => MediaQuery.sizeOf(this).width >= Breakpoints.tablet;
}
