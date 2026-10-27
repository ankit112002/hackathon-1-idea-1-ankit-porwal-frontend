import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('eu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Iturrieta Book'**
  String get appTitle;

  /// No description provided for @motto.
  ///
  /// In en, this message translates to:
  /// **'Sagarretik txotxera'**
  String get motto;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'Cider house table bookings. See the open services, then reserve a table.'**
  String get homeIntro;

  /// No description provided for @bookCta.
  ///
  /// In en, this message translates to:
  /// **'Book a table'**
  String get bookCta;

  /// No description provided for @shiftsHeading.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get shiftsHeading;

  /// No description provided for @emptyShifts.
  ///
  /// In en, this message translates to:
  /// **'No active services.'**
  String get emptyShifts;

  /// No description provided for @shiftsError.
  ///
  /// In en, this message translates to:
  /// **'The services could not be loaded.'**
  String get shiftsError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @comingLater.
  ///
  /// In en, this message translates to:
  /// **'This screen arrives in a later step.'**
  String get comingLater;

  /// No description provided for @missingSupabase.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not configured. Start the app with --dart-define-from-file=env.json and set SUPABASE_URL and SUPABASE_ANON_KEY.'**
  String get missingSupabase;

  /// No description provided for @stepDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get stepDate;

  /// No description provided for @stepParty.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get stepParty;

  /// No description provided for @stepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get stepDetails;

  /// No description provided for @stepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get stepConfirm;

  /// No description provided for @buttonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonContinue;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get buttonConfirm;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonCall.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get buttonCall;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @bookTitle.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get bookTitle;

  /// No description provided for @confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmTitle;

  /// No description provided for @manageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your booking'**
  String get manageTitle;

  /// No description provided for @manageToken.
  ///
  /// In en, this message translates to:
  /// **'Reference: {token}'**
  String manageToken(String token);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff sign in'**
  String get loginTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @waiterTitle.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get waiterTitle;

  /// No description provided for @floorTitle.
  ///
  /// In en, this message translates to:
  /// **'Floor plan'**
  String get floorTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @shiftSummary.
  ///
  /// In en, this message translates to:
  /// **'{name} · {day} · {start}–{last} · {covers} covers'**
  String shiftSummary(
    String name,
    String day,
    String start,
    String last,
    int covers,
  );

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @errorShiftFull.
  ///
  /// In en, this message translates to:
  /// **'This service is full.'**
  String get errorShiftFull;

  /// No description provided for @errorClosedDay.
  ///
  /// In en, this message translates to:
  /// **'The restaurant is closed that day.'**
  String get errorClosedDay;

  /// No description provided for @errorWrongWeekday.
  ///
  /// In en, this message translates to:
  /// **'We are open Thursday to Sunday.'**
  String get errorWrongWeekday;

  /// No description provided for @errorTooLate.
  ///
  /// In en, this message translates to:
  /// **'That time is after the last booking time.'**
  String get errorTooLate;

  /// No description provided for @errorPartyTooSmall.
  ///
  /// In en, this message translates to:
  /// **'The group is smaller than the minimum.'**
  String get errorPartyTooSmall;

  /// No description provided for @errorPartyTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The group is larger than the maximum.'**
  String get errorPartyTooLarge;

  /// No description provided for @errorOnlineMax.
  ///
  /// In en, this message translates to:
  /// **'For a group this size, please call us.'**
  String get errorOnlineMax;

  /// No description provided for @errorBlacklisted.
  ///
  /// In en, this message translates to:
  /// **'We cannot confirm this date.'**
  String get errorBlacklisted;

  /// No description provided for @errorNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to do that.'**
  String get errorNotAllowed;

  /// No description provided for @errorNotCancellable.
  ///
  /// In en, this message translates to:
  /// **'This booking can no longer be cancelled.'**
  String get errorNotCancellable;

  /// No description provided for @errorTooManyBookings.
  ///
  /// In en, this message translates to:
  /// **'Too many bookings from this phone. Please try again later.'**
  String get errorTooManyBookings;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorShiftMissing.
  ///
  /// In en, this message translates to:
  /// **'That service is no longer available. Choose another time.'**
  String get errorShiftMissing;

  /// No description provided for @errorGroupRange.
  ///
  /// In en, this message translates to:
  /// **'Groups from {min} to {max} people can book this service.'**
  String errorGroupRange(int min, int max);

  /// No description provided for @staffLink.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffLink;

  /// No description provided for @seatsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} seats left'**
  String seatsRemaining(int count);

  /// No description provided for @dayClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'We are closed that day. Please choose another date.'**
  String get dayClosedMessage;

  /// No description provided for @noShiftThatDay.
  ///
  /// In en, this message translates to:
  /// **'There is no service that day. We open Thursday to Sunday.'**
  String get noShiftThatDay;

  /// No description provided for @chooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a time'**
  String get chooseTime;

  /// No description provided for @adults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get adults;

  /// No description provided for @children.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get children;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Allergies, celiac, vegetarian'**
  String get notesHint;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get guestName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Menu total'**
  String get totalLabel;

  /// No description provided for @includesCider.
  ///
  /// In en, this message translates to:
  /// **'Cider is included.'**
  String get includesCider;

  /// No description provided for @depositLine.
  ///
  /// In en, this message translates to:
  /// **'Deposit {amount}'**
  String depositLine(String amount);

  /// No description provided for @callUsForGroup.
  ///
  /// In en, this message translates to:
  /// **'For a group this size, please call us {phone}'**
  String callUsForGroup(String phone);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill in this field.'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number with at least 9 digits.'**
  String get invalidPhone;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your table is reserved.'**
  String get bookingConfirmed;

  /// No description provided for @manageCta.
  ///
  /// In en, this message translates to:
  /// **'Manage this booking'**
  String get manageCta;

  /// No description provided for @payDeposit.
  ///
  /// In en, this message translates to:
  /// **'Pay deposit'**
  String get payDeposit;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'A deposit is waiting. The booking is held for 15 minutes.'**
  String get paymentPending;

  /// No description provided for @paymentNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Card payment is not set up yet. Please call us to confirm the deposit.'**
  String get paymentNotConfigured;

  /// No description provided for @paymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Deposit paid.'**
  String get paymentPaid;

  /// No description provided for @depositPolicy.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation is {hours} hours before. After that, the deposit stays with the house.'**
  String depositPolicy(int hours);

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @changeDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get changeDate;

  /// No description provided for @bookingCancelled.
  ///
  /// In en, this message translates to:
  /// **'The booking is cancelled.'**
  String get bookingCancelled;

  /// No description provided for @bookingChanged.
  ///
  /// In en, this message translates to:
  /// **'The booking has a new date.'**
  String get bookingChanged;

  /// No description provided for @bookingMissing.
  ///
  /// In en, this message translates to:
  /// **'We could not find this booking.'**
  String get bookingMissing;

  /// No description provided for @waitlistPrompt.
  ///
  /// In en, this message translates to:
  /// **'This service is full. Join the waitlist and we will offer you a seat if one opens.'**
  String get waitlistPrompt;

  /// No description provided for @joinWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Join the waitlist'**
  String get joinWaitlist;

  /// No description provided for @waitlistSaved.
  ///
  /// In en, this message translates to:
  /// **'You are on the waitlist.'**
  String get waitlistSaved;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Those details did not match. Try again.'**
  String get authFailed;

  /// No description provided for @noBookingsToday.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet today.'**
  String get noBookingsToday;

  /// No description provided for @showNextService.
  ///
  /// In en, this message translates to:
  /// **'Show the next open service'**
  String get showNextService;

  /// No description provided for @markSeated.
  ///
  /// In en, this message translates to:
  /// **'Seated'**
  String get markSeated;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get markCompleted;

  /// No description provided for @markNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get markNoShow;

  /// No description provided for @assignTable.
  ///
  /// In en, this message translates to:
  /// **'Assign table'**
  String get assignTable;

  /// No description provided for @phoneBooking.
  ///
  /// In en, this message translates to:
  /// **'Phone booking'**
  String get phoneBooking;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get saved;

  /// No description provided for @closedReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get closedReason;

  /// No description provided for @addClosedDay.
  ///
  /// In en, this message translates to:
  /// **'Close this day'**
  String get addClosedDay;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @affectedWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} bookings are already on this day.'**
  String affectedWarning(int count);

  /// No description provided for @adultPrice.
  ///
  /// In en, this message translates to:
  /// **'Adult menu'**
  String get adultPrice;

  /// No description provided for @childPrice.
  ///
  /// In en, this message translates to:
  /// **'Child menu'**
  String get childPrice;

  /// No description provided for @depositEach.
  ///
  /// In en, this message translates to:
  /// **'Deposit per person'**
  String get depositEach;

  /// No description provided for @depositFrom.
  ///
  /// In en, this message translates to:
  /// **'Deposit from this many people'**
  String get depositFrom;

  /// No description provided for @onlineMax.
  ///
  /// In en, this message translates to:
  /// **'Largest group online'**
  String get onlineMax;

  /// No description provided for @freeCancelHours.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation, hours before'**
  String get freeCancelHours;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Public phone'**
  String get contactPhone;

  /// No description provided for @minGroup.
  ///
  /// In en, this message translates to:
  /// **'Smallest group'**
  String get minGroup;

  /// No description provided for @maxGroup.
  ///
  /// In en, this message translates to:
  /// **'Largest group'**
  String get maxGroup;

  /// No description provided for @maxCovers.
  ///
  /// In en, this message translates to:
  /// **'Covers'**
  String get maxCovers;

  /// No description provided for @lastBooking.
  ///
  /// In en, this message translates to:
  /// **'Last booking'**
  String get lastBooking;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endTime;

  /// No description provided for @addTable.
  ///
  /// In en, this message translates to:
  /// **'Add table'**
  String get addTable;

  /// No description provided for @saveFloor.
  ///
  /// In en, this message translates to:
  /// **'Save floor'**
  String get saveFloor;

  /// No description provided for @noTables.
  ///
  /// In en, this message translates to:
  /// **'No tables on the floor yet.'**
  String get noTables;

  /// No description provided for @tableLabel.
  ///
  /// In en, this message translates to:
  /// **'Table name'**
  String get tableLabel;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get capacity;

  /// No description provided for @coversToday.
  ///
  /// In en, this message translates to:
  /// **'Covers today'**
  String get coversToday;

  /// No description provided for @coversTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Covers tomorrow'**
  String get coversTomorrow;

  /// No description provided for @bookingsToday.
  ///
  /// In en, this message translates to:
  /// **'Bookings today'**
  String get bookingsToday;

  /// No description provided for @noShows30.
  ///
  /// In en, this message translates to:
  /// **'No-shows, 30 days'**
  String get noShows30;

  /// No description provided for @depositsPaid.
  ///
  /// In en, this message translates to:
  /// **'Deposits from today'**
  String get depositsPaid;

  /// No description provided for @staffHeading.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffHeading;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleWaiter.
  ///
  /// In en, this message translates to:
  /// **'Waiter'**
  String get roleWaiter;

  /// No description provided for @auditHeading.
  ///
  /// In en, this message translates to:
  /// **'Recent changes'**
  String get auditHeading;

  /// No description provided for @noAudit.
  ///
  /// In en, this message translates to:
  /// **'No changes yet.'**
  String get noAudit;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get eventTitle;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescription;

  /// No description provided for @publishEvent.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get publishEvent;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get newEvent;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events yet.'**
  String get noEvents;

  /// No description provided for @eventDate.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get eventDate;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmed;

  /// No description provided for @statusSeated.
  ///
  /// In en, this message translates to:
  /// **'Seated'**
  String get statusSeated;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusNoShow.
  ///
  /// In en, this message translates to:
  /// **'No-show'**
  String get statusNoShow;

  /// No description provided for @navService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get navService;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get navFloor;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @guestCount.
  ///
  /// In en, this message translates to:
  /// **'{adults} adults, {children} children'**
  String guestCount(int adults, int children);

  /// No description provided for @fullShift.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get fullShift;

  /// No description provided for @selectShift.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectShift;

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a table, then save.'**
  String get dragHint;

  /// No description provided for @bookingAdded.
  ///
  /// In en, this message translates to:
  /// **'The phone booking is on the list.'**
  String get bookingAdded;

  /// No description provided for @emptyClosed.
  ///
  /// In en, this message translates to:
  /// **'No closed days.'**
  String get emptyClosed;

  /// No description provided for @confirmAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get confirmAnyway;

  /// No description provided for @shiftHeading.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get shiftHeading;

  /// No description provided for @eventsPublic.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get eventsPublic;

  /// No description provided for @paidThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you. The deposit is paid.'**
  String get paidThanks;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy manage link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get linkCopied;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'No table yet'**
  String get unassigned;

  /// No description provided for @roleSaved.
  ///
  /// In en, this message translates to:
  /// **'Role updated.'**
  String get roleSaved;

  /// No description provided for @nextOpen.
  ///
  /// In en, this message translates to:
  /// **'Next open day'**
  String get nextOpen;

  /// No description provided for @partyHeading.
  ///
  /// In en, this message translates to:
  /// **'How many people?'**
  String get partyHeading;

  /// No description provided for @detailsHeading.
  ///
  /// In en, this message translates to:
  /// **'How can we reach you?'**
  String get detailsHeading;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get sending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'eu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
