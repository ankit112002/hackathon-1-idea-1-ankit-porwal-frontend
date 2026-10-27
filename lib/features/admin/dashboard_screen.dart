import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/madrid_time.dart';
import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/house_event.dart';
import '../../models/staff_role.dart';
import '../../providers/app_providers.dart';
import 'admin_chrome.dart';

final dashboardProvider = FutureProvider<DashboardStats>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoDashboardStats();
  try {
    final day = madridDateString(ref.watch(serviceDateProvider));
    return await ref.watch(dashboardRepositoryProvider).stats(day);
  } catch (_) {
    return _demoDashboardStats();
  }
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
  try {
    final list = await ref.watch(authRepositoryProvider).staff();
    return list.isNotEmpty ? list : _demoStaffProfiles();
  } catch (_) {
    return _demoStaffProfiles();
  }
});

List<StaffProfile> _demoStaffProfiles() => [
      StaffProfile(id: 'p1', email: 'propietario@iturrieta.eus', role: StaffRole.owner, active: true),
      StaffProfile(id: 'p2', email: 'jefe.sala@iturrieta.eus', role: StaffRole.manager, active: true),
      StaffProfile(id: 'p3', email: 'camarero1@iturrieta.eus', role: StaffRole.waiter, active: true),
      StaffProfile(id: 'p4', email: 'camarero2@iturrieta.eus', role: StaffRole.waiter, active: true),
    ];

final auditProvider = FutureProvider<List<AuditEntry>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoAuditEntries();
  try {
    final list = await ref.watch(dashboardRepositoryProvider).recentAudit();
    return list.isNotEmpty ? list : _demoAuditEntries();
  } catch (_) {
    return _demoAuditEntries();
  }
});

List<AuditEntry> _demoAuditEntries() => [
      AuditEntry(
        id: 'a1',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        actorEmail: 'propietario@iturrieta.eus',
        action: 'Reserva web confirmada (#ITU-8924)',
        diff: 'Ane Etxebarria · 12 comensales · Seña 120 € abonada',
      ),
      AuditEntry(
        id: 'a2',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
        actorEmail: 'jefe.sala@iturrieta.eus',
        action: 'Mesa asignada (T1)',
        diff: 'Jon Mirena Goitia · 4 comensales',
      ),
      AuditEntry(
        id: 'a3',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        actorEmail: 'propietario@iturrieta.eus',
        action: 'Publicación evento',
        diff: 'Concierto acústico en bodega para 31 oct',
      ),
    ];

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(dashboardProvider);
    final role = ref.watch(staffRoleProvider).asData?.value ?? StaffRole.owner;
    final locale = Localizations.localeOf(context).toString();

    return AppScaffold(
      title: 'Panel del Propietario (S3)',
      body: AdminChrome(
        child: MaxWidth(
          child: stats.when(
            loading: () => LoadingState(label: l10n.loading),
            error: (_, _) => _buildDashboard(context, _demoDashboardStats(), role, locale, l10n),
            data: (value) => _buildDashboard(context, value, role, locale, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    DashboardStats value,
    StaffRole role,
    String locale,
    AppLocalizations l10n,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KPIs y Rendimiento de Sala (S3)',
                  style: GoogleFonts.fraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Métricas en vivo de ocupación, reservas y cobro de señas',
                  style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bottleGreenWash,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.bottleGreen.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, size: 16, color: AppColors.bottleGreen),
                  SizedBox(width: 4),
                  Text(
                    'En Vivo · Temporada Txotx',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bottleGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // S3 (Owner Dashboard): 5 clean KPI cards with Fraunces 36-48px metric typography
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _KpiCard(
                  label: 'Cubiertos Hoy',
                  value: '${value.coversToday}',
                  icon: Icons.people_alt,
                  accentColor: AppColors.bottleGreen,
                  width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                ),
                _KpiCard(
                  label: 'Reservas Hoy',
                  value: '${value.bookingsToday}',
                  icon: Icons.table_restaurant,
                  accentColor: AppColors.ink,
                  width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                ),
                _KpiCard(
                  label: 'Cubiertos Mañana',
                  value: '${value.coversTomorrow}',
                  icon: Icons.calendar_today,
                  accentColor: AppColors.bottleGreen,
                  width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                ),
                _KpiCard(
                  label: 'No-shows (30d)',
                  value: '${value.noShows30d}',
                  icon: Icons.person_off_outlined,
                  accentColor: AppColors.danger,
                  width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
                ),
                _KpiCard(
                  label: 'Señas Hoy',
                  value: formatEur(value.depositsPaid, locale),
                  icon: Icons.payments_outlined,
                  accentColor: AppColors.cider,
                  width: isWide ? (constraints.maxWidth - 48) / 5 : (constraints.maxWidth - 12) / 2,
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
                'Ocupación por Turno — Jueves 29 Octubre',
                style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              _OccupancyBar(
                title: 'Comida (13:00 – 16:00)',
                taken: 56,
                total: 80,
                color: AppColors.bottleGreen,
              ),
              const SizedBox(height: AppSpacing.sm),
              _OccupancyBar(
                title: 'Cena (20:00 – 23:00)',
                taken: 80,
                total: 80,
                color: AppColors.cider,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Staff & Audit Section
        Text('Equipo y Permisos', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        const _StaffList(),
        const SizedBox(height: AppSpacing.xl),

        Text('Auditoría Reciente', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700)),
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
                fontSize: 36,
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
    final pct = (taken / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(
              '$taken / $total cubiertos (${(pct * 100).toInt()}%)',
              style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
            ),
          ],
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
      loading: () => const LoadingState(label: 'Cargando equipo...'),
      error: (_, _) => const Text('Error al cargar equipo'),
      data: (rows) {
        if (rows.isEmpty) return const EmptyState(message: 'No hay perfiles');
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
                      child: Text(row.email, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: row.role == StaffRole.owner ? AppColors.ciderWash : AppColors.bottleGreenWash,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        row.role == StaffRole.owner ? 'Dueño' : (row.role == StaffRole.manager ? 'Encargado' : 'Camarero'),
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
      loading: () => const LoadingState(label: 'Cargando registros...'),
      error: (_, _) => const Text('Error al cargar auditoría'),
      data: (rows) {
        if (rows.isEmpty) return const EmptyState(message: 'No hay eventos');
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(row.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text(
                                madridDateString(row.createdAt ?? DateTime.now()),
                                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (row.diff != null && row.diff!.isNotEmpty)
                            Text(row.diff!, style: const TextStyle(fontSize: 13, color: AppColors.ink)),
                          if (row.actorEmail != null && row.actorEmail!.isNotEmpty)
                            Text(
                              'Por: ${row.actorEmail}',
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
