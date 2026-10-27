import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../theme/app_colors.dart';

class LocaleSwitcher extends ConsumerWidget {
  const LocaleSwitcher({super.key});

  static const _options = <(Locale, String, String, String)>[
    (Locale('es'), 'ES', 'Español', '🇪🇸'),
    (Locale('eu'), 'EU', 'Euskara', '🏴'),
    (Locale('en'), 'EN', 'English', '🇬🇧'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 520;

    final currentOption = _options.firstWhere(
      (opt) => opt.$1.languageCode == current.languageCode,
      orElse: () => _options.first,
    );

    if (isCompact) {
      return Semantics(
        label: l10n.languageLabel,
        button: true,
        child: Theme(
          data: Theme.of(context).copyWith(
            popupMenuTheme: PopupMenuThemeData(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.line),
              ),
              elevation: 4,
            ),
          ),
          child: PopupMenuButton<Locale>(
            tooltip: l10n.languageLabel,
            initialValue: current,
            onSelected: (locale) => ref.read(localeProvider.notifier).setLocale(locale),
            itemBuilder: (context) => [
              for (final option in _options)
                PopupMenuItem<Locale>(
                  value: option.$1,
                  child: Row(
                    children: [
                      Text(option.$4, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${option.$3} (${option.$2})',
                          style: TextStyle(
                            fontWeight: current.languageCode == option.$1.languageCode
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: current.languageCode == option.$1.languageCode
                                ? AppColors.bottleGreen
                                : AppColors.ink,
                          ),
                        ),
                      ),
                      if (current.languageCode == option.$1.languageCode)
                        const Icon(Icons.check, size: 18, color: AppColors.bottleGreen),
                    ],
                  ),
                ),
            ],
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, size: 18, color: AppColors.bottleGreen),
                  const SizedBox(width: 6),
                  Text(
                    currentOption.$2,
                    style: const TextStyle(
                      color: AppColors.bottleGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.inkMuted),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Wide screen layout: icon + segmented tabs
    return Semantics(
      label: l10n.languageLabel,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.language, size: 18, color: AppColors.bottleGreen),
            ),
            for (final option in _options) ...[
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => ref.read(localeProvider.notifier).setLocale(option.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: current.languageCode == option.$1.languageCode
                        ? AppColors.bottleGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    option.$2,
                    style: TextStyle(
                      color: current.languageCode == option.$1.languageCode
                          ? Colors.white
                          : AppColors.ink,
                      fontWeight: current.languageCode == option.$1.languageCode
                          ? FontWeight.w700
                          : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

