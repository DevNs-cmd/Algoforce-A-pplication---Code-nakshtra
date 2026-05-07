import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_service.dart';

final themeModeProvider = StateNotifierProvider<AppThemeController, ThemeMode>(
  (ref) => AppThemeController(ref.watch(preferencesServiceProvider)),
);

class AppThemeController extends StateNotifier<ThemeMode> {
  AppThemeController(this._prefs)
    : super(_prefs.getString(key) == 'dark' ? ThemeMode.dark : ThemeMode.light);

  final PreferencesService _prefs;
  static const key = 'theme_mode';

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(key, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> toggle() {
    return setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
