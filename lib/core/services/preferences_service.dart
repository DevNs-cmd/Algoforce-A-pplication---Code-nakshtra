import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('SharedPreferences is overridden in main.dart'),
);

final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => PreferencesService(ref.watch(sharedPreferencesProvider)),
);

class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const nexusBuildHistoryKey = 'nexus_build_history';
  static const roadmapCompletionsKey = 'roadmap_completions';
  static const academyDraftEnrollmentKey = 'academy_draft_enrollment';
  static const revenueScenarioKey = 'revenue_scenario';
  static const onboardingCompleteKey = 'onboarding_complete';
  static const sidebarCollapsedKey = 'sidebar_collapsed';
  static const activeScreenKey = 'active_screen';
  static const nexusSettingsKey = 'nexus_settings';
  static const studioKanbanOrderKey = 'studio_kanban_order';
  static const revenueSliderValuesKey = 'revenue_slider_values';
  static const academySortColumnKey = 'academy_sort_column';
  static const academySortAscKey = 'academy_sort_asc';
  static const roadmapExpandedPhaseKey = 'roadmap_expanded_phase';
  static const verifiedApplicationDraftKey = 'verified_application_draft';
  static const activityFeedKey = 'activity_feed';

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  int? getInt(String key) => _prefs.getInt(key);
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);
  Future<bool> remove(String key) => _prefs.remove(key);

  bool getOnboardingComplete() =>
      _prefs.getBool(onboardingCompleteKey) ?? false;
  Future<bool> setOnboardingComplete(bool value) =>
      _prefs.setBool(onboardingCompleteKey, value);

  String? getNexusBuildHistory() => _prefs.getString(nexusBuildHistoryKey);
  Future<bool> setNexusBuildHistory(String value) =>
      _prefs.setString(nexusBuildHistoryKey, value);

  bool getSidebarCollapsed() => _prefs.getBool(sidebarCollapsedKey) ?? false;
  Future<bool> setSidebarCollapsed(bool value) =>
      _prefs.setBool(sidebarCollapsedKey, value);

  String getActiveScreen() => _prefs.getString(activeScreenKey) ?? '/';
  Future<bool> setActiveScreen(String value) =>
      _prefs.setString(activeScreenKey, value);

  String? getNexusSettings() => _prefs.getString(nexusSettingsKey);
  Future<bool> setNexusSettings(String value) =>
      _prefs.setString(nexusSettingsKey, value);

  String? getStudioKanbanOrder() => _prefs.getString(studioKanbanOrderKey);
  Future<bool> setStudioKanbanOrder(String value) =>
      _prefs.setString(studioKanbanOrderKey, value);

  String? getRoadmapCompletions() => _prefs.getString(roadmapCompletionsKey);
  Future<bool> setRoadmapCompletions(String value) =>
      _prefs.setString(roadmapCompletionsKey, value);

  String? getAcademyDraftEnrollment() =>
      _prefs.getString(academyDraftEnrollmentKey);
  Future<bool> setAcademyDraftEnrollment(String value) =>
      _prefs.setString(academyDraftEnrollmentKey, value);

  String getRevenueScenario() => _prefs.getString(revenueScenarioKey) ?? 'base';
  Future<bool> setRevenueScenario(String value) =>
      _prefs.setString(revenueScenarioKey, value);

  String? getRevenueSliderValues() => _prefs.getString(revenueSliderValuesKey);
  Future<bool> setRevenueSliderValues(String value) =>
      _prefs.setString(revenueSliderValuesKey, value);

  int getAcademySortColumn() => _prefs.getInt(academySortColumnKey) ?? 0;
  bool getAcademySortAscending() => _prefs.getBool(academySortAscKey) ?? true;
  Future<bool> setAcademySort(int column, bool asc) async {
    final first = await _prefs.setInt(academySortColumnKey, column);
    final second = await _prefs.setBool(academySortAscKey, asc);
    return first && second;
  }

  int getRoadmapExpandedPhase() => _prefs.getInt(roadmapExpandedPhaseKey) ?? 1;
  Future<bool> setRoadmapExpandedPhase(int value) =>
      _prefs.setInt(roadmapExpandedPhaseKey, value);

  String? getVerifiedApplicationDraft() =>
      _prefs.getString(verifiedApplicationDraftKey);
  Future<bool> setVerifiedApplicationDraft(String value) =>
      _prefs.setString(verifiedApplicationDraftKey, value);

  String? getActivityFeed() => _prefs.getString(activityFeedKey);
  Future<bool> setActivityFeed(String value) =>
      _prefs.setString(activityFeedKey, value);
}
