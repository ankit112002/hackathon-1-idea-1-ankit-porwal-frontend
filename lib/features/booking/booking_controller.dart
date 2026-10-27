import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/madrid_time.dart';
import '../../models/shift_availability.dart';

class BookingDraft {
  const BookingDraft({
    required this.date,
    this.shift,
    this.time,
    this.adults = 2,
    this.children = 0,
    this.notes = '',
    this.step = 0,
    this.waitlist = false,
  });

  final DateTime date;
  final ShiftAvailability? shift;
  final String? time;
  final int adults;
  final int children;
  final String notes;
  final int step;
  final bool waitlist;

  int get party => adults + children;

  BookingDraft copyWith({
    DateTime? date,
    ShiftAvailability? shift,
    String? time,
    int? adults,
    int? children,
    String? notes,
    int? step,
    bool? waitlist,
    bool clearShift = false,
    bool clearTime = false,
  }) {
    return BookingDraft(
      date: date ?? this.date,
      shift: clearShift ? null : shift ?? this.shift,
      time: clearTime || clearShift ? null : time ?? this.time,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      notes: notes ?? this.notes,
      step: step ?? this.step,
      waitlist: waitlist ?? this.waitlist,
    );
  }
}

class BookingController extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => BookingDraft(date: nextOpenDay(madridNow()));

  void selectDate(DateTime date) {
    state = state.copyWith(
      date: DateTime(date.year, date.month, date.day),
      clearShift: true,
      step: 0,
      waitlist: false,
    );
  }

  void selectShift(ShiftAvailability shift) {
    state = state.copyWith(
      shift: shift,
      clearTime: true,
      waitlist: shift.remaining <= 0 || shift.isClosed,
    );
  }

  void selectTime(String time) => state = state.copyWith(time: time, waitlist: false);

  void setParty({int? adults, int? children, String? notes}) {
    state = state.copyWith(adults: adults, children: children, notes: notes);
  }

  void setStep(int step) => state = state.copyWith(step: step);

  void setWaitlist(bool value) => state = state.copyWith(waitlist: value);

  /// Clears a finished reservation so the next visit starts at the date step.
  void reset() => state = BookingDraft(date: nextOpenDay(madridNow()));
}

final bookingControllerProvider =
    NotifierProvider<BookingController, BookingDraft>(BookingController.new);
