import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

final dealRoomProvider =
    StateNotifierProvider<DealRoomController, List<DealRoomEntry>>(
      (ref) => DealRoomController(),
    );
final dealRoomSectorProvider = StateProvider<String>((ref) => 'All');
final dealRoomSortProvider = StateProvider<String>((ref) => 'Latest');
final dealRoomSearchProvider = StateProvider<String>((ref) => '');

class DealRoomScreen extends ConsumerWidget {
  const DealRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sector = ref.watch(dealRoomSectorProvider);
    final sort = ref.watch(dealRoomSortProvider);
    final query = ref.watch(dealRoomSearchProvider).toLowerCase();
    var entries = ref.watch(dealRoomProvider).where((entry) {
      final sectorOk = sector == 'All' || entry.sector == sector;
      final queryOk =
          query.isEmpty ||
          entry.startupName.toLowerCase().contains(query) ||
          entry.founderName.toLowerCase().contains(query);
      return sectorOk && queryOk;
    }).toList();
    entries.sort((a, b) {
      return switch (sort) {
        'Highest Score' => b.indexScore.compareTo(a.indexScore),
        'Highest Ask' => b.askAmount.compareTo(a.askAmount),
        'Most Interest' => b.interestedInvestors.length.compareTo(
          a.interestedInvestors.length,
        ),
        _ => b.certificationDate.compareTo(a.certificationDate),
      };
    });
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verified Deal Room', style: AppText.display(size: 28)),
          const SizedBox(height: AppDimensions.space8),
          Text(
            'Private investor workspace for certified founder opportunities.',
            style: AppText.body(size: 15, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.space18),
          _FilterBar(),
          const SizedBox(height: AppDimensions.space18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 1100
                  ? 3
                  : constraints.maxWidth > 720
                  ? 2
                  : 1;
              return MasonryGridView.count(
                crossAxisCount: columns,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) =>
                    DealRoomCard(entry: entries[index]),
              );
            },
          ),
          const SizedBox(height: AppDimensions.space32),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: AppDimensions.space10,
      runSpacing: AppDimensions.space10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 240,
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search startup',
            ),
            onChanged: (value) =>
                ref.read(dealRoomSearchProvider.notifier).state = value,
          ),
        ),
        for (final sector in [
          'All',
          'Fintech',
          'EdTech',
          'HealthTech',
          'AgriTech',
          'CleanTech',
          'SaaS',
        ])
          ChoiceChip(
            label: Text(sector),
            selected: ref.watch(dealRoomSectorProvider) == sector,
            onSelected: (_) =>
                ref.read(dealRoomSectorProvider.notifier).state = sector,
          ),
        DropdownButton<String>(
          value: ref.watch(dealRoomSortProvider),
          items: const [
            DropdownMenuItem(value: 'Latest', child: Text('Latest')),
            DropdownMenuItem(
              value: 'Highest Score',
              child: Text('Highest Score'),
            ),
            DropdownMenuItem(value: 'Highest Ask', child: Text('Highest Ask')),
            DropdownMenuItem(
              value: 'Most Interest',
              child: Text('Most Interest'),
            ),
          ],
          onChanged: (value) =>
              ref.read(dealRoomSortProvider.notifier).state = value ?? 'Latest',
        ),
      ],
    );
  }
}

class DealRoomCard extends ConsumerWidget {
  const DealRoomCard({super.key, required this.entry});

  final DealRoomEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _sectorColor(entry.sector);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, AppColors.purple]),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radius16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.startupName,
                        style: AppText.heading(size: 16),
                      ),
                    ),
                    const Icon(
                          Icons.verified_rounded,
                          color: AppColors.verified,
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1600.ms),
                  ],
                ),
                const SizedBox(height: AppDimensions.space8),
                Wrap(
                  spacing: AppDimensions.space8,
                  children: [
                    Chip(label: Text(entry.sector)),
                    Chip(label: Text(entry.status.name)),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
                Row(
                  children: [
                    _Score(score: entry.indexScore),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Text(
                        '₹${(entry.askAmount / 10000000).toStringAsFixed(1)} Cr at ${entry.equityOffered.toStringAsFixed(1)}%',
                        style: AppText.mono(size: 18, color: AppColors.navy),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space12),
                Row(
                  children: [
                    _AvatarRow(names: entry.interestedInvestors),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      '${entry.interestedInvestors.length} investors interested',
                      style: AppText.body(size: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeck(context, entry),
                        icon: const Icon(Icons.slideshow_rounded),
                        label: const Text('View Deck'),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showInterest(context, ref, entry),
                        icon: const Icon(Icons.handshake_rounded),
                        label: const Text('Interest'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DealRoomController extends StateNotifier<List<DealRoomEntry>> {
  DealRoomController() : super(_mockDeals);

  void expressInterest(String id, String investor) {
    state = [
      for (final entry in state)
        if (entry.id == id)
          entry.copyWith(
            interestedInvestors: [investor, ...entry.interestedInvestors],
          )
        else
          entry,
    ];
  }
}

class DealRoomEntry {
  const DealRoomEntry({
    required this.id,
    required this.founderName,
    required this.startupName,
    required this.sector,
    required this.askAmount,
    required this.equityOffered,
    required this.indexScore,
    required this.certificationDate,
    required this.deckUrl,
    required this.viewCount,
    required this.interestedInvestors,
    required this.status,
  });

  final String id;
  final String founderName;
  final String startupName;
  final String sector;
  final int askAmount;
  final double equityOffered;
  final int indexScore;
  final DateTime certificationDate;
  final String deckUrl;
  final int viewCount;
  final List<String> interestedInvestors;
  final DealRoomStatus status;

  DealRoomEntry copyWith({List<String>? interestedInvestors}) {
    return DealRoomEntry(
      id: id,
      founderName: founderName,
      startupName: startupName,
      sector: sector,
      askAmount: askAmount,
      equityOffered: equityOffered,
      indexScore: indexScore,
      certificationDate: certificationDate,
      deckUrl: deckUrl,
      viewCount: viewCount,
      interestedInvestors: interestedInvestors ?? this.interestedInvestors,
      status: status,
    );
  }
}

enum DealRoomStatus { open, funded, closed }

class _Score extends StatelessWidget {
  const _Score({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            color: AppColors.verified,
            backgroundColor: AppColors.border,
          ),
          Center(child: Text('$score', style: AppText.mono(size: 12))),
        ],
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 24,
      child: Stack(
        children: [
          for (var i = 0; i < names.take(3).length; i++)
            Positioned(
              left: i * 18,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.purple,
                child: Text(
                  names[i][0],
                  style: AppText.body(size: 9, color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _showDeck(BuildContext context, DealRoomEntry entry) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _DeckViewer(entry: entry),
  );
}

class _DeckViewer extends StatelessWidget {
  const _DeckViewer({required this.entry});

  final DealRoomEntry entry;
  static const slides = [
    'Problem',
    'Solution',
    'Market',
    'Product',
    'Traction',
    'Team',
    'Financials',
    'Ask',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .76,
      child: Column(
        children: [
          Text(entry.startupName, style: AppText.heading(size: 18)),
          Expanded(
            child: PageView(
              controller: controller,
              children: [
                for (final slide in slides)
                  Container(
                    margin: const EdgeInsets.all(AppDimensions.space18),
                    decoration: BoxDecoration(
                      color: _sectorColor(entry.sector).withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(slide, style: AppText.display(size: 32)),
                          const SizedBox(height: AppDimensions.space8),
                          Text(
                            '${entry.startupName} - ${entry.sector} opportunity',
                            style: AppText.body(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space16),
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request sent to founder')),
              ),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Deck'),
            ),
          ),
        ],
      ),
    );
  }
}

void _showInterest(BuildContext context, WidgetRef ref, DealRoomEntry entry) {
  final formKey = GlobalKey<FormState>();
  final message = TextEditingController();
  var checkSize = '₹25L–1Cr';
  var timeline = '30 days';
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Express Interest', style: AppText.heading(size: 18)),
            const SizedBox(height: AppDimensions.space12),
            TextFormField(
              controller: message,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message to founder',
              ),
              validator: (value) => (value ?? '').trim().length >= 30
                  ? null
                  : 'Minimum 30 characters',
            ),
            const SizedBox(height: AppDimensions.space12),
            DropdownButtonFormField<String>(
              initialValue: checkSize,
              decoration: const InputDecoration(labelText: 'Check size range'),
              items: const [
                DropdownMenuItem(value: '< ₹25L', child: Text('< ₹25L')),
                DropdownMenuItem(value: '₹25L–1Cr', child: Text('₹25L–1Cr')),
                DropdownMenuItem(value: '> ₹1Cr', child: Text('> ₹1Cr')),
              ],
              onChanged: (value) => checkSize = value ?? checkSize,
            ),
            const SizedBox(height: AppDimensions.space12),
            DropdownButtonFormField<String>(
              initialValue: timeline,
              decoration: const InputDecoration(
                labelText: 'Timeline to decision',
              ),
              items: const [
                DropdownMenuItem(value: '7 days', child: Text('7 days')),
                DropdownMenuItem(value: '30 days', child: Text('30 days')),
                DropdownMenuItem(value: '60 days', child: Text('60 days')),
              ],
              onChanged: (value) => timeline = value ?? timeline,
            ),
            const SizedBox(height: AppDimensions.space16),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  ref
                      .read(dealRoomProvider.notifier)
                      .expressInterest(entry.id, 'You');
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit Interest'),
            ),
          ],
        ),
      ),
    ),
  ).whenComplete(message.dispose);
}

Color _sectorColor(String sector) {
  return switch (sector) {
    'Fintech' => AppColors.nexus,
    'EdTech' => AppColors.academy,
    'HealthTech' => AppColors.verified,
    'AgriTech' => AppColors.academyD,
    'CleanTech' => AppColors.nexusD,
    _ => AppColors.purple,
  };
}

final _mockDeals = [
  DealRoomEntry(
    id: 'dr1',
    founderName: 'Neha Gupta',
    startupName: 'FinEase',
    sector: 'Fintech',
    askAmount: 12000000,
    equityOffered: 8,
    indexScore: 91,
    certificationDate: DateTime(2026, 2, 2),
    deckUrl: 'demo',
    viewCount: 42,
    interestedInvestors: const ['A', 'R', 'K'],
    status: DealRoomStatus.open,
  ),
  DealRoomEntry(
    id: 'dr2',
    founderName: 'Maya Krishnan',
    startupName: 'SkillNest',
    sector: 'EdTech',
    askAmount: 8000000,
    equityOffered: 10,
    indexScore: 78,
    certificationDate: DateTime(2026, 1, 18),
    deckUrl: 'demo',
    viewCount: 31,
    interestedInvestors: const ['S', 'P'],
    status: DealRoomStatus.open,
  ),
  DealRoomEntry(
    id: 'dr3',
    founderName: 'Rohan Tiwari',
    startupName: 'GreenRoute',
    sector: 'CleanTech',
    askAmount: 15000000,
    equityOffered: 7.5,
    indexScore: 84,
    certificationDate: DateTime(2026, 3, 1),
    deckUrl: 'demo',
    viewCount: 56,
    interestedInvestors: const ['M', 'I', 'V'],
    status: DealRoomStatus.funded,
  ),
];
