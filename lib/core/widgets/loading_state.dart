import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(label),
          ],
        ),
      ),
    );
  }
}
