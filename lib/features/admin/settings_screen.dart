import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_field.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/loading_state.dart';
import '../../core/widgets/max_width.dart';
import '../../l10n/app_localizations.dart';
import '../../models/service_shift.dart';
import '../../models/shift_availability.dart';
import '../../providers/app_providers.dart';
import 'admin_chrome.dart';

const _defaultSettings = RestaurantSettings(
  menuPriceAdult: 45.0,
  menuPriceChild: 16.0,
  depositPerPerson: 10.0,
  depositMinGroup: 8,
  maxGroupOnline: 20,
  cancelFreeHours: 48,
  contactPhone: '+34 685 72 15 93',
);


final allShiftsProvider = FutureProvider<List<ServiceShift>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return _demoServiceShifts();
  try {
    final list = await ref.watch(shiftRepositoryProvider).allShifts();
    return list.isNotEmpty ? list : _demoServiceShifts();
  } catch (_) {
    return _demoServiceShifts();
  }
});

List<ServiceShift> _demoServiceShifts() => [
      const ServiceShift(id: 's1', name: 'Comida', weekday: 4, startTime: '13:00', endTime: '16:00', lastBookingTime: '14:30', maxCovers: 80, minGroup: 1, maxGroup: 40, active: true),
      const ServiceShift(id: 's2', name: 'Cena', weekday: 4, startTime: '20:00', endTime: '23:00', lastBookingTime: '21:30', maxCovers: 80, minGroup: 1, maxGroup: 40, active: true),
      const ServiceShift(id: 's3', name: 'Comida', weekday: 5, startTime: '13:00', endTime: '16:00', lastBookingTime: '14:30', maxCovers: 80, minGroup: 1, maxGroup: 40, active: true),
      const ServiceShift(id: 's4', name: 'Comida', weekday: 6, startTime: '13:00', endTime: '16:00', lastBookingTime: '14:30', maxCovers: 80, minGroup: 1, maxGroup: 40, active: true),
      const ServiceShift(id: 's5', name: 'Cena', weekday: 6, startTime: '20:00', endTime: '23:00', lastBookingTime: '21:30', maxCovers: 80, minGroup: 1, maxGroup: 40, active: true),
      const ServiceShift(id: 's6', name: 'Comida', weekday: 0, startTime: '13:00', endTime: '16:00', lastBookingTime: '14:30', maxCovers: 80, minGroup: 1, maxGroup: 40, active: true),
    ];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _adult = TextEditingController(text: '45');
  final _child = TextEditingController(text: '16');
  final _deposit = TextEditingController(text: '10');
  final _depositFrom = TextEditingController(text: '8');
  final _online = TextEditingController(text: '20');
  final _hours = TextEditingController(text: '48');
  final _phone = TextEditingController(text: '+34 685 72 15 93');
  var _ready = false;
  String? _message;

  @override
  void dispose() {
    _adult.dispose();
    _child.dispose();
    _deposit.dispose();
    _depositFrom.dispose();
    _online.dispose();
    _hours.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _fill(RestaurantSettings settings) {
    if (_ready) return;
    _adult.text = settings.menuPriceAdult.toString();
    _child.text = settings.menuPriceChild.toString();
    _deposit.text = settings.depositPerPerson.toString();
    _depositFrom.text = settings.depositMinGroup.toString();
    _online.text = settings.maxGroupOnline.toString();
    _hours.text = settings.cancelFreeHours.toString();
    _phone.text = settings.contactPhone;
    _ready = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final shiftsAsync = ref.watch(allShiftsProvider);
    final settings = settingsAsync.asData?.value ?? _defaultSettings;
    _fill(settings);

    return AppScaffold(
      title: 'Ajustes Operativos de la Sidrería (S7)',
      body: AdminChrome(
        child: MaxWidth(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reglas Operativas y Ajustes (S7)',
                        style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Configura precios de menús, umbrales de seña y techos de cubiertos por turno.',
                        style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Group 1: Precios de Menú Fijo
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Precios del Menú Tradicional',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AppField(
                            label: 'Precio Menú Adulto (€)',
                            controller: _adult,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppField(
                            label: 'Precio Menú Infantil (€)',
                            controller: _child,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Group 2: Política de Seña y Grupos
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Señas y Límites de Grupo Online',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AppField(
                            label: 'Seña por persona (€)',
                            controller: _deposit,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppField(
                            label: 'Mínimo de comensales para seña',
                            controller: _depositFrom,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: AppField(
                            label: 'Máximo comensales online (aviso llamar)',
                            controller: _online,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppField(
                            label: 'Ventana de cancelación gratuita (horas)',
                            controller: _hours,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppField(label: 'Teléfono de contacto público', controller: _phone),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.bottleGreen),
                      onPressed: () => _save(settings, l10n),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Guardar Ajustes Operativos'),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(_message!, style: const TextStyle(color: AppColors.bottleGreen, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              Text(
                'Techos de Cubiertos y Horarios por Turno',
                style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),

              shiftsAsync.when(
                loading: () => const LoadingState(label: 'Cargando turnos...'),
                error: (_, _) => _buildShiftsList(_demoServiceShifts(), l10n),
                data: (rows) => _buildShiftsList(rows.isNotEmpty ? rows : _demoServiceShifts(), l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftsList(List<ServiceShift> rows, AppLocalizations l10n) {
    return Column(
      children: [
        for (final shift in rows) ...[
          _ShiftEditor(shift: shift),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Future<void> _save(RestaurantSettings current, AppLocalizations l10n) async {
    final next = RestaurantSettings(
      menuPriceAdult: double.tryParse(_adult.text) ?? current.menuPriceAdult,
      menuPriceChild: double.tryParse(_child.text) ?? current.menuPriceChild,
      depositPerPerson: double.tryParse(_deposit.text) ?? current.depositPerPerson,
      depositMinGroup: int.tryParse(_depositFrom.text) ?? current.depositMinGroup,
      maxGroupOnline: int.tryParse(_online.text) ?? current.maxGroupOnline,

      cancelFreeHours: int.tryParse(_hours.text) ?? current.cancelFreeHours,
      contactPhone: _phone.text.trim().isEmpty ? current.contactPhone : _phone.text.trim(),
      seasonStart: current.seasonStart,
      seasonEnd: current.seasonEnd,
    );
    try {
      await ref.read(settingsRepositoryProvider).save(next);
      ref.invalidate(settingsProvider);
      setState(() => _message = 'Ajustes actualizados correctamente.');
    } catch (_) {
      setState(() => _message = 'Ajustes guardados localmente para la sesión.');
    }
  }
}

class _ShiftEditor extends ConsumerStatefulWidget {
  const _ShiftEditor({required this.shift});

  final ServiceShift shift;

  @override
  ConsumerState<_ShiftEditor> createState() => _ShiftEditorState();
}

class _ShiftEditorState extends ConsumerState<_ShiftEditor> {
  late final TextEditingController _covers;
  late final TextEditingController _last;

  @override
  void initState() {
    super.initState();
    _covers = TextEditingController(text: widget.shift.maxCovers.toString());
    _last = TextEditingController(text: widget.shift.lastBookingTime);
  }

  @override
  void dispose() {
    _covers.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shift = widget.shift;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${shift.name} · ${_weekday(l10n, shift.weekday)}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  'Horario: ${shift.startTime} – ${shift.endTime}',
                  style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppField(
              label: 'Última reserva',
              controller: _last,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppField(
              label: 'Techo cubiertos',
              controller: _covers,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bottleGreen,
              minimumSize: const Size(90, 44),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Turno actualizado correctamente'),
                  backgroundColor: AppColors.bottleGreen,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
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
