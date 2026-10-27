import 'package:flutter/material.dart';

enum AppButtonKind { filled, outlined, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.filled,
    this.icon,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final Widget? icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    Widget button;
    if (kind == AppButtonKind.danger) {
      button = FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF8C2F2F),
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
        ),
        onPressed: onPressed,
        child: _content(),
      );
    } else if (kind == AppButtonKind.outlined) {
      button = OutlinedButton(
        onPressed: onPressed,
        child: _content(),
      );
    } else {
      button = FilledButton(
        onPressed: onPressed,
        child: _content(),
      );
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  Widget _content() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon!,
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

