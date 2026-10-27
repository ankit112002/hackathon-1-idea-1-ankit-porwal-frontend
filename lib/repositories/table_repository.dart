import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/floor_table.dart';
import 'supabase_guard.dart';

/// Floor plan positions. Staff can read. Admins can move and add tables.
class TableRepository {
  TableRepository(this._client);

  final SupabaseClient _client;

  Future<List<FloorTable>> list() async {
    final rows = await _client
        .from('floor_tables')
        .select('id, label, capacity, pos_x, pos_y, width, height, shape, active')
        .eq('active', true)
        .order('label');
    return rowList(rows).map(FloorTable.fromMap).toList();
  }

  Future<void> savePositions(List<FloorTable> tables) {
    return guardBooking(() async {
      for (final table in tables) {
        await _client
            .from('floor_tables')
            .update({'pos_x': table.posX, 'pos_y': table.posY})
            .eq('id', table.id);
      }
    });
  }

  Future<void> addTable(String label, int capacity) {
    return guardBooking(() async {
      await _client.from('floor_tables').insert({
        'label': label,
        'capacity': capacity,
        'pos_x': 24,
        'pos_y': 24,
        'width': 96,
        'height': 72,
        'shape': 'rect',
        'active': true,
      });
    });
  }
}
