import 'package:flutter/widgets.dart';

class ShellNavigationScope extends InheritedWidget {
  const ShellNavigationScope({
    super.key,
    required this.currentIndex,
    required this.goToRoute,
    required super.child,
  });

  final int currentIndex;
  final void Function(String route) goToRoute;

  static ShellNavigationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellNavigationScope>();
  }

  static ShellNavigationScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No ShellNavigationScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShellNavigationScope oldWidget) {
    return currentIndex != oldWidget.currentIndex ||
        goToRoute != oldWidget.goToRoute;
  }
}
