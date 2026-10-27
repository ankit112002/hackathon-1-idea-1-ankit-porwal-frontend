import 'package:flutter/material.dart';

import '../breakpoints.dart';

/// Centers page content and caps it at 1100 px.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: Breakpoints.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
