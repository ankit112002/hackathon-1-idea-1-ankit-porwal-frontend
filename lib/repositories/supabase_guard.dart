import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors.dart';

/// Runs a Supabase call and turns database error codes into [BookingFailure].
Future<T> guardBooking<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on PostgrestException catch (error) {
    throw BookingFailure(bookingErrorCode(error.message));
  }
}

Map<String, dynamic> firstRow(dynamic data) {
  if (data is List && data.isNotEmpty && data.first is Map) {
    return Map<String, dynamic>.from(data.first as Map);
  }
  if (data is Map) return Map<String, dynamic>.from(data);
  throw BookingFailure(BookingErrorCode.generic);
}

List<Map<String, dynamic>> rowList(dynamic data) {
  if (data is List) {
    return data.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }
  return const [];
}
