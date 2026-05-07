import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/capital_os_theme.dart';
import '../../core/domain/venture_object.dart';
import '../../core/state/capital_os_controller.dart';
import '../../core/widgets/capital_glass.dart';

class VentureExecutionScreen extends ConsumerWidget {
  const VentureExecutionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(capitalOsControllerProvider);
    final venture = state.venture;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Title(
          title: 'Venture Execution',
          subtitle: 'Forced state transitions with evidence-gated tasks.',
        ),
        const SizedBox(height: 16),
        if (venture == null)
          const _NoVenture()
        else ...[
          _StateMachineRail(venture: venture),
          const SizedBox(height: 14),
          _ArtifactPanel(venture: venture),
          const SizedBox(height: 14),
          ...venture.executionTasks.map((task) => _TaskCard(task: task)),
          const SizedBox(height: 14),
          _TransitionControls(venture: venture),
          const SizedBox(height: 14),
          _EventStream(events: venture.events),
        ],
      ],
    );
  }
}

class _NoVenture extends StatelessWidget {
  const _NoVenture();

  @override
  Widget build(BuildContext context) {
    return const CapitalGlass(
      child: Row(
        children: [
          Icon(Icons.account_tree_outlined, color: CapitalColors.muted),
          SizedBox(width: 12),
          Expanded(child: Text('Create a Venture Object to start execution.')),
        ],
      ),
    );
  }
}

class _StateMachineRail extends StatelessWidget {
  const _StateMachineRail({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context) {
    return CapitalGlass(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: VentureState.values.map((state) {
            final reached = venture.executionState.index >= state.index;
            final active = venture.executionState == state;
            final color = active
                ? CapitalColors.purple
                : reached
                ? CapitalColors.green
                : CapitalColors.muted;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 136,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: active ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: color.withValues(alpha: 0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    reached
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: CapitalColors.deepBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ArtifactPanel extends StatelessWidget {
  const _ArtifactPanel({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context) {
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generated MVP build outputs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          if (venture.mvpArtifacts.isEmpty)
            Text(
              'Blueprint generation creates backend, mobile, and event outputs.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CapitalColors.muted,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...venture.mvpArtifacts.map(
              (artifact) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artifact.layer,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: CapitalColors.purple,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: artifact.outputs
                          .map(
                            (output) => Chip(
                              label: Text(output),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.78,
                              ),
                              side: const BorderSide(color: CapitalColors.line),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskCard extends ConsumerStatefulWidget {
  const _TaskCard({required this.task});

  final ExecutionTask task;

  @override
  ConsumerState<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  late final TextEditingController _evidence;

  @override
  void initState() {
    super.initState();
    _evidence = TextEditingController();
  }

  @override
  void dispose() {
    _evidence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final color = switch (task.status) {
      ExecutionTaskStatus.blocked => CapitalColors.muted,
      ExecutionTaskStatus.ready => CapitalColors.purple,
      ExecutionTaskStatus.inProgress => CapitalColors.amber,
      ExecutionTaskStatus.completed => CapitalColors.green,
    };
    return CapitalGlass(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.task_alt_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CapitalColors.deepBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${task.ownerLogic} - ${task.status.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: task.requiredEvidence
                .map(
                  (item) => Chip(
                    label: Text(item),
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        task.evidence.length >=
                            task.requiredEvidence.indexOf(item) + 1
                        ? CapitalColors.green.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.78),
                    side: const BorderSide(color: CapitalColors.line),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _evidence,
            enabled:
                task.status != ExecutionTaskStatus.blocked &&
                task.status != ExecutionTaskStatus.completed,
            decoration: const InputDecoration(
              labelText: 'Completion evidence',
              prefixIcon: Icon(Icons.verified_rounded),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed:
                task.status == ExecutionTaskStatus.blocked ||
                    task.status == ExecutionTaskStatus.completed
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(capitalOsControllerProvider.notifier)
                        .submitTaskEvidence(
                          taskId: task.id,
                          evidence: _evidence.text,
                        );
                    _evidence.clear();
                  },
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Submit Evidence'),
            style: FilledButton.styleFrom(
              backgroundColor: CapitalColors.deepBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitionControls extends ConsumerWidget {
  const _TransitionControls({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(capitalOsControllerProvider.notifier);
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'State transition commands',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: controller.launchVenture,
                icon: const Icon(Icons.flight_takeoff_rounded),
                label: const Text('Launch'),
              ),
              FilledButton.icon(
                onPressed: controller.activateTraction,
                icon: const Icon(Icons.trending_up_rounded),
                label: const Text('Activate Traction'),
              ),
              FilledButton.icon(
                onPressed: controller.markFundraisingReady,
                icon: const Icon(Icons.account_balance_rounded),
                label: const Text('Fundraising Ready'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventStream extends StatelessWidget {
  const _EventStream({required this.events});

  final List<CapitalEvent> events;

  @override
  Widget build(BuildContext context) {
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event stream',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...events
              .take(6)
              .map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: const BoxDecoration(
                          color: CapitalColors.purple,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: CapitalColors.deepBlue,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Text(
                              event.message,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: CapitalColors.muted,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: CapitalColors.deepBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: CapitalColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
