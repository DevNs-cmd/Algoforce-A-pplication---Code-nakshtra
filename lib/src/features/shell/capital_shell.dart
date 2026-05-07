import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/capital_os_theme.dart';
import '../../core/domain/venture_object.dart';
import '../../core/state/capital_os_controller.dart';
import '../../core/widgets/capital_background.dart';
import '../../core/widgets/capital_glass.dart';
import '../equity_finance/equity_finance_screen.dart';
import '../intelligence/intelligence_engine_screen.dart';
import '../venture_creation/venture_creation_screen.dart';
import '../venture_execution/venture_execution_screen.dart';

class CapitalShell extends ConsumerStatefulWidget {
  const CapitalShell({super.key});

  @override
  ConsumerState<CapitalShell> createState() => _CapitalShellState();
}

class _CapitalShellState extends ConsumerState<CapitalShell> {
  final _pageController = PageController();
  Timer? _messageTimer;

  static const _screens = [
    VentureCreationScreen(),
    VentureExecutionScreen(),
    EquityFinanceScreen(),
    IntelligenceEngineScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(capitalOsControllerProvider);
    ref.listen(capitalOsControllerProvider, (previous, next) {
      final index = next.activeIndex;
      if (previous?.activeIndex != index && _pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: CapitalBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: _VentureHeader(state: state),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(capitalOsControllerProvider.notifier)
                          .setActiveIndex(index);
                    },
                    children: _screens,
                  ),
                ),
                if (state.lastMessage != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: _SystemMessage(message: state.lastMessage!),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: _CoreNav(
                    index: state.activeIndex,
                    onSelected: (index) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(capitalOsControllerProvider.notifier)
                          .setActiveIndex(index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VentureHeader extends ConsumerWidget {
  const _VentureHeader({required this.state});

  final CapitalOsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venture = state.venture;
    return CapitalGlass(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 22,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CapitalColors.deepBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.account_tree_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  venture?.name ?? 'Create Venture Object',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CapitalColors.deepBlue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  venture?.executionState.label ??
                      'Authenticated as ${state.session?.displayName ?? 'Founder'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CapitalColors.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Sign out',
            child: IconButton.filledTonal(
              onPressed: () =>
                  ref.read(capitalOsControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CapitalGlass(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      opacity: 0.84,
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: CapitalColors.purple, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CapitalColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoreNav extends StatelessWidget {
  const _CoreNav({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return CapitalGlass(
      radius: 26,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _Item(
            icon: Icons.add_business_rounded,
            label: 'Create',
            selected: index == 0,
            onTap: () => onSelected(0),
          ),
          _Item(
            icon: Icons.route_rounded,
            label: 'Execute',
            selected: index == 1,
            onTap: () => onSelected(1),
          ),
          _Item(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Finance',
            selected: index == 2,
            onTap: () => onSelected(2),
          ),
          _Item(
            icon: Icons.psychology_alt_rounded,
            label: 'Intel',
            selected: index == 3,
            onTap: () => onSelected(3),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? CapitalColors.deepBlue : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : CapitalColors.muted,
                  size: 21,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? Colors.white : CapitalColors.muted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
