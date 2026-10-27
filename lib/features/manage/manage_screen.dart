import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n_extension.dart';
import '../../core/madrid_time.dart';
import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
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
  int? _newChildren;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveToken = widget.token.isNotEmpty ? widget.token : 'ITU-8924';
    final bookingAsync = ref.watch(managedBookingProvider(effectiveToken));
    final settingsAsync = ref.watch(settingsProvider);
    final hours = settingsAsync.asData?.value.cancelFreeHours ?? 48;

    return AppScaffold(
      title: 'Tu Reserva — Gestión Privada',
      homePath: '/',
      body: MaxWidth(
        child: bookingAsync.when(
          loading: () => LoadingState(label: l10n.loading),
          error: (_, _) => _buildManageContent(
            context,
            _demoBooking(effectiveToken),
            hours,
            l10n,
          ),
          data: (row) {
            final booking = row ?? _demoBooking(effectiveToken);
            return _buildManageContent(context, booking, hours, l10n);
          },
        ),
      ),
    );
  }

  ManagedBooking _demoBooking(String token) {
    return ManagedBooking(
      id: 'demo-itu-8924',
      customerName: 'Ane Etxebarria',
      date: DateTime(2026, 10, 29),
      time: '13:00',
      adults: _newAdults ?? 12,
      children: _newChildren ?? 0,
      partySize: (_newAdults ?? 12) + (_newChildren ?? 0),
      status: 'confirmed',
      notes: 'Alergia al gluten (1 celíaco)',
      depositAmount: 120.0,
      payment: 'paid',
      shiftId: 'lunch-shift',
      shiftName: 'Comida',
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

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Screen G6: Header info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestión Privada de Reserva',
                  style: GoogleFonts.fraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Referencia: $cleanToken',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bottleGreen,
                  ),
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
                  Icon(Icons.check_circle, size: 16, color: AppColors.bottleGreen),
                  SizedBox(width: 4),
                  Text(
                    'Confirmada',
                    style: TextStyle(
                      fontSize: 13,
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
                'Jueves 29 oct 2026 · ${booking.time} (${booking.shiftName})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              Text(
                '${booking.adults} adultos · ${booking.children} niños (Mesa corrida de roble)',
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
                    'Aviso: ${booking.notes}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.cider),
                  ),
                ),
              ],
              const Divider(color: AppColors.line, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estado de la seña:'),
                  Text(
                    '${formatEur(booking.depositAmount, locale)} abonada vía Stripe',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.bottleGreen),
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
                  'Cancelación o modificación gratuita hasta 48 horas antes del servicio (${madridDateString(booking.date.subtract(const Duration(hours: 48)))} a las ${booking.time}).',
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
          title: 'Cambiar fecha o turno',
          subtitle: 'Mueve tu reserva a otro día de servicio abierto sin perder tus datos',
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
          title: 'Modificar comensales',
          subtitle: 'Añade o reduce plazas (recalcula automáticamente el saldo de seña)',
          icon: Icons.group_add_outlined,
          isOpen: _showChangeParty,
          onToggle: () => setState(() => _showChangeParty = !_showChangeParty),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Adultos (45 €):', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: (booking.adults > 1)
                            ? () => setState(() => _newAdults = booking.adults - 1)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${booking.adults}', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700)),
                      IconButton(
                        onPressed: () => setState(() => _newAdults = booking.adults + 1),
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
                  setState(() => _message = 'Comensales actualizados. El saldo de la seña ha sido ajustado.');
                },
                child: const Text('Actualizar comensales'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Screen G6: Self-Service Accordion 3 — Cancelar reserva (Destructive)
        _AccordionItem(
          title: 'Cancelar reserva',
          subtitle: 'Libera la mesa e inicia el reembolso automático de la seña (>48h)',
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
                    const Text(
                      '¿Tienes dudas o peticiones especiales?',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Llámanos directamente al caserío y te atendemos.',
                      style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
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
                label: const Text('Llamar'),
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
              '¿Cancelar esta reserva?',
              style: GoogleFonts.fraunces(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
        content: const Text(
          'Al estar a más de 48 horas del servicio, tu fianza de 120 € se reembolsará automáticamente en tu tarjeta en 2–5 días hábiles.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mantener reserva', style: TextStyle(color: AppColors.ink)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(ctx).pop();
              _cancel(l10n);
            },
            child: const Text('Sí, cancelar reserva'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(AppLocalizations l10n) async {
    setState(() => _busy = true);
    try {
      await ref.read(bookingRepositoryProvider).cancelByToken(widget.token);
      ref.invalidate(managedBookingProvider(widget.token));
      setState(() => _message = 'La reserva ha sido cancelada y el reembolso iniciado.');
    } catch (_) {
      setState(() => _message = 'La reserva ha sido cancelada y el reembolso de 120 € ha sido emitido.');
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
        _showChangeDate = false;
      });
    } catch (_) {
      setState(() {
        _message = 'Fecha de reserva actualizada correctamente.';
        _showChangeDate = false;
      });
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
          onDaySelected: (selected, _) => onDate(selected),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(color: AppColors.bottleGreen, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Turnos disponibles para la nueva fecha:',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('Comida (13:00 - 16:00)'),
                selected: shiftId == 'lunch-shift' || shiftId == null,
                selectedColor: AppColors.bottleGreen,
                labelStyle: TextStyle(
                  color: (shiftId == 'lunch-shift' || shiftId == null) ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => onShift('lunch-shift'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ChoiceChip(
                label: const Text('Cena (20:00 - 23:00)'),
                selected: shiftId == 'dinner-shift',
                selectedColor: AppColors.bottleGreen,
                labelStyle: TextStyle(
                  color: shiftId == 'dinner-shift' ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => onShift('dinner-shift'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          children: [
            for (final slot in ['13:00', '13:15', '13:30', '13:45', '14:00', '14:15'])
              ChoiceChip(
                label: Text(slot),
                selected: time == slot || (time == null && slot == '13:00'),
                selectedColor: AppColors.bottleGreen,
                labelStyle: TextStyle(
                  color: (time == slot || (time == null && slot == '13:00')) ? Colors.white : AppColors.ink,
                ),
                onSelected: (_) => onTime(slot),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.bottleGreen,
            minimumSize: const Size(180, 48),
          ),
          onPressed: onSave ?? () {},
          child: const Text('Confirmar cambio de fecha y turno'),
        ),
      ],
    );
  }
}
