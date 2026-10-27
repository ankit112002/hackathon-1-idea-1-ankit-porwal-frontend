import 'package:flutter_test/flutter_test.dart';
import 'package:iturrieta_book/core/booking_slots.dart';
import 'package:iturrieta_book/core/errors.dart';
import 'package:iturrieta_book/core/madrid_time.dart';

void main() {
  test('maps every server code the booking flow can raise', () {
    expect(bookingErrorCode('SHIFT_NOT_FOUND'), BookingErrorCode.shiftNotFound);
    expect(bookingErrorCode('WRONG_WEEKDAY'), BookingErrorCode.wrongWeekday);
    expect(bookingErrorCode('DAY_CLOSED'), BookingErrorCode.dayClosed);
    expect(bookingErrorCode('CLOSED_DAY'), BookingErrorCode.dayClosed);
    expect(bookingErrorCode('AFTER_LAST_BOOKING_TIME'), BookingErrorCode.tooLate);
    expect(bookingErrorCode('TOO_LATE'), BookingErrorCode.tooLate);
    expect(bookingErrorCode('GROUP_SIZE_NOT_ALLOWED'), BookingErrorCode.groupSize);
    expect(bookingErrorCode('PARTY_TOO_SMALL'), BookingErrorCode.groupSize);
    expect(bookingErrorCode('PARTY_TOO_LARGE'), BookingErrorCode.groupSize);
    expect(bookingErrorCode('GROUP_TOO_BIG_CALL_US'), BookingErrorCode.callUs);
    expect(bookingErrorCode('ONLINE_MAX_EXCEEDED'), BookingErrorCode.callUs);
    expect(bookingErrorCode('SHIFT_FULL'), BookingErrorCode.shiftFull);
    expect(bookingErrorCode('CUSTOMER_BLOCKED'), BookingErrorCode.blocked);
    expect(bookingErrorCode('BLACKLISTED'), BookingErrorCode.blocked);
    expect(bookingErrorCode('BOOKING_NOT_CANCELLABLE'), BookingErrorCode.notCancellable);
    expect(bookingErrorCode('TOO_MANY_BOOKINGS'), BookingErrorCode.tooMany);
    expect(bookingErrorCode('NOT_ALLOWED'), BookingErrorCode.notAllowed);
    expect(bookingErrorCode('something else'), BookingErrorCode.generic);
  });

  test('offers times only through the last booking time', () {
    expect(bookingSlots('13:00', '14:30'), [
      '13:00',
      '13:15',
      '13:30',
      '13:45',
      '14:00',
      '14:15',
      '14:30',
    ]);
    expect(bookingSlots('15:00', '14:00'), isEmpty);
  });

  test('party rules send large online groups to the phone', () {
    expect(
      partyDecision(party: 2, minGroup: 1, maxGroup: 40, onlineMax: 20),
      PartyDecision.ok,
    );
    expect(
      partyDecision(party: 0, minGroup: 1, maxGroup: 40, onlineMax: 20),
      PartyDecision.tooSmall,
    );
    expect(
      partyDecision(party: 21, minGroup: 1, maxGroup: 40, onlineMax: 20),
      PartyDecision.callUs,
    );
    expect(
      partyDecision(party: 41, minGroup: 1, maxGroup: 40, onlineMax: 20),
      PartyDecision.tooBigForShift,
    );
  });

  test('Madrid is UTC+1 after the October clock change', () {
    expect(madridOffsetHours(DateTime.utc(2026, 10, 26, 12)), 1);
    expect(madridOffsetHours(DateTime.utc(2026, 7, 1, 12)), 2);
    expect(madridOffsetHours(DateTime.utc(2026, 1, 15, 12)), 1);
    expect(nextOpenDay(DateTime(2026, 10, 26)), DateTime(2026, 10, 29));
  });
}
