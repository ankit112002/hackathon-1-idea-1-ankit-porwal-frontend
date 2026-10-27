import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/configure_url.dart';
import 'core/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureUrlStrategy();

  var ready = false;
  String? startupError;
  if (SupabaseConfig.hasCredentials) {
    try {
      await SupabaseConfig.initialize();
      ready = true;
    } catch (error) {
      startupError = error.toString();
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        supabaseReadyProvider.overrideWithValue(ready),
        startupErrorProvider.overrideWithValue(startupError),
      ],
      child: const IturrietaApp(),
    ),
  );
}
