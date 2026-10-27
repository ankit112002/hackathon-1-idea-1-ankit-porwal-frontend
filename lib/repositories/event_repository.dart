import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/house_event.dart';
import 'supabase_guard.dart';

/// Published events for the public site, and the full list for managers.
class EventRepository {
  EventRepository(this._client);

  final SupabaseClient _client;

  Future<List<HouseEvent>> published() async {
    final rows = await _client
        .from('events')
        .select('id, title, description, event_date, image_url, published')
        .eq('published', true)
        .order('event_date');
    return rowList(rows).map(HouseEvent.fromMap).toList();
  }

  Future<List<HouseEvent>> all() async {
    final rows = await _client
        .from('events')
        .select('id, title, description, event_date, image_url, published')
        .order('event_date', ascending: false);
    return rowList(rows).map(HouseEvent.fromMap).toList();
  }

  Future<void> save({
    String? id,
    required Map<String, String> title,
    required Map<String, String> description,
    required DateTime? eventDate,
    required bool published,
  }) {
    return guardBooking(() async {
      final payload = {
        'title': title,
        'description': description,
        'event_date': eventDate?.toUtc().toIso8601String(),
        'published': published,
      };
      if (id == null) {
        await _client.from('events').insert(payload);
      } else {
        await _client.from('events').update(payload).eq('id', id);
      }
    });
  }
}
