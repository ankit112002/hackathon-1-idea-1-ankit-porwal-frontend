import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chosen language. Spanish until the visitor switches. Not persisted yet.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => const Locale('es');

  void setLocale(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
