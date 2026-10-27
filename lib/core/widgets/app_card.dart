import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor,
    this.leftBorderColor,
    this.leftBorderWidth = 4.0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? leftBorderColor;
  final double leftBorderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = leftBorderColor;
    Widget inner = Padding(padding: padding, child: child);
    if (accent != null) {
      inner = DecoratedBox(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accent, width: leftBorderWidth)),
        ),
        child: inner,
      );
    }

    Widget box = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: borderColor ?? AppColors.line, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: inner,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onTap,
          child: box,
        ),
      );
    }
    return box;
  }
}

