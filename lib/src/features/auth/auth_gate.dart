import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/capital_os_theme.dart';
import '../../core/state/capital_os_controller.dart';
import '../../core/widgets/capital_background.dart';
import '../../core/widgets/capital_glass.dart';
import '../shell/capital_shell.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(capitalOsControllerProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: state.isAuthenticated
          ? const CapitalShell(key: ValueKey('shell'))
          : const _AuthScreen(key: ValueKey('auth')),
    );
  }
}

class _AuthScreen extends ConsumerStatefulWidget {
  const _AuthScreen({super.key});

  @override
  ConsumerState<_AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<_AuthScreen> {
  final _email = TextEditingController(text: 'founder@algoforce.ai');
  final _name = TextEditingController(text: 'Founder');

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(capitalOsControllerProvider);
    final creating = state.authIsCreatingAccount;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CapitalBackground()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(22),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: CapitalGlass(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _LogoMark(),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AlgoForce CapitalOS',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: CapitalColors.deepBlue,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  Text(
                                    'Venture execution engine',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: CapitalColors.muted,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: creating
                              ? TextField(
                                  key: const ValueKey('name'),
                                  controller: _name,
                                  decoration: const InputDecoration(
                                    labelText: 'Founder name',
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('no-name')),
                        ),
                        const SizedBox(height: 18),
                        CapitalAction(
                          label: creating ? 'Create Account' : 'Sign In',
                          icon: creating
                              ? Icons.person_add_alt_rounded
                              : Icons.login_rounded,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            ref
                                .read(capitalOsControllerProvider.notifier)
                                .signIn(
                                  email: _email.text,
                                  displayName: _name.text,
                                );
                          },
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(capitalOsControllerProvider.notifier)
                                  .toggleAuthMode();
                            },
                            child: Text(
                              creating
                                  ? 'Use existing sign in'
                                  : 'Create founder account',
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
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: CapitalColors.deepBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: CapitalColors.deepBlue.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/images/algoforce_mark.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
