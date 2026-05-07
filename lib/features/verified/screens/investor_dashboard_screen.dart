import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/verified_provider.dart';

class InvestorDashboardScreen extends ConsumerStatefulWidget {
  const InvestorDashboardScreen({super.key});

  @override
  ConsumerState<InvestorDashboardScreen> createState() =>
      _InvestorDashboardScreenState();
}

class _InvestorDashboardScreenState
    extends ConsumerState<InvestorDashboardScreen> {
  String _stage = 'All';
  String _sector = 'All';

  static const investors = [
    _Investor(
      'Ananya Rao',
      'SeedBridge Capital',
      'Tier-2 SaaS and AI tooling',
      '₹25L-₹1Cr',
      'B2B SaaS',
      'Seed',
      12,
    ),
    _Investor(
      'Kabir Malhotra',
      'Velocity Angels',
      'Founder-led commerce and logistics',
      '₹10L-₹50L',
      'Logistics',
      'Pre-seed',
      8,
    ),
    _Investor(
      'Mira Shah',
      'Northstar Ventures',
      'CleanTech and climate infrastructure',
      '₹50L-₹2Cr',
      'CleanTech',
      'Series A',
      17,
    ),
    _Investor(
      'Dev Patel',
      'Operator Syndicate',
      'Vertical workflow products',
      '₹15L-₹75L',
      'Fintech',
      'Seed',
      6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = investors.where((investor) {
      final stageOk = _stage == 'All' || investor.stage == _stage;
      final sectorOk = _sector == 'All' || investor.sector == _sector;
      return stageOk && sectorOk;
    }).toList();
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroCard(
            eyebrow: 'Verified Investors',
            title: 'Route certified founders to aligned capital',
            highlight: 'capital',
            description:
                'Filter investor thesis, check size, stage, and sector before requesting a curated AlgoForce intro.',
            accent: AppColors.verified,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              DropdownButton<String>(
                value: _stage,
                items: const ['All', 'Pre-seed', 'Seed', 'Series A']
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _stage = value ?? 'All'),
              ),
              DropdownButton<String>(
                value: _sector,
                items:
                    const [
                          'All',
                          'B2B SaaS',
                          'Logistics',
                          'CleanTech',
                          'Fintech',
                        ]
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _sector = value ?? 'All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _InvestorCard(investor: filtered[index]),
          ),
        ],
      ),
    );
  }
}

class _InvestorCard extends ConsumerWidget {
  const _InvestorCard({required this.investor});

  final _Investor investor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${investor.name} - ${investor.firm}',
                    style: AppText.body(weight: FontWeight.w800),
                  ),
                ),
                TagPill(label: investor.checkSize, color: AppColors.verified),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              investor.thesis,
              style: AppText.body(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              '${investor.intros} intros received',
              style: AppText.mono(size: 12, color: AppColors.nexus),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => _openIntroSheet(context, ref),
              icon: const Icon(Icons.handshake_rounded),
              label: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }

  void _openIntroSheet(BuildContext context, WidgetRef ref) {
    final founders = ref.read(verifiedProvider).certifiedFounders;
    final message = TextEditingController(
      text:
          'Requesting an AlgoForce curated intro based on verified traction and capital fit.',
    );
    var selected = founders.isEmpty ? '' : founders.first.founderName;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            8,
            18,
            MediaQuery.viewInsetsOf(context).bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selected.isEmpty ? null : selected,
                decoration: const InputDecoration(
                  labelText: 'Certified founder',
                ),
                items: founders
                    .map(
                      (founder) => DropdownMenuItem(
                        value: founder.founderName,
                        child: Text(
                          '${founder.founderName} - ${founder.startupName}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selected = value ?? selected),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: message,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Intro message',
                  helperText:
                      'Mention deck, scorecard, or diligence memo attachment.',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  ref
                      .read(verifiedProvider.notifier)
                      .logInvestorIntro(selected, investor.name);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Investor intro request logged.'),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit intro request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Investor {
  const _Investor(
    this.name,
    this.firm,
    this.thesis,
    this.checkSize,
    this.sector,
    this.stage,
    this.intros,
  );

  final String name;
  final String firm;
  final String thesis;
  final String checkSize;
  final String sector;
  final String stage;
  final int intros;
}
