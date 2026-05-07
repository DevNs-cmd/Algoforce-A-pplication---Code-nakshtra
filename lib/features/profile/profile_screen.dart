import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/services/preferences_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/inline_editable_text.dart';
import '../auth/models/user.dart';
import '../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;
    if (user == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Sign in'),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: AppDimensions.space18),
          _AccountDetails(user: user),
          const SizedBox(height: AppDimensions.space14),
          _RolePreferences(user: user),
          const SizedBox(height: AppDimensions.space14),
          const _AppSettings(),
          const SizedBox(height: AppDimensions.space14),
          _DataPrivacy(user: user),
          const SizedBox(height: AppDimensions.space14),
          const _AboutSection(),
          const SizedBox(height: AppDimensions.space18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.verified,
                side: const BorderSide(color: AppColors.verified),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AlgoUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => _avatarSheet(context),
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.nexus],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.initials,
                style: AppText.heading(size: 24, color: AppColors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.space16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: AppText.heading(size: 22)),
              Text(user.email, style: AppText.body(color: AppColors.textMuted)),
              const SizedBox(height: AppDimensions.space8),
              Chip(
                label: Text(user.role.label),
                avatar: const Icon(Icons.verified_user_rounded, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountDetails extends ConsumerWidget {
  const _AccountDetails({required this.user});

  final AlgoUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title: 'Account Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EditableRow(
            label: 'Full name',
            value: user.name,
            onChanged: (value) => ref
                .read(authProvider.notifier)
                .updateUser(user.copyWith(name: value)),
          ),
          _ReadonlyRow(
            label: 'Email',
            value: '${user.email} - contact support to change',
          ),
          _EditableRow(
            label: 'Phone',
            value: user.phone,
            keyboardType: TextInputType.phone,
            onChanged: (value) => ref
                .read(authProvider.notifier)
                .updateUser(user.copyWith(phone: value)),
          ),
          _EditableRow(
            label: user.role == UserRole.builder ? 'College' : 'Company',
            value: user.companyName ?? 'AlgoForce Labs',
            onChanged: (value) => ref
                .read(authProvider.notifier)
                .updateUser(user.copyWith(companyName: value)),
          ),
        ],
      ),
    );
  }
}

class _RolePreferences extends ConsumerWidget {
  const _RolePreferences({required this.user});

  final AlgoUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interests = ValueNotifier<Set<String>>(
      Set<String>.from(
        user.preferences['primaryInterest'] as List? ?? const [],
      ),
    );
    return _SectionCard(
      title: 'Role & Preferences',
      child: Column(
        children: [
          DropdownButtonFormField<UserRole>(
            initialValue: user.role,
            decoration: const InputDecoration(labelText: 'Current role'),
            items: [
              for (final role in UserRole.values)
                DropdownMenuItem(value: role, child: Text(role.label)),
            ],
            onChanged: (role) {
              if (role != null) {
                ref
                    .read(authProvider.notifier)
                    .updateUser(user.copyWith(role: role));
              }
            },
          ),
          const SizedBox(height: AppDimensions.space12),
          ValueListenableBuilder<Set<String>>(
            valueListenable: interests,
            builder: (context, selected, child) {
              return Wrap(
                spacing: AppDimensions.space8,
                children: [
                  for (final item in ['Academy', 'Studio', 'Verified', 'Nexus'])
                    FilterChip(
                      label: Text(item),
                      selected: selected.contains(item),
                      onSelected: (checked) {
                        final next = {...selected};
                        checked ? next.add(item) : next.remove(item);
                        interests.value = next;
                        ref
                            .read(authProvider.notifier)
                            .updateUser(
                              user.copyWith(
                                preferences: {
                                  ...user.preferences,
                                  'primaryInterest': next.toList(),
                                },
                              ),
                            );
                      },
                    ),
                ],
              );
            },
          ),
          const Divider(height: 24),
          for (final label in [
            'Cohort updates',
            'Studio milestones',
            'Verified renewals',
            'Revenue alerts',
            'Nexus completions',
          ])
            SwitchListTile(value: true, onChanged: (_) {}, title: Text(label)),
        ],
      ),
    );
  }
}

class _AppSettings extends ConsumerWidget {
  const _AppSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return _SectionCard(
      title: 'App Settings',
      child: Column(
        children: [
          SwitchListTile(
            value: themeMode == ThemeMode.dark,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            title: const Text('Dark mode'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) => ref.read(authProvider.notifier).extendSession(),
            title: const Text('Remember me'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Activity feed'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Smart notifications'),
          ),
          DropdownButtonFormField<String>(
            initialValue: '/',
            decoration: const InputDecoration(
              labelText: 'Default landing screen',
            ),
            items: const [
              DropdownMenuItem(value: '/', child: Text('Overview')),
              DropdownMenuItem(value: '/academy', child: Text('Academy')),
              DropdownMenuItem(value: '/studio', child: Text('Studio')),
              DropdownMenuItem(value: '/verified', child: Text('Verified')),
            ],
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}

class _DataPrivacy extends ConsumerWidget {
  const _DataPrivacy({required this.user});

  final AlgoUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesServiceProvider);
    return _SectionCard(
      title: 'Data & Privacy',
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.history_toggle_off_rounded),
            title: const Text('Clear build history'),
            onTap: () => _confirm(
              context,
              'Clear build history?',
              () => prefs.remove(PreferencesService.nexusBuildHistoryKey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.feed_outlined),
            title: const Text('Clear activity feed'),
            onTap: () => _confirm(
              context,
              'Clear activity feed?',
              () => prefs.remove(PreferencesService.activityFeedKey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Export my data'),
            onTap: () {
              Clipboard.setData(
                ClipboardData(
                  text: const JsonEncoder.withIndent(
                    '  ',
                  ).convert(user.toJson()),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User data copied to clipboard')),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: AppColors.verified,
            ),
            title: const Text('Delete account'),
            textColor: AppColors.verified,
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'About',
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('AlgoForce AI v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.star_rate_rounded),
            title: const Text('Rate the app'),
            onTap: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Rate AlgoForce AI'),
                content: const Text('★★★★★'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_rounded),
            title: const Text('Report a bug'),
            onTap: () => _bugSheet(context),
          ),
          for (final label in ['Terms', 'Privacy', 'Contact'])
            ListTile(
              title: Text(label),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Opening $label...'))),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading(size: 16)),
          const SizedBox(height: AppDimensions.space12),
          child,
        ],
      ),
    );
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: AppText.body(size: 12, color: AppColors.textMuted),
      ),
      subtitle: InlineEditableText(
        value: value,
        keyboardType: keyboardType,
        onSubmitted: onChanged,
        style: AppText.body(weight: FontWeight.w800),
      ),
    );
  }
}

class _ReadonlyRow extends StatelessWidget {
  const _ReadonlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: AppText.body(size: 12, color: AppColors.textMuted),
      ),
      subtitle: Text(value, style: AppText.body(weight: FontWeight.w800)),
    );
  }
}

void _avatarSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.camera_alt_rounded),
          title: const Text('Take photo'),
          onTap: () => _comingSoon(context),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_rounded),
          title: const Text('Choose from gallery'),
          onTap: () => _comingSoon(context),
        ),
      ],
    ),
  );
}

void _bugSheet(BuildContext context) {
  final controller = TextEditingController();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'What happened?'),
          ),
          const SizedBox(height: AppDimensions.space12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Bug report sent')));
            },
            child: const Text('Send'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _logout(BuildContext context, WidgetRef ref) async {
  final ok = await _confirmResult(context, 'Logout from AlgoForce AI?');
  if (ok == true) {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      context.go('/login');
    }
  }
}

Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
  final controller = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete account'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Type DELETE'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text == 'DELETE'),
          child: const Text(
            'Delete',
            style: TextStyle(color: AppColors.verified),
          ),
        ),
      ],
    ),
  );
  controller.dispose();
  if (ok == true) {
    await ref.read(authProvider.notifier).deleteAccount();
    if (context.mounted) {
      context.go('/login');
    }
  }
}

Future<void> _confirm(
  BuildContext context,
  String title,
  Future<bool> Function() action,
) async {
  final ok = await _confirmResult(context, title);
  if (ok == true) {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Done')));
    }
  }
}

Future<bool?> _confirmResult(BuildContext context, String title) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}

void _comingSoon(BuildContext context) {
  Navigator.pop(context);
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Feature coming soon')));
}
