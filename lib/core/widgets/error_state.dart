import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.retryLabel,
    this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(label: retryLabel, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
