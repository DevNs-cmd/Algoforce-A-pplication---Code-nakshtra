import 'package:flutter/material.dart';

import 'responsive_layout.dart';

class ResponsiveGridDelegate {
  const ResponsiveGridDelegate._();

  static SliverGridDelegateWithFixedCrossAxisCount of(
    BuildContext context, {
    int mobileCount = 1,
    int tabletCount = 2,
    int desktopCount = 4,
    double mainAxisSpacing = 12,
    double crossAxisSpacing = 12,
    double childAspectRatio = 1,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: ResponsiveValue.of<int>(
        context,
        mobile: mobileCount,
        tablet: tabletCount,
        desktop: desktopCount,
      ),
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
    );
  }

  static int crossAxisCount(
    BuildContext context, {
    int mobileCount = 1,
    int tabletCount = 2,
    int desktopCount = 4,
  }) {
    return ResponsiveValue.of<int>(
      context,
      mobile: mobileCount,
      tablet: tabletCount,
      desktop: desktopCount,
    );
  }
}
