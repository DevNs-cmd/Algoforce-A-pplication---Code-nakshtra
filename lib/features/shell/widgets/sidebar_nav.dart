import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/tag_pill.dart';
import '../../auth/models/user.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import 'shell_navigation_scope.dart';

class SidebarNav extends ConsumerWidget {
  const SidebarNav({
    super.key,
    this.collapsed = false,
    this.onCollapseToggle,
    this.drawerMode = false,
  });

  final bool collapsed;
  final VoidCallback? onCollapseToggle;
  final bool drawerMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationProvider);
    final role = ref.watch(authProvider).currentUser?.role;
    const platformItems = NavigationMetadata.platformItems;
    final financeItems = NavigationMetadata.financeItems
        .where((item) => _canSee(item.route, role))
        .toList();
    final width = drawerMode ? 280.0 : (collapsed ? 64.0 : 220.0);
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(collapsed && !drawerMode ? 14 : 18),
            child: LogoWidget(compact: collapsed && !drawerMode),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!collapsed || drawerMode) const SectionLabel('Platform'),
                  const SizedBox(height: 8),
                  for (var i = 0; i < platformItems.length; i++)
                    _NavItem(
                      item: platformItems[i],
                      active: nav.currentRoute == platformItems[i].route,
                      collapsed: collapsed && !drawerMode,
                      delayMs: i * 60,
                    ),
                  const SizedBox(height: 18),
                  if (!collapsed || drawerMode) const SectionLabel('Finance'),
                  const SizedBox(height: 8),
                  for (var i = 0; i < financeItems.length; i++)
                    _NavItem(
                      item: financeItems[i],
                      active: nav.currentRoute == financeItems[i].route,
                      collapsed: collapsed && !drawerMode,
                      delayMs: (platformItems.length + i) * 60,
                    ),
                ],
              ),
            ),
          ),
          if (!collapsed || drawerMode) _UserCard(),
          if (!drawerMode && onCollapseToggle != null)
            Tooltip(
              message: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
              child: IconButton(
                onPressed: onCollapseToggle,
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: collapsed ? .5 : 0,
                  child: const Icon(Icons.chevron_left_rounded),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );

    if (drawerMode || MediaQuery.of(context).disableAnimations) {
      return content;
    }
    return content
        .animate(onPlay: (controller) => controller.forward())
        .slideX(
          begin: -1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

bool _canSee(String route, UserRole? role) {
  if (role == UserRole.admin || role == UserRole.founder || role == null) {
    return true;
  }
  if (role == UserRole.builder) {
    return route != '/revenue' && route != '/analytics';
  }
  if (role == UserRole.investor) {
    return route != '/revenue' && route != '/analytics';
  }
  return true;
}

class _UserCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;
    final role = user?.role.label ?? 'Founder OS';
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        final scope = ShellNavigationScope.maybeOf(context);
        if (scope != null) {
          scope.goToRoute('/profile');
        } else {
          context.go('/profile');
        }
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.purple4,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.purple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user?.initials ?? 'AF',
                  style: AppText.body(
                    size: 12,
                    color: AppColors.white,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'AlgoForce AI',
                    style: AppText.body(
                      size: 13,
                      color: AppColors.navy,
                      weight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    role,
                    style: AppText.body(size: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.item,
    required this.active,
    required this.collapsed,
    required this.delayMs,
  });

  final NavigationItem item;
  final bool active;
  final bool collapsed;
  final int delayMs;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? AppColors.purple : AppColors.textMuted;
    final child = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: widget.active
              ? AppColors.purple4
              : (_hovered ? AppColors.bg2 : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            final scope = ShellNavigationScope.maybeOf(context);
            if (scope != null) {
              scope.goToRoute(widget.item.route);
            } else {
              context.go(widget.item.route);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 10,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: widget.active
                        ? AppColors.purple
                        : Colors.transparent,
                    shape: widget.collapsed
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: widget.collapsed
                        ? null
                        : BorderRadius.circular(6),
                  ),
                  child: Icon(
                    widget.item.icon,
                    size: 18,
                    color: widget.active ? AppColors.white : color,
                  ),
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: widget.collapsed ? 0 : 1,
                      child: Text(
                        widget.item.label,
                        style: AppText.body(
                          size: 13,
                          color: color,
                          weight: widget.active
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (widget.item.badge != null)
                    TagPill(label: widget.item.badge!, color: AppColors.purple),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _hovered ? 1 : 0,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    final wrapped = widget.collapsed
        ? Tooltip(message: widget.item.label, child: child)
        : child;
    if (MediaQuery.of(context).disableAnimations) {
      return wrapped;
    }
    return wrapped
        .animate(delay: Duration(milliseconds: widget.delayMs))
        .fadeIn(duration: 220.ms)
        .slideX(begin: -.2, end: 0, duration: 220.ms);
  }
}
