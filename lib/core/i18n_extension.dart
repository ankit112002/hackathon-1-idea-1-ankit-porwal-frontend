import 'package:flutter/widgets.dart';

extension I18nExtension on BuildContext {
  /// English only. Spanish and Basque arguments are ignored.
  String tr({required String es, required String eu, required String en}) {
    if (en.isNotEmpty) return en;
    if (es.isNotEmpty) return es;
    return eu;
  }
}
