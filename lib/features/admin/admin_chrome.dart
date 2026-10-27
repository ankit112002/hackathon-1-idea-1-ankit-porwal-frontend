import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/staff_role.dart';
import '../../providers/app_providers.dart';

class AdminChrome extends ConsumerWidget {
  const AdminChrome({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final role = ref.watch(staffRoleProvider).asData?.value;
    final isWaiter = role == StaffRole.waiter;
    final isHouse = role == StaffRole.owner || role == StaffRole.manager;
    final roleLabel = switch (role) {
      StaffRole.owner => context.tr(es: 'Dueño', eu: 'Jabea', en: 'Owner'),
      StaffRole.manager => context.tr(es: 'Jefe de sala', eu: 'Arduraduna', en: 'Manager'),
      StaffRole.waiter => context.tr(es: 'Camarero', eu: 'Zerbitzaria', en: 'Waiter'),
      null => '',
    };
    final roleColor = role == StaffRole.owner ? AppColors.cider : AppColors.bottleGreen;
    final roleWash = role == StaffRole.owner ? AppColors.ciderWash : AppColors.bottleGreenWash;
    final serviceLabel = context.tr(es: 'Sala', eu: 'Jangela', en: 'Service');

    final links = <(String, String, IconData)>[
      if (isWaiter) ('/admin/waiter', serviceLabel, Icons.table_restaurant),
      if (isHouse) ...[
        ('/admin', context.tr(es: 'Panel', eu: 'Panela', en: 'Dashboard'), Icons.analytics_outlined),
        ('/admin/waiter', serviceLabel, Icons.table_restaurant),
        ('/admin/floor', context.tr(es: 'Plano', eu: 'Planoa', en: 'Floor plan'), Icons.grid_view),
        ('/admin/calendar', context.tr(es: 'Calendario', eu: 'Egutegia', en: 'Calendar'), Icons.calendar_today),
        ('/admin/events', context.tr(es: 'Eventos', eu: 'Ekitaldiak', en: 'Events'), Icons.event_note),
        ('/admin/settings', context.tr(es: 'Ajustes', eu: 'Ezarpenak', en: 'Settings'), Icons.tune),
      ],
    ];

    final nav = SingleChildScrollView(
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
                  color: currentPath == link.$1 ? AppColors.bottleGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      link.$3,
                      size: 16,
                      color: currentPath == link.$1 ? Colors.white : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      link.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: currentPath == link.$1 ? FontWeight.w700 : FontWeight.w600,
                        color: currentPath == link.$1 ? Colors.white : AppColors.ink,
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
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 8, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (role != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleWash,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: roleColor),
                    ),
                    child: Text(
                      roleLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: roleColor,
                      ),
                    ),
                  ),
                ),
              if (role != null) const SizedBox(height: 6),
              nav,
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
