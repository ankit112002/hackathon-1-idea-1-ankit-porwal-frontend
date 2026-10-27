import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/i18n_extension.dart';
import '../../core/madrid_time.dart';
import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_state.dart';
import '../../models/shift_availability.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/house_event.dart';
import '../../models/staff_role.dart';
import '../../providers/app_providers.dart';
import 'admin_chrome.dart';

final dashboardProvider = FutureProvider<DashboardStats>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoDashboardStats();
  final day = madridDateString(ref.watch(serviceDateProvider));
  return ref.watch(dashboardRepositoryProvider).stats(day);
});

DashboardStats _demoDashboardStats() => const DashboardStats(
      coversToday: 86,
      bookingsToday: 14,
      coversTomorrow: 40,
      noShows30d: 3,
      depositsPaid: 240.0,
    );

final staffListProvider = FutureProvider<List<StaffProfile>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoStaffProfiles();
  return ref.watch(authRepositoryProvider).staff();
});

List<StaffProfile> _demoStaffProfiles() => [
      StaffProfile(id: 'p1', email: 'propietario@iturrieta.eus', role: StaffRole.owner, active: true),
      StaffProfile(id: 'p2', email: 'jefe.sala@iturrieta.eus', role: StaffRole.manager, active: true),
      StaffProfile(id: 'p3', email: 'camarero1@iturrieta.eus', role: StaffRole.waiter, active: true),
      StaffProfile(id: 'p4', email: 'camarero2@iturrieta.eus', role: StaffRole.waiter, active: true),
    ];

final auditProvider = FutureProvider<List<AuditEntry>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoAuditEntries();
  return ref.watch(dashboardRepositoryProvider).recentAudit();
});

List<AuditEntry> _demoAuditEntries() => [
      AuditEntry(
        id: 'a1',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        actorEmail: 'propietario@iturrieta.eus',
        action: 'Web booking confirmed (#ITU-8924)',
        diff: 'Ane Etxebarria · 12 guests · €120 deposit paid',
      ),
      AuditEntry(
        id: 'a2',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
        actorEmail: 'jefe.sala@iturrieta.eus',
        action: 'Table assigned (T1)',
        diff: 'Jon Mirena Goitia · 4 guests',
      ),
      AuditEntry(
        id: 'a3',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        actorEmail: 'propietario@iturrieta.eus',
        action: 'Event published',
        diff: 'Cellar acoustic concert for 31 Oct',
      ),
    ];

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(dashboardProvider);
    final locale = Localizations.localeOf(context).toString();
    final day = ref.watch(serviceDateProvider);
    final ready = ref.watch(supabaseReadyProvider);
    final shifts = ready
        ? ref.watch(availabilityProvider(madridDateString(day)))
        : const AsyncValue<List<ShiftAvailability>>.data([]);

    return AppScaffold(
      title: 'Dashboard',
      staffShell: true,
      body: AdminChrome(
        child: MaxWidth(
          child: stats.when(
            loading: () => LoadingState(label: l10n.loading),
            error: (_, _) => ErrorState(
              message: l10n.errorGeneric,
              retryLabel: l10n.retry,
              onRetry: () => ref.invalidate(dashboardProvider),
            ),
            data: (value) => _buildDashboard(context, value, locale, day, shifts),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    DashboardStats value,
    String locale,
    DateTime day,
    AsyncValue<List<ShiftAvailability>> shifts,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 480;
            final titleWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s service',
                  style: GoogleFonts.fraunces(
                    fontSize: isNarrow ? 22 : 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  madridDateString(day),
                  style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
                ),
              ],
            );

            final liveBadge = Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bottleGreenWash,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.bottleGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 16, color: AppColors.bottleGreen),
                  SizedBox(width: 4),
                  Text(
                    'Live',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bottleGreen,
                    ),
                  ),
                ],
              ),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  liveBadge,
                  const SizedBox(height: AppSpacing.sm),
                  titleWidget,
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: titleWidget),
                const SizedBox(width: AppSpacing.md),
                liveBadge,
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bottleGreen,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => context.go('/admin/waiter'),
            icon: const Icon(Icons.table_restaurant, size: 18),
            label: Text(
              context.tr(
                es: 'Abrir sala de servicio',
                eu: 'Ireki zerbitzu jangela',
                en: 'Open service floor',
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // S3 (Owner Dashboard): 5 clean KPI cards with Fraunces 36-48px metric typography
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 720;
            final cardWidth = wide ? (constraints.maxWidth - 48) / 5 : constraints.maxWidth;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _KpiCard(
                  label: 'Covers today',
                  value: '${value.coversToday}',
                  icon: Icons.people_alt,
                  accentColor: AppColors.bottleGreen,
                  width: cardWidth,
                ),
                _KpiCard(
                  label: 'Bookings today',
                  value: '${value.bookingsToday}',
                  icon: Icons.table_restaurant,
                  accentColor: AppColors.ink,
                  width: cardWidth,
                ),
                _KpiCard(
                  label: 'Covers tomorrow',
                  value: '${value.coversTomorrow}',
                  icon: Icons.calendar_today,
                  accentColor: AppColors.bottleGreen,
                  width: cardWidth,
                ),
                _KpiCard(
                  label: 'No-shows (30 days)',
                  value: '${value.noShows30d}',
                  icon: Icons.person_off_outlined,
                  accentColor: AppColors.danger,
                  width: cardWidth,
                ),
                _KpiCard(
                  label: 'Deposits collected',
                  value: formatEur(value.depositsPaid, locale),
                  icon: Icons.payments_outlined,
                  accentColor: AppColors.cider,
                  width: cardWidth,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),

        // Shift Occupancy Visualizer
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Occupancy · ${madridDateString(day)}',
                style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              shifts.when(
                loading: () => const LoadingState(label: 'Loading shifts...'),
                error: (_, _) => const Text(
                  'Could not load occupancy.',
                  style: TextStyle(color: AppColors.inkMuted),
                ),
                data: (rows) {
                  if (rows.isEmpty) {
                    return const Text(
                      'No shifts for this day.',
                      style: TextStyle(color: AppColors.inkMuted),
                    );
                  }
                  return Column(
                    children: [
                      for (final shift in rows) ...[
                        _OccupancyBar(
                          title: '${shift.shiftName} (${shift.startTime}–${shift.endTime})',
                          taken: shift.taken,
                          total: shift.maxCovers,
                          color: shift.isClosed ? AppColors.inkMuted : AppColors.bottleGreen,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Staff & Audit Section
        Text('Team', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        const _StaffList(),
        const SizedBox(height: AppSpacing.xl),

        Text('Recent activity', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        const _AuditList(),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.width,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        leftBorderColor: accentColor,
        leftBorderWidth: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                Icon(icon, size: 18, color: accentColor),
              ],
            ),
            const SizedBox(height: 8),
            // Fraunces metric number (36-48px per spec)
            Text(
              value,
              style: GoogleFonts.fraunces(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({
    required this.title,
    required this.taken,
    required this.total,
    required this.color,
  });

  final String title;
  final int taken;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total <= 0 ? 0.0 : (taken / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 2),
        Text(
          '$taken / $total covers (${(pct * 100).toInt()}%)',
          style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.line,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

class _StaffList extends ConsumerWidget {
  const _StaffList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staff = ref.watch(staffListProvider);
    return staff.when(
      loading: () => const LoadingState(label: 'Loading team...'),
      error: (_, _) => const Text('Could not load the team'),
      data: (rows) {
        if (rows.isEmpty) return const EmptyState(message: 'No staff profiles');
        return Column(
          children: [
            for (final row in rows) ...[
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: row.role == StaffRole.owner ? AppColors.ciderWash : AppColors.bottleGreenWash,
                      child: Text(
                        row.email.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: row.role == StaffRole.owner ? AppColors.cider : AppColors.bottleGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        row.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: row.role == StaffRole.owner ? AppColors.ciderWash : AppColors.bottleGreenWash,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        row.role == StaffRole.owner ? 'Owner' : (row.role == StaffRole.manager ? 'Manager' : 'Waiter'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: row.role == StaffRole.owner ? AppColors.cider : AppColors.bottleGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}

class _AuditList extends ConsumerWidget {
  const _AuditList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audit = ref.watch(auditProvider);
    return audit.when(
      loading: () => const LoadingState(label: 'Loading activity...'),
      error: (_, _) => const Text('Could not load activity'),
      data: (rows) {
        if (rows.isEmpty) return const EmptyState(message: 'No activity yet');
        return Column(
          children: [
            for (final row in rows) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.history, size: 18, color: AppColors.inkMuted),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.action,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          Text(
                            madridDateString(row.createdAt ?? DateTime.now()),
                            style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                          ),
                          const SizedBox(height: 2),
                          if (row.diff != null && row.diff!.isNotEmpty)
                            Text(row.diff!, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
                          if (row.actorEmail != null && row.actorEmail!.isNotEmpty)
                            Text(
                              'By: ${row.actorEmail}',
                              style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        );
      },
    );
  }
}
