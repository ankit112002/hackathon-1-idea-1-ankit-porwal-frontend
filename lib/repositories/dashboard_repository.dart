import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';
import '../models/booking.dart';
import '../models/house_event.dart';
import 'supabase_guard.dart';

/// Owner numbers and the audit trail of settings changes.
class DashboardRepository {
  DashboardRepository(this._client);

  final SupabaseClient _client;

  Future<DashboardStats> stats(String date) {
    return guardBooking(() async {
      final data = await _client.rpc('dashboard_stats', params: {'p_date': date});
      if (data is Map) {
        return DashboardStats.fromMap(Map<String, dynamic>.from(data));
      }
      throw BookingFailure(BookingErrorCode.generic);
    });
  }

  Future<List<AuditEntry>> recentAudit() async {
    final rows = await _client
        .from('audit_log')
        .select('table_name, action, created_at')
        .order('created_at', ascending: false)
        .limit(20);
    return rowList(rows).map(AuditEntry.fromMap).toList();
  }
}
