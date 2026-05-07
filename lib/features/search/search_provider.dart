import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/preferences_service.dart';

final searchProvider =
    StateNotifierProvider<SpotlightSearchController, SearchState>((ref) {
      return SpotlightSearchController(ref.watch(preferencesServiceProvider));
    });

class SearchState {
  const SearchState({
    this.query = '',
    this.recent = const [],
    this.highlightedIndex = 0,
  });

  final String query;
  final List<String> recent;
  final int highlightedIndex;

  SearchState copyWith({
    String? query,
    List<String>? recent,
    int? highlightedIndex,
  }) {
    return SearchState(
      query: query ?? this.query,
      recent: recent ?? this.recent,
      highlightedIndex: highlightedIndex ?? this.highlightedIndex,
    );
  }
}

class SpotlightSearchController extends StateNotifier<SearchState> {
  SpotlightSearchController(this._prefs)
    : super(SearchState(recent: _load(_prefs)));

  final PreferencesService _prefs;
  static const historyKey = 'search_history';

  void setQuery(String query) {
    state = state.copyWith(query: query, highlightedIndex: 0);
  }

  void moveHighlight(int delta, int max) {
    if (max <= 0) {
      state = state.copyWith(highlightedIndex: 0);
      return;
    }
    state = state.copyWith(
      highlightedIndex: (state.highlightedIndex + delta).clamp(0, max - 1),
    );
  }

  Future<void> addRecent(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final next = [
      trimmed,
      ...state.recent.where(
        (item) => item.toLowerCase() != trimmed.toLowerCase(),
      ),
    ].take(10).toList();
    state = state.copyWith(recent: next);
    await _prefs.setString(historyKey, jsonEncode(next));
  }

  Future<void> clearRecent() async {
    state = state.copyWith(recent: const []);
    await _prefs.remove(historyKey);
  }

  static List<String> _load(PreferencesService prefs) {
    final raw = prefs.getString(historyKey);
    if (raw == null) {
      return const [];
    }
    try {
      return (jsonDecode(raw) as List).whereType<String>().take(10).toList();
    } catch (_) {
      return const [];
    }
  }
}

class SpotlightResult {
  const SpotlightResult({
    required this.icon,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String type;
  final String title;
  final String subtitle;
  final String route;
}
