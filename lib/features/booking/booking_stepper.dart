import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';

class BookingStepper extends StatelessWidget {
  const BookingStepper({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      (0, '1', l10n.stepDate),
      (1, '2', l10n.stepParty),
      (2, '3', l10n.stepDetails),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepItem(
              stepNumber: steps[i].$2,
              title: steps[i].$3,
              isActive: currentStep == steps[i].$1,
              isCompleted: currentStep > steps[i].$1,
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  color: currentStep > i
                      ? AppColors.bottleGreen
                      : AppColors.line,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  final String stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color circleBg;
    Color textColor;
    Border? border;

    if (isCompleted) {
      circleBg = AppColors.bottleGreen;
      textColor = Colors.white;
    } else if (isActive) {
      circleBg = AppColors.bottleGreen;
      textColor = Colors.white;
    } else {
      circleBg = AppColors.surface;
      textColor = AppColors.inkMuted;
      border = Border.all(color: AppColors.line, width: 1.5);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            border: border,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.bottleGreen.withValues(alpha: 0.25),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text(
                  stepNumber,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.bottleGreen : (isCompleted ? AppColors.ink : AppColors.inkMuted),
          ),
        ),
      ],
    );
  }
}
