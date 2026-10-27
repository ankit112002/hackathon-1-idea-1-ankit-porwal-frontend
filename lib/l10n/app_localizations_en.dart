// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Iturrieta Book';

  @override
  String get motto => 'Sagarretik txotxera';

  @override
  String get homeIntro =>
      'Cider house table bookings. See the open services, then reserve a table.';

  @override
  String get bookCta => 'Book a table';

  @override
  String get shiftsHeading => 'Services';

  @override
  String get emptyShifts => 'No active services.';

  @override
  String get shiftsError => 'The services could not be loaded.';

  @override
  String get loading => 'Loading';

  @override
  String get retry => 'Try again';

  @override
  String get comingLater => 'This screen arrives in a later step.';

  @override
  String get missingSupabase =>
      'Supabase is not configured. Start the app with --dart-define-from-file=env.json and set SUPABASE_URL and SUPABASE_ANON_KEY.';

  @override
  String get stepDate => 'Date';

  @override
  String get stepParty => 'Party';

  @override
  String get stepDetails => 'Details';

  @override
  String get stepConfirm => 'Confirm';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonConfirm => 'Confirm booking';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonCall => 'Call us';

  @override
  String get languageLabel => 'Language';

  @override
  String get bookTitle => 'Book';

  @override
  String get confirmTitle => 'Confirmation';

  @override
  String get manageTitle => 'Your booking';

  @override
  String manageToken(String token) {
    return 'Reference: $token';
  }

  @override
  String get loginTitle => 'Staff sign in';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get waiterTitle => 'Service';

  @override
  String get floorTitle => 'Floor plan';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get eventsTitle => 'Events';

  @override
  String get settingsTitle => 'Settings';

  @override
  String shiftSummary(
    String name,
    String day,
    String start,
    String last,
    int covers,
  ) {
    return '$name · $day · $start–$last · $covers covers';
  }

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get errorShiftFull => 'This service is full.';

  @override
  String get errorClosedDay => 'The restaurant is closed that day.';

  @override
  String get errorWrongWeekday => 'We are open Thursday to Sunday.';

  @override
  String get errorTooLate => 'That time is after the last booking time.';

  @override
  String get errorPartyTooSmall => 'The group is smaller than the minimum.';

  @override
  String get errorPartyTooLarge => 'The group is larger than the maximum.';

  @override
  String get errorOnlineMax => 'For a group this size, please call us.';

  @override
  String get errorBlacklisted => 'We cannot confirm this date.';

  @override
  String get errorNotAllowed => 'You are not allowed to do that.';

  @override
  String get errorNotCancellable => 'This booking can no longer be cancelled.';

  @override
  String get errorTooManyBookings =>
      'Too many bookings from this phone. Please try again later.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorShiftMissing =>
      'That service is no longer available. Choose another time.';

  @override
  String errorGroupRange(int min, int max) {
    return 'Groups from $min to $max people can book this service.';
  }

  @override
  String get staffLink => 'Staff';

  @override
  String seatsRemaining(int count) {
    return '$count seats left';
  }

  @override
  String get dayClosedMessage =>
      'We are closed that day. Please choose another date.';

  @override
  String get noShiftThatDay =>
      'There is no service that day. We open Thursday to Sunday.';

  @override
  String get chooseTime => 'Choose a time';

  @override
  String get adults => 'Adults';

  @override
  String get children => 'Children';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Allergies, celiac, vegetarian';

  @override
  String get guestName => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get totalLabel => 'Menu total';

  @override
  String get includesCider => 'Cider is included.';

  @override
  String depositLine(String amount) {
    return 'Deposit $amount';
  }

  @override
  String callUsForGroup(String phone) {
    return 'For a group this size, please call us $phone';
  }

  @override
  String get fieldRequired => 'Please fill in this field.';

  @override
  String get invalidEmail => 'Enter a valid email.';

  @override
  String get invalidPhone => 'Enter a phone number with at least 9 digits.';

  @override
  String get bookingConfirmed => 'Your table is reserved.';

  @override
  String get manageCta => 'Manage this booking';

  @override
  String get payDeposit => 'Pay deposit';

  @override
  String get paymentPending =>
      'A deposit is waiting. The booking is held for 15 minutes.';

  @override
  String get paymentNotConfigured =>
      'Card payment is not set up yet. Please call us to confirm the deposit.';

  @override
  String get paymentPaid => 'Deposit paid.';

  @override
  String depositPolicy(int hours) {
    return 'Free cancellation is $hours hours before. After that, the deposit stays with the house.';
  }

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get changeDate => 'Change date';

  @override
  String get bookingCancelled => 'The booking is cancelled.';

  @override
  String get bookingChanged => 'The booking has a new date.';

  @override
  String get bookingMissing => 'We could not find this booking.';

  @override
  String get waitlistPrompt =>
      'This service is full. Join the waitlist and we will offer you a seat if one opens.';

  @override
  String get joinWaitlist => 'Join the waitlist';

  @override
  String get waitlistSaved => 'You are on the waitlist.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get authFailed => 'Those details did not match. Try again.';

  @override
  String get noBookingsToday => 'No bookings yet today.';

  @override
  String get showNextService => 'Show the next open service';

  @override
  String get markSeated => 'Seated';

  @override
  String get markCompleted => 'Completed';

  @override
  String get markNoShow => 'No-show';

  @override
  String get assignTable => 'Assign table';

  @override
  String get phoneBooking => 'Phone booking';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved.';

  @override
  String get closedReason => 'Reason';

  @override
  String get addClosedDay => 'Close this day';

  @override
  String get remove => 'Remove';

  @override
  String affectedWarning(int count) {
    return '$count bookings are already on this day.';
  }

  @override
  String get adultPrice => 'Adult menu';

  @override
  String get childPrice => 'Child menu';

  @override
  String get depositEach => 'Deposit per person';

  @override
  String get depositFrom => 'Deposit from this many people';

  @override
  String get onlineMax => 'Largest group online';

  @override
  String get freeCancelHours => 'Free cancellation, hours before';

  @override
  String get contactPhone => 'Public phone';

  @override
  String get minGroup => 'Smallest group';

  @override
  String get maxGroup => 'Largest group';

  @override
  String get maxCovers => 'Covers';

  @override
  String get lastBooking => 'Last booking';

  @override
  String get startTime => 'Starts';

  @override
  String get endTime => 'Ends';

  @override
  String get addTable => 'Add table';

  @override
  String get saveFloor => 'Save floor';

  @override
  String get noTables => 'No tables on the floor yet.';

  @override
  String get tableLabel => 'Table name';

  @override
  String get capacity => 'Seats';

  @override
  String get coversToday => 'Covers today';

  @override
  String get coversTomorrow => 'Covers tomorrow';

  @override
  String get bookingsToday => 'Bookings today';

  @override
  String get noShows30 => 'No-shows, 30 days';

  @override
  String get depositsPaid => 'Deposits from today';

  @override
  String get staffHeading => 'Staff';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleWaiter => 'Waiter';

  @override
  String get auditHeading => 'Recent changes';

  @override
  String get noAudit => 'No changes yet.';

  @override
  String get eventTitle => 'Title';

  @override
  String get eventDescription => 'Description';

  @override
  String get publishEvent => 'Published';

  @override
  String get newEvent => 'New event';

  @override
  String get noEvents => 'No events yet.';

  @override
  String get eventDate => 'When';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusSeated => 'Seated';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusNoShow => 'No-show';

  @override
  String get navService => 'Service';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navFloor => 'Floor';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navEvents => 'Events';

  @override
  String get navSettings => 'Settings';

  @override
  String guestCount(int adults, int children) {
    return '$adults adults, $children children';
  }

  @override
  String get fullShift => 'Full';

  @override
  String get selectShift => 'Select';

  @override
  String get dragHint => 'Drag a table, then save.';

  @override
  String get bookingAdded => 'The phone booking is on the list.';

  @override
  String get emptyClosed => 'No closed days.';

  @override
  String get confirmAnyway => 'Save anyway';

  @override
  String get shiftHeading => 'Services';

  @override
  String get eventsPublic => 'News';

  @override
  String get paidThanks => 'Thank you. The deposit is paid.';

  @override
  String get copyLink => 'Copy manage link';

  @override
  String get linkCopied => 'Link copied.';

  @override
  String get unassigned => 'No table yet';

  @override
  String get roleSaved => 'Role updated.';

  @override
  String get nextOpen => 'Next open day';

  @override
  String get partyHeading => 'How many people?';

  @override
  String get detailsHeading => 'How can we reach you?';

  @override
  String get sending => 'Sending';
}
