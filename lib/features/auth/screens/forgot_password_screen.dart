import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _success = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _email.dispose();
    _success.dispose();
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
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxFormWidth,
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: _success,
                builder: (context, success, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: success
                        ? _Success(email: _email.text)
                        : Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              key: const ValueKey('form'),
                              children: [
                                IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space20),
                                Text(
                                  'Reset your password',
                                  style: AppText.display(
                                    size: 28,
                                    color: AppColors.navy,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space8),
                                Text(
                                  'Enter your email and we will send reset instructions.',
                                  style: AppText.body(
                                    size: 15,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space24),
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined),
                                    labelText: 'Email',
                                  ),
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    if (!RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(email)) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: auth.isLoading
                                        ? null
                                        : () => unawaited(_submit()),
                                    icon: auth.isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.send_rounded),
                                    label: Text(
                                      auth.isLoading
                                          ? 'Sending...'
                                          : 'Send Reset Link',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.space16),
                                Center(
                                  child: TextButton(
                                    onPressed: () => context.pop(),
                                    child: const Text('Back to login'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref.read(authProvider.notifier).forgotPassword(_email.text);
    if (mounted) {
      _success.value = true;
    }
  }
}

class _Success extends StatelessWidget {
  const _Success({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: AppColors.academyL,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.academy,
            size: 42,
          ),
        ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
        const SizedBox(height: AppDimensions.space24),
        Text(
          'Check your inbox',
          style: AppText.display(size: 28, color: AppColors.navy),
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          "If this email exists, you'll receive a reset link.",
          textAlign: TextAlign.center,
          style: AppText.body(size: 15, color: AppColors.textMuted),
        ),
        const SizedBox(height: AppDimensions.space6),
        Text(email, style: AppText.mono(color: AppColors.purple)),
        const SizedBox(height: AppDimensions.space24),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Back to login'),
        ),
      ],
    );
  }
}
