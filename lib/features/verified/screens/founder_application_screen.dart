import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/responsive/responsive_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/hero_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../providers/verified_provider.dart';
import '../widgets/verification_stepper.dart';

class FounderApplicationScreen extends ConsumerStatefulWidget {
  const FounderApplicationScreen({super.key});

  @override
  ConsumerState<FounderApplicationScreen> createState() =>
      _FounderApplicationScreenState();
}

class _FounderApplicationScreenState
    extends ConsumerState<FounderApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(verifiedProvider).applicationForm;
    final notifier = ref.read(verifiedProvider.notifier);
    return SingleChildScrollView(
      padding: responsivePadding(context),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroCard(
              eyebrow: 'Verified Application',
              title: 'Submit founder evidence for certification',
              highlight: 'evidence',
              description:
                  'Complete five layers: legitimacy, fundamentals, index scoring, council review, and payment.',
              accent: AppColors.verified,
              children: [
                VerificationStepper(currentLayer: form.currentStep + 1),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Stepper(
                currentStep: form.currentStep,
                onStepTapped: notifier.setStep,
                controlsBuilder: (context, details) {
                  final isLast = form.currentStep == 4;
                  return Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Row(
                      children: [
                        PrimaryButton(
                          label: isLast
                              ? 'Pay ₹5,000 & Submit Application'
                              : 'Continue',
                          icon: isLast
                              ? Icons.payments_rounded
                              : Icons.arrow_forward_rounded,
                          loading: form.isSubmitting,
                          onPressed: () async {
                            if (isLast) {
                              if (_formKey.currentState?.validate() != true ||
                                  !form.acceptedTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Complete required fields and accept certification terms.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              await notifier.submitApplication();
                              if (!context.mounted) {
                                return;
                              }
                              await showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  icon: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: .5, end: 1),
                                    duration: const Duration(milliseconds: 350),
                                    builder: (context, value, child) =>
                                        Transform.scale(
                                          scale: value,
                                          child: child,
                                        ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.academy,
                                      size: 54,
                                    ),
                                  ),
                                  title: const Text('Application received'),
                                  content: const Text(
                                    'Track your founder certification in the Pending tab.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              notifier.setStep(form.currentStep + 1);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: form.currentStep == 0
                              ? null
                              : () => notifier.setStep(form.currentStep - 1),
                          child: const Text('Back'),
                        ),
                      ],
                    ),
                  );
                },
                steps: [
                  Step(
                    title: const Text('Identity & Legitimacy'),
                    isActive: form.currentStep >= 0,
                    content: _identity(form),
                  ),
                  Step(
                    title: const Text('Business Fundamentals'),
                    isActive: form.currentStep >= 1,
                    content: _business(form),
                  ),
                  Step(
                    title: const Text('AlgoForce Index Score'),
                    isActive: form.currentStep >= 2,
                    content: _index(),
                  ),
                  Step(
                    title: const Text('Curation Council'),
                    isActive: form.currentStep >= 3,
                    content: _council(form),
                  ),
                  Step(
                    title: const Text('Payment'),
                    isActive: form.currentStep >= 4,
                    content: _payment(form),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ).animate().fadeIn(duration: 200.ms).slideY(begin: .02, end: 0, duration: 200.ms),
      ),
    );
  }

  Widget _identity(VerifiedApplicationFormState form) {
    final notifier = ref.read(verifiedProvider.notifier);
    return Column(
      children: [
        TextFormField(
          initialValue: form.legalName,
          decoration: const InputDecoration(labelText: 'Legal founder name'),
          validator: _required,
          onChanged: (v) => notifier.updateForm(legalName: v),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: form.registrationNumber,
          decoration: const InputDecoration(
            labelText: 'Company CIN/registration number',
          ),
          validator: _required,
          onChanged: (v) => notifier.updateForm(registrationNumber: v),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: form.companyType,
          decoration: const InputDecoration(labelText: 'Company type'),
          items: const ['Pvt Ltd', 'LLP', 'Sole Prop', 'Other']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (v) => notifier.updateForm(companyType: v),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: form.address,
          decoration: const InputDecoration(labelText: 'Registered address'),
          validator: _required,
          onChanged: (v) => notifier.updateForm(address: v),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                form.certificateFile.isEmpty
                    ? 'No incorporation certificate selected'
                    : form.certificateFile,
                style: AppText.body(size: 12, color: AppColors.textMuted),
              ),
            ),
            TextButton.icon(
              onPressed: () => notifier.updateForm(
                certificateFile: 'incorporation-certificate.pdf',
              ),
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _business(VerifiedApplicationFormState form) {
    final notifier = ref.read(verifiedProvider.notifier);
    return Column(
      children: [
        TextFormField(
          initialValue: form.productDescription,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Product description'),
          validator: (v) =>
              (v ?? '').length < 100 ? 'Write at least 100 characters.' : null,
          onChanged: (v) => notifier.updateForm(productDescription: v),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: form.marketSize,
          decoration: const InputDecoration(
            labelText: 'Target market size estimate',
          ),
          validator: _required,
          onChanged: (v) => notifier.updateForm(marketSize: v),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: form.revenueModel,
          decoration: const InputDecoration(labelText: 'Revenue model'),
          items: const ['SaaS', 'Marketplace', 'D2C', 'Agency', 'Other']
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (v) => notifier.updateForm(revenueModel: v),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: form.currentRevenue,
          decoration: const InputDecoration(labelText: 'Current MRR or ARR'),
          onChanged: (v) => notifier.updateForm(currentRevenue: v),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: form.customerCount,
          decoration: const InputDecoration(
            labelText: 'Number of paying customers',
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => notifier.updateForm(customerCount: v),
        ),
      ],
    );
  }

  Widget _index() {
    const weights = {
      'Traction': .30,
      'Market clarity': .20,
      'Team evidence': .20,
      'Execution': .20,
      'Capital fit': .10,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our team will compute your index score based on submitted data.',
          style: AppText.body(color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        for (final item in weights.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    item.key,
                    style: AppText.body(size: 12, weight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: item.value),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      color: AppColors.verified,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(item.value * 100).round()}%',
                  style: AppText.mono(size: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _council(VerifiedApplicationFormState form) {
    final notifier = ref.read(verifiedProvider.notifier);
    return Column(
      children: [
        Text(
          'Application will be reviewed by our council within 5-7 business days.',
          style: AppText.body(color: AppColors.textMuted),
        ),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: form.certificationReason,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Why should AlgoForce certify your startup?',
          ),
          validator: (v) =>
              (v ?? '').length < 200 ? 'Write at least 200 characters.' : null,
          onChanged: (v) => notifier.updateForm(certificationReason: v),
        ),
        CheckboxListTile(
          value: form.acceptedTerms,
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => notifier.updateForm(acceptedTerms: v ?? false),
          title: const Text(
            'I agree to the certification terms and revocation policy',
          ),
        ),
      ],
    );
  }

  Widget _payment(VerifiedApplicationFormState form) {
    final notifier = ref.read(verifiedProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TagPill(
          label: 'Application fee ₹5,000 non-refundable',
          color: AppColors.verified,
        ),
        const SizedBox(height: 10),
        for (final method in const ['UPI', 'Bank Transfer', 'Credit Card'])
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: method,
            // ignore: deprecated_member_use
            groupValue: form.paymentMethod,
            // ignore: deprecated_member_use
            onChanged: (v) => notifier.updateForm(paymentMethod: v),
            title: Text(method),
          ),
        if (form.paymentMethod == 'UPI')
          TextFormField(
            initialValue: form.upiId,
            decoration: const InputDecoration(labelText: 'UPI ID'),
            validator: (v) =>
                form.paymentMethod == 'UPI' && !(v ?? '').contains('@')
                ? 'Enter a valid UPI ID.'
                : null,
            onChanged: (v) => notifier.updateForm(upiId: v),
          ),
      ],
    );
  }

  String? _required(String? value) =>
      (value ?? '').trim().isEmpty ? 'This field is required.' : null;
}
