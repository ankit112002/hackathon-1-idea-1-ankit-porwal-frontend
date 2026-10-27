import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/errors.dart';
import '../../core/i18n_extension.dart';
import '../../core/madrid_time.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/floor_table.dart';
import '../../models/shift_availability.dart';
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
        notes: 'Gluten allergy (1 guest)',
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
        notes: '1 high chair',
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
    final ready = ref.watch(supabaseReadyProvider);
    final now = madridNow();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = day == today;

    return AppScaffold(
      title: 'Service',
      staffShell: true,
      body: AdminChrome(
        child: MaxWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Header & Date (Responsive layout to prevent overflow on mobile)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 450;
                  final heading = isToday
                      ? context.tr(
                          es: 'Reservas de hoy',
                          eu: 'Gaurko erreserbak',
                          en: "Today's bookings",
                        )
                      : context.tr(
                          es: 'Reservas del servicio',
                          eu: 'Zerbitzuko erreserbak',
                          en: 'Service bookings',
                        );
                  final titleWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: GoogleFonts.fraunces(
                          fontSize: isNarrow ? 22 : 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: context.tr(
                              es: 'Día anterior',
                              eu: 'Aurreko eguna',
                              en: 'Previous day',
                            ),
                            onPressed: () => ref.read(serviceDateProvider.notifier).setDay(
                                  day.subtract(const Duration(days: 1)),
                                ),
                            icon: const Icon(Icons.chevron_left, color: AppColors.ink),
                          ),
                          Text(
                            madridDateString(day),
                            style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
                          ),
                          IconButton(
                            tooltip: context.tr(
                              es: 'Día siguiente',
                              eu: 'Hurrengo eguna',
                              en: 'Next day',
                            ),
                            onPressed: () => ref.read(serviceDateProvider.notifier).setDay(
                                  day.add(const Duration(days: 1)),
                                ),
                            icon: const Icon(Icons.chevron_right, color: AppColors.ink),
                          ),
                        ],
                      ),
                    ],
                  );

                  final button = FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.bottleGreen,
                      minimumSize: isNarrow ? const Size(double.infinity, 42) : const Size(150, 42),
                    ),
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _PhoneBookingDialog(),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      context.tr(
                        es: 'Reserva por teléfono',
                        eu: 'Telefono erreserba',
                        en: 'Phone booking',
                      ),
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleWidget,
                        const SizedBox(height: AppSpacing.sm),
                        button,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleWidget),
                      const SizedBox(width: AppSpacing.md),
                      button,
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),

              bookings.when(
                loading: () => const LoadingState(label: 'Loading bookings...'),
                error: (_, _) {
                  if (ready) {
                    return ErrorState(
                      message: l10n.errorGeneric,
                      retryLabel: l10n.retry,
                      onRetry: () => ref.invalidate(liveBookingsProvider),
                    );
                  }
                  return _serviceList(context, _demoLiveBookings(), ref);
                },
                data: (rows) {
                  final open = rows.where((row) => row.status != 'cancelled').toList();
                  if (open.isEmpty) {
                    if (ready) return EmptyState(message: l10n.noBookingsToday);
                    return _serviceList(context, _demoLiveBookings(), ref);
                  }
                  return _serviceList(context, open, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _serviceList(BuildContext context, List<LiveBooking> list, WidgetRef ref) {
    final noted = list.where((row) => row.hasNotes).toList();
    return Column(
      children: [
        if (noted.isNotEmpty) ...[
          _AllergenBanner(rows: noted),
          const SizedBox(height: AppSpacing.lg),
        ],
        for (final row in list) ...[
          _BookingCard(booking: row),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _AllergenBanner extends StatelessWidget {
  const _AllergenBanner({required this.rows});

  final List<LiveBooking> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  context.tr(
                    es: 'COCINA / ALERTA DE ALERGIA',
                    eu: 'SUKALDEA / ALERGIA ALERTA',
                    en: 'KITCHEN / ALLERGY ALERT',
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cider,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                for (final row in rows)
                  Text(
                    '• ${row.time} ${row.customerName}${row.tableLabels.isEmpty ? '' : ' (${row.tableLabels.join(', ')})'}: ${row.notes}',
                    style: const TextStyle(
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
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});

  final LiveBooking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = booking.tableLabels.isEmpty
        ? context.tr(es: 'Sin mesa', eu: 'Mahairik ez', en: 'No table')
        : booking.tableLabels.join(', ');
    final isSeated = booking.status == 'seated';
    final isCompleted = booking.status == 'completed';

    Color statusColor = AppColors.bottleGreen;
    Color statusBg = AppColors.bottleGreenWash;
    String statusLabel = 'Confirmed';

    if (isSeated) {
      statusColor = AppColors.cider;
      statusBg = AppColors.ciderWash;
      statusLabel = context.tr(es: 'Sentado', eu: 'Eserita', en: 'Seated');
    } else if (isCompleted) {
      statusColor = AppColors.inkMuted;
      statusBg = AppColors.paper;
      statusLabel = context.tr(es: 'Terminado', eu: 'Amaituta', en: 'Finished');
    } else {
      statusLabel = context.tr(es: 'Confirmada', eu: 'Berretsita', en: 'Confirmed');
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
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            booking.customerName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.inkMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.adults} adults${booking.children > 0 ? " · ${booking.children} children" : ""}',
                    style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.table_restaurant_outlined, size: 16, color: AppColors.bottleGreen),
                  const SizedBox(width: 4),
                  Text(
                    '${context.tr(es: 'Mesa', eu: 'Mahaia', en: 'Table')}: $tables',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bottleGreen,
                    ),
                  ),
                ],
              ),
              if (booking.depositAmount > 0)
                Text(
                  booking.payment == 'paid'
                      ? '${booking.depositAmount.toInt()} € deposit paid'
                      : '${booking.depositAmount.toInt()} € deposit pending',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: booking.payment == 'paid' ? AppColors.bottleGreen : AppColors.cider,
                  ),
                ),
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
                  Expanded(
                    child: Text(
                      'Notes: ${booking.notes}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cider,
                      ),
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
                  onPressed: () => _setStatus(context, ref, 'seated'),
                  icon: const Icon(Icons.chair, size: 16),
                  label: Text(context.tr(es: 'Sentar', eu: 'Eseri', en: 'Seat')),
                ),
              if (!isCompleted)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(130, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _setStatus(context, ref, 'completed'),
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(context.tr(es: 'Hecho', eu: 'Eginda', en: 'Done')),
                ),
              if (!isCompleted)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _assign(context, ref),
                  icon: const Icon(Icons.edit_location_alt, size: 16),
                  label: Text(
                    context.tr(es: 'Asignar mesa', eu: 'Mahaia esleitu', en: 'Assign table'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setStatus(BuildContext context, WidgetRef ref, String status) async {
    try {
      await ref.read(liveBookingsProvider.notifier).setStatus(booking.id, status);
      ref.invalidate(liveBookingsProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              es: 'No se pudo actualizar la reserva',
              eu: 'Ezin izan da erreserba eguneratu',
              en: 'Could not update the booking',
            ),
          ),
        ),
      );
    }
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
            context.tr(es: 'Asignar una mesa', eu: 'Mahaia esleitu', en: 'Assign a table'),
            style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 380,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final table in tables)
                  ListTile(
                    title: Text('${table.label} · Seats: ${table.capacity}'),
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
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _adults.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final adults = int.tryParse(_adults.text.trim()) ?? 0;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (name.isEmpty || digits.length < 9 || adults < 1) {
      setState(() => _error = l10n.fieldRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final day = ref.read(serviceDateProvider);
      final shifts = await ref.read(availabilityProvider(madridDateString(day)).future);
      ShiftAvailability? lunch;
      for (final shift in shifts) {
        if (shift.isClosed) continue;
        final label = shift.shiftName.toLowerCase();
        if (label.contains('comida') || label.contains('lunch') || label.contains('bazkari')) {
          lunch = shift;
          break;
        }
      }
      lunch ??= shifts.where((shift) => !shift.isClosed).firstOrNull;
      if (lunch == null) {
        setState(() => _error = l10n.errorShiftMissing);
        return;
      }
      await ref.read(bookingRepositoryProvider).create(
        name: name,
        phone: phone,
        email: 'phone-booking@iturrieta.eus',
        language: 'en',
        shiftId: lunch.shiftId,
        date: day,
        time: lunch.startTime,
        adults: adults,
        children: 0,
        notes: _notes.text.trim(),
        channel: 'phone',
      );
      ref.invalidate(liveBookingsProvider);
      if (mounted) Navigator.pop(context);
    } on BookingFailure catch (error) {
      if (!mounted) return;
      setState(() => _error = bookingErrorText(l10n, error.code));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
            context.tr(es: 'Reserva por teléfono', eu: 'Telefono erreserba', en: 'Phone booking'),
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
              AppField(label: 'Guest name', controller: _name),
              const SizedBox(height: AppSpacing.sm),
              AppField(label: 'Phone', controller: _phone, keyboardType: TextInputType.phone),
              const SizedBox(height: AppSpacing.sm),
              AppField(label: 'Guests', controller: _adults, keyboardType: TextInputType.number),
              const SizedBox(height: AppSpacing.sm),
              AppField(label: 'Allergies / notes', controller: _notes),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.inkMuted)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
          onPressed: _busy ? null : _save,
          child: const Text('Save booking'),
        ),
      ],
    );
  }
}
