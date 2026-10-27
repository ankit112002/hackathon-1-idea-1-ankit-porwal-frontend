import 'package:flutter/widgets.dart';

extension I18nExtension on BuildContext {
  /// Returns the localized string matching the active locale (ES / EU / EN).
  String tr({required String es, required String eu, required String en}) {
    final code = Localizations.localeOf(this).languageCode.toLowerCase();
    if (code == 'eu') return eu;
    if (code == 'en') return en;
    return es;
  }

  String get langCode => Localizations.localeOf(this).languageCode.toLowerCase();
}
