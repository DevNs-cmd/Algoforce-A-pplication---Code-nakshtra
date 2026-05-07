import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/ghost_button.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _step = ValueNotifier<int>(0);
  final _persona = ValueNotifier<String>('Founder');
  final _phoneVerified = ValueNotifier<bool>(false);
  final _otpInFlight = ValueNotifier<bool>(false);
  final _termsAccepted = ValueNotifier<bool>(false);
  final _updatesOptIn = ValueNotifier<bool>(true);
  final _passwordStrength = ValueNotifier<double>(0);
  final _obscurePassword = ValueNotifier<bool>(true);

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _startupName = TextEditingController();
  final _problem = TextEditingController();
  final _college = TextEditingController();
  final _github = TextEditingController();
  final _firm = TextEditingController();
  final _thesis = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final _startupStage = ValueNotifier<String>('Idea');
  final _primaryNeed = ValueNotifier<String>('Build MVP');
  final _currentYear = ValueNotifier<String>('3rd');
  final _primarySkill = ValueNotifier<String>('Full-Stack');
  final _checkSize = ValueNotifier<String>('₹25L–1Cr');
  final _preferredStage = ValueNotifier<String>('Seed');

  @override
  void initState() {
    super.initState();
    _password.addListener(() {
      _passwordStrength.value = _scorePassword(_password.text);
    });
  }

  @override
  void dispose() {
    _step.dispose();
    _persona.dispose();
    _phoneVerified.dispose();
    _otpInFlight.dispose();
    _termsAccepted.dispose();
    _updatesOptIn.dispose();
    _passwordStrength.dispose();
    _obscurePassword.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _startupName.dispose();
    _problem.dispose();
    _college.dispose();
    _github.dispose();
    _firm.dispose();
    _thesis.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _startupStage.dispose();
    _primaryNeed.dispose();
    _currentYear.dispose();
    _primarySkill.dispose();
    _checkSize.dispose();
    _preferredStage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radius20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _step,
                    builder: (context, step, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create your account',
                            style: AppText.display(
                              size: 28,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space6),
                          Text(
                            'Join AlgoForce AI - free to start',
                            style: AppText.body(
                              size: 15,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space24),
                          _StepIndicator(step: step),
                          const SizedBox(height: AppDimensions.space24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: switch (step) {
                              0 => _personalInfo(),
                              1 => _roleSpecificInfo(),
                              _ => _security(auth),
                            },
                          ),
                          if (auth.status == AuthStatus.error &&
                              auth.message != null) ...[
                            const SizedBox(height: AppDimensions.space12),
                            _ErrorCard(message: auth.message!),
                          ],
                          const SizedBox(height: AppDimensions.space22),
                          Row(
                            children: [
                              if (step > 0)
                                GhostButton(
                                  label: 'Back',
                                  icon: Icons.arrow_back_rounded,
                                  onPressed: () => _step.value = step - 1,
                                )
                              else
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: const Text('Back to login'),
                                ),
                              const Spacer(),
                              if (step < 2)
                                ElevatedButton.icon(
                                  onPressed: _next,
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('Next'),
                                )
                              else
                                ValueListenableBuilder<bool>(
                                  valueListenable: _termsAccepted,
                                  builder: (context, accepted, child) {
                                    return ElevatedButton.icon(
                                      onPressed: accepted && !auth.isLoading
                                          ? () => unawaited(_submit())
                                          : null,
                                      icon: auth.isLoading
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person_add_rounded,
                                            ),
                                      label: Text(
                                        auth.isLoading
                                            ? 'Creating...'
                                            : 'Create Account',
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _personalInfo() {
    return Column(
      key: const ValueKey('personal'),
      children: [
        TextFormField(
          controller: _name,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline_rounded),
            labelText: 'Full name',
          ),
          validator: (value) {
            final parts = (value ?? '').trim().split(RegExp(r'\s+'));
            return parts.length < 2 ? 'Enter your full name' : null;
          },
        ),
        const SizedBox(height: AppDimensions.space14),
        TextFormField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            labelText: 'Email',
          ),
          validator: (value) {
            final email = value?.trim() ?? '';
            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                ? null
                : 'Enter a valid email address';
          },
        ),
        const SizedBox(height: AppDimensions.space14),
        ValueListenableBuilder<bool>(
          valueListenable: _phoneVerified,
          builder: (context, verified, child) {
            return TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                prefixText: '+91 ',
                prefixIcon: const Icon(Icons.phone_iphone_rounded),
                labelText: 'Phone number',
                counterText: '',
                suffixIcon: verified
                    ? const Icon(
                        Icons.verified_rounded,
                        color: AppColors.academy,
                      )
                    : TextButton(
                        onPressed: () => unawaited(_openOtp()),
                        child: const Text('Verify'),
                      ),
              ),
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
                  return 'Enter a valid 10-digit Indian phone number';
                }
                if (!_phoneVerified.value) {
                  return 'Verify your phone number';
                }
                return null;
              },
              onChanged: (value) {
                if (value.length == 10 &&
                    RegExp(r'^[6-9]\d{9}$').hasMatch(value) &&
                    !_phoneVerified.value &&
                    !_otpInFlight.value) {
                  unawaited(_openOtp());
                }
              },
            );
          },
        ),
        const SizedBox(height: AppDimensions.space14),
        ValueListenableBuilder<String>(
          valueListenable: _persona,
          builder: (context, persona, child) {
            return DropdownButtonFormField<String>(
              initialValue: persona,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.badge_outlined),
                labelText: 'I am a...',
              ),
              items: const [
                DropdownMenuItem(value: 'Founder', child: Text('Founder')),
                DropdownMenuItem(value: 'Builder', child: Text('Builder')),
                DropdownMenuItem(value: 'Investor', child: Text('Investor')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => _persona.value = value ?? 'Founder',
            );
          },
        ),
      ],
    );
  }

  Widget _roleSpecificInfo() {
    return ValueListenableBuilder<String>(
      key: const ValueKey('role'),
      valueListenable: _persona,
      builder: (context, persona, child) {
        if (persona == 'Builder') {
          return _builderFields();
        }
        if (persona == 'Investor') {
          return _investorFields();
        }
        return _founderFields();
      },
    );
  }

  Widget _founderFields() {
    return Column(
      children: [
        TextFormField(
          controller: _startupName,
          decoration: const InputDecoration(labelText: 'Startup name'),
          validator: _required,
        ),
        const SizedBox(height: AppDimensions.space14),
        _DropdownValue(
          label: 'Startup stage',
          value: _startupStage,
          items: const ['Idea', 'MVP', 'Revenue', 'Funded'],
        ),
        const SizedBox(height: AppDimensions.space14),
        TextFormField(
          controller: _problem,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'What problem are you solving?',
          ),
          validator: (value) =>
              (value ?? '').trim().length >= 50 ? null : 'Minimum 50 chars',
        ),
        const SizedBox(height: AppDimensions.space14),
        _DropdownValue(
          label: 'Primary need',
          value: _primaryNeed,
          items: const ['Build MVP', 'Get Verified', 'Find Builders'],
        ),
      ],
    );
  }

  Widget _builderFields() {
    return Column(
      children: [
        TextFormField(
          controller: _college,
          decoration: const InputDecoration(labelText: 'College/University'),
          validator: _required,
        ),
        const SizedBox(height: AppDimensions.space14),
        _DropdownValue(
          label: 'Current year',
          value: _currentYear,
          items: const ['1st', '2nd', '3rd', '4th', 'Graduate'],
        ),
        const SizedBox(height: AppDimensions.space14),
        _DropdownValue(
          label: 'Primary skill',
          value: _primarySkill,
          items: const ['Frontend', 'Backend', 'Full-Stack', 'AI/ML', 'Design'],
        ),
        const SizedBox(height: AppDimensions.space14),
        TextFormField(
          controller: _github,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'GitHub profile URL'),
        ),
      ],
    );
  }

  Widget _investorFields() {
    return Column(
      children: [
        TextFormField(
          controller: _firm,
          decoration: const InputDecoration(
            labelText: 'Firm/Organization name',
          ),
          validator: _required,
        ),
        const SizedBox(height: AppDimensions.space14),
        _DropdownValue(
          label: 'Check size',
          value: _checkSize,
          items: const ['< ₹25L', '₹25L–1Cr', '> ₹1Cr'],
        ),
        const SizedBox(height: AppDimensions.space14),
        TextFormField(
          controller: _thesis,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Investment thesis'),
          validator: (value) =>
              (value ?? '').trim().length >= 30 ? null : 'Minimum 30 chars',
        ),
        const SizedBox(height: AppDimensions.space14),
        _DropdownValue(
          label: 'Preferred stage',
          value: _preferredStage,
          items: const ['Pre-seed', 'Seed', 'Series A'],
        ),
      ],
    );
  }

  Widget _security(AuthState auth) {
    return Column(
      key: const ValueKey('security'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _obscurePassword,
          builder: (context, obscure, child) {
            return TextFormField(
              controller: _password,
              obscureText: obscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outlined),
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => _obscurePassword.value = !obscure,
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) =>
                  RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(value ?? '')
                  ? null
                  : 'Use 8+ chars, 1 uppercase, and 1 number',
            );
          },
        ),
        const SizedBox(height: AppDimensions.space10),
        ValueListenableBuilder<double>(
          valueListenable: _passwordStrength,
          builder: (context, value, child) {
            final color = value < .4
                ? AppColors.verified
                : value < .75
                ? Colors.orange
                : AppColors.academy;
            final label = value < .4
                ? 'Weak'
                : value < .75
                ? 'Medium'
                : 'Strong';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  minHeight: 7,
                  value: value.clamp(.05, 1),
                  backgroundColor: AppColors.bg3,
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(label, style: AppText.body(size: 11, color: color)),
              ],
            );
          },
        ),
        const SizedBox(height: AppDimensions.space14),
        TextFormField(
          controller: _confirmPassword,
          obscureText: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_reset_rounded),
            labelText: 'Confirm password',
          ),
          validator: (value) =>
              value == _password.text ? null : 'Passwords do not match',
        ),
        const SizedBox(height: AppDimensions.space10),
        ValueListenableBuilder<bool>(
          valueListenable: _termsAccepted,
          builder: (context, accepted, child) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: accepted,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(color: AppColors.purple),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showOpening('Terms of Service'),
                    ),
                    const TextSpan(text: ' and Privacy Policy'),
                  ],
                ),
                style: AppText.body(size: 12),
              ),
              onChanged: (value) => _termsAccepted.value = value ?? false,
            );
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _updatesOptIn,
          builder: (context, value, child) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: value,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                "I'd like to receive updates about AlgoForce AI",
                style: AppText.body(size: 12),
              ),
              onChanged: (next) => _updatesOptIn.value = next ?? true,
            );
          },
        ),
      ],
    );
  }

  Future<void> _openOtp() async {
    final phone = _phone.text.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      return;
    }
    _otpInFlight.value = true;
    final verified = await context.push<bool>('/otp-verify', extra: phone);
    if (mounted && verified == true) {
      _phoneVerified.value = true;
    }
    _otpInFlight.value = false;
  }

  void _next() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _step.value = (_step.value + 1).clamp(0, 2).toInt();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final persona = _persona.value;
    final details = <String, dynamic>{
      if (persona == 'Founder' || persona == 'Other') ...{
        'startupStage': _startupStage.value,
        'problem': _problem.text.trim(),
        'primaryNeed': _primaryNeed.value,
      },
      if (persona == 'Builder') ...{
        'college': _college.text.trim(),
        'currentYear': _currentYear.value,
        'primarySkill': _primarySkill.value,
        'github': _github.text.trim(),
      },
      if (persona == 'Investor') ...{
        'firm': _firm.text.trim(),
        'checkSize': _checkSize.value,
        'thesis': _thesis.text.trim(),
        'preferredStage': _preferredStage.value,
      },
    };
    await ref
        .read(authProvider.notifier)
        .register(
          RegisterRequest(
            name: _name.text,
            email: _email.text,
            phone: _phone.text,
            role: _roleFromPersona(persona),
            password: _password.text,
            confirmPassword: _confirmPassword.text,
            termsAccepted: _termsAccepted.value,
            phoneVerified: _phoneVerified.value,
            roleDetails: details,
            primaryInterest: const ['Academy', 'Studio', 'Verified'],
            companyName: persona == 'Investor'
                ? _firm.text
                : (persona == 'Builder' ? _college.text : _startupName.text),
            updatesOptIn: _updatesOptIn.value,
          ),
        );
    if (mounted && ref.read(authProvider).isAuthenticated) {
      context.go('/onboarding');
    }
  }

  UserRole _roleFromPersona(String persona) {
    return switch (persona) {
      'Builder' => UserRole.builder,
      'Investor' => UserRole.investor,
      _ => UserRole.founder,
    };
  }

  String? _required(String? value) {
    return (value ?? '').trim().isEmpty ? 'Required' : null;
  }

  void _showOpening(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening $label...')));
  }

  double _scorePassword(String value) {
    var score = 0.0;
    if (value.length >= 8) {
      score += .35;
    }
    if (RegExp('[A-Z]').hasMatch(value)) {
      score += .2;
    }
    if (RegExp(r'\d').hasMatch(value)) {
      score += .2;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) {
      score += .15;
    }
    if (value.length >= 12) {
      score += .1;
    }
    return score.clamp(0, 1);
  }
}

class _DropdownValue extends StatelessWidget {
  const _DropdownValue({
    required this.label,
    required this.value,
    required this.items,
  });

  final String label;
  final ValueNotifier<String> value;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: value,
      builder: (context, selected, child) {
        return DropdownButtonFormField<String>(
          initialValue: selected,
          decoration: InputDecoration(labelText: label),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (next) => value.value = next ?? selected,
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          _StepDot(index: i, step: step),
          if (i < 2)
            Expanded(
              child: Container(
                height: 2,
                color: i < step ? AppColors.academy : AppColors.border2,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.step});

  final int index;
  final int step;

  @override
  Widget build(BuildContext context) {
    final done = index < step;
    final active = index == step;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: done
            ? AppColors.academy
            : active
            ? AppColors.purple
            : AppColors.bg3,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, color: AppColors.white, size: 18)
            : Text(
                '${index + 1}',
                style: AppText.body(
                  color: active ? AppColors.white : AppColors.textMuted,
                  weight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.verifiedL,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
      ),
      child: Text(
        message,
        style: AppText.body(
          color: AppColors.verifiedD,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}
