import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_service.dart';
import '../../activity/providers/activity_feed_provider.dart';
import '../services/nexus_api_service.dart';
import 'nexus_models.dart';

final nexusApiServiceProvider = Provider<NexusApiService>(
  (ref) => NexusApiService(),
);

final nexusProvider = StateNotifierProvider<NexusController, NexusState>(
  (ref) => NexusController(
    ref.watch(nexusApiServiceProvider),
    ref.watch(preferencesServiceProvider),
    ref.read(activityFeedProvider.notifier),
  ),
);

class NexusState {
  const NexusState({
    this.promptText =
        'Build a SaaS landing page with waitlist form and Stripe checkout',
    this.isGenerating = false,
    this.generatedCode,
    this.filename = 'component.jsx',
    this.deployUrl = 'nexus.algoforceai.com/demo',
    this.buildHistory = const [],
    this.error,
    this.framework = 'React',
    this.styling = 'Tailwind',
    this.includeTypeScript = false,
    this.mobileResponsive = true,
    this.streamedCode = '',
    this.includeComments = true,
    this.autoDeploy = true,
    this.showLineNumbers = false,
    this.maxLines = 60,
    this.codeStyle = 'hooks-first',
    this.isStreamingComplete = true,
  });

  final String promptText;
  final bool isGenerating;
  final String? generatedCode;
  final String filename;
  final String deployUrl;
  final List<NexusBuild> buildHistory;
  final String? error;
  final String framework;
  final String styling;
  final bool includeTypeScript;
  final bool mobileResponsive;
  final String streamedCode;
  final bool includeComments;
  final bool autoDeploy;
  final bool showLineNumbers;
  final int maxLines;
  final String codeStyle;
  final bool isStreamingComplete;

  NexusState copyWith({
    String? promptText,
    bool? isGenerating,
    String? generatedCode,
    String? filename,
    String? deployUrl,
    List<NexusBuild>? buildHistory,
    String? error,
    String? framework,
    String? styling,
    bool? includeTypeScript,
    bool? mobileResponsive,
    String? streamedCode,
    bool? includeComments,
    bool? autoDeploy,
    bool? showLineNumbers,
    int? maxLines,
    String? codeStyle,
    bool? isStreamingComplete,
  }) {
    return NexusState(
      promptText: promptText ?? this.promptText,
      isGenerating: isGenerating ?? this.isGenerating,
      generatedCode: generatedCode ?? this.generatedCode,
      filename: filename ?? this.filename,
      deployUrl: deployUrl ?? this.deployUrl,
      buildHistory: buildHistory ?? this.buildHistory,
      error: error,
      framework: framework ?? this.framework,
      styling: styling ?? this.styling,
      includeTypeScript: includeTypeScript ?? this.includeTypeScript,
      mobileResponsive: mobileResponsive ?? this.mobileResponsive,
      streamedCode: streamedCode ?? this.streamedCode,
      includeComments: includeComments ?? this.includeComments,
      autoDeploy: autoDeploy ?? this.autoDeploy,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      maxLines: maxLines ?? this.maxLines,
      codeStyle: codeStyle ?? this.codeStyle,
      isStreamingComplete: isStreamingComplete ?? this.isStreamingComplete,
    );
  }

  Map<String, dynamic> settingsToJson() {
    return {
      'framework': framework,
      'styling': styling,
      'includeTypeScript': includeTypeScript,
      'mobileResponsive': mobileResponsive,
      'includeComments': includeComments,
      'autoDeploy': autoDeploy,
      'showLineNumbers': showLineNumbers,
      'maxLines': maxLines,
      'codeStyle': codeStyle,
    };
  }

  factory NexusState.fromSettings({
    required List<NexusBuild> buildHistory,
    required String? rawSettings,
  }) {
    if (rawSettings == null) {
      return NexusState(buildHistory: buildHistory);
    }
    try {
      final json = Map<String, dynamic>.from(jsonDecode(rawSettings) as Map);
      return NexusState(
        buildHistory: buildHistory,
        framework: json['framework'] as String? ?? 'React',
        styling: json['styling'] as String? ?? 'Tailwind',
        includeTypeScript: json['includeTypeScript'] as bool? ?? false,
        mobileResponsive: json['mobileResponsive'] as bool? ?? true,
        includeComments: json['includeComments'] as bool? ?? true,
        autoDeploy: json['autoDeploy'] as bool? ?? true,
        showLineNumbers: json['showLineNumbers'] as bool? ?? false,
        maxLines: json['maxLines'] as int? ?? 60,
        codeStyle: json['codeStyle'] as String? ?? 'hooks-first',
      );
    } catch (_) {
      return NexusState(buildHistory: buildHistory);
    }
  }
}

class NexusController extends StateNotifier<NexusState> {
  NexusController(this._api, this._prefs, this._activity)
    : super(
        NexusState.fromSettings(
          buildHistory: NexusBuild.listFromJson(_prefs.getNexusBuildHistory()),
          rawSettings: _prefs.getNexusSettings(),
        ),
      );

  final NexusApiService _api;
  final PreferencesService _prefs;
  final ActivityFeedController _activity;
  Timer? _streamTimer;

  void setPrompt(String value) {
    state = state.copyWith(promptText: value, error: null);
  }

  void updateSettings({
    String? framework,
    String? styling,
    bool? includeTypeScript,
    bool? mobileResponsive,
    bool? includeComments,
    bool? autoDeploy,
    bool? showLineNumbers,
    int? maxLines,
    String? codeStyle,
  }) {
    state = state.copyWith(
      framework: framework,
      styling: styling,
      includeTypeScript: includeTypeScript,
      mobileResponsive: mobileResponsive,
      includeComments: includeComments,
      autoDeploy: autoDeploy,
      showLineNumbers: showLineNumbers,
      maxLines: maxLines,
      codeStyle: codeStyle,
      error: null,
    );
    unawaited(_prefs.setNexusSettings(jsonEncode(state.settingsToJson())));
  }

  Future<void> generate({bool stream = false}) async {
    if (state.isGenerating) {
      return;
    }
    state = state.copyWith(
      isGenerating: true,
      error: null,
      streamedCode: stream ? '' : state.streamedCode,
      isStreamingComplete: !stream,
    );
    final code = await _api.generateCode(
      state.promptText,
      framework: state.framework,
      includeComments: state.includeComments,
      maxLines: state.maxLines,
      codeStyle: state.codeStyle,
    );
    final filename = _filename(code);
    final deployUrl = state.autoDeploy
        ? 'nexus.algoforceai.com/${_randomHex(6)}'
        : 'local-preview-${_randomHex(4)}';
    final build = NexusBuild(
      prompt: state.promptText,
      filename: filename,
      code: code,
      deployUrl: deployUrl,
      createdAt: DateTime.now(),
      framework: state.framework,
    );
    final history = [build, ...state.buildHistory].take(12).toList();
    await _prefs.setNexusBuildHistory(NexusBuild.listToJson(history));
    state = state.copyWith(
      isGenerating: false,
      generatedCode: code,
      filename: filename,
      deployUrl: deployUrl,
      buildHistory: history,
      streamedCode: stream ? '' : code,
      error: null,
      isStreamingComplete: !stream,
    );
    _activity.add(
      icon: Icons.auto_awesome_rounded,
      description: 'Nexus generated $filename',
      route: '/nexus',
    );
    if (stream) {
      _startStreaming(code);
    }
  }

  void clearOutput() {
    state = state.copyWith(generatedCode: null, streamedCode: '', error: null);
  }

  void restoreBuild(int index) {
    if (index < 0 || index >= state.buildHistory.length) {
      return;
    }
    final build = state.buildHistory[index];
    state = state.copyWith(
      promptText: build.prompt,
      generatedCode: build.code,
      filename: build.filename,
      deployUrl: build.deployUrl,
      streamedCode: build.code,
      framework: build.framework,
      isStreamingComplete: true,
      error: null,
    );
  }

  Future<void> deleteBuild(int index) async {
    if (index < 0 || index >= state.buildHistory.length) {
      return;
    }
    final history = [...state.buildHistory]..removeAt(index);
    state = state.copyWith(buildHistory: history);
    await _prefs.setNexusBuildHistory(NexusBuild.listToJson(history));
  }

  void _startStreaming(String code) {
    _streamTimer?.cancel();
    var index = 0;
    _streamTimer = Timer.periodic(const Duration(milliseconds: 12), (timer) {
      index += 3;
      if (index >= code.length) {
        timer.cancel();
        HapticFeedback.lightImpact();
        state = state.copyWith(streamedCode: code, isStreamingComplete: true);
      } else {
        if (index % 50 == 0) {
          HapticFeedback.selectionClick();
        }
        state = state.copyWith(streamedCode: code.substring(0, index));
      }
    });
  }

  String _filename(String code) {
    final firstLine = code.split('\n').first.trim();
    if (firstLine.startsWith('//')) {
      final value = firstLine.replaceFirst('//', '').trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return 'component.jsx';
  }

  String _randomHex(int length) {
    const chars = '0123456789abcdef';
    final random = Random();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    super.dispose();
  }
}
