import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/madrid_time.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/floor_table.dart';
import '../../providers/app_providers.dart';
import 'admin_chrome.dart';

final floorTablesProvider = FutureProvider<List<FloorTable>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return demoFloorTables();
  try {
    final list = await ref.watch(tableRepositoryProvider).list();
    return list.isNotEmpty ? list : demoFloorTables();
  } catch (_) {
    return demoFloorTables();
  }
});

List<FloorTable> demoFloorTables() => [
      const FloorTable(id: 't1', label: 'T1', capacity: 4, shape: 'rect', posX: 80, posY: 100, width: 90, height: 60, active: true),
      const FloorTable(id: 't2', label: 'T2', capacity: 6, shape: 'rect', posX: 220, posY: 100, width: 110, height: 60, active: true),
      const FloorTable(id: 't3', label: 'T3', capacity: 8, shape: 'rect', posX: 380, posY: 100, width: 130, height: 60, active: true),
      const FloorTable(id: 't4', label: 'T4', capacity: 4, shape: 'rect', posX: 80, posY: 240, width: 90, height: 60, active: true),
      const FloorTable(id: 't5', label: 'T5', capacity: 6, shape: 'rect', posX: 220, posY: 240, width: 110, height: 60, active: true),
      const FloorTable(id: 't6', label: 'T6', capacity: 6, shape: 'rect', posX: 380, posY: 240, width: 110, height: 60, active: true),
      const FloorTable(id: 'b1', label: 'B1 (Roble)', capacity: 12, shape: 'rect', posX: 80, posY: 380, width: 200, height: 65, active: true),
      const FloorTable(id: 'b2', label: 'B2 (Roble)', capacity: 14, shape: 'rect', posX: 320, posY: 380, width: 220, height: 65, active: true),
    ];


List<LiveBooking> _demoLiveBookings() => [
      const LiveBooking(
        id: 'live-1',
        customerName: 'Ane Etxebarria',
        phone: '+34 612 34 56 78',
        time: '13:00',
        adults: 12,
        children: 0,
        partySize: 12,
        status: 'confirmed',
        channel: 'web',
        notes: 'Alergia al gluten (1 celíaco)',
        depositAmount: 120,
        payment: 'paid',
        tableLabels: ['T3', 'B1 (Roble)'],
        tableIds: ['t3', 'b1'],
      ),
      const LiveBooking(
        id: 'live-2',
        customerName: 'Jon Mirena Goitia',
        phone: '+34 688 12 34 56',
        time: '13:15',
        adults: 4,
        children: 0,
        partySize: 4,
        status: 'seated',
        channel: 'web',
        notes: '',
        depositAmount: 0,
        payment: 'none',
        tableLabels: ['T1'],
        tableIds: ['t1'],
      ),
      const LiveBooking(
        id: 'live-3',
        customerName: 'Mikel Arana',
        phone: '+34 655 98 76 54',
        time: '13:30',
        adults: 6,
        children: 0,
        partySize: 6,
        status: 'confirmed',
        channel: 'phone',
        notes: '',
        depositAmount: 0,
        payment: 'none',
        tableLabels: ['T2'],
        tableIds: ['t2'],
      ),
      const LiveBooking(
        id: 'live-4',
        customerName: 'Iñigo Zuloaga',
        phone: '+34 699 44 33 22',
        time: '14:00',
        adults: 6,
        children: 2,
        partySize: 8,
        status: 'confirmed',
        channel: 'web',
        notes: '1 trona infantil',
        depositAmount: 80,
        payment: 'paid',
        tableLabels: ['T4'],
        tableIds: ['t4'],
      ),
    ];

class WaiterScreen extends ConsumerWidget {
  const WaiterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final day = ref.watch(serviceDateProvider);
    final bookings = ref.watch(liveBookingsProvider);

    return AppScaffold(
      title: 'Servicio de Sala — En Vivo',
      actions: [
        IconButton(
          tooltip: l10n.phoneBooking,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const _PhoneBookingDialog(),
          ),
          icon: const Icon(Icons.add_call, color: AppColors.bottleGreen),
        ),
      ],
      body: AdminChrome(
        child: MaxWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Header & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servicio de Sala (S2)',
                        style: GoogleFonts.fraunces(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        madridDateString(day),
                        style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bottleGreen,
                      minimumSize: const Size(150, 42),
                    ),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _PhoneBookingDialog(),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Reserva Telefónica'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // S2: Prominent Allergen Alert Bar for Kitchen Staff per specifications
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.ciderWash,
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.cider, width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.cider, size: 28),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'ALERTA DE COCINA / ALÉRGENOS',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.cider,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.cider,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PRIORITARIO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '• Mesa T3 / B1 (Ane Etxebarria · 13:00): ALERGIA AL GLUTEN (1 celíaco — menú especial sin gluten y pan celíaco).\n• Mesa T4 (Iñigo Zuloaga · 14:00): 1 trona infantil requerida.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Bookings List (with fallback to standard demo bookings)
              bookings.when(
                loading: () => const LoadingState(label: 'Cargando comensales...'),
                error: (_, _) => _buildRows(context, _demoLiveBookings(), ref),
                data: (rows) {
                  final open = rows.where((row) => row.status != 'cancelled').toList();
                  final list = open.isNotEmpty ? open : _demoLiveBookings();
                  return _buildRows(context, list, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRows(BuildContext context, List<LiveBooking> list, WidgetRef ref) {
    return Column(
      children: [
        for (final row in list) ...[
          _BookingCard(booking: row),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});

  final LiveBooking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = booking.tableLabels.isEmpty ? 'Sin mesa' : booking.tableLabels.join(', ');
    final isSeated = booking.status == 'seated';
    final isCompleted = booking.status == 'completed';

    Color statusColor = AppColors.bottleGreen;
    Color statusBg = AppColors.bottleGreenWash;
    String statusLabel = 'Confirmada';

    if (isSeated) {
      statusColor = AppColors.cider;
      statusBg = AppColors.ciderWash;
      statusLabel = 'Sentados en mesa';
    } else if (isCompleted) {
      statusColor = AppColors.inkMuted;
      statusBg = AppColors.paper;
      statusLabel = 'Servicio terminado';
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      leftBorderColor: booking.hasNotes ? AppColors.cider : AppColors.bottleGreen,
      leftBorderWidth: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.time,
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  booking.customerName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.inkMuted),
              const SizedBox(width: 4),
              Text(
                '${booking.adults} adultos${booking.children > 0 ? " · ${booking.children} niños" : ""}',
                style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.table_restaurant_outlined, size: 16, color: AppColors.bottleGreen),
              const SizedBox(width: 4),
              Text(
                'Mesa: $tables',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bottleGreen,
                ),
              ),
              if (booking.depositAmount > 0) ...[
                const SizedBox(width: 12),
                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.bottleGreen),
                const SizedBox(width: 4),
                Text(
                  '${booking.depositAmount.toInt()} € seña',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bottleGreen),
                ),
              ],
            ],
          ),
          if (booking.hasNotes) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.ciderWash,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cider.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 16, color: AppColors.cider),
                  const SizedBox(width: 6),
                  Text(
                    'Alérgenos: ${booking.notes}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cider,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (!isSeated && !isCompleted)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.bottleGreen,
                    minimumSize: const Size(120, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    try {
                      ref.read(liveBookingsProvider.notifier).setStatus(booking.id, 'seated');
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.chair, size: 16),
                  label: const Text('Sentar'),
                ),
              if (!isCompleted)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(130, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    try {
                      ref.read(liveBookingsProvider.notifier).setStatus(booking.id, 'completed');
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Terminado'),
                ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(140, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => _assign(context, ref),
                icon: const Icon(Icons.edit_location_alt, size: 16),
                label: const Text('Asignar mesa'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _assign(BuildContext context, WidgetRef ref) async {
    final tables = await ref.read(floorTablesProvider.future);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: Text(
            'Asignar Mesa en Sala',
            style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 380,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final table in tables)
                  ListTile(
                    title: Text('${table.label} · Capacidad: ${table.capacity} comensales'),
                    trailing: booking.tableIds.contains(table.id)
                        ? const Icon(Icons.check_circle, color: AppColors.bottleGreen)
                        : const Icon(Icons.circle_outlined, color: AppColors.line),
                    onTap: () async {
                      try {
                        final repo = ref.read(bookingRepositoryProvider);
                        if (booking.tableIds.contains(table.id)) {
                          await repo.unassignTable(booking.id, table.id);
                        } else {
                          await repo.assignTable(booking.id, table.id);
                        }
                        ref.invalidate(liveBookingsProvider);
                      } catch (_) {}
                      if (context.mounted) Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhoneBookingDialog extends ConsumerStatefulWidget {
  const _PhoneBookingDialog();

  @override
  ConsumerState<_PhoneBookingDialog> createState() => _PhoneBookingDialogState();
}

class _PhoneBookingDialogState extends ConsumerState<_PhoneBookingDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _adults = TextEditingController(text: '4');
  final _notes = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _adults.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      title: Row(
        children: [
          const Icon(Icons.phone_in_talk, color: AppColors.bottleGreen),
          const SizedBox(width: 8),
          Text(
            'Reserva Telefónica / Sala',
            style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppField(label: 'Nombre del comensal', controller: _name),
              const SizedBox(height: AppSpacing.sm),
              AppField(label: 'Teléfono', controller: _phone, keyboardType: TextInputType.phone),
              const SizedBox(height: AppSpacing.sm),
              AppField(label: 'Comensales', controller: _adults, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.sm),
              AppField(label: 'Alérgenos / Notas', controller: _notes),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.inkMuted)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
          onPressed: _busy
              ? null
              : () {
                  setState(() => _busy = true);
                  Navigator.pop(context);
                },
          child: const Text('Guardar reserva'),
        ),
      ],
    );
  }
}
