import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../models/staff_role.dart';
import '../../providers/app_providers.dart';

class AdminChrome extends ConsumerWidget {
  const AdminChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentPath = GoRouterState.of(context).uri.path;
    final role = ref.watch(staffRoleProvider).asData?.value ?? StaffRole.owner;
    final waiterOnly = role == StaffRole.waiter;

    final links = <(String, String, IconData)>[
      ('/admin/waiter', 'Sala (Servicio)', Icons.table_restaurant),
      if (!waiterOnly) ...[
        ('/admin', 'Panel (KPIs)', Icons.analytics_outlined),
        ('/admin/floor', 'Plano de Sala', Icons.grid_view),
        ('/admin/calendar', 'Calendario', Icons.calendar_today),
        ('/admin/events', 'Eventos', Icons.event_note),
        ('/admin/settings', 'Ajustes', Icons.tune),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Admin Bar
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          child: Row(
            children: [
              // Role Badge & Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: role == StaffRole.owner ? AppColors.ciderWash : AppColors.bottleGreenWash,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: role == StaffRole.owner ? AppColors.cider : AppColors.bottleGreen,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role == StaffRole.owner ? Icons.admin_panel_settings : Icons.restaurant,
                      size: 14,
                      color: role == StaffRole.owner ? AppColors.cider : AppColors.bottleGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      role == StaffRole.owner ? 'Dueño' : 'Camarero',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: role == StaffRole.owner ? AppColors.cider : AppColors.bottleGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Navigation Tabs
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final link in links) ...[
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => context.go(link.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: currentPath == link.$1
                                  ? AppColors.bottleGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  link.$3,
                                  size: 16,
                                  color: currentPath == link.$1
                                      ? Colors.white
                                      : AppColors.inkMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  link.$2,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: currentPath == link.$1
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: currentPath == link.$1
                                        ? Colors.white
                                        : AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ],
                  ),
                ),
              ),

              // Quick Switch Role button (for testing convenience)
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(80, 36),
                  foregroundColor: AppColors.inkMuted,
                ),
                onPressed: () {
                  if (currentPath == '/admin/waiter') {
                    context.go('/admin');
                  } else {
                    context.go('/admin/waiter');
                  }
                },
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: Text(
                  currentPath == '/admin/waiter' ? 'Ver como Dueño' : 'Ver como Sala',
                  style: const TextStyle(fontSize: 12),
                ),
              ),

              const SizedBox(width: 4),
              IconButton(
                tooltip: l10n.signOut,
                onPressed: () async {
                  try {
                    await ref.read(authRepositoryProvider).signOut();
                  } catch (_) {}
                  ref.read(authEpochProvider.notifier).bump();
                  if (context.mounted) context.go('/admin/login');
                },
                icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
              ),
            ],
          ),
        ),

        Expanded(child: child),
      ],
    );
  }
}
