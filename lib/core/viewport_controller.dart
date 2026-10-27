import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewportMode {
  responsive, // Default desktop / native window width (up to 1120px container)
  mobile390,  // Mobile-first 390px simulated ratio
}

class ViewportNotifier extends Notifier<ViewportMode> {
  @override
  ViewportMode build() => ViewportMode.responsive;

  void toggle() {
    state = state == ViewportMode.responsive
        ? ViewportMode.mobile390
        : ViewportMode.responsive;
  }

  void setMode(ViewportMode mode) => state = mode;
}

final viewportModeProvider =
    NotifierProvider<ViewportNotifier, ViewportMode>(ViewportNotifier.new);
