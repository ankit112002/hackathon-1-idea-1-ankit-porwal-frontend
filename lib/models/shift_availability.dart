import '../core/madrid_time.dart';
import '../core/money.dart';

class ShiftAvailability {
  const ShiftAvailability({
    required this.shiftId,
    required this.shiftName,
    required this.startTime,
    required this.endTime,
    required this.lastBookingTime,
    required this.maxCovers,
    required this.minGroup,
    required this.maxGroup,
    required this.taken,
    required this.remaining,
    required this.isClosed,
  });

  factory ShiftAvailability.fromMap(Map<String, dynamic> map) {
    return ShiftAvailability(
      shiftId: map['shift_id']?.toString() ?? '',
      shiftName: map['shift_name'] as String? ?? '',
      startTime: clockLabel(map['start_time']),
      endTime: clockLabel(map['end_time']),
      lastBookingTime: clockLabel(map['last_booking_time']),
      maxCovers: (map['max_covers'] as num?)?.toInt() ?? 0,
      minGroup: (map['min_group'] as num?)?.toInt() ?? 1,
      maxGroup: (map['max_group'] as num?)?.toInt() ?? 1,
      taken: (map['taken'] as num?)?.toInt() ?? 0,
      remaining: (map['remaining'] as num?)?.toInt() ?? 0,
      isClosed: map['is_closed'] as bool? ?? false,
    );
  }

  final String shiftId;
  final String shiftName;
  final String startTime;
  final String endTime;
  final String lastBookingTime;
  final int maxCovers;
  final int minGroup;
  final int maxGroup;
  final int taken;
  final int remaining;
  final bool isClosed;
}

class RestaurantSettings {
  const RestaurantSettings({
    required this.menuPriceAdult,
    required this.menuPriceChild,
    required this.depositPerPerson,
    required this.depositMinGroup,
    required this.maxGroupOnline,
    required this.cancelFreeHours,
    required this.contactPhone,
    this.seasonStart,
    this.seasonEnd,
  });

  factory RestaurantSettings.fromMap(Map<String, dynamic> map) {
    return RestaurantSettings(
      menuPriceAdult: asMoney(map['menu_price_adult']),
      menuPriceChild: asMoney(map['menu_price_child']),
      depositPerPerson: asMoney(map['deposit_per_person']),
      depositMinGroup: (map['deposit_min_group'] as num?)?.toInt() ?? 8,
      maxGroupOnline: (map['max_group_online'] as num?)?.toInt() ?? 20,
      cancelFreeHours: (map['cancel_free_hours'] as num?)?.toInt() ?? 48,
      contactPhone: map['contact_phone'] as String? ?? '',
      seasonStart: _day(map['season_start']),
      seasonEnd: _day(map['season_end']),
    );
  }

  final double menuPriceAdult;
  final double menuPriceChild;
  final double depositPerPerson;
  final int depositMinGroup;
  final int maxGroupOnline;
  final int cancelFreeHours;
  final String contactPhone;
  final DateTime? seasonStart;
  final DateTime? seasonEnd;

  static DateTime? _day(Object? value) {
    if (value == null) return null;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
