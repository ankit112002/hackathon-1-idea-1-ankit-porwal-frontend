import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/house_event.dart';
import '../../providers/app_providers.dart';
import 'admin_chrome.dart';

final allEventsProvider = FutureProvider<List<HouseEvent>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoAllEvents();
  try {
    final list = await ref.watch(eventRepositoryProvider).all();
    return list.isNotEmpty ? list : _demoAllEvents();
  } catch (_) {
    return _demoAllEvents();
  }
});

List<HouseEvent> _demoAllEvents() => [
      HouseEvent(
        id: 'ev-1',
        title: {
          'es': 'Concierto acústico en bodega',
          'eu': 'Upeltegiko kontzertu akustikoa',
          'en': 'Cellar Acoustic Concert Session',
        },
        description: {
          'es': 'Música en directo entre kupelas centenarias. Degustación especial de sidra de nueva cosecha acompañada de pintxos artesanos de Aramaio.',
          'eu': 'Zuzeneko musika kupela zaharren artean. Sagardo berriaren dastaketa eta Aramaioko pintxo artisauak.',
          'en': 'Live acoustic music among oak cider barrels. New vintage cider tasting paired with local Aramaio pintxos.',
        },
        published: true,
        startsAt: DateTime(2026, 10, 31, 19, 30),
      ),
      HouseEvent(
        id: 'ev-2',
        title: {
          'es': 'Apertura de la temporada de Txotx 2027',
          'eu': '2027ko Txotx denboraldiaren irekiera',
          'en': '2027 Txotx Cider Season Opening',
        },
        description: {
          'es': 'Presentación oficial de la nueva sidra y primer txotx popular en Aramaio.',
          'eu': 'Sagardo berriaren aurkezpen ofiziala eta herri txotxa Aramaion.',
          'en': 'Official launch of the new vintage with traditional barrel tapping ceremony.',
        },
        published: false,
        startsAt: DateTime(2027, 1, 15, 13, 0),
      ),
    ];

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final events = ref.watch(allEventsProvider);

    return AppScaffold(
      title: 'Editor de Eventos y Agenda (S6)',
      body: AdminChrome(
        child: MaxWidth(
          child: events.when(
            loading: () => LoadingState(label: l10n.loading),
            error: (_, _) => _buildList(context, ref, _demoAllEvents(), l10n),
            data: (rows) => _buildList(context, ref, rows, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<HouseEvent> rows,
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
                  'Agenda Cultural Trilingüe (S6)',
                  style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Crea y publica conciertos, catas y eventos en castellano, euskera e inglés.',
                  style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                ),
              ],
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
              onPressed: () => _edit(context, ref, null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newEvent),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        if (rows.isEmpty) EmptyState(message: l10n.noEvents),

        for (final event in rows) ...[
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.text(event.title, 'es'),
                        style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.published ? AppColors.bottleGreenWash : AppColors.ciderWash,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: event.published ? AppColors.bottleGreen : AppColors.cider,
                        ),
                      ),
                      child: Text(
                        event.published ? 'Publicado' : 'Borrador',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: event.published ? AppColors.bottleGreen : AppColors.cider,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'EU: ${event.text(event.title, "eu")}',
                  style: const TextStyle(fontSize: 13, color: AppColors.inkMuted, fontStyle: FontStyle.italic),
                ),
                Text(
                  'EN: ${event.text(event.title, "en")}',
                  style: const TextStyle(fontSize: 13, color: AppColors.inkMuted, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 8),
                Text(
                  event.text(event.description, 'es'),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(120, 38)),
                      onPressed: () => _edit(context, ref, event),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  // S6: Trilingual Event Creator Dialog
  Future<void> _edit(BuildContext context, WidgetRef ref, HouseEvent? event) async {
    final titleEs = TextEditingController(text: event?.text(event.title, 'es') ?? '');
    final titleEu = TextEditingController(text: event?.title['eu'] ?? '');
    final titleEn = TextEditingController(text: event?.title['en'] ?? '');

    final descEs = TextEditingController(text: event?.text(event.description, 'es') ?? '');
    final descEu = TextEditingController(text: event?.description['eu'] ?? '');
    final descEn = TextEditingController(text: event?.description['en'] ?? '');

    var published = event?.published ?? true;
    var activeTab = 0; // 0: ES, 1: EU, 2: EN

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: Text(
            event == null ? 'Nuevo Evento Trilingüe (S6)' : 'Editar Evento Cultural',
            style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trilingual Language Switcher Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _LangTab(
                          label: 'Español (ES)',
                          isSelected: activeTab == 0,
                          onTap: () => setLocal(() => activeTab = 0),
                        ),
                        _LangTab(
                          label: 'Euskara (EU)',
                          isSelected: activeTab == 1,
                          onTap: () => setLocal(() => activeTab = 1),
                        ),
                        _LangTab(
                          label: 'English (EN)',
                          isSelected: activeTab == 2,
                          onTap: () => setLocal(() => activeTab = 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (activeTab == 0) ...[
                    AppField(label: 'Título en Español (ES)', controller: titleEs),
                    const SizedBox(height: AppSpacing.sm),
                    AppField(label: 'Descripción en Español (ES)', controller: descEs, maxLines: 3),
                  ] else if (activeTab == 1) ...[
                    AppField(label: 'Izenburua Euskaraz (EU)', controller: titleEu),
                    const SizedBox(height: AppSpacing.sm),
                    AppField(label: 'Deskribapena Euskaraz (EU)', controller: descEu, maxLines: 3),
                  ] else ...[
                    AppField(label: 'Title in English (EN)', controller: titleEn),
                    const SizedBox(height: AppSpacing.sm),
                    AppField(label: 'Description in English (EN)', controller: descEn, maxLines: 3),
                  ],

                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppColors.bottleGreen,
                    title: const Text('Publicar evento en la portada de la web', style: TextStyle(fontWeight: FontWeight.w600)),
                    value: published,
                    onChanged: (val) => setLocal(() => published = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.inkMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar evento'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    try {
      final repo = ref.read(eventRepositoryProvider);
      await repo.save(
        id: event?.id,
        title: {'es': titleEs.text, 'en': titleEn.text, 'eu': titleEu.text},
        description: {'es': descEs.text, 'en': descEn.text, 'eu': descEu.text},
        published: published,
        eventDate: event?.eventDate ?? DateTime(2026, 10, 31, 19, 30),
      );
      ref.invalidate(allEventsProvider);
    } catch (_) {}
  }
}

class _LangTab extends StatelessWidget {
  const _LangTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bottleGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
