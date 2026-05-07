import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/astronaut_widget.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'founder@algoforce.ai');
  final _password = TextEditingController(text: 'Password1');
  final _obscure = ValueNotifier<bool>(true);
  final _rememberMe = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _obscure.dispose();
    _rememberMe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && mounted) {
        context.go('/');
      }
    });

    final auth = ref.watch(authProvider);
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.tablet;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Row(
          children: [
            if (wide) const Expanded(flex: 45, child: _LoginVisualPanel()),
            Expanded(
              flex: 55,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.space24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimensions.maxFormWidth,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!wide) ...[
                            const LogoWidget(),
                            const SizedBox(height: AppDimensions.space32),
                          ],
                          Text(
                            'Welcome back',
                            style: AppText.display(
                              size: 28,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space6),
                          Text(
                            'Sign in to your AlgoForce OS',
                            style: AppText.body(
                              size: 15,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space28),
                          _AnimatedFormItem(
                            index: 0,
                            child: TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                labelText: 'Email',
                              ),
                              validator: _validateEmail,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space14),
                          _AnimatedFormItem(
                            index: 1,
                            child: ValueListenableBuilder<bool>(
                              valueListenable: _obscure,
                              builder: (context, obscure, child) {
                                return TextFormField(
                                  controller: _password,
                                  obscureText: obscure,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                      tooltip: obscure
                                          ? 'Show password'
                                          : 'Hide password',
                                      onPressed: () =>
                                          _obscure.value = !obscure,
                                      icon: Icon(
                                        obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  validator: _validatePassword,
                                  onFieldSubmitted: (_) => _submit(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space6),
                          _AnimatedFormItem(
                            index: 2,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ValueListenableBuilder<bool>(
                                    valueListenable: _rememberMe,
                                    builder: (context, value, child) {
                                      return CheckboxListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: value,
                                        title: Text(
                                          'Remember me for 30 days',
                                          style: AppText.body(size: 12),
                                        ),
                                        onChanged: (next) =>
                                            _rememberMe.value = next ?? false,
                                      );
                                    },
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.push('/forgot-password'),
                                  child: const Text('Forgot password?'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space14),
                          _AnimatedFormItem(
                            index: 3,
                            child: _AuthPrimaryButton(
                              label: auth.isLoading
                                  ? 'Signing in...'
                                  : 'Sign In',
                              loading: auth.isLoading,
                              onPressed: auth.isLoading ? null : _submit,
                            ),
                          ),
                          if (auth.status == AuthStatus.error &&
                              auth.message != null) ...[
                            const SizedBox(height: AppDimensions.space12),
                            _ErrorCard(message: auth.message!),
                          ],
                          const SizedBox(height: AppDimensions.space20),
                          const _DividerLabel(),
                          const SizedBox(height: AppDimensions.space16),
                          _AnimatedFormItem(
                            index: 4,
                            child: _GoogleButton(
                              loading: auth.isLoading,
                              onPressed: auth.isLoading
                                  ? null
                                  : () => unawaited(_showGoogleAccounts()),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space22),
                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text(
                                "Don't have an account? Create one",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGoogleAccounts() async {
    final selected = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Google account', style: AppText.heading(size: 18)),
              const SizedBox(height: AppDimensions.space12),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.purple4,
                  child: SvgPicture.string(_googleSvg, width: 22, height: 22),
                ),
                title: const Text('demo@algoforce.ai'),
                subtitle: const Text('AlgoForce AI demo workspace'),
                onTap: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );
      },
    );
    if (selected == true) {
      await ref
          .read(authProvider.notifier)
          .loginWithGoogle(rememberMe: _rememberMe.value);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(authProvider.notifier)
        .login(_email.text, _password.text, rememberMe: _rememberMe.value);
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
}

class _LoginVisualPanel extends StatelessWidget {
  const _LoginVisualPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2A4A), Color(0xFF243660)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Algo',
                    style: AppText.display(size: 38, color: AppColors.white),
                  ),
                  TextSpan(
                    text: 'Force',
                    style: AppText.display(size: 38, color: AppColors.purple3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),
            const AstronautWidget(size: 160),
            const SizedBox(height: AppDimensions.space28),
            const _FeaturePill(
              label: 'Train 300+ builders',
              color: AppColors.academyL,
            ),
            const _FeaturePill(
              label: 'Build MVPs in 60 days',
              color: AppColors.studioL,
              delay: 100,
            ),
            const _FeaturePill(
              label: 'Verify founders for investors',
              color: AppColors.verifiedL,
              delay: 200,
            ),
            const Spacer(),
            Text(
              'Trusted by founders across India',
              style: AppText.body(color: AppColors.white),
            ),
            const SizedBox(height: AppDimensions.space12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: .18),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.label,
    required this.color,
    this.delay = 0,
  });

  final String label;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space10),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space14,
        vertical: AppDimensions.space10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radius14),
      ),
      child: Text(
        label,
        style: AppText.body(weight: FontWeight.w800, color: AppColors.navy),
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn().slideY(begin: .2);
  }
}

class _AnimatedFormItem extends StatelessWidget {
  const _AnimatedFormItem({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return child;
    }
    return child
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 220.ms)
        .slideY(begin: .15, end: 0, duration: 220.ms);
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.login_rounded),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius14),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              SvgPicture.string(_googleSvg, width: 20, height: 20),
            const SizedBox(width: AppDimensions.space10),
            const Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space10,
          ),
          child: Text(
            'or continue with',
            style: AppText.body(size: 12, color: AppColors.textMuted),
          ),
        ),
        const Expanded(child: Divider()),
      ],
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

const _googleSvg = '''
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
  <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.3 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.1 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.4-.4-3.5z"/>
  <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.1 6.1 29.3 4 24 4 16.3 4 9.6 8.3 6.3 14.7z"/>
  <path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2C29.2 35.1 26.7 36 24 36c-5.3 0-9.8-3.4-11.3-8.1l-6.5 5C9.5 39.5 16.2 44 24 44z"/>
  <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.3-2.2 4.2-4.1 5.6l6.2 5.2C36.9 39.2 44 34 44 24c0-1.3-.1-2.4-.4-3.5z"/>
</svg>
''';
