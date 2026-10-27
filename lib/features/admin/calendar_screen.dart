import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/madrid_time.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
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

final closedDaysProvider = FutureProvider<List<ClosedDay>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoClosedDays();
  try {
    final list = await ref.watch(shiftRepositoryProvider).closedDays();
    return list.isNotEmpty ? list : _demoClosedDays();
  } catch (_) {
    return _demoClosedDays();
  }
});

List<ClosedDay> _demoClosedDays() => [
      ClosedDay(day: DateTime(2026, 12, 24), reason: 'Christmas Eve — closed for a family day'),
      ClosedDay(day: DateTime(2026, 12, 25), reason: 'Christmas Day — staff day off'),
      ClosedDay(day: DateTime(2026, 12, 31), reason: 'New Year\'s Eve — season prep'),
    ];

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _day = DateTime(2026, 10, 29);
  final _reason = TextEditingController(text: 'Barrel maintenance');
  String? _message;
  var _messageIsError = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = ref.watch(closedDaysProvider);

    return AppScaffold(
      title: 'Calendar',
      staffShell: true,
      body: AdminChrome(
        child: MaxWidth(
          child: days.when(
            loading: () => LoadingState(label: l10n.loading),
            error: (_, _) => _buildBody(context, _demoClosedDays(), l10n),
            data: (rows) => _buildBody(context, rows, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<ClosedDay> rows, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Closed days',
              style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            const Text(
              'Close a day when the house is not serving. Existing bookings are listed first.',
              style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Block day form
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Close a day',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Selected date: ${madridDateString(_day)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Tap to change the date'),
                trailing: const Icon(Icons.calendar_today, color: AppColors.bottleGreen),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _day,
                    firstDate: DateTime(2026, 1, 1),
                    lastDate: DateTime(2027, 12, 31),
                  );
                  if (picked != null) setState(() => _day = picked);
                },
              ),
              AppField(
                label: 'Reason',
                controller: _reason,
                hintText: 'For example, annual maintenance or a staff day off',
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Close this day',
                onPressed: () => _add(l10n),
              ),
              if (_message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _messageIsError ? AppColors.danger : AppColors.bottleGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Text(
          'Closed days',
          style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),

        if (rows.isEmpty) EmptyState(message: l10n.emptyClosed),

        for (final row in rows)
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.event_busy, color: AppColors.cider, size: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        madridDateString(row.day),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(row.reason, style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Reopen day',
                  onPressed: () async {
                    try {
                      await ref.read(shiftRepositoryProvider).removeClosedDay(row.day);
                      ref.invalidate(closedDaysProvider);
                      setState(() {
                        _message = 'Day reopened for bookings.';
                        _messageIsError = false;
                      });
                    } catch (_) {
                      setState(() {
                        _message = l10n.errorGeneric;
                        _messageIsError = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // S5 Specification: High-risk modal protection ("Hay 6 reservas en este día")
  Future<void> _add(AppLocalizations l10n) async {
    // Check if there are active bookings on that day
    List<String> names = [];
    try {
      names = await ref.read(shiftRepositoryProvider).affectedNames(
            date: madridDateString(_day),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = l10n.errorGeneric;
        _messageIsError = true;
      });
      return;
    }

    if (!mounted) return;

    if (names.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          title: Row(
            children: [
              const Icon(Icons.warning, color: AppColors.danger, size: 28),
              const SizedBox(width: 8),
              Text(
                'Bookings already exist',
                style: GoogleFonts.fraunces(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.dangerWash,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'There are ${names.length} bookings on this day.',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Guests already booked:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              for (final name in names)
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Text('• $name', style: const TextStyle(fontSize: 13, color: AppColors.ink)),
                ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Closing this day cancels those bookings. Confirm anyway?',
                style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep the day open', style: TextStyle(color: AppColors.ink)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Close anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    try {
      await ref.read(shiftRepositoryProvider).addClosedDay(_day, _reason.text.trim());
      ref.invalidate(closedDaysProvider);
      setState(() {
        _message = '${madridDateString(_day)} is now closed.';
        _messageIsError = false;
      });
    } catch (_) {
      setState(() {
        _message = l10n.errorGeneric;
        _messageIsError = true;
      });
    }
  }
}
