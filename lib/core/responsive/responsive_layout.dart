import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return desktop;
        }
        if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

class ResponsiveValue<T> {
  const ResponsiveValue._();

  static T of<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) {
      return desktop;
    }
    if (width >= 600) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

EdgeInsets responsivePadding(BuildContext context) {
  return ResponsiveValue.of<EdgeInsets>(
    context,
    mobile: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(20),
    desktop: const EdgeInsets.all(24),
  );
}
