import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/capital_os_theme.dart';
import '../../core/domain/venture_object.dart';
import '../../core/state/capital_os_controller.dart';
import '../../core/widgets/capital_glass.dart';

class EquityFinanceScreen extends ConsumerWidget {
  const EquityFinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venture = ref.watch(capitalOsControllerProvider).venture;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Title(
          title: 'Equity & Finance',
          subtitle:
              'Calculated ownership, cliff logic, burn, valuation, and capital requirement.',
        ),
        const SizedBox(height: 16),
        if (venture == null)
          const CapitalGlass(
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: CapitalColors.muted),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Create a Venture Object to calculate finance.'),
                ),
              ],
            ),
          )
        else ...[
          _EquityPanel(venture: venture),
          const SizedBox(height: 14),
          _FinancePanel(venture: venture),
          const SizedBox(height: 14),
          _UnlockRules(venture: venture),
        ],
      ],
    );
  }
}

class _EquityPanel extends ConsumerWidget {
  const _EquityPanel({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equity = venture.equityStructure;
    final unlockedRatio = equity.algoForceEquity == 0
        ? 0.0
        : equity.unlockedAlgoForceEquity / equity.algoForceEquity;
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equity engine output',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: equity.founderEquity.round(),
                child: Container(
                  height: 16,
                  decoration: const BoxDecoration(
                    color: CapitalColors.deepBlue,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(999),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: equity.algoForceEquity.round(),
                child: Container(
                  height: 16,
                  decoration: const BoxDecoration(
                    color: CapitalColors.purple,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              CapitalMetric(
                label: 'Founder',
                value: '${equity.founderEquity.toStringAsFixed(1)}%',
                color: CapitalColors.deepBlue,
              ),
              CapitalMetric(
                label: 'AlgoForce',
                value: '${equity.algoForceEquity.toStringAsFixed(1)}%',
                color: CapitalColors.purple,
              ),
              CapitalMetric(
                label: 'Cliff',
                value: '${equity.cliffMonths} mo',
                color: CapitalColors.amber,
              ),
              CapitalMetric(
                label: 'Vesting',
                value: '${equity.vestingMonths} mo',
                color: CapitalColors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Unlocked ${equity.unlockedAlgoForceEquity.toStringAsFixed(2)}% of ${equity.algoForceEquity.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: CapitalColors.muted,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: unlockedRatio,
              minHeight: 9,
              color: CapitalColors.green,
              backgroundColor: CapitalColors.green.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 16),
          CapitalAction(
            label: 'Simulate 6-Month Cliff',
            icon: Icons.lock_open_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref
                  .read(capitalOsControllerProvider.notifier)
                  .simulateCliffReached();
            },
          ),
        ],
      ),
    );
  }
}

class _FinancePanel extends ConsumerWidget {
  const _FinancePanel({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = venture.financialModel;
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial model',
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
              CapitalMetric(
                label: 'Revenue/mo',
                value: _money(model.projectedMonthlyRevenue),
                color: CapitalColors.green,
              ),
              CapitalMetric(
                label: 'Burn/mo',
                value: _money(model.monthlyBurn),
                color: CapitalColors.red,
              ),
              CapitalMetric(
                label: 'Break-even',
                value: '${model.breakEvenMonth} mo',
                color: CapitalColors.amber,
              ),
              CapitalMetric(
                label: 'Funding',
                value: _money(model.fundingRequirement),
                color: CapitalColors.purple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Valuation: ${_money(model.valuationEstimate)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          Slider(
            value: model.valuationEstimate.clamp(500000, 10000000),
            min: 500000,
            max: 10000000,
            divisions: 38,
            label: _money(model.valuationEstimate),
            onChanged: (value) => ref
                .read(capitalOsControllerProvider.notifier)
                .updateValuation(value),
          ),
        ],
      ),
    );
  }
}

class _UnlockRules extends StatelessWidget {
  const _UnlockRules({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context) {
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milestone unlock rules',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...venture.equityStructure.unlockRules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    rule.unlocked
                        ? Icons.verified_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: rule.unlocked
                        ? CapitalColors.green
                        : CapitalColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rule.trigger,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: CapitalColors.ink,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          rule.failureReason ?? rule.requiredState.label,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: rule.failureReason == null
                                    ? CapitalColors.muted
                                    : CapitalColors.red,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${rule.percent.toStringAsFixed(2)}%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: CapitalColors.purple,
                      fontWeight: FontWeight.w900,
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

String _money(double value) {
  if (value >= 1000000) {
    return '\$${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '\$${(value / 1000).round()}K';
  }
  return '\$${value.round()}';
}
