import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/booking_slots.dart';
import '../../core/i18n_extension.dart';
import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../l10n/app_localizations.dart';
import '../../models/shift_availability.dart';

class PartyStep extends StatelessWidget {
  const PartyStep({
    super.key,
    required this.adults,
    required this.children,
    required this.notesController,
    required this.shift,
    required this.settings,
    required this.onAdults,
    required this.onChildren,
    required this.onNotes,
    required this.onContinue,
    required this.onBack,
    this.onCall,
  });

  final int adults;
  final int children;
  final TextEditingController notesController;
  final ShiftAvailability shift;
  final RestaurantSettings settings;
  final ValueChanged<int> onAdults;
  final ValueChanged<int> onChildren;
  final ValueChanged<String> onNotes;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final party = adults + children;
    final decision = partyDecision(
      party: party,
      minGroup: shift.minGroup,
      maxGroup: shift.maxGroup,
      onlineMax: settings.maxGroupOnline,
    );
    final total = adults * settings.menuPriceAdult + children * settings.menuPriceChild;
    final deposit = party >= settings.depositMinGroup
        ? party * settings.depositPerPerson
        : 0.0;
    final full = party > shift.remaining;
    final blocked = decision != PartyDecision.ok;
    final locale = Localizations.localeOf(context).toString();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Info
        Text(
          l10n.partyHeading,
          style: GoogleFonts.fraunces(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr(
            es: 'Elige el número de comensales para el servicio',
            eu: 'Hautatu zerbitzurako mahaikide kopurua',
            en: 'Choose the number of guests for this service',
          ),
          style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),

        // Quick Preset Party Chips
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _PresetChip(
              label: context.tr(es: '2 personas', eu: '2 lagun', en: '2 guests'),
              selected: adults == 2 && children == 0,
              onTap: () {
                onAdults(2);
                onChildren(0);
              },
            ),
            _PresetChip(
              label: context.tr(es: '4 personas', eu: '4 lagun', en: '4 guests'),
              selected: adults == 4 && children == 0,
              onTap: () {
                onAdults(4);
                onChildren(0);
              },
            ),
            _PresetChip(
              label: context.tr(
                es: '8 personas (con seña)',
                eu: '8 lagun (seinalearekin)',
                en: '8 guests (with deposit)',
              ),
              selected: adults == 8 && children == 0,
              onTap: () {
                onAdults(8);
                onChildren(0);
              },
            ),
            _PresetChip(
              label: context.tr(
                es: '12 adultos (Demo estándar)',
                eu: '12 heldu (Demo estandarra)',
                en: '12 adults (Standard demo)',
              ),
              highlight: true,
              selected: adults == 12 && children == 0,
              onTap: () {
                onAdults(12);
                onChildren(0);
                if (!notesController.text.contains('Alergia') && !notesController.text.contains('Allergy') && !notesController.text.contains('Alergi')) {
                  notesController.text = context.tr(
                    es: 'Alergia al gluten (1 celíaco)',
                    eu: 'Gluten alergia (zeliako 1)',
                    en: 'Gluten allergy (1 celiac)',
                  );
                  onNotes(notesController.text);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Counter Cards (Screen G3 Party Steppers)
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Column(
            children: [
              _Count(
                label: l10n.adults,
                subtitle: context.tr(
                  es: '45 € · Incluye sidra al txotx sin límite',
                  eu: '45 € · Kupelako sagardoa mugarik gabe',
                  en: '45 € · Unlimited barrel cider included',
                ),
                value: adults,
                onMinus: adults > 1 ? () => onAdults(adults - 1) : null,
                onPlus: () => onAdults(adults + 1),
              ),
              const Divider(color: AppColors.line, height: 28),
              _Count(
                label: l10n.children,
                subtitle: context.tr(
                  es: '16 € · Menores de 12 años · Zumo natural prensado',
                  eu: '16 € · 12 urtetik beherakoak · Sagar zuku naturala',
                  en: '16 € · Under 12 years · Fresh pressed apple juice',
                ),
                value: children,
                onMinus: children > 0 ? () => onChildren(children - 1) : null,
                onPlus: () => onChildren(children + 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Special Dietary Requirements Input & Tags
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notes,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const Key('notes-field'),
              controller: notesController,
              onChanged: onNotes,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: l10n.notesHint,
                helperText: context.tr(
                  es: 'Alergias, celiaquía, comensales vegetarianos o tronas para bebés',
                  eu: 'Alergiak, zeliakia, begetarianoak edo haurrentzako aulkiak',
                  en: 'Allergies, celiac, vegetarian guests or high chairs',
                ),
                helperStyle: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _TagChip(
                  label: context.tr(
                    es: '+ Alergia al gluten (1 celíaco)',
                    eu: '+ Gluten alergia (zeliako 1)',
                    en: '+ Gluten allergy (1 celiac)',
                  ),
                  onTap: () {
                    final curr = notesController.text.trim();
                    final add = context.tr(
                      es: 'Alergia al gluten (1 celíaco)',
                      eu: 'Gluten alergia (zeliako 1)',
                      en: 'Gluten allergy (1 celiac)',
                    );
                    notesController.text = curr.isEmpty ? add : '$curr, $add';
                    onNotes(notesController.text);
                  },
                ),
                _TagChip(
                  label: context.tr(
                    es: '+ Vegetariano (1)',
                    eu: '+ Begetarianoa (1)',
                    en: '+ Vegetarian menu (1)',
                  ),
                  onTap: () {
                    final curr = notesController.text.trim();
                    final add = context.tr(
                      es: '1 menú vegetariano',
                      eu: 'Menu begetariano 1',
                      en: '1 vegetarian menu',
                    );
                    notesController.text = curr.isEmpty ? add : '$curr, $add';
                    onNotes(notesController.text);
                  },
                ),
                _TagChip(
                  label: context.tr(
                    es: '+ Trona infantil',
                    eu: '+ Haurrentzako aulkia',
                    en: '+ High chair',
                  ),
                  onTap: () {
                    final curr = notesController.text.trim();
                    final add = context.tr(
                      es: '1 trona infantil',
                      eu: 'Haurrentzako aulki 1',
                      en: '1 high chair',
                    );
                    notesController.text = curr.isEmpty ? add : '$curr, $add';
                    onNotes(notesController.text);
                  },
                ),
                _TagChip(
                  label: context.tr(
                    es: '+ Sin frutos secos',
                    eu: '+ Fruitu lehorrik gabe',
                    en: '+ Nut-free',
                  ),
                  onTap: () {
                    final curr = notesController.text.trim();
                    final add = context.tr(
                      es: 'Sin frutos secos',
                      eu: 'Fruitu lehorrik gabe',
                      en: 'Nut-free',
                    );
                    notesController.text = curr.isEmpty ? add : '$curr, $add';
                    onNotes(notesController.text);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Menu Breakdown Card (Hero Visual per Screen G3 with 4px Cider Amber left border)
        AppCard(
          leftBorderColor: AppColors.cider,
          leftBorderWidth: 4,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.totalLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  Text(
                    formatEur(total, locale),
                    style: GoogleFonts.fraunces(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$party ${party == 1 ? context.tr(es: "persona", eu: "lagun", en: "guest") : context.tr(es: "personas", eu: "lagun", en: "guests")} ($adults ${context.tr(es: "adultos", eu: "heldu", en: "adults")} × 45 €${children > 0 ? " + $children ${context.tr(es: "niños", eu: "haur", en: "children")} × 16 €" : ""}) · ${l10n.includesCider}',
                style: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
              ),

              if (deposit > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.ciderWash,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cider.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppColors.cider),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${context.tr(es: "Seña requerida ahora", eu: "Orain eskatutako seinalea", en: "Deposit required now")}: ${formatEur(deposit, locale)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cider,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr(
                                es: '10 € / persona para grupos de 8 o más. Se descuenta íntegramente de la cuenta final en mesa.',
                                eu: '10 € / pertsonako 8 edo gehiagoko taldeentzat. Mahiko azken kontutik kenduko da.',
                                en: '10 € / person for groups of 8 or more. Deducted in full from final table bill.',
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Blocked warning / Call us banner (> 20 people)
        if (blocked) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.ciderWash,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.cider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_in_talk, color: AppColors.cider, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      decision == PartyDecision.callUs
                          ? context.tr(
                              es: 'Reserva especial para grupos grandes',
                              eu: 'Talde handientzako erreserba berezia',
                              en: 'Special booking for large groups',
                            )
                          : context.tr(
                              es: 'Aviso de grupo',
                              eu: 'Talde oharra',
                              en: 'Group notice',
                            ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.cider,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  decision == PartyDecision.callUs
                      ? l10n.callUsForGroup(settings.contactPhone)
                      : l10n.errorGroupRange(shift.minGroup, shift.maxGroup),
                  style: const TextStyle(fontSize: 15, color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],

        if (!blocked && full) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.ciderWash,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.cider),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top, color: AppColors.cider, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.waitlistPrompt,
                    style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Action Buttons
        if (decision == PartyDecision.callUs && onCall != null)
          AppButton(
            label: l10n.buttonCall,
            onPressed: onCall,
            kind: AppButtonKind.outlined,
          ),
        if (!blocked)
          AppButton(
            label: full
                ? l10n.joinWaitlist
                : (deposit > 0
                    ? context.tr(
                        es: 'Continuar con la seña (${formatEur(deposit, locale)}) →',
                        eu: 'Seinalearekin jarraitu (${formatEur(deposit, locale)}) →',
                        en: 'Continue to deposit (${formatEur(deposit, locale)}) →',
                      )
                    : context.tr(
                        es: 'Continuar a los datos de contacto →',
                        eu: 'Jarraitu harremanetarako datuetara →',
                        en: 'Continue to contact details →',
                      )),
            onPressed: onContinue,
          ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.buttonBack,
          onPressed: onBack,
          kind: AppButtonKind.outlined,
        ),
      ],
    ),
  );
}
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (highlight ? AppColors.cider : AppColors.bottleGreen)
              : (highlight ? AppColors.ciderWash : AppColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? (highlight ? AppColors.cider : AppColors.bottleGreen)
                : (highlight ? AppColors.cider.withValues(alpha: 0.5) : AppColors.line),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected
                ? Colors.white
                : (highlight ? AppColors.cider : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String subtitle;
  final int value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
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
        // 44px circular - button per Screen G3 specs
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onMinus,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onMinus != null ? AppColors.surface : AppColors.paper,
              border: Border.all(
                color: onMinus != null ? AppColors.bottleGreen : AppColors.line,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.remove,
              size: 20,
              color: onMinus != null ? AppColors.bottleGreen : AppColors.line,
            ),
          ),
        ),
        // Fraunces 40px center number per Screen G3 specs
        SizedBox(
          width: 64,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: GoogleFonts.fraunces(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ),
        // 44px circular + button per Screen G3 specs
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPlus,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bottleGreen,
              border: Border.all(color: AppColors.bottleGreen, width: 1.5),
            ),
            child: const Icon(Icons.add, size: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
