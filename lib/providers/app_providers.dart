import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/madrid_time.dart';
import '../core/supabase_client.dart';

export '../core/supabase_client.dart' show supabaseReadyProvider;
import '../models/booking.dart';
import '../models/house_event.dart';
import '../models/service_shift.dart';
import '../models/shift_availability.dart';
import '../models/staff_role.dart';
import '../repositories/auth_repository.dart';
import '../repositories/booking_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/shift_repository.dart';
import '../repositories/table_repository.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  return ShiftRepository(Supabase.instance.client);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(Supabase.instance.client);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(Supabase.instance.client);
});

final tableRepositoryProvider = Provider<TableRepository>((ref) {
  return TableRepository(Supabase.instance.client);
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(Supabase.instance.client);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(Supabase.instance.client);
});

final shiftsProvider = FutureProvider<List<ServiceShift>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) {
    throw StateError('Supabase is not configured.');
  }
  return ref.watch(shiftRepositoryProvider).activeShifts();
});

final settingsProvider = FutureProvider<RestaurantSettings>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) {
    throw StateError('Supabase is not configured.');
  }
  return ref.watch(settingsRepositoryProvider).load();
});

final availabilityProvider =
    FutureProvider.family<List<ShiftAvailability>, String>((ref, date) async {
      if (!ref.watch(supabaseReadyProvider)) {
        throw StateError('Supabase is not configured.');
      }
      return ref.watch(bookingRepositoryProvider).availability(DateTime.parse(date));
    });

final publishedEventsProvider = FutureProvider<List<HouseEvent>>((ref) async {
  if (!ref.watch(supabaseReadyProvider)) return const [];
  return ref.watch(eventRepositoryProvider).published();
});

class AuthEpoch extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final authEpochProvider = NotifierProvider<AuthEpoch, int>(AuthEpoch.new);

final staffRoleProvider = FutureProvider<StaffRole?>((ref) async {
  ref.watch(authEpochProvider);
  if (!ref.watch(supabaseReadyProvider)) return null;
  if (Supabase.instance.client.auth.currentSession == null) return null;
  return ref.watch(authRepositoryProvider).currentRole();
});

class ServiceDate extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = madridNow();
    return DateTime(now.year, now.month, now.day);
  }

  void setDay(DateTime day) => state = DateTime(day.year, day.month, day.day);
}

final serviceDateProvider = NotifierProvider<ServiceDate, DateTime>(
  ServiceDate.new,
);

class LiveBookingsController extends AsyncNotifier<List<LiveBooking>> {
  @override
  Future<List<LiveBooking>> build() async {
    if (!ref.watch(supabaseReadyProvider)) return const [];
    final date = madridDateString(ref.watch(serviceDateProvider));
    final repo = ref.watch(bookingRepositoryProvider);
    final cancel = repo.watchDate(date, () {
      if (ref.mounted) ref.invalidateSelf();
    });
    ref.onDispose(cancel);
    return repo.liveOn(date);
  }

  Future<void> setStatus(String id, String status) async {
    await ref.read(bookingRepositoryProvider).setStatus(id, status);
  }

  Future<void> markNoShow(String id) async {
    await ref.read(bookingRepositoryProvider).markNoShow(id);
  }
}

final liveBookingsProvider =
    AsyncNotifierProvider<LiveBookingsController, List<LiveBooking>>(
      LiveBookingsController.new,
    );
