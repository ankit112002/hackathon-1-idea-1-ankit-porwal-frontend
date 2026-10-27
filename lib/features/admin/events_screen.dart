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
      title: 'Events',
      staffShell: true,
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
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 450;
            final titleWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Events',
                  style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Publish concerts and tastings on the home page.',
                  style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                ),
              ],
            );

            final button = FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bottleGreen,
                minimumSize: isNarrow ? const Size(double.infinity, 42) : null,
              ),
              onPressed: () => _edit(context, ref, null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.newEvent),
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
                        event.text(event.title, 'en'),
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
                        event.published ? 'Published' : 'Draft',
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
                const SizedBox(height: 8),
                Text(
                  event.text(event.description, 'en'),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(120, 38)),
                      onPressed: () => _edit(context, ref, event),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
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

  Future<void> _edit(BuildContext context, WidgetRef ref, HouseEvent? event) async {
    final title = TextEditingController(text: event?.text(event.title, 'en') ?? '');
    final description = TextEditingController(text: event?.text(event.description, 'en') ?? '');
    var published = event?.published ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: Text(
            event == null ? 'New event' : 'Edit event',
            style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppField(label: 'Title', controller: title),
                  const SizedBox(height: AppSpacing.sm),
                  AppField(label: 'Description', controller: description, maxLines: 3),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeTrackColor: AppColors.bottleGreen,
                    title: const Text('Show on the home page', style: TextStyle(fontWeight: FontWeight.w600)),
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
              child: const Text('Cancel', style: TextStyle(color: AppColors.inkMuted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save event'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    try {
      final text = {'en': title.text, 'es': title.text, 'eu': title.text};
      final body = {'en': description.text, 'es': description.text, 'eu': description.text};
      await ref.read(eventRepositoryProvider).save(
        id: event?.id,
        title: text,
        description: body,
        published: published,
        eventDate: event?.eventDate ?? DateTime(2026, 10, 31, 19, 30),
      );
      ref.invalidate(allEventsProvider);
    } catch (_) {}
  }
}
