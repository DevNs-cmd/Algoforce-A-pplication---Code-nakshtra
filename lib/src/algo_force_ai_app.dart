import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const _navy = Color(0xFF14243A);
const _ink = Color(0xFF14243A);
const _muted = Color(0xFF667085);
const _paper = Color(0xFFF8FAFC);
const _surface = Color(0xFFFFFFFF);
const _purple = Color(0xFF7C3AED);
const _violet = Color(0xFFA855F7);
const _cyan = Color(0xFF38BDF8);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _danger = Color(0xFFE11D48);

String get _defaultApiBase {
  const configured = String.fromEnvironment('API_BASE_URL');
  if (configured.isNotEmpty) return configured;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:4000';
  }
  return 'http://localhost:4000';
}

final apiProvider = Provider((ref) => ApiClient(_defaultApiBase));
final osProvider = StateNotifierProvider<OsController, OsState>((ref) {
  return OsController(ref.watch(apiProvider));
});

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(register: false),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const AuthScreen(register: true),
      ),
      GoRoute(
        path: '/dashboard/founder',
        builder: (context, state) => const FounderWorkspace(),
      ),
      GoRoute(
        path: '/dashboard/investor',
        builder: (context, state) => const InvestorWorkspace(),
      ),
      GoRoute(
        path: '/dashboard/builder',
        builder: (context, state) => const BuilderWorkspace(),
      ),
      GoRoute(
        path: '/dashboard/admin',
        builder: (context, state) => const AdminWorkspace(),
      ),
      GoRoute(
        path: '/startup/:id',
        builder: (context, state) =>
            StartupWorkspace(id: state.pathParameters['id']!),
      ),
    ],
  );
});

class AlgoForceAiApp extends ConsumerWidget {
  const AlgoForceAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AlgoForce AI',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _violet,
          brightness: Brightness.light,
          surface: _surface,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ).apply(bodyColor: _ink, displayColor: _ink),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          prefixIconColor: _purple,
          labelStyle: const TextStyle(
            color: _muted,
            fontWeight: FontWeight.w700,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _navy.withValues(alpha: .08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _navy.withValues(alpha: .08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: _purple, width: 1.4),
          ),
        ),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class ApiClient {
  ApiClient(this.baseUrl);
  final String baseUrl;
  String? token;
  String? testRole;
  static const bool useRemoteApi = bool.fromEnvironment(
    'USE_REMOTE_API',
    defaultValue: false,
  );
  SharedPreferences? _prefs;
  Map<String, dynamic>? _local;
  int _id = 0;

  Uri uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);
  Uri wsUri() => Uri.parse('${baseUrl.replaceFirst('http', 'ws')}/ws');

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
    if (token == null && testRole != null) 'x-test-role': testRole!,
  };

  Future<dynamic> get(String path, [Map<String, String>? query]) async {
    if (!useRemoteApi) return _localGet(path, query ?? const {});
    try {
      final response = await http.get(uri(path, query), headers: headers);
      return _decode(response);
    } catch (_) {
      return _localGet(path, query ?? const {});
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    if (!useRemoteApi) return _localPost(path, body);
    try {
      final response = await http.post(
        uri(path),
        headers: headers,
        body: jsonEncode(body),
      );
      return _decode(response);
    } catch (_) {
      return _localPost(path, body);
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    if (!useRemoteApi) return _localPut(path, body);
    try {
      final response = await http.put(
        uri(path),
        headers: headers,
        body: jsonEncode(body),
      );
      return _decode(response);
    } catch (_) {
      return _localPut(path, body);
    }
  }

  Future<void> delete(String path) async {
    if (!useRemoteApi) {
      await _localDelete(path);
      return;
    }
    try {
      final response = await http.delete(uri(path), headers: headers);
      if (response.statusCode >= 400) _decode(response);
    } catch (_) {
      await _localDelete(path);
    }
  }

  Future<dynamic> uploadEvidence(String taskId, String content) async {
    if (!useRemoteApi) {
      return _localPut('/task/$taskId', {
        'evidenceUrl': 'local://evidence/$taskId.txt',
      });
    }
    final request = http.MultipartRequest(
      'POST',
      uri('/task/$taskId/evidence'),
    );
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        utf8.encode(content),
        filename: 'evidence-$taskId.txt',
      ),
    );
    final response = await http.Response.fromStream(await request.send());
    return _decode(response);
  }

  Future<void> _loadLocal() async {
    if (_local != null) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('algoforce_ai_local_mvp');
    if (raw != null) {
      _local = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      _id = _local!['idCounter'] as int? ?? 0;
      return;
    }
    _local = {
      'idCounter': 0,
      'users': <Map<String, dynamic>>[],
      'startups': <Map<String, dynamic>>[],
      'tasks': <Map<String, dynamic>>[],
      'investments': <Map<String, dynamic>>[],
      'events': <Map<String, dynamic>>[],
      'builders': <Map<String, dynamic>>[],
      'notifications': <Map<String, dynamic>>[],
    };
    await _saveLocal();
  }

  Future<void> _saveLocal() async {
    if (_prefs == null || _local == null) return;
    _local!['idCounter'] = _id;
    await _prefs!.setString('algoforce_ai_local_mvp', jsonEncode(_local));
  }

  List<Map<String, dynamic>> _list(String key) {
    return ((_local![key] as List?) ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  String _next(String prefix) {
    _id += 1;
    return '${prefix}_$_id';
  }

  Future<Map<String, dynamic>> _localUser(String role) async {
    await _loadLocal();
    final users = _list('users');
    final email = 'testing-$role@algoforce.ai';
    var user = users.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['email'] == email,
      orElse: () => null,
    );
    if (user == null) {
      user = {
        'id': _next('usr'),
        'name':
            'Testing ${role.substring(0, 1).toUpperCase()}${role.substring(1)}',
        'email': email,
        'role': role,
        'trustScore': 99,
      };
      users.add(user);
      _local!['users'] = users;
      await _saveLocal();
    }
    return user;
  }

  Future<void> _event(
    String type,
    Map<String, dynamic> payload, [
    String? startupId,
  ]) async {
    final role = testRole ?? 'admin';
    final user = await _localUser(role);
    final events = _list('events');
    events.insert(0, {
      'id': _next('evt'),
      'type': type,
      'payload': payload,
      'actorId': user['id'],
      'startupId': startupId,
      'timestamp': DateTime.now().toIso8601String(),
    });
    _local!['events'] = events.take(100).toList();
    await _saveLocal();
  }

  Map<String, dynamic> _withRelations(Map<String, dynamic> startup) {
    final id = startup['id'];
    return {
      ...startup,
      'tasks': _list('tasks').where((task) => task['startupId'] == id).toList(),
      'investments': _list(
        'investments',
      ).where((deal) => deal['startupId'] == id).toList(),
      'events': _list(
        'events',
      ).where((event) => event['startupId'] == id).toList(),
      'analytics': _score(startup),
    };
  }

  Map<String, dynamic> _score(Map<String, dynamic> startup) {
    final tasks = _list(
      'tasks',
    ).where((task) => task['startupId'] == startup['id']).toList();
    final investments = _list(
      'investments',
    ).where((deal) => deal['startupId'] == startup['id']).toList();
    final done = tasks.where((task) => task['status'] == 'DONE').length;
    final evidence = tasks.where((task) => task['evidenceUrl'] != null).length;
    final execution = tasks.isEmpty ? 0 : ((done / tasks.length) * 100).round();
    final evidenceScore = tasks.isEmpty
        ? 0
        : ((evidence / tasks.length) * 100).round();
    final ideaClarity =
        (((('${startup['name'] ?? ''}'.length +
                            '${startup['idea'] ?? ''}'.length) /
                        160) *
                    100)
                .round())
            .clamp(0, 100);
    final capital =
        (investments.fold<int>(
                  0,
                  (sum, item) => sum + ((item['amount'] as num?)?.toInt() ?? 0),
                ) /
                10000)
            .round()
            .clamp(0, 100);
    final market = ((startup['marketScore'] as num?)?.toInt() ?? 50).clamp(
      0,
      100,
    );
    final team = ((startup['teamStrength'] as num?)?.toInt() ?? 50).clamp(
      0,
      100,
    );
    final score =
        (market * .24 +
                ideaClarity * .18 +
                execution * .24 +
                team * .18 +
                evidenceScore * .10 +
                capital * .06)
            .round();
    return {
      'score': score,
      'risk': score >= 76
          ? 'low'
          : score >= 52
          ? 'medium'
          : 'high',
      'marketScore': market,
      'ideaClarity': ideaClarity,
      'executionProgress': execution,
      'teamStrength': team,
      'evidenceScore': evidenceScore,
      'capitalSignal': capital,
      'recommendation': score >= 76
          ? 'Scale fundraising'
          : score >= 52
          ? 'Add execution evidence'
          : 'Clarify market and ship core tasks',
    };
  }

  Future<dynamic> _localGet(String path, Map<String, String> query) async {
    await _loadLocal();
    if (path == '/events')
      return {'items': _list('events'), 'total': _list('events').length};
    if (path == '/notifications')
      return {
        'items': _list('notifications'),
        'total': _list('notifications').length,
      };
    if (path == '/builder-profile')
      return {'items': _list('builders'), 'total': _list('builders').length};
    if (path == '/builder/tasks')
      return {'items': _list('tasks'), 'total': _list('tasks').length};
    if (path == '/startup') {
      final q = (query['q'] ?? '').toLowerCase();
      final items = _list('startups')
          .where((startup) {
            if (q.isEmpty) return true;
            return '${startup['name']} ${startup['idea']}'
                .toLowerCase()
                .contains(q);
          })
          .map(_withRelations)
          .toList();
      return {'items': items, 'total': items.length};
    }
    if (path.startsWith('/startup/') && path.endsWith('/analytics')) {
      final id = path.split('/')[2];
      final startup = _list('startups').firstWhere((item) => item['id'] == id);
      return _score(startup);
    }
    if (path.startsWith('/startup/')) {
      final id = path.split('/').last;
      final startup = _list('startups').firstWhere((item) => item['id'] == id);
      await _event('STARTUP_VIEWED', {'startupId': id}, id);
      return _withRelations(startup);
    }
    if (path.startsWith('/task/')) {
      final startupId = path.split('/').last;
      final items = _list(
        'tasks',
      ).where((task) => task['startupId'] == startupId).toList();
      return {'items': items, 'total': items.length};
    }
    if (path.startsWith('/portfolio/')) {
      final items = _list('investments').map((deal) {
        final startup = _list('startups')
            .cast<Map<String, dynamic>?>()
            .firstWhere(
              (item) => item?['id'] == deal['startupId'],
              orElse: () => null,
            );
        return {...deal, 'startup': startup};
      }).toList();
      return {'items': items, 'total': items.length};
    }
    return {'items': []};
  }

  Future<dynamic> _localPost(String path, Map<String, dynamic> body) async {
    await _loadLocal();
    if (path == '/auth/register' || path == '/auth/login') {
      final role = '${body['role'] ?? testRole ?? 'founder'}';
      final user = await _localUser(role);
      return {
        'user': user,
        'accessToken': 'local-token',
        'refreshToken': 'local-refresh',
      };
    }
    if (path == '/startup') {
      final user = await _localUser(testRole ?? 'founder');
      final startups = _list('startups');
      final startup = {
        'id': _next('st'),
        'founderId': user['id'],
        'name': body['name'] ?? 'Untitled Startup',
        'idea': body['idea'] ?? '',
        'status': body['status'] ?? 'ACTIVE',
        'fundingStage': body['fundingStage'] ?? 'BOOTSTRAPPED',
        'marketScore': body['marketScore'] ?? 50,
        'teamStrength': body['teamStrength'] ?? 50,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      startups.insert(0, startup);
      _local!['startups'] = startups;
      await _event('STARTUP_CREATED', {
        'startupId': startup['id'],
        'name': startup['name'],
      }, '${startup['id']}');
      await _saveLocal();
      return _withRelations(startup);
    }
    if (path == '/task') {
      final tasks = _list('tasks');
      final task = {
        'id': _next('task'),
        'startupId': body['startupId'],
        'title': body['title'] ?? 'Untitled Task',
        'status': body['status'] ?? 'TODO',
        'assignedTo': body['assignedTo'],
        'evidenceUrl': null,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      tasks.insert(0, task);
      _local!['tasks'] = tasks;
      await _event('TASK_CREATED', {
        'taskId': task['id'],
        'title': task['title'],
      }, '${task['startupId']}');
      await _saveLocal();
      return task;
    }
    if (path == '/invest') {
      final user = await _localUser(testRole ?? 'investor');
      final deals = _list('investments');
      final deal = {
        'id': _next('inv'),
        'investorId': user['id'],
        'startupId': body['startupId'],
        'amount': body['amount'] ?? 0,
        'createdAt': DateTime.now().toIso8601String(),
      };
      deals.insert(0, deal);
      _local!['investments'] = deals;
      await _event('INVESTMENT_CREATED', {
        'investmentId': deal['id'],
        'amount': deal['amount'],
      }, '${deal['startupId']}');
      await _saveLocal();
      return deal;
    }
    return {};
  }

  Future<dynamic> _localPut(String path, Map<String, dynamic> body) async {
    await _loadLocal();
    if (path.startsWith('/startup/')) {
      final id = path.split('/').last;
      final startups = _list('startups');
      final index = startups.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        startups[index] = {
          ...startups[index],
          ...body,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        _local!['startups'] = startups;
        await _event('STARTUP_UPDATED', {'startupId': id, 'patch': body}, id);
        await _saveLocal();
        return _withRelations(startups[index]);
      }
    }
    if (path.startsWith('/task/')) {
      final id = path.split('/').last;
      final tasks = _list('tasks');
      final index = tasks.indexWhere((item) => item['id'] == id);
      if (index >= 0) {
        tasks[index] = {
          ...tasks[index],
          ...body,
          'updatedAt': DateTime.now().toIso8601String(),
        };
        _local!['tasks'] = tasks;
        await _event(
          body['evidenceUrl'] == null
              ? 'TASK_UPDATED'
              : 'TASK_EVIDENCE_UPLOADED',
          {'taskId': id, 'patch': body},
          '${tasks[index]['startupId']}',
        );
        await _saveLocal();
        return tasks[index];
      }
    }
    if (path == '/builder-profile/me') {
      final user = await _localUser(testRole ?? 'builder');
      final builders = _list('builders');
      final skills = body['skills'] is List
          ? body['skills']
          : '${body['skills'] ?? ''}'
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
      final profile = {
        'userId': user['id'],
        'skills': skills,
        'rating': body['rating'] ?? 4.8,
        'user': user,
      };
      final index = builders.indexWhere((item) => item['userId'] == user['id']);
      if (index >= 0) {
        builders[index] = profile;
      } else {
        builders.insert(0, profile);
      }
      _local!['builders'] = builders;
      await _event('BUILDER_PROFILE_UPDATED', {
        'userId': user['id'],
        'skills': skills,
      });
      await _saveLocal();
      return profile;
    }
    return {};
  }

  Future<void> _localDelete(String path) async {
    await _loadLocal();
    if (path.startsWith('/startup/')) {
      final id = path.split('/').last;
      _local!['startups'] = _list(
        'startups',
      ).where((item) => item['id'] != id).toList();
      _local!['tasks'] = _list(
        'tasks',
      ).where((item) => item['startupId'] != id).toList();
      await _event('STARTUP_DELETED', {'startupId': id}, id);
    }
    if (path.startsWith('/task/')) {
      final id = path.split('/').last;
      final task = _list('tasks').cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?['id'] == id,
        orElse: () => null,
      );
      _local!['tasks'] = _list(
        'tasks',
      ).where((item) => item['id'] != id).toList();
      await _event('TASK_DELETED', {
        'taskId': id,
      }, task?['startupId']?.toString());
    }
    await _saveLocal();
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 400) {
      throw ApiException(
        body is Map ? '${body['error']}' : 'HTTP_${response.statusCode}',
      );
    }
    return body;
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class OsState {
  const OsState({
    this.user,
    this.startups = const [],
    this.selectedStartup,
    this.tasks = const [],
    this.events = const [],
    this.notifications = const [],
    this.builders = const [],
    this.portfolio = const [],
    this.analytics,
    this.loading = false,
    this.error,
    this.live = false,
  });

  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>> startups;
  final Map<String, dynamic>? selectedStartup;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> notifications;
  final List<Map<String, dynamic>> builders;
  final List<Map<String, dynamic>> portfolio;
  final Map<String, dynamic>? analytics;
  final bool loading;
  final String? error;
  final bool live;

  String? get role => user?['role'] as String?;
  bool get authed => user != null;

  OsState copyWith({
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? startups,
    Map<String, dynamic>? selectedStartup,
    List<Map<String, dynamic>>? tasks,
    List<Map<String, dynamic>>? events,
    List<Map<String, dynamic>>? notifications,
    List<Map<String, dynamic>>? builders,
    List<Map<String, dynamic>>? portfolio,
    Map<String, dynamic>? analytics,
    bool? loading,
    String? error,
    bool clearError = false,
    bool? live,
  }) {
    return OsState(
      user: user ?? this.user,
      startups: startups ?? this.startups,
      selectedStartup: selectedStartup ?? this.selectedStartup,
      tasks: tasks ?? this.tasks,
      events: events ?? this.events,
      notifications: notifications ?? this.notifications,
      builders: builders ?? this.builders,
      portfolio: portfolio ?? this.portfolio,
      analytics: analytics ?? this.analytics,
      loading: loading ?? this.loading,
      error: clearError ? null : error ?? this.error,
      live: live ?? this.live,
    );
  }
}

class OsController extends StateNotifier<OsState> {
  OsController(this.api) : super(const OsState());
  final ApiClient api;
  WebSocketChannel? _socket;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await _run(() async {
      final result = await api.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      api.token = result['accessToken'] as String;
      state = state.copyWith(
        user: Map<String, dynamic>.from(result['user'] as Map),
        clearError: true,
      );
      _connectRealtime();
      await refreshAll();
    });
  }

  Future<void> login({required String email, required String password}) async {
    await _run(() async {
      final result = await api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      api.token = result['accessToken'] as String;
      state = state.copyWith(
        user: Map<String, dynamic>.from(result['user'] as Map),
        clearError: true,
      );
      _connectRealtime();
      await refreshAll();
    });
  }

  Future<void> enterTesting(String role) async {
    api.token = null;
    api.testRole = role;
    await api._localUser(role);
    state = state.copyWith(
      user: {
        'id': 'testing-$role',
        'name':
            'Testing ${role.substring(0, 1).toUpperCase()}${role.substring(1)}',
        'email': 'testing-$role@algoforce.ai',
        'role': role,
        'trustScore': 99,
      },
      clearError: true,
    );
    _connectRealtime();
    await _run(refreshAll);
  }

  Future<void> refreshAll() async {
    if (!state.authed) return;
    await Future.wait([
      loadStartups(),
      loadEvents(),
      loadNotifications(),
      if (state.role == 'founder' || state.role == 'admin') loadBuilders(),
      if (state.role == 'builder') loadBuilderTasks(),
      if (state.role == 'investor') loadPortfolio(),
    ]);
  }

  Future<void> loadStartups({String q = ''}) async {
    final result = await api.get('/startup', {
      'pageSize': '30',
      if (q.isNotEmpty) 'q': q,
    });
    state = state.copyWith(startups: _items(result));
  }

  Future<void> openStartup(String id) async {
    await _run(() async {
      final result = await api.get('/startup/$id');
      final startup = Map<String, dynamic>.from(result as Map);
      final taskResult = await api.get('/task/$id', {'pageSize': '50'});
      state = state.copyWith(
        selectedStartup: startup,
        analytics: Map<String, dynamic>.from(startup['analytics'] as Map),
        tasks: _items(taskResult),
        clearError: true,
      );
    });
  }

  Future<void> createStartup(Map<String, dynamic> data) async {
    await _run(() async {
      await api.post('/startup', data);
      await loadStartups();
      await loadEvents();
    });
  }

  Future<void> updateStartup(String id, Map<String, dynamic> data) async {
    await _run(() async {
      await api.put('/startup/$id', data);
      await openStartup(id);
      await loadEvents();
    });
  }

  Future<void> deleteStartup(String id) async {
    await _run(() async {
      await api.delete('/startup/$id');
      state = state.copyWith(selectedStartup: {});
      await loadStartups();
      await loadEvents();
    });
  }

  Future<void> createTask(
    String startupId,
    String title,
    String? assignedTo,
  ) async {
    await _run(() async {
      await api.post('/task', {
        'startupId': startupId,
        'title': title,
        if (assignedTo != null && assignedTo.isNotEmpty)
          'assignedTo': assignedTo,
      });
      await openStartup(startupId);
    });
  }

  Future<void> updateTask(
    Map<String, dynamic> task,
    Map<String, dynamic> patch,
  ) async {
    await _run(() async {
      await api.put('/task/${task['id']}', patch);
      await openStartup('${task['startupId']}');
    });
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    await _run(() async {
      await api.delete('/task/${task['id']}');
      await openStartup('${task['startupId']}');
    });
  }

  Future<void> uploadEvidence(Map<String, dynamic> task) async {
    await _run(() async {
      await api.uploadEvidence(
        '${task['id']}',
        'Evidence uploaded from AlgoForce AI at ${DateTime.now().toIso8601String()} for ${task['title']}',
      );
      await openStartup('${task['startupId']}');
    });
  }

  Future<void> invest(String startupId, int amount) async {
    await _run(() async {
      await api.post('/invest', {'startupId': startupId, 'amount': amount});
      await loadPortfolio();
      await loadEvents();
    });
  }

  Future<void> loadPortfolio() async {
    final userId = state.user?['id'];
    if (userId == null) return;
    final result = await api.get('/portfolio/$userId', {'pageSize': '50'});
    state = state.copyWith(portfolio: _items(result));
  }

  Future<void> loadBuilders() async {
    final result = await api.get('/builder-profile', {'pageSize': '50'});
    state = state.copyWith(builders: _items(result));
  }

  Future<void> loadBuilderTasks() async {
    final result = await api.get('/builder/tasks', {'pageSize': '50'});
    state = state.copyWith(tasks: _items(result));
  }

  Future<void> saveBuilderProfile(String skills, double rating) async {
    await _run(() async {
      await api.put('/builder-profile/me', {
        'skills': skills,
        'rating': rating,
      });
      await loadBuilders();
      await loadEvents();
    });
  }

  Future<void> loadEvents() async {
    final result = await api.get('/events', {'pageSize': '50'});
    state = state.copyWith(events: _items(result));
  }

  Future<void> loadNotifications() async {
    final result = await api.get('/notifications', {'pageSize': '30'});
    state = state.copyWith(notifications: _items(result));
  }

  void _connectRealtime() {
    if (!ApiClient.useRemoteApi) {
      state = state.copyWith(live: true);
      return;
    }
    _socket?.sink.close();
    _socket = WebSocketChannel.connect(api.wsUri());
    state = state.copyWith(live: true);
    _socket!.stream.listen(
      (_) => refreshAll(),
      onError: (_) => state = state.copyWith(live: false),
      onDone: () => state = state.copyWith(live: false),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await action();
      state = state.copyWith(loading: false, clearError: true);
    } catch (error) {
      state = state.copyWith(loading: false, error: error.toString());
    }
  }

  List<Map<String, dynamic>> _items(dynamic result) {
    final raw = result is Map ? result['items'] : result;
    return (raw as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  void dispose() {
    _socket?.sink.close();
    super.dispose();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(1400.ms, () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OsBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LogoOrb(),
              const SizedBox(height: 18),
              const BrandLockup(center: true),
              const SizedBox(height: 8),
              Text(
                'Build. Govern. Scale.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 450.ms).slideY(begin: .06, end: 0),
        ),
      ),
    );
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.register});
  final bool register;
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final name = TextEditingController(text: 'Founder');
  final email = TextEditingController(text: 'founder@algoforce.ai');
  final password = TextEditingController(text: 'password123');
  String role = 'founder';

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osProvider);
    ref.listen(osProvider, (previous, next) {
      if (previous?.user == null && next.user != null && context.mounted)
        context.go('/dashboard/${next.role}');
    });
    return Scaffold(
      body: OsBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BrandLockup(),
                    const SizedBox(height: 24),
                    Text(
                      widget.register
                          ? 'Create execution account'
                          : 'Sign in to AlgoForce AI',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 14),
                    if (widget.register) ...[
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.register)
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.badge_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'founder',
                            child: Text('Founder'),
                          ),
                          DropdownMenuItem(
                            value: 'investor',
                            child: Text('Investor'),
                          ),
                          DropdownMenuItem(
                            value: 'builder',
                            child: Text('Builder'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => role = value ?? 'founder'),
                      ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: state.loading
                          ? 'Working...'
                          : widget.register
                          ? 'Register'
                          : 'Login',
                      icon: Icons.login_rounded,
                      onTap: state.loading
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              if (widget.register) {
                                ref
                                    .read(osProvider.notifier)
                                    .register(
                                      name: name.text,
                                      email: email.text,
                                      password: password.text,
                                      role: role,
                                    );
                              } else {
                                ref
                                    .read(osProvider.notifier)
                                    .login(
                                      email: email.text,
                                      password: password.text,
                                    );
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Testing access',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _muted,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final testRole in const [
                          'founder',
                          'investor',
                          'builder',
                          'admin',
                        ])
                          ActionChip(
                            label: Text(testRole),
                            avatar: const Icon(Icons.bolt_rounded, size: 16),
                            onPressed: state.loading
                                ? null
                                : () {
                                    ref
                                        .read(osProvider.notifier)
                                        .enterTesting(testRole);
                                    context.go('/dashboard/$testRole');
                                  },
                          ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          context.go(widget.register ? '/login' : '/signup'),
                      child: Text(
                        widget.register
                            ? 'Use existing login'
                            : 'Create a new account',
                      ),
                    ),
                    if (state.error != null) ErrorBanner(state.error!),
                    const SizedBox(height: 8),
                    Text(
                      ApiClient.useRemoteApi
                          ? 'Remote API: ${ref.watch(apiProvider).baseUrl}'
                          : 'Local MVP mode: no backend required',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FounderWorkspace extends ConsumerWidget {
  const FounderWorkspace({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osProvider);
    return WorkspaceScaffold(
      title: 'Founder Execution',
      actions: [
        IconButton(
          onPressed: () => _startupDialog(context, ref),
          icon: const Icon(Icons.add_business_rounded),
          tooltip: 'Create startup',
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => ref.read(osProvider.notifier).refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            if (state.error != null) ErrorBanner(state.error!),
            SectionTitle(
              'Startups from PostgreSQL',
              trailing: '${state.startups.length}',
            ),
            const SizedBox(height: 12),
            if (state.startups.isEmpty)
              const EmptyState(
                'No startups yet. Create one to begin event-driven execution.',
              ),
            for (final startup in state.startups)
              StartupCard(
                startup: startup,
                onOpen: () => context.go('/startup/${startup['id']}'),
              ),
            const SizedBox(height: 18),
            EventStream(events: state.events),
          ],
        ),
      ),
    );
  }
}

class InvestorWorkspace extends ConsumerWidget {
  const InvestorWorkspace({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osProvider);
    return WorkspaceScaffold(
      title: 'Investor Platform',
      child: RefreshIndicator(
        onRefresh: () => ref.read(osProvider.notifier).refreshAll(),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            if (state.error != null) ErrorBanner(state.error!),
            const SectionTitle('Live Deal Flow'),
            const SizedBox(height: 12),
            if (state.startups.isEmpty)
              const EmptyState(
                'No founder startups are available from the backend yet.',
              ),
            for (final startup in state.startups)
              StartupCard(
                startup: startup,
                onOpen: () => context.go('/startup/${startup['id']}'),
                action: PrimaryButton(
                  label: 'Invest',
                  icon: Icons.payments_rounded,
                  onTap: () => _investDialog(context, ref, '${startup['id']}'),
                ),
              ),
            const SizedBox(height: 18),
            const SectionTitle('Portfolio Records'),
            for (final item in state.portfolio)
              DataRowCard(
                title: '${item['startup']?['name'] ?? 'Startup'}',
                subtitle: 'Investment amount: ${item['amount']}',
              ),
          ],
        ),
      ),
    );
  }
}

class BuilderWorkspace extends ConsumerWidget {
  const BuilderWorkspace({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = TextEditingController();
    final state = ref.watch(osProvider);
    return WorkspaceScaffold(
      title: 'Builder Workbench',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (state.error != null) ErrorBanner(state.error!),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle('Skills Profile'),
                const SizedBox(height: 12),
                TextField(
                  controller: skills,
                  decoration: const InputDecoration(
                    labelText: 'Skills, comma separated',
                    prefixIcon: Icon(Icons.graphic_eq_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Save Builder Profile',
                  icon: Icons.save_rounded,
                  onTap: () => ref
                      .read(osProvider.notifier)
                      .saveBuilderProfile(skills.text, 4.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionTitle('Assigned Tasks'),
          if (state.tasks.isEmpty)
            const EmptyState(
              'No assigned tasks yet. Founder assignments will arrive live.',
            ),
          for (final task in state.tasks) TaskCard(task: task),
          const SizedBox(height: 18),
          EventStream(events: state.events),
        ],
      ),
    );
  }
}

class AdminWorkspace extends ConsumerWidget {
  const AdminWorkspace({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osProvider);
    return WorkspaceScaffold(
      title: 'Governance Control',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          ResponsiveGrid(
            children: [
              MetricCard(
                'Users role',
                state.role ?? 'none',
                _purple,
                Icons.verified_user_rounded,
              ),
              MetricCard(
                'Startups',
                state.startups.length,
                _green,
                Icons.business_center_rounded,
              ),
              MetricCard(
                'Events',
                state.events.length,
                _cyan,
                Icons.receipt_long_rounded,
              ),
              MetricCard(
                'Notifications',
                state.notifications.length,
                _amber,
                Icons.notifications_active_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          EventStream(events: state.events),
        ],
      ),
    );
  }
}

class StartupWorkspace extends ConsumerStatefulWidget {
  const StartupWorkspace({super.key, required this.id});
  final String id;
  @override
  ConsumerState<StartupWorkspace> createState() => _StartupWorkspaceState();
}

class _StartupWorkspaceState extends ConsumerState<StartupWorkspace> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(osProvider.notifier).openStartup(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(osProvider);
    final startup = state.selectedStartup;
    return WorkspaceScaffold(
      title: startup?['name']?.toString() ?? 'Startup',
      actions: [
        if (state.role == 'founder' || state.role == 'admin')
          IconButton(
            onPressed: startup == null
                ? null
                : () => _taskDialog(context, ref, '${startup['id']}'),
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Create task',
          ),
        if (state.role == 'founder' || state.role == 'admin')
          IconButton(
            onPressed: startup == null
                ? null
                : () => _editStartupDialog(context, ref, startup),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit startup',
          ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (state.error != null) ErrorBanner(state.error!),
          if (startup == null || startup.isEmpty)
            const EmptyState('Loading startup from backend...')
          else
            StartupSummary(startup: startup, analytics: state.analytics),
          const SizedBox(height: 18),
          const SectionTitle('Execution Tasks'),
          Kanban(tasks: state.tasks),
          const SizedBox(height: 18),
          EventStream(
            events: (startup?['events'] as List? ?? state.events)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class WorkspaceScaffold extends ConsumerWidget {
  const WorkspaceScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });
  final String title;
  final Widget child;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(osProvider);
    return Scaffold(
      body: OsBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Row(
                  children: [
                    const BrandLockup(),
                    const Spacer(),
                    StatusPill(state.live ? 'Live sync' : 'Offline socket'),
                    const SizedBox(width: 8),
                    StatusPill(state.role ?? 'guest'),
                    ...actions,
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    if (MediaQuery.sizeOf(context).width >= 900)
                      const SideRail(),
                    Expanded(child: child),
                    if (MediaQuery.sizeOf(context).width >= 1180)
                      SizedBox(
                        width: 340,
                        child: EventStream(events: state.events, compact: true),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SideRail extends ConsumerWidget {
  const SideRail({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(osProvider).role;
    final items = [
      ('founder', Icons.rocket_launch_rounded),
      ('investor', Icons.account_balance_rounded),
      ('builder', Icons.handyman_rounded),
      ('admin', Icons.verified_user_rounded),
    ];
    return Container(
      width: 86,
      margin: const EdgeInsets.fromLTRB(18, 10, 4, 18),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: glassDecoration(22),
      child: Column(
        children: [
          for (final item in items)
            IconButton(
              tooltip: item.$1,
              color: role == item.$1 ? _purple : _muted,
              icon: Icon(item.$2),
              onPressed: () => context.go('/dashboard/${item.$1}'),
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(osProvider.notifier).refreshAll(),
          ),
        ],
      ),
    );
  }
}

class StartupSummary extends StatelessWidget {
  const StartupSummary({
    super.key,
    required this.startup,
    required this.analytics,
  });
  final Map<String, dynamic> startup;
  final Map<String, dynamic>? analytics;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${startup['name']}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${startup['idea']}',
                style: const TextStyle(color: _muted, height: 1.35),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatusPill('${startup['status']}'),
                  StatusPill('${startup['fundingStage']}'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (analytics != null)
          ResponsiveGrid(
            children: [
              MetricCard(
                'AI score',
                analytics!['score'],
                _purple,
                Icons.auto_awesome_rounded,
              ),
              MetricCard(
                'Risk',
                analytics!['risk'],
                _danger,
                Icons.radar_rounded,
              ),
              MetricCard(
                'Execution',
                analytics!['executionProgress'],
                _green,
                Icons.task_alt_rounded,
              ),
              MetricCard(
                'Evidence',
                analytics!['evidenceScore'],
                _cyan,
                Icons.upload_file_rounded,
              ),
            ],
          ),
      ],
    );
  }
}

class StartupCard extends StatelessWidget {
  const StartupCard({
    super.key,
    required this.startup,
    required this.onOpen,
    this.action,
  });
  final Map<String, dynamic> startup;
  final VoidCallback onOpen;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final taskCount = (startup['tasks'] as List?)?.length ?? 0;
    final investmentCount = (startup['investments'] as List?)?.length ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${startup['name']}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                StatusPill('${startup['fundingStage']}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${startup['idea']}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _muted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusPill('${startup['status']}'),
                StatusPill('$taskCount tasks'),
                StatusPill('$investmentCount investments'),
              ],
            ),
            if (action != null) ...[const SizedBox(height: 12), action!],
          ],
        ),
      ),
    );
  }
}

class Kanban extends ConsumerWidget {
  const Kanban({super.key, required this.tasks});
  final List<Map<String, dynamic>> tasks;
  static const statuses = ['TODO', 'IN_PROGRESS', 'REVIEW', 'DONE'];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty)
      return const EmptyState(
        'No tasks yet. Create one and it will persist in PostgreSQL.',
      );
    return SizedBox(
      height: 370,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final scoped = tasks
              .where((task) => task['status'] == status)
              .toList();
          return SizedBox(
            width: 300,
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        status,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const Spacer(),
                      StatusPill('${scoped.length}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: scoped
                          .map((task) => TaskCard(task: task))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task});
  final Map<String, dynamic> task;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(osProvider).role;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${task['title']}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Assignee: ${task['assignee']?['name'] ?? task['assignedTo'] ?? 'Unassigned'}',
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
          if (task['evidenceUrl'] != null)
            Text(
              'Evidence: ${task['evidenceUrl']}',
              style: const TextStyle(color: _green, fontSize: 12),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in Kanban.statuses)
                ChoiceChip(
                  label: Text(status),
                  selected: task['status'] == status,
                  onSelected: role == null
                      ? null
                      : (_) => ref.read(osProvider.notifier).updateTask(task, {
                          'status': status,
                        }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Evidence',
                  icon: Icons.upload_file_rounded,
                  onTap: () =>
                      ref.read(osProvider.notifier).uploadEvidence(task),
                ),
              ),
              const SizedBox(width: 8),
              if (role == 'founder' || role == 'admin')
                IconButton(
                  onPressed: () =>
                      ref.read(osProvider.notifier).deleteTask(task),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventStream extends StatelessWidget {
  const EventStream({super.key, required this.events, this.compact = false});
  final List<Map<String, dynamic>> events;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: compact
          ? const EdgeInsets.fromLTRB(4, 10, 18, 18)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('EventLog Audit Trail'),
          const SizedBox(height: 12),
          SizedBox(
            height: compact ? 650 : 280,
            child: events.isEmpty
                ? const EmptyState('No events returned from backend yet.')
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 5),
                              decoration: const BoxDecoration(
                                color: _purple,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${event['type']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    jsonEncode(event['payload']),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: _muted,
                                      height: 1.35,
                                    ),
                                  ),
                                  Text(
                                    '${event['timestamp']}',
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard(this.label, this.value, this.color, this.icon, {super.key});
  final String label;
  final Object? value;
  final Color color;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _muted)),
                const SizedBox(height: 6),
                Text(
                  '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataRowCard extends StatelessWidget {
  const DataRowCard({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: ListTile(title: Text(title), subtitle: Text(subtitle)),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(18),
    child: Text(message, style: const TextStyle(color: _muted)),
  );
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _danger.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(color: _danger, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final String? trailing;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        if (trailing != null) StatusPill(trailing!),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: _violet,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        side: BorderSide(color: _purple.withValues(alpha: .20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: _ink,
        ),
      ),
    );
  }
}

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.center = false});
  final bool center;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: _violet.withValues(alpha: .25), blurRadius: 24),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/algoforce_mark.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.auto_awesome_rounded),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                'AlgoForce AI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Text(
                'Build. Govern. Scale.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LogoOrb extends StatelessWidget {
  const LogoOrb({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _violet.withValues(alpha: .22),
                      _purple.withValues(alpha: .08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Lottie.asset(
                'assets/lottie/venture_pulse.json',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              const Icon(Icons.rocket_launch_rounded, size: 70, color: _navy),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: -6, end: 6, duration: 1600.ms);
  }
}

class OsBackground extends StatelessWidget {
  const OsBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_surface, _paper, Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(top: -140, right: -90, child: _Glow(size: 340)),
        Positioned(bottom: -150, left: -90, child: _Glow(size: 300)),
        Positioned.fill(child: CustomPaint(painter: GridPainter())),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [_violet.withValues(alpha: .16), Colors.transparent],
      ),
    ),
  );
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _navy.withValues(alpha: .035)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = EdgeInsets.zero,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          margin: margin,
          padding: const EdgeInsets.all(18),
          decoration: glassDecoration(22),
          child: child,
        ),
      ),
    );
    return onTap == null
        ? card
        : InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: card,
          );
  }
}

BoxDecoration glassDecoration(double radius) => BoxDecoration(
  color: Colors.white.withValues(alpha: .76),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: _purple.withValues(alpha: .10)),
  boxShadow: [
    BoxShadow(
      color: _navy.withValues(alpha: .08),
      blurRadius: 28,
      offset: const Offset(0, 18),
    ),
    BoxShadow(
      color: _purple.withValues(alpha: .10),
      blurRadius: 22,
      offset: const Offset(0, 8),
    ),
  ],
);

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minWidth = 250,
  });
  final List<Widget> children;
  final double minWidth;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth ~/ minWidth).clamp(1, 6).toInt();
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children
              .map(
                (child) => SizedBox(
                  width: (constraints.maxWidth - (count - 1) * 14) / count,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

Future<void> _startupDialog(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController();
  final idea = TextEditingController();
  final market = TextEditingController(text: '70');
  final team = TextEditingController(text: '70');
  await showDialog<void>(
    context: context,
    builder: (context) => _FormDialog(
      title: 'Create Startup',
      fields: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: idea,
          decoration: const InputDecoration(labelText: 'Idea'),
        ),
        TextField(
          controller: market,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Market score'),
        ),
        TextField(
          controller: team,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Team strength'),
        ),
      ],
      onSubmit: () {
        ref.read(osProvider.notifier).createStartup({
          'name': name.text,
          'idea': idea.text,
          'marketScore': int.tryParse(market.text) ?? 50,
          'teamStrength': int.tryParse(team.text) ?? 50,
        });
        Navigator.pop(context);
      },
    ),
  );
}

Future<void> _editStartupDialog(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> startup,
) async {
  final name = TextEditingController(text: '${startup['name']}');
  final idea = TextEditingController(text: '${startup['idea']}');
  final status = TextEditingController(text: '${startup['status']}');
  final funding = TextEditingController(text: '${startup['fundingStage']}');
  await showDialog<void>(
    context: context,
    builder: (context) => _FormDialog(
      title: 'Edit Startup',
      fields: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: idea,
          decoration: const InputDecoration(labelText: 'Idea'),
        ),
        TextField(
          controller: status,
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        TextField(
          controller: funding,
          decoration: const InputDecoration(labelText: 'Funding stage'),
        ),
      ],
      danger: () {
        ref.read(osProvider.notifier).deleteStartup('${startup['id']}');
        Navigator.pop(context);
      },
      onSubmit: () {
        ref.read(osProvider.notifier).updateStartup('${startup['id']}', {
          'name': name.text,
          'idea': idea.text,
          'status': status.text,
          'fundingStage': funding.text,
        });
        Navigator.pop(context);
      },
    ),
  );
}

Future<void> _taskDialog(
  BuildContext context,
  WidgetRef ref,
  String startupId,
) async {
  final title = TextEditingController();
  String? assignedTo;
  final builders = ref.read(osProvider).builders;
  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _FormDialog(
        title: 'Create Task',
        fields: [
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Task title'),
          ),
          DropdownButtonFormField<String?>(
            initialValue: assignedTo,
            decoration: const InputDecoration(labelText: 'Assign builder'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Unassigned'),
              ),
              for (final builder in builders)
                DropdownMenuItem<String?>(
                  value: '${builder['userId']}',
                  child: Text(
                    '${builder['user']?['name'] ?? builder['userId']}',
                  ),
                ),
            ],
            onChanged: (value) => setState(() => assignedTo = value),
          ),
        ],
        onSubmit: () {
          ref
              .read(osProvider.notifier)
              .createTask(startupId, title.text, assignedTo);
          Navigator.pop(context);
        },
      ),
    ),
  );
}

Future<void> _investDialog(
  BuildContext context,
  WidgetRef ref,
  String startupId,
) async {
  final amount = TextEditingController(text: '25000');
  await showDialog<void>(
    context: context,
    builder: (context) => _FormDialog(
      title: 'Create Investment',
      fields: [
        TextField(
          controller: amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
      ],
      onSubmit: () {
        ref
            .read(osProvider.notifier)
            .invest(startupId, int.tryParse(amount.text) ?? 0);
        Navigator.pop(context);
      },
    ),
  );
}

class _FormDialog extends StatelessWidget {
  const _FormDialog({
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.danger,
  });
  final String title;
  final List<Widget> fields;
  final VoidCallback onSubmit;
  final VoidCallback? danger;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields
                .map(
                  (field) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: field,
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        if (danger != null)
          TextButton(onPressed: danger, child: const Text('Delete')),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: onSubmit, child: const Text('Save')),
      ],
    );
  }
}
