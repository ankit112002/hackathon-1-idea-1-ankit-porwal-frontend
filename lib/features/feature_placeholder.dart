import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/max_width.dart';
import '../l10n/app_localizations.dart';

class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: title,
      body: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: EmptyState(message: l10n.comingLater),
        ),
      ),
    );
  }
}
