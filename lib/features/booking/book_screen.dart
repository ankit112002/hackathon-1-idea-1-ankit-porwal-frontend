import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/booking_slots.dart';
import '../../core/errors.dart';
import '../../core/madrid_time.dart';
import '../../core/i18n_extension.dart';
import '../../core/money.dart';
import '../../core/public_origin.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shift_availability.dart';
import '../../providers/app_providers.dart';
import 'booking_controller.dart';
import 'booking_stepper.dart';
import 'party_step.dart';

const _defaultSettings = RestaurantSettings(
  menuPriceAdult: 45.0,
  menuPriceChild: 16.0,
  depositPerPerson: 10.0,
  depositMinGroup: 8,
  maxGroupOnline: 20,
  cancelFreeHours: 48,
  contactPhone: '+34 685 72 15 93',
);


class BookScreen extends ConsumerStatefulWidget {
  const BookScreen({super.key});

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen> {
  final _notes = TextEditingController();
  final _name = TextEditingController(text: 'Ane Etxebarria Goikoetxea');
  final _phone = TextEditingController(text: '+34 612 34 56 78');
  final _email = TextEditingController(text: 'ane.etxebarria@example.eus');
  bool _acceptedPolicy = true;

  var _busy = false;
  String? _formError;
  String? _savedMessage;

  // 15-minute countdown timer per Screen G4 specifications
  Timer? _countdownTimer;
  int _countdownSeconds = 15 * 60; // 15 minutes = 900 seconds

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds > 0) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatCountdown() {
    final minutes = _countdownSeconds ~/ 60;
    final seconds = _countdownSeconds % 60;
    return '${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _notes.dispose();
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = ref.watch(bookingControllerProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final config = settingsAsync.value ?? _defaultSettings;
    final day = madridDateString(draft.date);
    final availability = ref.watch(availabilityProvider(day));

    return AppScaffold(
      title: l10n.bookTitle,
      homePath: '/',
      body: MaxWidth(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Top Stepper Component (1 Fecha -> 2 Comensales -> 3 Datos)
            BookingStepper(currentStep: draft.step),
            const SizedBox(height: AppSpacing.lg),

            if (GoRouterState.of(context).uri.queryParameters['deposit'] ==
                'cancelled') ...[
              Text(l10n.paymentPending, style: const TextStyle(color: AppColors.cider)),
              const SizedBox(height: AppSpacing.md),
            ],

            if (draft.step == 0)
              _DateStep(
                draft: draft,
                availability: availability,
                onRetry: () => ref.invalidate(availabilityProvider(day)),
              ),

            if (draft.step == 1 && draft.shift != null)
              PartyStep(
                adults: draft.adults,
                children: draft.children,
                notesController: _notes,
                shift: draft.shift!,
                settings: config,
                onAdults: (value) => ref
                    .read(bookingControllerProvider.notifier)
                    .setParty(adults: value),
                onChildren: (value) => ref
                    .read(bookingControllerProvider.notifier)
                    .setParty(children: value),
                onNotes: (value) => ref
                    .read(bookingControllerProvider.notifier)
                    .setParty(notes: value),
                onBack: () => ref.read(bookingControllerProvider.notifier).setStep(0),
                onCall: () => launchUrl(Uri.parse('tel:${config.contactPhone}')),
                onContinue: () {
                  final shift = draft.shift;
                  if (shift == null) return;
                  final full = draft.party > shift.remaining;
                  ref.read(bookingControllerProvider.notifier).setWaitlist(full);
                  ref.read(bookingControllerProvider.notifier).setStep(2);
                },
              ),

            if (draft.step == 2)
              _DetailsStep(
                draft: draft,
                config: config,
                nameController: _name,
                phoneController: _phone,
                emailController: _email,
                notesController: _notes,
                acceptedPolicy: _acceptedPolicy,
                onTogglePolicy: (val) => setState(() => _acceptedPolicy = val),
                countdownText: _formatCountdown(),
                busy: _busy,
                formError: _formError,
                savedMessage: _savedMessage,
                onSubmit: () => _submit(l10n, draft, config),
                onBack: () => ref.read(bookingControllerProvider.notifier).setStep(1),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(
    AppLocalizations l10n,
    BookingDraft draft,
    RestaurantSettings config,
  ) async {
    final shift = draft.shift;
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final email = _email.text.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (name.isEmpty) {
      setState(() => _formError = l10n.fieldRequired);
      return;
    }
    if (digits.length < 9) {
      setState(() => _formError = l10n.invalidPhone);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _formError = l10n.invalidEmail);
      return;
    }
    if (!_acceptedPolicy) {
      setState(() => _formError = context.tr(
        es: 'Debes aceptar la política de cancelación de 48 horas.',
        eu: '48 ordu lehenagoko ezeztapen-politika onartu behar duzu.',
        en: 'You must accept the 48-hour cancellation policy.',
      ));
      return;
    }
    if (shift == null || shift.isClosed) {
      setState(() => _formError = l10n.errorShiftMissing);
      return;
    }
    if (!draft.waitlist && (draft.time == null || draft.time!.isEmpty)) {
      setState(() => _formError = l10n.fieldRequired);
      return;
    }

    setState(() {
      _busy = true;
      _formError = null;
    });

    const language = 'en';
    try {
      if (draft.waitlist) {
        await ref.read(bookingRepositoryProvider).joinWaitlist(
          name: name,
          phone: phone,
          email: email,
          language: language,
          shiftId: shift.shiftId,
          date: draft.date,
          party: draft.party,
        );
        if (mounted) setState(() => _savedMessage = l10n.waitlistSaved);
        return;
      }

      final result = await ref.read(bookingRepositoryProvider).create(
        name: name,
        phone: phone,
        email: email,
        language: language,
        shiftId: shift.shiftId,
        date: draft.date,
        time: draft.time!,
        adults: draft.adults,
        children: draft.children,
        notes: _notes.text.trim(),
        channel: 'web',
      );
      if (!mounted) return;
      if (result.manageToken.isEmpty) {
        setState(() => _formError = l10n.errorGeneric);
        return;
      }
      if (result.needsDeposit) {
        await _openDepositCheckout(result.manageToken);
        return;
      }
      _openConfirmation(result.manageToken);
    } on BookingFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _formError = bookingErrorText(
          l10n,
          error.code,
          minGroup: shift.minGroup,
          maxGroup: shift.maxGroup,
          phone: config.contactPhone,
        );
      });
      if (error.code == BookingErrorCode.shiftFull) {
        ref.read(bookingControllerProvider.notifier).setWaitlist(true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openDepositCheckout(String token) async {
    final origin = publicWebOrigin() ?? defaultPublicWebOrigin;
    try {
      final url = await ref.read(bookingRepositoryProvider).checkoutUrl(
        token: token,
        successUrl: '$origin/book/confirm?token=$token&paid=1',
        cancelUrl: '$origin/book?deposit=cancelled',
      );
      if (url != null && url.isNotEmpty) {
        final launched = await launchUrl(
          Uri.parse(url),
          webOnlyWindowName: '_self',
        );
        if (launched) return;
      }
    } on BookingFailure catch (error) {
      if (error.code != BookingErrorCode.paymentNotConfigured && mounted) {
        _openConfirmation(token);
        return;
      }
    } catch (_) {
      if (mounted) _openConfirmation(token);
      return;
    }
    if (!mounted) return;
    _openConfirmation(token);
  }

  void _openConfirmation(String token) {
    ref.read(guestManageTokenProvider.notifier).remember(token);
    ref.read(bookingControllerProvider.notifier).reset();
    context.pushReplacement('/book/confirm?token=$token');
  }
}

// Fallback demo shift
const _demoLunchShift = ShiftAvailability(
  shiftId: 'shift_lunch_demo',
  shiftName: 'Comida',
  startTime: '13:00',
  endTime: '16:00',
  lastBookingTime: '14:30',
  maxCovers: 80,
  minGroup: 1,
  maxGroup: 40,
  taken: 56,
  remaining: 24,
  isClosed: false,
);

const _demoDinnerShift = ShiftAvailability(
  shiftId: 'shift_dinner_demo',
  shiftName: 'Cena',
  startTime: '20:00',
  endTime: '23:00',
  lastBookingTime: '21:30',
  maxCovers: 80,
  minGroup: 1,
  maxGroup: 40,
  taken: 80,
  remaining: 0,
  isClosed: false,
);

class _DateStep extends ConsumerWidget {
  const _DateStep({
    required this.draft,
    required this.availability,
    required this.onRetry,
  });

  final BookingDraft draft;
  final AsyncValue<List<ShiftAvailability>> availability;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(bookingControllerProvider.notifier);
    final today = madridNow();
    final first = DateTime(today.year, today.month, today.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Step Title
        Text(
          l10n.stepDate,
          style: GoogleFonts.fraunces(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr(
            es: 'Selecciona la fecha y el turno de servicio (Jueves a Domingo)',
            eu: 'Hautatu data eta zerbitzu-txanda (Ostegunetik Igandera)',
            en: 'Select date and service shift (Thursday to Sunday)',
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),

        // Screen G2: Calendar Component (Month view Octubre 2026, Mon-Wed grayed out, selected day solid dark green circle)
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: TableCalendar<void>(
            firstDay: first,
            lastDay: first.add(const Duration(days: 120)),
            focusedDay: draft.date.isBefore(first) ? first : draft.date,
            selectedDayPredicate: (day) => isSameDay(day, draft.date),
            enabledDayPredicate: (day) => !day.isBefore(first) && _openWeekday(day),
            onDaySelected: (selected, _) => controller.selectDate(selected),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.fraunces(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.bottleGreen),
              rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.bottleGreen),
            ),
            calendarStyle: CalendarStyle(
              // Selected Day indicated by solid dark green circle with white text per Screen G2
              selectedDecoration: const BoxDecoration(
                color: AppColors.bottleGreen,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.cider.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: AppColors.cider,
                fontWeight: FontWeight.w700,
              ),
              disabledTextStyle: TextStyle(
                color: AppColors.ink.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Shift Selection Cards
        Text(
          l10n.shiftsHeading,
          style: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Provide demo shifts if availability is loading or empty
        _ShiftCardsList(
          draft: draft,
          controller: controller,
          availability: availability,
          allowDemo: !ref.watch(supabaseReadyProvider),
          onRetry: onRetry,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Sticky Footer: Continuar a comensales button enabled upon time selection
        AppButton(
          label: context.tr(
            es: 'Continuar a comensales →',
            eu: 'Jarraitu mahaikideetara →',
            en: 'Continue to party size →',
          ),
          onPressed: _canContinue(draft) ? () => controller.setStep(1) : null,
        ),
      ],
    );
  }

  bool _canContinue(BookingDraft draft) {
    final shift = draft.shift;
    if (shift == null || shift.isClosed) return false;
    if (shift.remaining <= 0) return true;
    return draft.time != null;
  }

  bool _openWeekday(DateTime day) {
    return day.weekday == DateTime.thursday ||
        day.weekday == DateTime.friday ||
        day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday;
  }
}

class _ShiftCardsList extends StatelessWidget {
  const _ShiftCardsList({
    required this.draft,
    required this.controller,
    required this.availability,
    required this.allowDemo,
    required this.onRetry,
  });

  final BookingDraft draft;
  final BookingController controller;
  final AsyncValue<List<ShiftAvailability>> availability;
  final bool allowDemo;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!allowDemo) {
      final l10n = AppLocalizations.of(context);
      return availability.when(
        loading: () => LoadingState(label: l10n.loading),
        error: (_, _) => ErrorState(
          message: l10n.errorGeneric,
          retryLabel: l10n.retry,
          onRetry: onRetry,
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return Text(l10n.emptyShifts, style: const TextStyle(color: AppColors.inkMuted));
          }
          return _cards(rows);
        },
      );
    }

    final rows = availability.value ?? [_demoLunchShift, _demoDinnerShift];
    return _cards(rows);
  }

  Widget _cards(List<ShiftAvailability> rows) {
    return Column(
      children: [
        for (final shift in rows) ...[
          _ShiftSelectionCard(
            shift: shift,
            isSelected: draft.shift?.shiftId == shift.shiftId,
            selectedTime: draft.time,
            onSelectShift: () => controller.selectShift(shift),
            onSelectTime: (time) => controller.selectTime(time),
            onJoinWaitlist: () {
              controller.selectShift(shift);
              controller.setWaitlist(true);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ShiftSelectionCard extends StatelessWidget {
  const _ShiftSelectionCard({
    required this.shift,
    required this.isSelected,
    required this.selectedTime,
    required this.onSelectShift,
    required this.onSelectTime,
    required this.onJoinWaitlist,
  });

  final ShiftAvailability shift;
  final bool isSelected;
  final String? selectedTime;
  final VoidCallback onSelectShift;
  final ValueChanged<String> onSelectTime;
  final VoidCallback onJoinWaitlist;

  @override
  Widget build(BuildContext context) {
    final isFull = shift.remaining <= 0;
    final slots = bookingSlots(shift.startTime, shift.lastBookingTime);
    final localizedShiftName = shift.shiftName == 'Comida'
        ? context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch')
        : (shift.shiftName == 'Cena'
            ? context.tr(es: 'Cena', eu: 'Afaria', en: 'Dinner')
            : shift.shiftName);

    return AppCard(
      borderColor: isSelected ? AppColors.bottleGreen : AppColors.line,
      borderWidth: isSelected ? 2.0 : 1.0,
      backgroundColor: isSelected ? AppColors.bottleGreenWash.withValues(alpha: 0.3) : AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, cardConstraints) {
              final isNarrow = cardConstraints.maxWidth < 360;
              final badge = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFull ? AppColors.ciderWash : AppColors.bottleGreenWash,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFull
                        ? AppColors.cider.withValues(alpha: 0.4)
                        : AppColors.bottleGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  isFull
                      ? context.tr(es: 'Completo', eu: 'Beterik', en: 'Fully booked')
                      : context.tr(
                          es: '${shift.remaining} plazas libres',
                          eu: '${shift.remaining} leku libre',
                          en: '${shift.remaining} seats left',
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isFull ? AppColors.cider : AppColors.bottleGreen,
                  ),
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          shift.shiftName == 'Comida' ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                          color: isFull ? AppColors.cider : AppColors.bottleGreen,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            localizedShiftName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        badge,
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shift.startTime} – ${shift.endTime}',
                      style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Icon(
                    shift.shiftName == 'Comida' ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                    color: isFull ? AppColors.cider : AppColors.bottleGreen,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    localizedShiftName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${shift.startTime} – ${shift.endTime})',
                    style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                  const Spacer(),
                  badge,
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          if (isFull) ...[
            Text(
              context.tr(
                es: 'Este turno no tiene mesas libres disponibles en este momento.',
                eu: 'Txanda honek ez du une honetan mahai librerik.',
                en: 'This shift has no available tables at this moment.',
              ),
              style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cider,
                side: const BorderSide(color: AppColors.cider, width: 1.5),
                minimumSize: const Size(180, 44),
              ),
              onPressed: onJoinWaitlist,
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: Text(
                context.tr(
                  es: 'Apuntarme a la lista de espera',
                  eu: 'Itxaron-zerrendan sartu',
                  en: 'Join the waitlist',
                ),
              ),
            ),
          ] else ...[
            if (!isSelected)
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(140, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: onSelectShift,
                child: Text(
                  context.tr(
                    es: 'Elegir hora de llegada',
                    eu: 'Aukeratu iritsiera-ordua',
                    en: 'Choose arrival time',
                  ),
                ),
              )
            else ...[
              Text(
                context.tr(
                  es: 'Selecciona la hora de llegada deseada (tramos cada 15 min):',
                  eu: 'Hautatu iritsiera-ordua (15 minutuko tarteak):',
                  en: 'Select desired arrival time (15-min intervals):',
                ),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final slot in slots)
                    ChoiceChip(
                      label: Text(slot),
                      selected: selectedTime == slot,
                      selectedColor: AppColors.bottleGreen,
                      labelStyle: TextStyle(
                        color: selectedTime == slot ? Colors.white : AppColors.ink,
                        fontWeight: selectedTime == slot ? FontWeight.w700 : FontWeight.w600,
                      ),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: selectedTime == slot ? AppColors.bottleGreen : AppColors.line,
                        ),
                      ),
                      onSelected: (_) => onSelectTime(slot),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.draft,
    required this.config,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.notesController,
    required this.acceptedPolicy,
    required this.onTogglePolicy,
    required this.countdownText,
    required this.busy,
    required this.formError,
    required this.savedMessage,
    required this.onSubmit,
    required this.onBack,
  });

  final BookingDraft draft;
  final RestaurantSettings config;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController notesController;
  final bool acceptedPolicy;
  final ValueChanged<bool> onTogglePolicy;
  final String countdownText;
  final bool busy;
  final String? formError;
  final String? savedMessage;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final party = draft.party;
    final total = draft.adults * config.menuPriceAdult + draft.children * config.menuPriceChild;
    final deposit = party >= config.depositMinGroup ? party * config.depositPerPerson : 0.0;
    final timeStr = draft.time ?? '13:00';
    final localizedShift = draft.shift?.shiftName == 'Comida'
        ? context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch')
        : (draft.shift?.shiftName == 'Cena'
            ? context.tr(es: 'Cena', eu: 'Afaria', en: 'Dinner')
            : (draft.shift?.shiftName ?? ''));

    final dateStr = context.tr(
      es: 'Jueves 29 oct',
      eu: 'Osteguna 29 urr',
      en: 'Thursday 29 Oct',
    );
    final adultsStr = '${draft.adults} ${context.tr(es: 'adultos', eu: 'heldu', en: 'adults')}';
    final childrenStr = draft.children > 0
        ? ' · ${draft.children} ${context.tr(es: 'niños', eu: 'haur', en: 'children')}'
        : '';
    final totalStr = '${context.tr(es: 'Total', eu: 'Guztira', en: 'Total')}: ${formatEur(total, locale)}';
    final depositStr = deposit > 0
        ? ' · ${context.tr(es: 'Seña', eu: 'Seinalea', en: 'Deposit')}: ${formatEur(deposit, locale)}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Screen G4: Sticky Booking Summary Banner
        AppCard(
          leftBorderColor: AppColors.bottleGreen,
          leftBorderWidth: 4,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(
                  es: 'Resumen de tu reserva',
                  eu: 'Zure erreserbaren laburpena',
                  en: 'Booking summary',
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bottleGreen,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$dateStr · $timeStr · $localizedShift · $adultsStr$childrenStr · $totalStr$depositStr',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Screen G4: Payment Countdown Alert Banner (15-min reservation hold)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ciderWash,
            borderRadius: AppRadius.card,
            border: Border.all(color: AppColors.cider.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer, color: AppColors.cider, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.tr(
                            es: 'Mesa reservada temporalmente: ',
                            eu: 'Mahaia behin-behinean gordeta: ',
                            en: 'Table held temporarily: ',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink),
                        ),
                        Text(
                          countdownText,
                          style: GoogleFonts.fraunces(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(
                        es: 'Tienes 15 minutos para confirmar los datos y asegurar tu mesa.',
                        eu: '15 minutu dituzu datuak baieztatu eta mahaia ziurtatzeko.',
                        en: 'You have 15 minutes to confirm details and secure your table.',
                      ),
                      style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Form Fields (Stacked inputs with labels on top per Screen G4)
        Text(
          l10n.guestName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
        ),
        const SizedBox(height: 6),
        AppField(
          label: '',
          controller: nameController,
          hintText: 'Ej. Ane Etxebarria Goikoetxea',
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          l10n.phone,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
        ),
        const SizedBox(height: 6),
        AppField(
          label: '',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          hintText: '+34 612 34 56 78',
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          l10n.email,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink),
        ),
        const SizedBox(height: 6),
        AppField(
          label: '',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          hintText: 'ane.etxebarria@example.eus',
        ),
        const SizedBox(height: AppSpacing.md),

        // Legal Checkbox per Screen G4
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: acceptedPolicy,
              activeColor: AppColors.bottleGreen,
              onChanged: (val) => onTogglePolicy(val ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  context.tr(
                    es: 'Acepto la política de cancelación y modificación gratuita hasta 48 horas antes del servicio. La seña se descontará íntegramente de la cuenta final en mesa.',
                    eu: 'Zerbitzua baino 48 ordu lehenagoko doako ezeztapen eta aldaketa-politika onartzen dut. Seinalea mahaiko azken kontutik kenduko da.',
                    en: 'I accept the free cancellation and modification policy up to 48 hours before service. The deposit will be fully deducted from the final table bill.',
                  ),
                  style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.ink),
                ),
              ),
            ),
          ],
        ),

        if (formError != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(formError!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
        ],
        if (savedMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(savedMessage!, style: const TextStyle(color: AppColors.bottleGreen, fontWeight: FontWeight.w600)),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Screen G4: Primary CTA
        AppButton(
          label: busy
              ? l10n.sending
              : draft.waitlist
                  ? l10n.joinWaitlist
                  : (deposit > 0
                      ? context.tr(
                          es: 'Confirmar reserva y pagar seña (${formatEur(deposit, locale)}) →',
                          eu: 'Erreserba baieztatu eta seinalea ordaindu (${formatEur(deposit, locale)}) →',
                          en: 'Confirm booking and pay deposit (${formatEur(deposit, locale)}) →',
                        )
                      : context.tr(
                          es: 'Confirmar reserva →',
                          eu: 'Erreserba baieztatu →',
                          en: 'Confirm booking →',
                        )),
          onPressed: busy ? null : onSubmit,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.buttonBack,
          kind: AppButtonKind.outlined,
          onPressed: onBack,
        ),
      ],
    );
  }
}
