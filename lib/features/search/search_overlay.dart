import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../features/academy/providers/academy_provider.dart';
import '../../features/advisor/advisor_sheet.dart';
import '../../features/nexus/providers/nexus_provider.dart';
import '../../features/roadmap/providers/roadmap_provider.dart';
import '../../features/studio/providers/studio_provider.dart';
import '../../features/verified/providers/verified_provider.dart';
import '../../shared/widgets/astronaut_widget.dart';
import 'search_provider.dart';

Future<void> showSearchOverlay(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close search',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SearchOverlay(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final results = _results(state.query);
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _CloseSearchIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveSearchIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveSearchIntent(-1),
        SingleActivator(LogicalKeyboardKey.enter): _SubmitSearchIntent(),
      },
      child: Actions(
        actions: {
          _CloseSearchIntent: CallbackAction<_CloseSearchIntent>(
            onInvoke: (_) {
              Navigator.of(context).maybePop();
              return null;
            },
          ),
          _MoveSearchIntent: CallbackAction<_MoveSearchIntent>(
            onInvoke: (intent) {
              ref
                  .read(searchProvider.notifier)
                  .moveHighlight(intent.delta, results.length);
              return null;
            },
          ),
          _SubmitSearchIntent: CallbackAction<_SubmitSearchIntent>(
            onInvoke: (_) {
              if (results.isNotEmpty) {
                _openResult(
                  results[state.highlightedIndex.clamp(0, results.length - 1)],
                );
              }
              return null;
            },
          ),
        },
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withValues(alpha: .4),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.fromLTRB(16, 86, 16, 16),
                child: GestureDetector(
                  onTap: () {},
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimensions.maxSearchWidth,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .16),
                            blurRadius: 30,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  color: state.query.isEmpty
                                      ? AppColors.textHint
                                      : AppColors.purple,
                                ),
                                hintText: 'Search AlgoForce OS...',
                                suffixIcon: IconButton(
                                  tooltip: 'Close',
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ),
                              onChanged: _onChanged,
                            ),
                          ),
                          const Divider(height: 1),
                          Flexible(
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(10),
                              children: state.query.isEmpty
                                  ? _recent(state)
                                  : _resultWidgets(results, state),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        ref.read(searchProvider.notifier).setQuery(value);
      }
    });
  }

  List<Widget> _recent(SearchState state) {
    if (state.recent.isEmpty) {
      return const [_EmptyRecent()];
    }
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text('Recent', style: AppText.body(weight: FontWeight.w800)),
            const Spacer(),
            TextButton(
              onPressed: () => ref.read(searchProvider.notifier).clearRecent(),
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
      for (final item in state.recent.take(5))
        ListTile(
          leading: const Icon(Icons.history_rounded),
          title: Text(item),
          onTap: () {
            _controller.text = item;
            ref.read(searchProvider.notifier).setQuery(item);
          },
        ),
    ];
  }

  List<Widget> _resultWidgets(
    List<SpotlightResult> results,
    SearchState state,
  ) {
    if (results.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            children: [
              const AstronautWidget(size: 64),
              const SizedBox(height: AppDimensions.space14),
              Text(
                "No results for '${state.query}'",
                style: AppText.body(color: AppColors.textMuted),
              ),
              TextButton.icon(
                onPressed: () =>
                    showAdvisorSheet(context, ref, prefill: state.query),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text("Ask Advisor: '${state.query}'"),
              ),
            ],
          ),
        ),
      ];
    }
    final groups = <String, List<SpotlightResult>>{};
    for (final result in results) {
      groups.putIfAbsent(result.type, () => []).add(result);
    }
    var flatIndex = 0;
    return [
      for (final group in groups.entries) ...[
        _SectionHeader(group.key),
        for (final result in group.value)
          _ResultTile(
            result: result,
            highlighted: flatIndex++ == state.highlightedIndex,
            onTap: () => _openResult(result),
          ),
      ],
    ];
  }

  List<SpotlightResult> _results(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return const [];
    }
    bool matches(String value) => value.toLowerCase().contains(trimmed);
    final academy = ref.watch(academyProvider);
    final studio = ref.watch(studioProvider);
    final verified = ref.watch(verifiedProvider);
    final nexus = ref.watch(nexusProvider);
    final roadmap = ref.watch(roadmapProvider);
    const screens = [
      SpotlightResult(
        icon: Icons.dashboard_rounded,
        type: 'Screens',
        title: 'Overview',
        subtitle: '/',
        route: '/',
      ),
      SpotlightResult(
        icon: Icons.school_rounded,
        type: 'Screens',
        title: 'Academy',
        subtitle: '/academy',
        route: '/academy',
      ),
      SpotlightResult(
        icon: Icons.rocket_launch_rounded,
        type: 'Screens',
        title: 'Studio',
        subtitle: '/studio',
        route: '/studio',
      ),
      SpotlightResult(
        icon: Icons.verified_rounded,
        type: 'Screens',
        title: 'Verified',
        subtitle: '/verified',
        route: '/verified',
      ),
      SpotlightResult(
        icon: Icons.query_stats_rounded,
        type: 'Screens',
        title: 'Analytics',
        subtitle: '/analytics',
        route: '/analytics',
      ),
    ];
    return [
      for (final screen in screens)
        if (matches(screen.title)) screen,
      for (final cohort in academy.cohorts)
        for (final student in cohort.students)
          if (matches(student.name) || matches(student.college))
            SpotlightResult(
              icon: Icons.person_rounded,
              type: 'Students',
              title: student.name,
              subtitle: '${student.college} - ${cohort.name}',
              route: '/academy/cohort/${cohort.id}/student/${student.id}',
            ),
      for (final project in studio.projects)
        if (matches(project.startupName) || matches(project.founderName))
          SpotlightResult(
            icon: Icons.rocket_launch_rounded,
            type: 'Build Projects',
            title: project.startupName,
            subtitle: '${project.founderName} - ${project.status.name}',
            route: '/studio/project/${project.id}',
          ),
      for (final founder in verified.certifiedFounders)
        if (matches(founder.founderName) || matches(founder.startupName))
          SpotlightResult(
            icon: Icons.verified_rounded,
            type: 'Certified Founders',
            title: founder.founderName,
            subtitle: '${founder.startupName} - score ${founder.indexScore}',
            route: '/verified/founder/${founder.id}',
          ),
      for (final phase in roadmap.phases)
        if (matches(phase.title) ||
            phase.items.any((item) => matches(item.description)))
          SpotlightResult(
            icon: Icons.map_rounded,
            type: 'Roadmap Items',
            title: phase.title,
            subtitle: phase.items.first.description,
            route: '/roadmap',
          ),
      for (final build in nexus.buildHistory)
        if (matches(build.prompt) || matches(build.filename))
          SpotlightResult(
            icon: Icons.code_rounded,
            type: 'Nexus Builds',
            title: build.filename,
            subtitle: build.prompt,
            route: '/nexus',
          ),
    ].take(40).toList();
  }

  Future<void> _openResult(SpotlightResult result) async {
    await ref.read(searchProvider.notifier).addRecent(_controller.text);
    if (!mounted) {
      return;
    }
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(result.route);
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.highlighted,
    required this.onTap,
  });

  final SpotlightResult result;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.purple4 : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.purple4,
          child: Icon(result.icon, color: AppColors.purple),
        ),
        title: Text(result.title, style: AppText.body(weight: FontWeight.w800)),
        subtitle: Text(
          '${result.type} - ${result.subtitle}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.keyboard_return_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Text(
        label.toUpperCase(),
        style: AppText.body(
          size: 10,
          color: AppColors.textHint,
          weight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Row(
        children: [
          const AstronautWidget(size: 42),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Text(
              'Search screens, students, builds, founders, roadmap items, and Nexus history.',
              style: AppText.body(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseSearchIntent extends Intent {
  const _CloseSearchIntent();
}

class _MoveSearchIntent extends Intent {
  const _MoveSearchIntent(this.delta);
  final int delta;
}

class _SubmitSearchIntent extends Intent {
  const _SubmitSearchIntent();
}
