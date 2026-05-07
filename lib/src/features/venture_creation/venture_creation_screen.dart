import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/capital_os_theme.dart';
import '../../core/domain/venture_object.dart';
import '../../core/state/capital_os_controller.dart';
import '../../core/widgets/capital_glass.dart';

class VentureCreationScreen extends ConsumerStatefulWidget {
  const VentureCreationScreen({super.key});

  @override
  ConsumerState<VentureCreationScreen> createState() =>
      _VentureCreationScreenState();
}

class _VentureCreationScreenState extends ConsumerState<VentureCreationScreen> {
  late final TextEditingController _idea;
  late final TextEditingController _customer;
  late final TextEditingController _problem;
  var _industry = 'AI SaaS';
  var _businessModel = 'Subscription';
  var _pricing = 99.0;
  var _budget = 50000.0;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(capitalOsControllerProvider).draft;
    _idea = TextEditingController(text: draft.idea);
    _customer = TextEditingController(text: draft.targetCustomer);
    _problem = TextEditingController(text: draft.problem);
    _industry = draft.industry;
    _businessModel = draft.businessModel;
    _pricing = draft.pricing;
    _budget = draft.launchBudget;
  }

  @override
  void dispose() {
    _idea.dispose();
    _customer.dispose();
    _problem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(capitalOsControllerProvider);
    final venture = state.venture;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Title(
          title: 'Venture Creation',
          subtitle: 'Construct the core financial execution unit.',
        ),
        const SizedBox(height: 16),
        CapitalGlass(
          child: Column(
            children: [
              TextField(
                controller: _idea,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Idea metadata',
                  hintText: 'AI operating system for venture execution...',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customer,
                decoration: const InputDecoration(
                  labelText: 'Target customer',
                  hintText: 'Seed-stage founders building fundable startups',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _problem,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Market problem evidence',
                  hintText:
                      'Founders cannot convert ideas into executed MVPs...',
                ),
              ),
              const SizedBox(height: 12),
              _Select(
                label: 'Industry',
                value: _industry,
                values: const [
                  'AI SaaS',
                  'FinTech',
                  'HealthTech',
                  'EdTech',
                  'ClimateTech',
                  'Enterprise',
                ],
                onChanged: (value) => setState(() => _industry = value),
              ),
              const SizedBox(height: 12),
              _Select(
                label: 'Business model',
                value: _businessModel,
                values: const [
                  'Subscription',
                  'Usage based',
                  'Marketplace take rate',
                  'Services + equity',
                  'Enterprise license',
                ],
                onChanged: (value) => setState(() => _businessModel = value),
              ),
              const SizedBox(height: 14),
              _MoneySlider(
                label: 'Price point',
                value: _pricing,
                min: 19,
                max: 799,
                divisions: 39,
                onChanged: (value) => setState(() => _pricing = value),
              ),
              _MoneySlider(
                label: 'Launch budget',
                value: _budget,
                min: 10000,
                max: 250000,
                divisions: 48,
                onChanged: (value) => setState(() => _budget = value),
              ),
              const SizedBox(height: 16),
              CapitalAction(
                label: 'Create Venture Object',
                icon: Icons.add_business_rounded,
                onPressed: _createVenture,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (venture != null) _VentureLifecycleActions(venture: venture),
      ],
    );
  }

  void _createVenture() {
    HapticFeedback.mediumImpact();
    ref.read(capitalOsControllerProvider.notifier)
      ..updateDraft(
        VentureDraft(
          idea: _idea.text,
          industry: _industry,
          targetCustomer: _customer.text,
          problem: _problem.text,
          businessModel: _businessModel,
          pricing: _pricing,
          launchBudget: _budget,
        ),
      )
      ..createVentureObject();
  }
}

class _VentureLifecycleActions extends ConsumerWidget {
  const _VentureLifecycleActions({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(capitalOsControllerProvider.notifier);
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  venture.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: CapitalColors.deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatePill(state: venture.executionState),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              CapitalMetric(
                label: 'Viability',
                value: '${venture.genome.ventureViability}',
                color: CapitalColors.green,
              ),
              CapitalMetric(
                label: 'Risk',
                value: '${venture.riskScore.overallRisk}',
                color: CapitalColors.red,
              ),
              CapitalMetric(
                label: 'MVP',
                value: '${venture.genome.expectedTimeToMvpWeeks} wk',
                color: CapitalColors.purple,
              ),
            ],
          ),
          if (venture.milestoneEngine.validationFailures.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...venture.milestoneEngine.validationFailures.map(
              (failure) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: CapitalColors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        failure,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: CapitalColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SmallAction(
                label: 'Validate',
                icon: Icons.fact_check_rounded,
                onTap: controller.validateVenture,
              ),
              _SmallAction(
                label: 'Blueprint',
                icon: Icons.schema_rounded,
                onTap: controller.generateBlueprint,
              ),
              _SmallAction(
                label: 'Start MVP',
                icon: Icons.rocket_launch_rounded,
                onTap: controller.requestMvpBuild,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Capital model: ${_money(venture.capitalRequirement.fundingRequired)} required, ${_money(venture.capitalRequirement.monthlyBurn)} monthly burn.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CapitalColors.muted,
              fontWeight: FontWeight.w700,
              height: 1.35,
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

class _Select extends StatelessWidget {
  const _Select({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      borderRadius: BorderRadius.circular(18),
      items: values
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _MoneySlider extends StatelessWidget {
  const _MoneySlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${_money(value)}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: CapitalColors.deepBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: _money(value),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({required this.state});

  final VentureState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: CapitalColors.deepBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: CapitalColors.deepBlue,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: CapitalColors.deepBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

String _money(double value) {
  if (value >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '\$${(value / 1000).round()}K';
  }
  return '\$${value.round()}';
}
