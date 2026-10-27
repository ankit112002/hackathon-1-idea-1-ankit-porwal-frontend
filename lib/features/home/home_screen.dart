import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/i18n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;

    return AppScaffold(
      title: l10n.appTitle,
      body: MaxWidth(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Screen G1: Hero Section with Full-Bleed Basque Cidery Image
            const _HeroSection(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Highlights Bar (Adult 45€, Child 16€, Seña 10€, 48h cancel)
                  const _HighlightsBar(),

                  const SizedBox(height: AppSpacing.xxl),

                  // Turnos Semanales Section
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 500;
                      final shiftsSubtitle = context.tr(
                        es: 'Servicios abiertos de jueves a domingo',
                        eu: 'Ostegunetik igandera zabalik dauden zerbitzuak',
                        en: 'Services open from Thursday to Sunday',
                      );
                      final viewCalendar = context.tr(
                        es: 'Ver calendario',
                        eu: 'Egutegia ikusi',
                        en: 'View calendar',
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.shiftsHeading,
                              style: text.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              shiftsSubtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                              onPressed: () => context.go('/book'),
                              icon: const Icon(Icons.calendar_month, size: 18, color: AppColors.bottleGreen),
                              label: Text(
                                viewCalendar,
                                style: const TextStyle(color: AppColors.bottleGreen, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.shiftsHeading,
                                style: text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                shiftsSubtitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/book'),
                            icon: const Icon(Icons.calendar_month, size: 18, color: AppColors.bottleGreen),
                            label: Text(
                              viewCalendar,
                              style: const TextStyle(color: AppColors.bottleGreen, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _ShiftList(),

                  const SizedBox(height: AppSpacing.xxl),

                  // Agenda Cultural Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.eventsPublic,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(
                          es: 'Conciertos y catas especiales en nuestra bodega',
                          eu: 'Kontzertuak eta dasta bereziak gure upeltegian',
                          en: 'Concerts and special tastings in our cellar',
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _EventList(),

                  const SizedBox(height: AppSpacing.xxl),

                  // Footer Section
                  const _HomeFooter(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 460),
      decoration: BoxDecoration(
        color: AppColors.ink,
        border: const Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Stack(
        children: [
          // Background photo with dark contrast wash
          Positioned.fill(
            child: Image.asset(
              'assets/images/txotx_hero.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF2C1E14),
                child: const Center(
                  child: Icon(Icons.wine_bar, size: 80, color: AppColors.cider),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),

          // Over-image copy
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.md),
                // Eyebrow
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE28B45),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr(
                          es: 'SIDRERÍA · ARAMAIO',
                          eu: 'SAGARDOTEGIA · ARAMAIO',
                          en: 'CIDER HOUSE · ARAMAIO',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Brand Motto (Immutable)
                Text(
                  'Sagarretik txotxera',
                  style: GoogleFonts.fraunces(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFFDF8),
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Subtitle explaining open services
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    context.tr(
                      es: 'Temporada de sidra al txotx abierta en Aramaio. Menú tradicional con txotx ilimitado directo de kupela, chuletón a la brasa y bacalao. Abierto de jueves a domingo.',
                      eu: 'Txotx sagardo denboraldia zabalik Aramaion. Ohiko menua kupelatik zuzeneko txotx mugagabearekin, txuleta brasan eta bakailaoa. Ostegunetik igandera zabalik.',
                      en: 'Txotx cider season open in Aramaio. Traditional menu with unlimited barrel cider, charcoal-grilled ribeye steak, and cod. Open Thursday to Sunday.',
                    ),
                    style: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      height: 1.5,
                      color: const Color(0xFFF6F1E7),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // CTA Buttons
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.bottleGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.go('/book'),
                      icon: const Icon(Icons.table_restaurant, size: 20),
                      label: Text(
                        context.tr(
                          es: 'Reservar mesa',
                          eu: 'Mahaia erreserbatu',
                          en: 'Book a table',
                        ),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFFDF8),
                        side: const BorderSide(color: Color(0xFFFFFDF8), width: 1.5),
                        minimumSize: const Size(160, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.go('/manage/ITU-8924'),
                      icon: const Icon(Icons.confirmation_number_outlined, size: 20),
                      label: Text(
                        context.tr(
                          es: 'Gestionar reserva',
                          eu: 'Erreserba kudeatu',
                          en: 'Manage booking',
                        ),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsBar extends StatelessWidget {
  const _HighlightsBar();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 750;
        final isMedium = constraints.maxWidth > 420;
        final cardWidth = isWide
            ? (constraints.maxWidth - 36) / 4
            : (isMedium ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth);
        final items = [
          (
            Icons.local_dining,
            context.tr(es: 'Menú Adulto 45 €', eu: 'Helduen Menua 45 €', en: 'Adult Menu 45 €'),
            context.tr(
              es: 'Txotx ilimitado de kupela, bacalao, chuletón a la brasa e Idiazabal.',
              eu: 'Kupelako txotx mugagabea, bakailaoa, brasan egindako txuleta eta Idiazabal.',
              en: 'Unlimited barrel txotx cider, cod, charcoal-grilled ribeye & Idiazabal.',
            ),
            AppColors.bottleGreen,
          ),
          (
            Icons.child_care,
            context.tr(es: 'Menú Infantil 16 €', eu: 'Umeen Menua 16 €', en: 'Child Menu 16 €'),
            context.tr(
              es: 'Zumo natural prensado de manzana de nuestro caserío y menú adaptado.',
              eu: 'Gure baserriko sagar zuku naturala eta umeentzako menu egokitua.',
              en: 'Fresh pressed farm apple juice and child-friendly cider house menu.',
            ),
            AppColors.cider,
          ),
          (
            Icons.security,
            context.tr(es: 'Seña 10 € / pers.', eu: 'Seinalea 10 € / perts.', en: 'Deposit 10 € / pers.'),
            context.tr(
              es: 'Solo requerida a partir de 8 personas. Descontada de la cuenta final.',
              eu: '8 lagunetik gorako taldeetan bakarrik. Azken kontutik deskontatua.',
              en: 'Only required for 8+ guests. Deducted in full from final table bill.',
            ),
            AppColors.cider,
          ),
          (
            Icons.schedule,
            context.tr(es: 'Cancelación 48h', eu: '48h Ezeztapena', en: '48h Cancellation'),
            context.tr(
              es: 'Modificación o cancelación 100% gratuita hasta 48h antes del servicio.',
              eu: 'Doako aldaketa edo ezeztapena zerbitzua baino 48 ordu lehenago arte.',
              en: '100% free change or cancellation up to 48 hours before service.',
            ),
            AppColors.bottleGreen,
          ),
        ];

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.$1, size: 22, color: item.$4),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ShiftList extends ConsumerWidget {
  const _ShiftList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ready = ref.watch(supabaseReadyProvider);
    final shiftsAsync = ref.watch(shiftsProvider);

    // If Supabase provides shifts, display them; otherwise render the standard demo shift rows
    if (ready) {
      return shiftsAsync.when(
        loading: () => const LoadingState(label: 'Cargando turnos...'),
        error: (_, _) => _DemoShifts(l10n: l10n),
        data: (rows) {
          if (rows.isEmpty) return _DemoShifts(l10n: l10n);
          return Column(
            children: [
              for (final shift in rows) ...[
                _ShiftRow(
                  name: shift.name,
                  dayName: _weekday(l10n, shift.weekday),
                  hours: '${shift.startTime} – ${shift.endTime}',
                  maxCovers: shift.maxCovers,
                  isWaitlist: false,
                  statusText: '${shift.maxCovers} plazas totales',
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        },
      );
    }

    return _DemoShifts(l10n: l10n);
  }

  String _weekday(AppLocalizations l10n, int weekday) {
    return switch (weekday) {
      0 => l10n.weekdaySunday,
      1 => l10n.weekdayMonday,
      2 => l10n.weekdayTuesday,
      3 => l10n.weekdayWednesday,
      4 => l10n.weekdayThursday,
      5 => l10n.weekdayFriday,
      6 => l10n.weekdaySaturday,
      _ => '$weekday',
    };
  }
}

class _DemoShifts extends StatelessWidget {
  const _DemoShifts({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // 4 distinct weekly shifts as specified in Section 4 (Screen G1)
    final demoShifts = [
      (
        context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch'),
        context.tr(es: 'Jueves 29 Octubre 2026', eu: 'Osteguna 2026ko Urriak 29', en: 'Thursday 29 October 2026'),
        '13:00 – 16:00',
        context.tr(es: '24 plazas libres', eu: '24 leku libre', en: '24 seats left'),
        context.tr(es: 'Mesas libres', eu: 'Mahai libreak', en: 'Available tables'),
        AppColors.bottleGreen,
        AppColors.bottleGreenWash,
        false,
      ),
      (
        context.tr(es: 'Cena', eu: 'Afaria', en: 'Dinner'),
        context.tr(es: 'Jueves 29 Octubre 2026', eu: 'Osteguna 2026ko Urriak 29', en: 'Thursday 29 October 2026'),
        '20:00 – 23:00',
        context.tr(es: 'Completo', eu: 'Beterik', en: 'Fully booked'),
        context.tr(es: 'Lista de espera', eu: 'Itxaron-zerrenda', en: 'Waitlist'),
        AppColors.cider,
        AppColors.ciderWash,
        true,
      ),
      (
        context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch'),
        context.tr(es: 'Viernes 30 Octubre 2026', eu: 'Ostirala 2026ko Urriak 30', en: 'Friday 30 October 2026'),
        '13:00 – 16:00',
        context.tr(es: '18 plazas libres', eu: '18 leku libre', en: '18 seats left'),
        context.tr(es: 'Mesas libres', eu: 'Mahai libreak', en: 'Available tables'),
        AppColors.bottleGreen,
        AppColors.bottleGreenWash,
        false,
      ),
      (
        context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch'),
        context.tr(es: 'Sábado 31 Octubre 2026', eu: 'Larunbata 2026ko Urriak 31', en: 'Saturday 31 October 2026'),
        '13:00 – 16:00',
        context.tr(es: '6 plazas libres', eu: '6 leku libre', en: '6 seats left'),
        context.tr(es: 'Últimas plazas', eu: 'Azken lekuak', en: 'Last seats'),
        AppColors.cider,
        AppColors.ciderWash,
        false,
      ),
    ];

    final bookLabel = context.tr(es: 'Reservar', eu: 'Erreserbatu', en: 'Book');

    return Column(
      children: [
        for (final row in demoShifts) ...[
          AppCard(
            onTap: () => context.go('/book'),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 450;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: row.$7,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              row.$1 == context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch')
                                  ? Icons.wb_sunny_outlined
                                  : Icons.nights_stay_outlined,
                              color: row.$6,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  row.$2,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Text(
                                  '(${row.$1})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: row.$6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: row.$7,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: row.$6.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              row.$5,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: row.$6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${context.tr(es: "Horario", eu: "Ordutegia", en: "Hours")}: ${row.$3} · ${row.$4}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                bookLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.bottleGreen,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.bottleGreen),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: row.$7,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        row.$1 == context.tr(es: 'Comida', eu: 'Bazkaria', en: 'Lunch')
                            ? Icons.wb_sunny_outlined
                            : Icons.nights_stay_outlined,
                        color: row.$6,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                row.$2,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${row.$1})',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: row.$6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${context.tr(es: "Horario de servicio", eu: "Zerbitzu ordutegia", en: "Service hours")}: ${row.$3} · ${row.$4}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: row.$7,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: row.$6.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        row.$5,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: row.$6,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      tooltip: bookLabel,
                      onPressed: () => context.go('/book'),
                      icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.bottleGreen),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _ShiftRow extends StatelessWidget {
  const _ShiftRow({
    required this.name,
    required this.dayName,
    required this.hours,
    required this.maxCovers,
    required this.isWaitlist,
    required this.statusText,
  });

  final String name;
  final String dayName;
  final String hours;
  final int maxCovers;
  final bool isWaitlist;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final bookLabel = context.tr(es: 'Reservar', eu: 'Erreserbatu', en: 'Book');

    return AppCard(
      onTap: () => context.go('/book'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 450;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$dayName · $name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isWaitlist ? AppColors.ciderWash : AppColors.bottleGreenWash,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isWaitlist
                              ? AppColors.cider.withValues(alpha: 0.3)
                              : AppColors.bottleGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isWaitlist ? AppColors.cider : AppColors.bottleGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.tr(es: "Horario", eu: "Ordutegia", en: "Hours")}: $hours',
                      style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        minimumSize: const Size(36, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => context.go('/book'),
                      child: Text(bookLabel),
                    ),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$dayName · $name',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${context.tr(es: "Horario", eu: "Ordutegia", en: "Hours")}: $hours',
                      style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isWaitlist ? AppColors.ciderWash : AppColors.bottleGreenWash,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWaitlist
                        ? AppColors.cider.withValues(alpha: 0.3)
                        : AppColors.bottleGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isWaitlist ? AppColors.cider : AppColors.bottleGreen,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () => context.go('/book'),
                child: Text(bookLabel),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EventList extends ConsumerWidget {
  const _EventList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = Localizations.localeOf(context).languageCode;
    final ready = ref.watch(supabaseReadyProvider);
    final eventsAsync = ref.watch(publishedEventsProvider);

    if (ready) {
      return eventsAsync.when(
        loading: () => const LoadingState(label: 'Cargando agenda...'),
        error: (_, _) => _AcousticConcertCard(language: language),
        data: (rows) {
          if (rows.isEmpty) return _AcousticConcertCard(language: language);
          return Column(
            children: [
              for (final event in rows) ...[
                _AcousticConcertCard(
                  language: language,
                  customTitle: event.text(event.title, language),
                  customDescription: event.text(event.description, language),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      );
    }

    return _AcousticConcertCard(language: language);
  }
}

class _AcousticConcertCard extends StatelessWidget {
  const _AcousticConcertCard({
    required this.language,
    this.customTitle,
    this.customDescription,
  });

  final String language;
  final String? customTitle;
  final String? customDescription;

  @override
  Widget build(BuildContext context) {
    final title = customTitle ??
        (language == 'eu'
            ? 'Upeltegiko kontzertu akustikoa'
            : (language == 'en'
                ? 'Cellar Acoustic Concert Session'
                : 'Concierto acústico en bodega'));

    final description = customDescription ??
        (language == 'eu'
            ? 'Zuzeneko musika kupela zaharren artean. Sagardo berriaren dastaketa eta Aramaioko pintxo artisauak.'
            : (language == 'en'
                ? 'Live acoustic music among hundred-year-old oak cider barrels. New vintage cider tasting paired with local Aramaio pintxos.'
                : 'Música en directo entre kupelas centenarias. Degustación especial de sidra de nueva cosecha acompañada de pintxos artesanos de Aramaio.'));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.cider, width: 2), // 2px Cider border per spec
        boxShadow: [
          BoxShadow(
            color: AppColors.cider.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Concert image
          SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/concert.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF332014),
                    child: const Center(
                      child: Icon(Icons.music_note, size: 64, color: AppColors.cider),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cider,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      context.tr(
                        es: 'Aforo limitado',
                        eu: 'Edukiera mugatua',
                        en: 'Limited capacity',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: AppColors.cider),
                    const SizedBox(width: 6),
                    Text(
                      context.tr(
                        es: 'Sábado 31 Octubre 2026 · 19:30',
                        eu: 'Larunbata 2026ko Urriak 31 · 19:30',
                        en: 'Saturday 31 October 2026 · 19:30',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cider,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.fraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppButton(
                      label: context.tr(
                        es: 'Reservar para el concierto',
                        eu: 'Kontzerturako erreserbatu',
                        en: 'Book for the concert',
                      ),
                      onPressed: () => context.go('/book'),
                    ),
                    Text(
                      context.tr(
                        es: 'Incluido con menú de cena',
                        eu: 'Afariko menuarekin batera barne',
                        en: 'Included with dinner menu',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Iturrieta Sagardotegia',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bottleGreen,
                ),
              ),
              const Text('·', style: TextStyle(color: AppColors.line)),
              const Text(
                'Aramaio, Álava',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '"Sagarretik txotxera"',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 14,
              color: AppColors.cider,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr(
              es: 'Teléfono de reservas y grupos: +34 685 72 15 93 · Abierto de Jueves a Domingo',
              eu: 'Erreserba eta taldeen telefonoa: +34 685 72 15 93 · Ostegunetik Igandera zabalik',
              en: 'Bookings & group phone: +34 685 72 15 93 · Open Thursday to Sunday',
            ),
            style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
