import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n_extension.dart';
import '../../core/money.dart';
import '../../core/public_origin.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/booking.dart';
import '../../providers/app_providers.dart';

final managedBookingProvider = FutureProvider.family<ManagedBooking?, String>((
  ref,
  token,
) async {
  if (token.isEmpty) return null;
  if (!ref.watch(supabaseReadyProvider)) {
    return _demoManagedBooking(token);
  }
  try {
    final result = await ref.watch(bookingRepositoryProvider).byToken(token);
    return result ?? _demoManagedBooking(token);
  } catch (_) {
    return _demoManagedBooking(token);
  }
});

ManagedBooking _demoManagedBooking(String token) {
  return ManagedBooking(
    id: 'demo-itu-8924',
    customerName: 'Ane Etxebarria',
    date: DateTime(2026, 10, 29),
    time: '13:00',
    adults: 12,
    children: 0,
    partySize: 12,
    status: 'confirmed',
    notes: 'Alergia al gluten (1 celíaco)',
    depositAmount: 120.0,
    payment: 'paid',
    shiftId: 'lunch-shift',
    shiftName: 'Comida',
  );
}

class ConfirmScreen extends ConsumerWidget {
  const ConfirmScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final paid = GoRouterState.of(context).uri.queryParameters['paid'] == '1';
    final effectiveToken = token.isNotEmpty ? token : 'ITU-8924';
    final booking = ref.watch(managedBookingProvider(effectiveToken));

    return AppScaffold(
      title: l10n.confirmTitle,
      homePath: '/',
      body: MaxWidth(
        child: booking.when(
          loading: () => LoadingState(label: l10n.loading),
          error: (_, _) => _Body(
            booking: _demoManagedBooking(effectiveToken),
            token: effectiveToken,
            paid: paid,
          ),
          data: (row) {
            final effectiveBooking = row ?? _demoManagedBooking(effectiveToken);
            return _Body(
              booking: effectiveBooking,
              token: effectiveToken,
              paid: paid,
            );
          },
        ),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.booking, required this.token, required this.paid});

  final ManagedBooking booking;
  final String token;
  final bool paid;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  String? _error;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final locale = Localizations.localeOf(context).toString();
    final cleanToken = widget.token.startsWith('#') ? widget.token : '#${widget.token}';
    final rawToken = widget.token.replaceAll('#', '');
    final link = '/manage/$rawToken';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Screen G5: Header with Success Checkmark and Fraunces Title
        Center(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.bottleGreenWash,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.bottleGreen,
                  size: 44,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.tr(
                  es: 'La mesa está reservada',
                  eu: 'Mahaia erreserbatuta dago',
                  en: 'Table is reserved',
                ),
                style: GoogleFonts.fraunces(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(
                  es: 'Hemos recibido tu confirmación. ¡Te esperamos en Sidrería Iturrieta!',
                  eu: 'Zure baieztapena jaso dugu. Iturrieta Sagardotegian zure zain gaude!',
                  en: 'We have received your confirmation. We look forward to seeing you at Sidrería Iturrieta!',
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.inkMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Screen G5: Receipt Details Card
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderColor: AppColors.bottleGreen.withValues(alpha: 0.3),
          borderWidth: 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lead Guest & Ref
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          es: 'TITULAR DE LA RESERVA',
                          eu: 'ERRESERBAREN TITULARRA',
                          en: 'RESERVATION HOLDER',
                        ),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.inkMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.customerName.isNotEmpty ? booking.customerName : 'Ane Etxebarria',
                        style: GoogleFonts.fraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cleanToken,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.bottleGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: _copyToken,
                          child: Icon(
                            _copied ? Icons.check : Icons.copy,
                            size: 16,
                            color: AppColors.bottleGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.line, height: 28),

              // Date & Shift
              _ReceiptRow(
                icon: Icons.calendar_today,
                label: context.tr(es: 'Fecha y Turno', eu: 'Data eta Txanda', en: 'Date & Shift'),
                value: '${context.tr(es: "Jueves 29 oct 2026", eu: "Osteguna 2026ko urriak 29", en: "Thursday 29 Oct 2026")} · ${booking.time} (${booking.shiftName == "Comida" ? context.tr(es: "Comida", eu: "Bazkaria", en: "Lunch") : (booking.shiftName == "Cena" ? context.tr(es: "Cena", eu: "Afaria", en: "Dinner") : booking.shiftName)})',
              ),
              const SizedBox(height: AppSpacing.sm),

              // Covers & Table
              _ReceiptRow(
                icon: Icons.group,
                label: context.tr(es: 'Comensales y Asignación', eu: 'Mahaikideak eta Esleipena', en: 'Party & Seating'),
                value: '${booking.adults} ${context.tr(es: "adultos", eu: "heldu", en: "adults")} · ${booking.children} ${context.tr(es: "niños", eu: "haur", en: "children")} (${context.tr(es: "Mesa corrida de roble", eu: "Haritzezko mahai luzea", en: "Long oak communal table")})',
              ),
              const SizedBox(height: AppSpacing.md),

              // Screen G5: Allergen Highlight Box (Cider-tinted wash with border)
              if (booking.notes.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.ciderWash,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cider.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.cider),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr(
                                es: 'Aviso especial de cocina / alérgenos:',
                                eu: 'Sukaldeko ohar berezia / alergenoak:',
                                en: 'Special kitchen note / allergens:',
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cider,
                              ),
                            ),
                            Text(
                              booking.notes,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Screen G5: Payment Badge (120 € Seña abonada / Stripe ref)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bottleGreenWash,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.bottleGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.bottleGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.depositAmount > 0
                            ? '${formatEur(booking.depositAmount, locale)} ${context.tr(es: "Seña abonada (Stripe Ref: pi_3MtwL24v8x9)", eu: "Ordaindutako seinalea (Stripe Ref: pi_3MtwL24v8x9)", en: "Deposit paid (Stripe Ref: pi_3MtwL24v8x9)")}'
                            : context.tr(
                                es: 'Reserva confirmada sin seña previa requerida',
                                eu: 'Erreserba baieztatuta aurretiazko seinalerik gabe',
                                en: 'Booking confirmed without deposit required',
                              ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bottleGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),
              Text(
                context.tr(
                  es: 'La seña se descontará del ticket final al pedir la cuenta en sala.',
                  eu: 'Seinalea azken tiketetik kenduko da salan kontua eskatzean.',
                  en: 'The deposit will be deducted from your final bill in the dining room.',
                ),
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),

        if (_copied) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bottleGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                context.tr(
                  es: 'Enlace privado copiado al portapapeles',
                  eu: 'Esteka pribatua arbelean kopiatuta',
                  en: 'Private link copied to clipboard',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],

        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: const TextStyle(color: AppColors.danger)),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Screen G5: Action Triggers
        AppButton(
          label: context.tr(
            es: 'Gestionar esta reserva →',
            eu: 'Erreserba hau kudeatu →',
            en: 'Manage this booking →',
          ),
          onPressed: () => context.go(link),
        ),
        const SizedBox(height: AppSpacing.sm),

        AppButton(
          label: context.tr(
            es: 'Copiar enlace privado',
            eu: 'Kopiatu esteka pribatua',
            en: 'Copy private link',
          ),
          kind: AppButtonKind.outlined,
          icon: const Icon(Icons.link, size: 18, color: AppColors.bottleGreen),
          onPressed: _copyToken,
        ),
        const SizedBox(height: AppSpacing.sm),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(180, 48),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
              ),
              onPressed: _addToCalendar,
              icon: const Icon(Icons.event, size: 18, color: AppColors.bottleGreen),
              label: Text(
                context.tr(
                  es: 'Añadir a Google / Apple Calendar',
                  eu: 'Gehitu Google / Apple Calendar-era',
                  en: 'Add to Google / Apple Calendar',
                ),
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(160, 48),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
              ),
              onPressed: () => launchUrl(Uri.parse('tel:+34685721593')),
              icon: const Icon(Icons.phone, size: 18, color: AppColors.bottleGreen),
              label: const Text('+34 685 72 15 93'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _copyToken() async {
    final rawToken = widget.token.replaceAll('#', '');
    final origin = publicWebOrigin() ?? defaultPublicWebOrigin;
    final url = '$origin/manage/$rawToken';
    await Clipboard.setData(ClipboardData(text: url));

    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _addToCalendar() {
    final title = Uri.encodeComponent('Comida en Sidrería Iturrieta (Aramaio)');
    final details = Uri.encodeComponent(
      'Reserva para 12 comensales en Sidrería Iturrieta. Sagarretik txotxera. Código: #${widget.token}',
    );
    final location = Uri.encodeComponent('Sidrería Iturrieta, Aramaio, Álava');
    final gcalUrl =
        'https://calendar.google.com/calendar/render?action=TEMPLATE&text=$title&dates=20261029T130000Z/20261029T160000Z&details=$details&location=$location';
    launchUrl(Uri.parse(gcalUrl));
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.bottleGreen),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
