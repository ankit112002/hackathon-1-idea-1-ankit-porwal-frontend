import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/shift_availability.dart';
import 'supabase_guard.dart';

/// The single `settings` row: prices, deposit, limits, and the public phone.
class SettingsRepository {
  SettingsRepository(this._client);

  final SupabaseClient _client;

  Future<RestaurantSettings> load() async {
    final row = await _client.from('settings').select().eq('id', 1).single();
    return RestaurantSettings.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> save(RestaurantSettings settings) {
    return guardBooking(() async {
      await _client
          .from('settings')
          .update({
            'menu_price_adult': settings.menuPriceAdult,
            'menu_price_child': settings.menuPriceChild,
            'deposit_per_person': settings.depositPerPerson,
            'deposit_min_group': settings.depositMinGroup,
            'max_group_online': settings.maxGroupOnline,
            'cancel_free_hours': settings.cancelFreeHours,
            'contact_phone': settings.contactPhone,
          })
          .eq('id', 1);
    });
  }
}
