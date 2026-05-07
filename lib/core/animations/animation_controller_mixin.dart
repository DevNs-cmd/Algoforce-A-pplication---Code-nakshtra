import 'package:flutter/material.dart';

mixin StandardAnimationControllerMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  late final AnimationController standardAnimationController;

  Duration get animationDuration => const Duration(milliseconds: 300);
  bool get autoPlayAnimation => true;

  @override
  void initState() {
    super.initState();
    standardAnimationController = AnimationController(
      vsync: this,
      duration: animationDuration,
      value: autoPlayAnimation ? 0 : 1,
    );
    if (autoPlayAnimation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
          standardAnimationController.value = 1;
        } else {
          standardAnimationController.forward();
        }
      });
    }
  }

  Future<void> playForward() {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      standardAnimationController.value = 1;
      return Future<void>.value();
    }
    return standardAnimationController.forward();
  }

  Future<void> playReverse() {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      standardAnimationController.value = 0;
      return Future<void>.value();
    }
    return standardAnimationController.reverse();
  }

  @override
  void dispose() {
    standardAnimationController.dispose();
    super.dispose();
  }
}
