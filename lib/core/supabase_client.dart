import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads Supabase settings from `--dart-define` / `--dart-define-from-file`.
class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasCredentials => url.isNotEmpty && anonKey.isNotEmpty;

  static bool _ready = false;
  static bool get isReady => _ready;

  static Future<void> initialize() async {
    if (!hasCredentials) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
        'Run with --dart-define-from-file=env.json.',
      );
    }
    await Supabase.initialize(url: url, publishableKey: anonKey);
    _ready = true;
  }
}

/// True after a successful [SupabaseConfig.initialize]. Override in `main`.
final supabaseReadyProvider = Provider<bool>((ref) => false);

/// Init failure text, when credentials were present but startup failed.
final startupErrorProvider = Provider<String?>((ref) => null);
