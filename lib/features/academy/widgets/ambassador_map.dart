import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';

class AmbassadorMap extends StatefulWidget {
  const AmbassadorMap({super.key});

  @override
  State<AmbassadorMap> createState() => _AmbassadorMapState();
}

class _AmbassadorMapState extends State<AmbassadorMap> {
  final _ambassadors = <_Ambassador>[
    const _Ambassador(
      'Bhopal',
      'Aarav Singh',
      'Tier 2',
      46,
      115000,
      Offset(.45, .45),
    ),
    const _Ambassador(
      'Indore',
      'Naina Mehta',
      'Tier 2',
      38,
      93000,
      Offset(.36, .50),
    ),
    const _Ambassador(
      'Jaipur',
      'Ritika Bansal',
      'Tier 2',
      29,
      72000,
      Offset(.30, .36),
    ),
    const _Ambassador(
      'Hubballi',
      'Mihir Rao',
      'Tier 3',
      21,
      51000,
      Offset(.42, .72),
    ),
    const _Ambassador(
      'Bhubaneswar',
      'Anika Das',
      'Tier 3',
      24,
      58000,
      Offset(.66, .56),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Campus ambassador map',
                  style: AppText.heading(size: 16),
                ),
              ),
              TextButton.icon(
                onPressed: _showAddSheet,
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            label: 'Interactive India map with city ambassador dots.',
            child: InteractiveViewer(
              minScale: .8,
              maxScale: 3,
              child: AspectRatio(
                aspectRatio: 1.05,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/svg/india_simplified.svg',
                          ),
                        ),
                        for (final ambassador in _ambassadors)
                          Positioned(
                            left:
                                ambassador.position.dx * constraints.maxWidth -
                                10,
                            top:
                                ambassador.position.dy * constraints.maxHeight -
                                10,
                            child: Tooltip(
                              message:
                                  '${ambassador.city} - ${ambassador.name}',
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showCityCard(ambassador);
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: ambassador.tier == 'Tier 2'
                                        ? AppColors.nexus
                                        : AppColors.academy,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.navy.withValues(
                                          alpha: .18,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCityCard(_Ambassador ambassador) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ambassador.city, style: AppText.heading(size: 20)),
            Text(
              ambassador.name,
              style: AppText.body(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Text(
              '${ambassador.students} students enrolled',
              style: AppText.body(weight: FontWeight.w800),
            ),
            Text(
              'Commission earned ₹${ambassador.commission}',
              style: AppText.mono(color: AppColors.academy),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          8,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'City search',
                helperText: 'Start with Tier 2 or Tier 3 campus clusters.',
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(labelText: 'Ambassador name'),
            ),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save Ambassador'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ambassador {
  const _Ambassador(
    this.city,
    this.name,
    this.tier,
    this.students,
    this.commission,
    this.position,
  );

  final String city;
  final String name;
  final String tier;
  final int students;
  final int commission;
  final Offset position;
}
