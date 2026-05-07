import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../models/certified_founder.dart';
import '../providers/verified_provider.dart';
import '../widgets/founder_list.dart';
import '../widgets/layer_card.dart';
import '../widgets/verification_pipeline.dart';

class VerifiedScreen extends ConsumerWidget {
  const VerifiedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifiedProvider);
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeroCard(
            eyebrow: 'VerifiedTM Engine',
            title: 'Founder trust becomes a monetized layer',
            highlight: 'trust',
            description:
                'Verified turns founder diligence into a structured index, council review, investor signal, renewal stream, and revocation policy.',
            accent: AppColors.verified,
            children: [
              PrimaryButton(
                label: 'Apply for certification',
                icon: Icons.verified_user_rounded,
                onPressed: () => context.push('/verified/apply'),
              ),
              PrimaryButton(
                label: 'Investor dashboard',
                icon: Icons.account_balance_rounded,
                onPressed: () => context.push('/verified/investors'),
              ),
              PrimaryButton(
                label: 'Open deal room',
                icon: Icons.handshake_rounded,
                onPressed: () => context.push('/verified/deal-room'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SectionLabel('Five Layers'),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < 760
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 20) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  LayerCard(
                    number: 1,
                    title: 'Identity & Legitimacy',
                    description:
                        'Founder, entity, address, and incorporation checks.',
                  ),
                  LayerCard(
                    number: 2,
                    title: 'Business Fundamentals',
                    description:
                        'Market, product, revenue, traction, and customer sanity.',
                  ),
                  LayerCard(
                    number: 3,
                    title: 'AlgoForce Index',
                    description:
                        'Weighted score across traction, clarity, team, and evidence.',
                  ),
                  LayerCard(
                    number: 4,
                    title: 'Curation Council',
                    description:
                        'Human review to protect trust and reject weak signals.',
                  ),
                  LayerCard(
                    number: 5,
                    title: 'Payment & Renewal',
                    description:
                        'Application fees, annual renewal, and revocation terms.',
                  ),
                ].map((child) => SizedBox(width: width, child: child)).toList(),
              );
            },
          ),
          const SizedBox(height: 18),
          const SectionLabel('Verification Pipeline'),
          const SizedBox(height: 10),
          const VerificationPipeline(),
          const SizedBox(height: 18),
          const SectionLabel('Certified Founders'),
          const SizedBox(height: 10),
          FounderList(founders: state.certifiedFounders),
          const SizedBox(height: 18),
          const SectionLabel('Pending Queue'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (final app in state.pendingApplications)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      app.founderName,
                      style: AppText.body(weight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${app.startupName} • Layer ${app.currentLayer}/5',
                      style: AppText.body(size: 12, color: AppColors.textMuted),
                    ),
                    trailing: TagPill(
                      label: app.totalFeesPaid > 0 ? 'Paid' : 'Unpaid',
                      color: app.totalFeesPaid > 0
                          ? AppColors.academy
                          : AppColors.verified,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionLabel('Renewal Tracker'),
          const SizedBox(height: 10),
          _RenewalTracker(founders: state.certifiedFounders),
          const SizedBox(height: 32),
        ],
      ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
    );
  }
}

class _RenewalTracker extends ConsumerWidget {
  const _RenewalTracker({required this.founders});

  final List<CertifiedFounder> founders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sorted = [...founders]
      ..sort((a, b) => a.annualRenewalDue.compareTo(b.annualRenewalDue));
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final founder = sorted[index];
          final days = founder.annualRenewalDue
              .difference(DateTime.now())
              .inDays;
          final overdue = days < 0;
          return ListTile(
            leading: Icon(
              overdue ? Icons.warning_rounded : Icons.event_available_rounded,
              color: overdue ? AppColors.verified : AppColors.academy,
            ),
            title: Text(
              founder.founderName,
              style: AppText.body(weight: FontWeight.w800),
            ),
            subtitle: Text(
              overdue
                  ? '${days.abs()} days overdue - renewal fee ₹15,000'
                  : '$days days until renewal - renewal fee ₹15,000',
              style: AppText.body(
                size: 12,
                color: overdue ? AppColors.verified : AppColors.textMuted,
              ),
            ),
            trailing: TextButton(
              onPressed: () => ref
                  .read(verifiedProvider.notifier)
                  .sendRenewalReminder(founder.id),
              child: const Text('Send Reminder'),
            ),
          );
        },
      ),
    );
  }
}
