import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/madrid_time.dart';
import '../models/house_event.dart';
import '../models/service_shift.dart';
import 'supabase_guard.dart';

/// Shifts, closed days, and the warning list of bookings already on a day.
class ShiftRepository {
  ShiftRepository(this._client);

  final SupabaseClient _client;

  Future<List<ServiceShift>> activeShifts() async {
    final rows = await _client
        .from('service_shifts')
        .select(
          'id, name, weekday, start_time, end_time, last_booking_time, max_covers, min_group, max_group, active',
        )
        .eq('active', true)
        .order('weekday');
    return rowList(rows).map(ServiceShift.fromMap).toList();
  }

  Future<List<ServiceShift>> allShifts() async {
    final rows = await _client
        .from('service_shifts')
        .select(
          'id, name, weekday, start_time, end_time, last_booking_time, max_covers, min_group, max_group, active',
        )
        .order('weekday');
    return rowList(rows).map(ServiceShift.fromMap).toList();
  }

  Future<void> updateShift(ServiceShift shift) {
    return guardBooking(() async {
      await _client
          .from('service_shifts')
          .update({
            'name': shift.name,
            'weekday': shift.weekday,
            'start_time': clockParam(shift.startTime),
            'end_time': clockParam(shift.endTime),
            'last_booking_time': clockParam(shift.lastBookingTime),
            'max_covers': shift.maxCovers,
            'min_group': shift.minGroup,
            'max_group': shift.maxGroup,
            'active': shift.active,
          })
          .eq('id', shift.id);
    });
  }

  Future<List<ClosedDay>> closedDays() async {
    final rows = await _client.from('closed_days').select('day, reason').order('day');
    return rowList(rows).map(ClosedDay.fromMap).toList();
  }

  Future<void> addClosedDay(DateTime day, String reason) {
    return guardBooking(() async {
      await _client.from('closed_days').insert({
        'day': madridDateString(day),
        'reason': reason,
      });
    });
  }

  Future<void> removeClosedDay(DateTime day) {
    return guardBooking(() async {
      await _client.from('closed_days').delete().eq('day', madridDateString(day));
    });
  }

  /// Names of parties already booked, so the owner can see who a change affects.
  Future<List<String>> affectedNames({String? date, String? shiftId}) async {
    var query = _client
        .from('bookings')
        .select('customers(name)')
        .inFilter('status', ['pending', 'confirmed', 'seated']);
    if (date != null) query = query.eq('booking_date', date);
    if (shiftId != null) query = query.eq('shift_id', shiftId);
    final rows = await query;
    return rowList(rows).map((row) {
      final customer = row['customers'];
      if (customer is Map) return customer['name']?.toString() ?? '';
      return '';
    }).where((name) => name.isNotEmpty).toList();
  }
}
