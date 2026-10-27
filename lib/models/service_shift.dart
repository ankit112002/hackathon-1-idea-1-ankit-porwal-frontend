import '../core/madrid_time.dart';

class ServiceShift {
  const ServiceShift({
    required this.id,
    required this.name,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.lastBookingTime,
    required this.maxCovers,
    required this.minGroup,
    required this.maxGroup,
    required this.active,
  });

  factory ServiceShift.fromMap(Map<String, dynamic> map) {
    return ServiceShift(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      weekday: (map['weekday'] as num?)?.toInt() ?? 0,
      startTime: clockLabel(map['start_time']),
      endTime: clockLabel(map['end_time']),
      lastBookingTime: clockLabel(map['last_booking_time']),
      maxCovers: (map['max_covers'] as num?)?.toInt() ?? 0,
      minGroup: (map['min_group'] as num?)?.toInt() ?? 1,
      maxGroup: (map['max_group'] as num?)?.toInt() ?? 1,
      active: map['active'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final int weekday;
  final String startTime;
  final String endTime;
  final String lastBookingTime;
  final int maxCovers;
  final int minGroup;
  final int maxGroup;
  final bool active;
}
