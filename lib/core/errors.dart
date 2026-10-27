import '../l10n/app_localizations.dart';

/// Server error codes from `create_booking` and the token RPCs.
enum BookingErrorCode {
  shiftNotFound,
  wrongWeekday,
  dayClosed,
  tooLate,
  groupSize,
  callUs,
  shiftFull,
  blocked,
  notCancellable,
  tooMany,
  notAllowed,
  paymentNotConfigured,
  generic,
}

/// Pulls a known code out of a Postgres exception message.
BookingErrorCode bookingErrorCode(String message) {
  const ordered = <String, BookingErrorCode>{
    'SHIFT_NOT_FOUND': BookingErrorCode.shiftNotFound,
    'WRONG_WEEKDAY': BookingErrorCode.wrongWeekday,
    'DAY_CLOSED': BookingErrorCode.dayClosed,
    'CLOSED_DAY': BookingErrorCode.dayClosed,
    'AFTER_LAST_BOOKING_TIME': BookingErrorCode.tooLate,
    'TOO_LATE': BookingErrorCode.tooLate,
    'GROUP_TOO_BIG_CALL_US': BookingErrorCode.callUs,
    'ONLINE_MAX_EXCEEDED': BookingErrorCode.callUs,
    'GROUP_SIZE_NOT_ALLOWED': BookingErrorCode.groupSize,
    'PARTY_TOO_SMALL': BookingErrorCode.groupSize,
    'PARTY_TOO_LARGE': BookingErrorCode.groupSize,
    'SHIFT_FULL': BookingErrorCode.shiftFull,
    'CUSTOMER_BLOCKED': BookingErrorCode.blocked,
    'BLACKLISTED': BookingErrorCode.blocked,
    'BOOKING_NOT_CANCELLABLE': BookingErrorCode.notCancellable,
    'TOO_MANY_BOOKINGS': BookingErrorCode.tooMany,
    'NOT_ALLOWED': BookingErrorCode.notAllowed,
  };
  for (final entry in ordered.entries) {
    if (message.contains(entry.key)) return entry.value;
  }
  return BookingErrorCode.generic;
}

class BookingFailure implements Exception {
  BookingFailure(this.code);

  final BookingErrorCode code;

  @override
  String toString() => code.name;
}

/// Friendly copy for a booking error. Never mentions a blacklist.
String bookingErrorText(
  AppLocalizations l10n,
  BookingErrorCode code, {
  int? minGroup,
  int? maxGroup,
  String? phone,
}) {
  return switch (code) {
    BookingErrorCode.shiftNotFound => l10n.errorShiftMissing,
    BookingErrorCode.wrongWeekday => l10n.errorWrongWeekday,
    BookingErrorCode.dayClosed => l10n.errorClosedDay,
    BookingErrorCode.tooLate => l10n.errorTooLate,
    BookingErrorCode.groupSize => l10n.errorGroupRange(
      minGroup ?? 0,
      maxGroup ?? 0,
    ),
    BookingErrorCode.callUs => l10n.callUsForGroup(phone ?? ''),
    BookingErrorCode.shiftFull => l10n.errorShiftFull,
    BookingErrorCode.blocked => l10n.errorBlacklisted,
    BookingErrorCode.notCancellable => l10n.errorNotCancellable,
    BookingErrorCode.tooMany => l10n.errorTooManyBookings,
    BookingErrorCode.notAllowed => l10n.errorNotAllowed,
    BookingErrorCode.paymentNotConfigured => l10n.paymentNotConfigured,
    BookingErrorCode.generic => l10n.errorGeneric,
  };
}
