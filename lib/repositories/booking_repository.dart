import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';
import '../core/madrid_time.dart';
import '../core/money.dart';
import '../models/booking.dart';
import '../models/shift_availability.dart';
import 'supabase_guard.dart';

/// Bookings, availability, the manage link, and the live service list.
class BookingRepository {
  BookingRepository(this._client);

  final SupabaseClient _client;

  Future<List<ShiftAvailability>> availability(DateTime date) {
    return guardBooking(() async {
      final rows = await _client.rpc(
        'get_availability',
        params: {'p_date': madridDateString(date)},
      );
      return rowList(rows).map(ShiftAvailability.fromMap).toList();
    });
  }

  Future<BookingResult> create({
    required String name,
    required String phone,
    required String email,
    required String language,
    required String shiftId,
    required DateTime date,
    required String time,
    required int adults,
    required int children,
    required String notes,
    required String channel,
  }) {
    return guardBooking(() async {
      final data = await _client.rpc(
        'create_public_booking',
        params: {
          'p_name': name,
          'p_phone': phone,
          'p_email': email,
          'p_lang': language,
          'p_shift': shiftId,
          'p_date': madridDateString(date),
          'p_time': clockParam(time),
          'p_adults': adults,
          'p_children': children,
          'p_notes': notes,
          'p_channel': channel,
        },
      );
      return BookingResult.fromMap(firstRow(data));
    });
  }

  Future<ManagedBooking?> byToken(String token) {
    return guardBooking(() async {
      final data = await _client.rpc(
        'get_booking_by_token',
        params: {'p_token': token},
      );
      final rows = rowList(data);
      if (rows.isEmpty) return null;
      return ManagedBooking.fromMap(rows.first);
    });
  }

  Future<void> cancelByToken(String token) {
    return guardBooking(() async {
      await _client.rpc('cancel_booking_by_token', params: {'p_token': token});
    });
  }

  Future<BookingResult> reschedule({
    required String token,
    required String shiftId,
    required DateTime date,
    required String time,
  }) {
    return guardBooking(() async {
      final data = await _client.rpc(
        'reschedule_booking_by_token',
        params: {
          'p_token': token,
          'p_shift': shiftId,
          'p_date': madridDateString(date),
          'p_time': clockParam(time),
        },
      );
      return BookingResult.fromMap(firstRow(data));
    });
  }

  Future<void> joinWaitlist({
    required String name,
    required String phone,
    required String email,
    required String language,
    required String shiftId,
    required DateTime date,
    required int party,
  }) {
    return guardBooking(() async {
      await _client.rpc(
        'join_waitlist',
        params: {
          'p_name': name,
          'p_phone': phone,
          'p_email': email,
          'p_lang': language,
          'p_shift': shiftId,
          'p_date': madridDateString(date),
          'p_party': party,
        },
      );
    });
  }

  Future<List<LiveBooking>> liveOn(String date) async {
    final rows = await _client
        .from('bookings')
        .select(
          'id, booking_time, adults, children, party_size, status, channel, notes, deposit_amount, payment, customers(name, phone), booking_tables(table_id, floor_tables(label))',
        )
        .eq('booking_date', date)
        .order('booking_time');
    return rowList(rows).map(_live).toList();
  }

  Future<void> setStatus(String id, String status) {
    return guardBooking(() async {
      await _client.from('bookings').update({'status': status}).eq('id', id);
    });
  }

  Future<void> markNoShow(String id) {
    return guardBooking(() async {
      await _client.rpc('mark_no_show', params: {'p_booking': id});
    });
  }

  Future<void> assignTable(String bookingId, String tableId) {
    return guardBooking(() async {
      await _client.from('booking_tables').insert({
        'booking_id': bookingId,
        'table_id': tableId,
      });
    });
  }

  Future<void> unassignTable(String bookingId, String tableId) {
    return guardBooking(() async {
      await _client
          .from('booking_tables')
          .delete()
          .eq('booking_id', bookingId)
          .eq('table_id', tableId);
    });
  }

  /// Listens for today's rows. Returns a cancel function.
  void Function() watchDate(String date, void Function() onChange) {
    final channel = _client.channel('service-$date');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_date',
            value: date,
          ),
          callback: (_) => onChange(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'booking_tables',
          callback: (_) => onChange(),
        )
        .subscribe();
    return () => _client.removeChannel(channel);
  }

  Future<String?> checkoutUrl({
    required String token,
    required String successUrl,
    required String cancelUrl,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'stripe_checkout',
        body: {
          'manage_token': token,
          'success_url': successUrl,
          'cancel_url': cancelUrl,
        },
      );
      final data = response.data;
      if (data is Map && data['url'] is String) return data['url'] as String;
      throw BookingFailure(BookingErrorCode.generic);
    } on FunctionException catch (error) {
      final details = error.details?.toString() ?? '';
      if (details.contains('STRIPE_NOT_CONFIGURED')) {
        throw BookingFailure(BookingErrorCode.paymentNotConfigured);
      }
      throw BookingFailure(BookingErrorCode.generic);
    }
  }

  LiveBooking _live(Map<String, dynamic> row) {
    final customer = row['customers'];
    final links = row['booking_tables'];
    final labels = <String>[];
    final ids = <String>[];
    if (links is List) {
      for (final link in links) {
        if (link is Map) {
          final id = link['table_id']?.toString();
          if (id != null && id.isNotEmpty) ids.add(id);
          final table = link['floor_tables'];
          if (table is Map && table['label'] != null) {
            labels.add(table['label'].toString());
          }
        }
      }
    }
    return LiveBooking(
      id: row['id']?.toString() ?? '',
      customerName: customer is Map ? customer['name']?.toString() ?? '' : '',
      phone: customer is Map ? customer['phone']?.toString() ?? '' : '',
      time: clockLabel(row['booking_time']),
      adults: (row['adults'] as num?)?.toInt() ?? 0,
      children: (row['children'] as num?)?.toInt() ?? 0,
      partySize: (row['party_size'] as num?)?.toInt() ?? 0,
      status: row['status']?.toString() ?? '',
      channel: row['channel']?.toString() ?? '',
      notes: row['notes'] as String? ?? '',
      depositAmount: asMoney(row['deposit_amount']),
      payment: row['payment']?.toString() ?? 'none',
      tableLabels: labels,
      tableIds: ids,
    );
  }
}
