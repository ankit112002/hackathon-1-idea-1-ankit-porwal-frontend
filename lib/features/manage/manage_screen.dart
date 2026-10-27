import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/booking_slots.dart';
import '../../core/i18n_extension.dart';
import '../../core/madrid_time.dart';
import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../models/shift_availability.dart';
import '../../providers/app_providers.dart';
import '../booking/confirm_screen.dart';

class ManageScreen extends ConsumerStatefulWidget {
  const ManageScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends ConsumerState<ManageScreen> {
  bool _showChangeDate = false;
  bool _showChangeParty = false;
  var _busy = false;
  String? _message;
  String? _error;

  DateTime? _newDate;
  String? _shiftId;
  String? _time;
  int? _newAdults;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bookingAsync = ref.watch(managedBookingProvider(widget.token));
    final settingsAsync = ref.watch(settingsProvider);
    final hours = settingsAsync.asData?.value.cancelFreeHours ?? 48;

    return AppScaffold(
      title: context.tr(
        es: 'Tu Reserva — Gestión Privada',
        eu: 'Zure Erreserba — Kudeaketa Pribatua',
        en: 'Your Booking — Private Management',
      ),
      homePath: '/',
      body: MaxWidth(
        child: bookingAsync.when(
          loading: () => LoadingState(label: l10n.loading),
          error: (_, _) => ErrorState(
            message: l10n.bookingMissing,
            retryLabel: l10n.retry,
            onRetry: () => ref.invalidate(managedBookingProvider(widget.token)),
          ),
          data: (row) {
            if (row == null) return EmptyState(message: l10n.bookingMissing);
            return _buildManageContent(context, row, hours, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildManageContent(
    BuildContext context,
    ManagedBooking booking,
    int hours,
    AppLocalizations l10n,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final cleanToken = widget.token.startsWith('#') ? widget.token : '#${widget.token}';
    final localizedShift = booking.shiftName == 'Comida'
        ? context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch')
        : (booking.shiftName == 'Cena'
            ? context.tr(es: 'Cena', eu: 'Afaria', en: 'Dinner')
            : booking.shiftName);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Screen G6: Header info (Responsive layout to prevent overflow on narrow screens)
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 460;

            final titleWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    es: 'Gestión Privada de Reserva',
                    eu: 'Erreserbaren Kudeaketa Pribatua',
                    en: 'Private Booking Management',
                  ),
                  style: GoogleFonts.fraunces(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.tr(es: "Referencia", eu: "Erreferentzia", en: "Reference")}: $cleanToken',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bottleGreen,
                  ),
                ),
              ],
            );

            final statusBadge = Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bottleGreenWash,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.bottleGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.bottleGreen),
                  const SizedBox(width: 4),
                  Text(
                    context.tr(es: 'Confirmada', eu: 'Baieztatuta', en: 'Confirmed'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bottleGreen,
                    ),
                  ),
                ],
              ),
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  statusBadge,
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
                const SizedBox(width: AppSpacing.sm),
                statusBadge,
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Screen G6: Overview Card
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderColor: AppColors.line,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.customerName,
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${madridDateString(booking.date)} · ${booking.time} ($localizedShift)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              Text(
                '${booking.adults} ${context.tr(es: "adultos", eu: "heldu", en: "adults")} · ${booking.children} ${context.tr(es: "niños", eu: "haur", en: "children")} (${context.tr(es: "Mesa corrida de roble", eu: "Haritzezko mahai luzea", en: "Long oak communal table")})',
                style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
              ),
              if (booking.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.ciderWash,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cider.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${context.tr(es: "Aviso", eu: "Oharra", en: "Notice")}: ${booking.notes}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.cider),
                  ),
                ),
              ],
              const Divider(color: AppColors.line, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.tr(es: 'Estado de la seña:', eu: 'Seinalearen egoera:', en: 'Deposit status:')),
                  Text(
                    _depositStatus(context, booking, locale),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: booking.payment == 'paid' || booking.depositAmount <= 0
                          ? AppColors.bottleGreen
                          : AppColors.cider,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 48h Policy Notice Banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.bottleGreen, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.tr(
                    es: 'Cancelación o modificación gratuita hasta $hours horas antes del servicio (${madridDateString(booking.date.subtract(Duration(hours: hours)))} a las ${booking.time}).',
                    eu: 'Doako ezeztapena edo aldaketa zerbitzua baino $hours ordu lehenago arte (${madridDateString(booking.date.subtract(Duration(hours: hours)))} ${booking.time}-etan).',
                    en: 'Free cancellation or change up to $hours hours before service (${madridDateString(booking.date.subtract(Duration(hours: hours)))} at ${booking.time}).',
                  ),
                  style: const TextStyle(fontSize: 13, color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),

        if (_message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.bottleGreenWash,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_message!, style: const TextStyle(color: AppColors.bottleGreen, fontWeight: FontWeight.w700)),
          ),
        ],

        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.dangerWash,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Screen G6: Self-Service Accordion 1 — Cambiar fecha o turno
        _AccordionItem(
          title: context.tr(es: 'Cambiar fecha o turno', eu: 'Data edo txanda aldatu', en: 'Change date or shift'),
          subtitle: context.tr(
            es: 'Mueve tu reserva a otro día de servicio abierto sin perder tus datos',
            eu: 'Aldatu zure erreserba beste zerbitzu-egun batera zure datuak galdu gabe',
            en: 'Move your booking to another open service day without losing your details',
          ),
          icon: Icons.calendar_month,
          isOpen: _showChangeDate,
          onToggle: () => setState(() => _showChangeDate = !_showChangeDate),
          content: _ChangeDateSection(
            date: _newDate ?? booking.date,
            shiftId: _shiftId,
            time: _time,
            onDate: (day) => setState(() {
              _newDate = day;
              _shiftId = null;
              _time = null;
            }),
            onShift: (id) => setState(() {
              _shiftId = id;
              _time = null;
            }),
            onTime: (time) => setState(() => _time = time),
            onSave: _busy ? null : () => _reschedule(l10n),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Screen G6: Self-Service Accordion 2 — Modificar comensales
        _AccordionItem(
          title: context.tr(es: 'Modificar comensales', eu: 'Mahaikideak aldatu', en: 'Modify guests'),
          subtitle: context.tr(
            es: 'Añade o reduce plazas (recalcula automáticamente el saldo de seña)',
            eu: 'Gehitu edo murriztu lekuak (seinalearen saldoa automatikoki birkalkulatzen du)',
            en: 'Add or reduce seats (automatically recalculates deposit balance)',
          ),
          icon: Icons.group_add_outlined,
          isOpen: _showChangeParty,
          onToggle: () => setState(() => _showChangeParty = !_showChangeParty),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${context.tr(es: "Adultos", eu: "Helduak", en: "Adults")} (45 €):', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: ((_newAdults ?? booking.adults) > 1)
                            ? () => setState(() => _newAdults = (_newAdults ?? booking.adults) - 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${_newAdults ?? booking.adults}', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: () => setState(() => _newAdults = (_newAdults ?? booking.adults) + 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bottleGreen,
                  minimumSize: const Size(180, 44),
                ),
                onPressed: () {
                  setState(() => _error = context.tr(
                    es: 'Para cambiar los comensales, llama a la sidrería.',
                    eu: 'Mahaikideak aldatzeko, deitu sagardotegira.',
                    en: 'To change the party size, call the cider house.',
                  ));
                },
                child: Text(context.tr(es: 'Actualizar comensales', eu: 'Mahaikideak eguneratu', en: 'Update party size')),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Screen G6: Self-Service Accordion 3 — Cancelar reserva (Destructive)
        _AccordionItem(
          title: context.tr(es: 'Cancelar reserva', eu: 'Erreserba ezeztatu', en: 'Cancel booking'),
          subtitle: context.tr(
            es: 'Libera la mesa e inicia el reembolso automático de la seña (>48h)',
            eu: 'Mahaia askatu eta seinalearen itzulketa automatikoa hasi (>48h)',
            en: 'Release the table and initiate automatic deposit refund (>48h)',
          ),
          icon: Icons.delete_outline,
          isDanger: true,
          isOpen: false,
          onToggle: () => _confirmCancel(context, l10n),
          content: const SizedBox.shrink(),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Screen G6: Direct Concierge Call
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          backgroundColor: AppColors.paper,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.bottleGreenWash,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent, color: AppColors.bottleGreen, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(
                        es: '¿Tienes dudas o peticiones especiales?',
                        eu: 'Galderarik edo eskaera berezirik baduzu?',
                        en: 'Have questions or special requests?',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(
                        es: 'Llámanos directamente al caserío y te atendemos.',
                        eu: 'Deitu zuzenean baserrira eta lagunduko dizugu.',
                        en: 'Call us directly at the cider house and we will assist you.',
                      ),
                      style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bottleGreen,
                  minimumSize: const Size(130, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () => launchUrl(Uri.parse('tel:+34685721593')),
                icon: const Icon(Icons.call, size: 16),
                label: Text(context.tr(es: 'Llamar', eu: 'Deitu', en: 'Call')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmCancel(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.danger),
            const SizedBox(width: 8),
            Text(
              ctx.tr(
                es: '¿Cancelar esta reserva?',
                eu: 'Erreserba hau ezeztatu?',
                en: 'Cancel this reservation?',
              ),
              style: GoogleFonts.fraunces(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: Text(
          ctx.tr(
            es: 'La mesa queda libre. Esta pantalla no devuelve la seña a la tarjeta.',
            eu: 'Mahaia libre geratzen da. Pantaila honek ez du seinalea txartelera itzultzen.',
            en: 'The table is released. This screen does not refund the card.',
          ),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              ctx.tr(es: 'Mantener reserva', eu: 'Erreserba mantendu', en: 'Keep booking'),
              style: const TextStyle(color: AppColors.ink),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(ctx).pop();
              _cancel(l10n);
            },
            child: Text(
              ctx.tr(es: 'Sí, cancelar reserva', eu: 'Bai, erreserba ezeztatu', en: 'Yes, cancel booking'),
            ),
          ),
        ],
      ),
    );
  }

  String _depositStatus(BuildContext context, ManagedBooking booking, String locale) {
    final l10n = AppLocalizations.of(context);
    if (booking.depositAmount <= 0) {
      return context.tr(
        es: 'Sin seña',
        eu: 'Seinalerik gabe',
        en: 'No deposit',
      );
    }
    if (booking.payment == 'paid') {
      return '${formatEur(booking.depositAmount, locale)} ${l10n.paymentPaid}';
    }
    return '${formatEur(booking.depositAmount, locale)}. ${l10n.paymentPending}';
  }

  Future<void> _cancel(AppLocalizations l10n) async {
    setState(() => _busy = true);
    try {
      await ref.read(bookingRepositoryProvider).cancelByToken(widget.token);
      ref.invalidate(managedBookingProvider(widget.token));
      setState(() {
        _message = l10n.bookingCancelled;
        _error = null;
      });
    } catch (_) {
      setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reschedule(AppLocalizations l10n) async {
    final shift = _shiftId;
    final time = _time;
    final date = _newDate;
    if (shift == null || time == null || date == null) {
      setState(() => _error = l10n.fieldRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(bookingRepositoryProvider).reschedule(
        token: widget.token,
        shiftId: shift,
        date: date,
        time: time,
      );
      ref.invalidate(managedBookingProvider(widget.token));
      setState(() {
        _message = l10n.bookingChanged;
        _error = null;
        _showChangeDate = false;
        _shiftId = null;
        _time = null;
      });
    } catch (_) {
      setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _AccordionItem extends StatelessWidget {
  const _AccordionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isOpen,
    required this.onToggle,
    required this.content,
    this.isDanger = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget content;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: isDanger ? AppColors.danger.withValues(alpha: 0.3) : AppColors.line,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: AppRadius.card,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDanger ? AppColors.dangerWash : AppColors.bottleGreenWash,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: isDanger ? AppColors.danger : AppColors.bottleGreen),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDanger ? AppColors.danger : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.expand_less : Icons.expand_more,
                    color: isDanger ? AppColors.danger : AppColors.inkMuted,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) ...[
            const Divider(color: AppColors.line, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: content,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChangeDateSection extends ConsumerWidget {
  const _ChangeDateSection({
    required this.date,
    required this.shiftId,
    required this.time,
    required this.onDate,
    required this.onShift,
    required this.onTime,
    required this.onSave,
  });

  final DateTime date;
  final String? shiftId;
  final String? time;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<String> onShift;
  final ValueChanged<String> onTime;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = madridNow();
    final first = DateTime(today.year, today.month, today.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TableCalendar<void>(
          firstDay: first,
          lastDay: first.add(const Duration(days: 120)),
          focusedDay: date.isBefore(first) ? first : date,
          selectedDayPredicate: (day) => isSameDay(day, date),
          enabledDayPredicate: (day) =>
              !day.isBefore(first) &&
              (day.weekday == DateTime.thursday ||
                  day.weekday == DateTime.friday ||
                  day.weekday == DateTime.saturday ||
                  day.weekday == DateTime.sunday),
          onDaySelected: (selected, _) => onDate(selected),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(color: AppColors.bottleGreen, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Shifts open on the new date:',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xs),
        _ShiftChoices(
          date: date,
          shiftId: shiftId,
          time: time,
          onShift: onShift,
          onTime: onTime,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.bottleGreen,
            minimumSize: const Size(180, 48),
          ),
          onPressed: onSave,
          child: const Text('Save new date and shift'),
        ),
      ],
    );
  }
}

class _ShiftChoices extends ConsumerWidget {
  const _ShiftChoices({
    required this.date,
    required this.shiftId,
    required this.time,
    required this.onShift,
    required this.onTime,
  });

  final DateTime date;
  final String? shiftId;
  final String? time;
  final ValueChanged<String> onShift;
  final ValueChanged<String> onTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final availability = ref.watch(availabilityProvider(madridDateString(date)));
    return availability.when(
      loading: () => LoadingState(label: l10n.loading),
      error: (_, _) => Text(l10n.errorGeneric, style: const TextStyle(color: AppColors.danger)),
      data: (shifts) {
        final open = shifts.where((shift) => !shift.isClosed).toList();
        if (open.isEmpty) {
          return Text(l10n.emptyShifts, style: const TextStyle(color: AppColors.inkMuted));
        }
        ShiftAvailability? selected;
        for (final shift in open) {
          if (shift.shiftId == shiftId) selected = shift;
        }
        final slots = selected == null
            ? const <String>[]
            : bookingSlots(selected.startTime, selected.lastBookingTime);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final shift in open)
                  ChoiceChip(
                    label: Text('${shift.shiftName} (${shift.startTime}–${shift.endTime})'),
                    selected: shift.shiftId == shiftId,
                    selectedColor: AppColors.bottleGreen,
                    labelStyle: TextStyle(
                      color: shift.shiftId == shiftId ? Colors.white : AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => onShift(shift.shiftId),
                  ),
              ],
            ),
            if (slots.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in slots)
                    ChoiceChip(
                      label: Text(slot),
                      selected: time == slot,
                      selectedColor: AppColors.bottleGreen,
                      labelStyle: TextStyle(
                        color: time == slot ? Colors.white : AppColors.ink,
                      ),
                      onSelected: (_) => onTime(slot),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
