import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/academy_provider.dart';

class EnrollFormSheet extends ConsumerStatefulWidget {
  const EnrollFormSheet({super.key});

  @override
  ConsumerState<EnrollFormSheet> createState() => _EnrollFormSheetState();
}

class _EnrollFormSheetState extends ConsumerState<EnrollFormSheet> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academyProvider);
    final form = state.enrollmentForm;
    return DraggableScrollableSheet(
      initialChildSize: .7,
      minChildSize: .45,
      maxChildSize: .94,
      expand: false,
      builder: (context, controller) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border2,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Enroll builder candidate',
                  style: AppText.heading(size: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  'Applications land in the Academy pending queue and keep draft fields locally.',
                  style: AppText.body(size: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  initialValue: form.fullName,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) => (value ?? '').trim().length < 2
                      ? 'Enter the candidate full name.'
                      : null,
                  onChanged: (value) => ref
                      .read(academyProvider.notifier)
                      .updateEnrollment(fullName: value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: form.email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value ?? '')
                      ? null
                      : 'Enter a valid email address.',
                  onChanged: (value) => ref
                      .read(academyProvider.notifier)
                      .updateEnrollment(email: value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: form.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      RegExp(r'^[6-9]\d{9}$').hasMatch(value ?? '')
                      ? null
                      : 'Enter a 10 digit Indian mobile number.',
                  onChanged: (value) => ref
                      .read(academyProvider.notifier)
                      .updateEnrollment(phone: value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: form.college,
                  decoration: const InputDecoration(labelText: 'College name'),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'College is required.'
                      : null,
                  onChanged: (value) => ref
                      .read(academyProvider.notifier)
                      .updateEnrollment(college: value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: form.cityTier,
                  decoration: const InputDecoration(labelText: 'City tier'),
                  items: const [
                    DropdownMenuItem(value: 'Tier 2', child: Text('Tier 2')),
                    DropdownMenuItem(value: 'Tier 3', child: Text('Tier 3')),
                  ],
                  onChanged: (value) => ref
                      .read(academyProvider.notifier)
                      .updateEnrollment(cityTier: value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: form.paymentType,
                  decoration: const InputDecoration(labelText: 'Payment type'),
                  items: const [
                    DropdownMenuItem(value: 'Upfront', child: Text('Upfront')),
                    DropdownMenuItem(
                      value: 'Income Share',
                      child: Text('Income Share'),
                    ),
                  ],
                  onChanged: (value) => ref
                      .read(academyProvider.notifier)
                      .updateEnrollment(paymentType: value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: form.linkedIn,
                  decoration: const InputDecoration(
                    labelText: 'LinkedIn profile URL',
                  ),
                  validator: (value) {
                    final raw = value ?? '';
                    if (raw.isEmpty) {
                      return null;
                    }
                    final uri = Uri.tryParse(raw);
                    return uri != null && uri.isAbsolute
                        ? null
                        : 'Enter a valid profile URL.';
                  },
                  onChanged: (value) => ref
                      .read(academyProvider.notifier)
                      .updateEnrollment(linkedIn: value),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Submit Application',
                  icon: Icons.send_rounded,
                  loading: form.isSubmitting,
                  onPressed: form.isValid
                      ? () async {
                          if (_formKey.currentState?.validate() != true) {
                            return;
                          }
                          await ref
                              .read(academyProvider.notifier)
                              .submitEnrollment();
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Academy application submitted.'),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
