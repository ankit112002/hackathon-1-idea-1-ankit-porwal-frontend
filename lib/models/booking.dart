import '../core/madrid_time.dart';
import '../core/money.dart';

class BookingResult {
  const BookingResult({
    required this.id,
    required this.manageToken,
    required this.depositAmount,
    required this.payment,
  });

  factory BookingResult.fromMap(Map<String, dynamic> map) {
    return BookingResult(
      id: map['id']?.toString() ?? '',
      manageToken: map['manage_token']?.toString() ?? '',
      depositAmount: asMoney(map['deposit_amount']),
      payment: map['payment']?.toString() ?? 'none',
    );
  }

  final String id;
  final String manageToken;
  final double depositAmount;
  final String payment;

  bool get needsDeposit => payment == 'pending' && depositAmount > 0;
}

class ManagedBooking {
  const ManagedBooking({
    required this.id,
    required this.date,
    required this.time,
    required this.adults,
    required this.children,
    required this.partySize,
    required this.status,
    required this.notes,
    required this.depositAmount,
    required this.payment,
    required this.shiftId,
    required this.shiftName,
    required this.customerName,
  });

  factory ManagedBooking.fromMap(Map<String, dynamic> map) {
    return ManagedBooking(
      id: map['id']?.toString() ?? '',
      date: parseDate(map['booking_date']),
      time: clockLabel(map['booking_time']),
      adults: (map['adults'] as num?)?.toInt() ?? 0,
      children: (map['children'] as num?)?.toInt() ?? 0,
      partySize: (map['party_size'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? '',
      notes: map['notes'] as String? ?? '',
      depositAmount: asMoney(map['deposit_amount']),
      payment: map['payment']?.toString() ?? 'none',
      shiftId: map['shift_id']?.toString() ?? '',
      shiftName: map['shift_name'] as String? ?? '',
      customerName: map['customer_name'] as String? ?? '',
    );
  }

  final String id;
  final DateTime date;
  final String time;
  final int adults;
  final int children;
  final int partySize;
  final String status;
  final String notes;
  final double depositAmount;
  final String payment;
  final String shiftId;
  final String shiftName;
  final String customerName;

  bool get canChange => status == 'pending' || status == 'confirmed';
  bool get needsDeposit => payment == 'pending' && depositAmount > 0;
}

class LiveBooking {
  const LiveBooking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.time,
    required this.adults,
    required this.children,
    required this.partySize,
    required this.status,
    required this.channel,
    required this.notes,
    required this.depositAmount,
    required this.payment,
    required this.tableLabels,
    required this.tableIds,
  });

  final String id;
  final String customerName;
  final String phone;
  final String time;
  final int adults;
  final int children;
  final int partySize;
  final String status;
  final String channel;
  final String notes;
  final double depositAmount;
  final String payment;
  final List<String> tableLabels;
  final List<String> tableIds;

  bool get hasNotes => notes.trim().isNotEmpty;
}

class DashboardStats {
  const DashboardStats({
    required this.coversToday,
    required this.bookingsToday,
    required this.coversTomorrow,
    required this.noShows30d,
    required this.depositsPaid,
  });

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      coversToday: (map['covers_today'] as num?)?.toInt() ?? 0,
      bookingsToday: (map['bookings_today'] as num?)?.toInt() ?? 0,
      coversTomorrow: (map['covers_tomorrow'] as num?)?.toInt() ?? 0,
      noShows30d: (map['no_shows_30d'] as num?)?.toInt() ?? 0,
      depositsPaid: asMoney(map['deposits_paid']),
    );
  }

  final int coversToday;
  final int bookingsToday;
  final int coversTomorrow;
  final int noShows30d;
  final double depositsPaid;
}
