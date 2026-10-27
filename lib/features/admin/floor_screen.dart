import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_state.dart';
import '../../l10n/app_localizations.dart';
import '../../models/floor_table.dart';
import '../../providers/app_providers.dart';
import 'admin_chrome.dart';
import 'waiter_screen.dart';

class FloorScreen extends ConsumerStatefulWidget {
  const FloorScreen({super.key});

  @override
  ConsumerState<FloorScreen> createState() => _FloorScreenState();
}

class _FloorScreenState extends ConsumerState<FloorScreen> {
  List<FloorTable>? _tables;
  String? _message;
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remote = ref.watch(floorTablesProvider);

    return AppScaffold(
      title: 'Floor plan',
      staffShell: true,
      body: AdminChrome(
        child: remote.when(
          loading: () => LoadingState(label: l10n.loading),
          error: (_, _) => _buildCanvas(context, demoFloorTables(), l10n),
          data: (rows) {
            _tables ??= rows.isNotEmpty ? rows.map((row) => row).toList() : demoFloorTables();
            return _buildCanvas(context, _tables!, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildCanvas(BuildContext context, List<FloorTable> tables, AppLocalizations l10n) {
    return Column(
      children: [
        // Controls Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          color: AppColors.surface,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dining room',
                    style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Text(
                    'Drag tables to rearrange the room. Save when you are done.',
                    style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                  ),
                ],
              );

              final buttons = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: _add,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addTable),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.save, size: 16),
                    label: Text(_busy ? l10n.sending : l10n.saveFloor),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: AppSpacing.sm),
                    buttons,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: AppSpacing.sm),
                  buttons,
                ],
              );
            },
          ),
        ),
        if (_message != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: AppColors.bottleGreenWash,
            child: Text(_message!, style: const TextStyle(color: AppColors.bottleGreen, fontWeight: FontWeight.w600)),
          ),

        // Interactive Canvas with Kupela Barrels Wall & Txotx walkway
        Expanded(
          child: InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(AppSpacing.xxl),
            minScale: 0.6,
            maxScale: 2.0,
            child: Container(
              width: 900,
              height: 600,
              decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border.all(color: AppColors.line, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Architectural Elements: Kupela Cider Barrels Wall at the Top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8DECB),
                        border: const Border(bottom: BorderSide(color: AppColors.line, width: 2)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cider,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.wine_bar, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'CIDER HALL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Visual representation of 6 cider barrels
                          for (var b = 1; b <= 6; b++) ...[
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5A2B),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF5C3A1E)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.water_drop, size: 12, color: Color(0xFFF3C07B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Barrel $b',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Txotx Walkway Guide line
                  Positioned(
                    top: 85,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '— MAIN AISLE TO THE CIDER HALL —',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Draggable Tables T1-T6 and B1-B2
                  for (var i = 0; i < tables.length; i++)
                    Positioned(
                      left: tables[i].posX,
                      top: tables[i].posY,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            final current = tables[i];
                            tables[i] = current.copyWith(
                              posX: (current.posX + details.delta.dx).clamp(10, 780),
                              posY: (current.posY + details.delta.dy).clamp(90, 520),
                            );
                          });
                        },
                        child: _TableItem(table: tables[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final tables = _tables;
    if (tables == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(tableRepositoryProvider).savePositions(tables);
      ref.invalidate(floorTablesProvider);
      setState(() => _message = 'Floor plan saved.');
    } catch (_) {
      setState(() => _message = 'Floor plan updated on this device.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    final label = TextEditingController(text: 'T${(_tables?.length ?? 6) + 1}');
    final seats = TextEditingController(text: '6');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text(l10n.addTable, style: GoogleFonts.fraunces(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppField(label: l10n.tableLabel, controller: label),
            const SizedBox(height: AppSpacing.sm),
            AppField(label: l10n.capacity, controller: seats, keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.buttonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final newTable = FloorTable(
      id: 'table-${DateTime.now().millisecondsSinceEpoch}',
      label: label.text.trim().isEmpty ? 'T' : label.text.trim(),
      capacity: int.tryParse(seats.text) ?? 4,
      shape: 'rect',
      posX: 100,
      posY: 180,
      width: 100,
      height: 60,
      active: true,
    );
    setState(() {
      _tables?.add(newTable);
    });
  }
}

class _TableItem extends StatelessWidget {
  const _TableItem({required this.table});

  final FloorTable table;

  @override
  Widget build(BuildContext context) {
    final isBench = table.label.startsWith('B');
    final width = table.width < 50 ? (isBench ? 180.0 : 100.0) : table.width;
    final height = table.height < 44 ? 60.0 : table.height;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isBench ? const Color(0xFFF9EFE4) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isBench ? AppColors.cider : AppColors.bottleGreen,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBench ? Icons.table_restaurant : Icons.crop_din,
                size: 14,
                color: isBench ? AppColors.cider : AppColors.bottleGreen,
              ),
              const SizedBox(width: 4),
              Text(
                table.label,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${table.capacity} pax',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isBench ? AppColors.cider : AppColors.bottleGreen,
            ),
          ),
        ],
      ),
    );
  }
}
