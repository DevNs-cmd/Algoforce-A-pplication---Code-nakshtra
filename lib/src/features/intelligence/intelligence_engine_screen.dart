import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/capital_os_theme.dart';
import '../../core/domain/venture_object.dart';
import '../../core/state/capital_os_controller.dart';
import '../../core/widgets/capital_glass.dart';

class IntelligenceEngineScreen extends ConsumerWidget {
  const IntelligenceEngineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venture = ref.watch(capitalOsControllerProvider).venture;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Title(
          title: 'Intelligence Engine',
          subtitle:
              'Startup Genome, risk gates, scope control, and network matching.',
        ),
        const SizedBox(height: 16),
        if (venture == null)
          const CapitalGlass(
            child: Row(
              children: [
                Icon(Icons.psychology_alt_rounded, color: CapitalColors.muted),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create a Venture Object to compute intelligence.',
                  ),
                ),
              ],
            ),
          )
        else ...[
          _GenomePanel(venture: venture),
          const SizedBox(height: 14),
          _NetworkPanel(venture: venture),
          const SizedBox(height: 14),
          _ScopePanel(venture: venture),
        ],
      ],
    );
  }
}

class _GenomePanel extends ConsumerWidget {
  const _GenomePanel({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genome = venture.genome;
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Startup Genome output',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 14,
            children: [
              ScoreRing(
                label: 'Viability',
                score: genome.ventureViability,
                color: CapitalColors.green,
              ),
              ScoreRing(
                label: 'Saturation',
                score: genome.marketSaturationIndex,
                color: CapitalColors.amber,
              ),
              ScoreRing(
                label: 'Complexity',
                score: genome.executionComplexityIndex,
                color: CapitalColors.red,
              ),
              ScoreRing(
                label: 'Funding',
                score: genome.fundingProbability,
                color: CapitalColors.purple,
              ),
              ScoreRing(
                label: 'Failure',
                score: genome.riskFailureProbability,
                color: CapitalColors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            genome.scopeDirective,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CapitalColors.ink,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          CapitalAction(
            label: 'Recompute Genome',
            icon: Icons.psychology_alt_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(capitalOsControllerProvider.notifier).recomputeGenome();
            },
          ),
        ],
      ),
    );
  }
}

class _NetworkPanel extends StatelessWidget {
  const _NetworkPanel({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context) {
    final network = venture.networkEffect;
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network effect simulation',
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
                label: 'Investor fit',
                value: '${network.investorMappingScore}',
                color: CapitalColors.purple,
              ),
              CapitalMetric(
                label: 'Talent fit',
                value: '${network.talentMatchScore}',
                color: CapitalColors.green,
              ),
              CapitalMetric(
                label: 'Similarity',
                value: '${network.similarityGraphScore}',
                color: CapitalColors.deepBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...network.recommendedInvestorProfiles.map(
            (profile) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_rounded,
                    color: CapitalColors.deepBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      ),
    );
  }
}

class _ScopePanel extends ConsumerWidget {
  const _ScopePanel({required this.venture});

  final VentureObject venture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = venture.mvpScope;
    return CapitalGlass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MVP scope control',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CapitalColors.deepBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${scope.expectedWeeks} weeks to MVP. Scope reduction: ${scope.scopeReducedByGenome ? 'applied' : 'pending'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CapitalColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...scope.coreFeatures.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: CapitalColors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CapitalColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          CapitalAction(
            label: 'Apply Scope Reduction',
            icon: Icons.compress_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref
                  .read(capitalOsControllerProvider.notifier)
                  .applyScopeReduction();
            },
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
