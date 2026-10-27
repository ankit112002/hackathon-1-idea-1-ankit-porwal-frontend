// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get appTitle => 'Iturrieta Book';

  @override
  String get motto => 'Sagarretik txotxera';

  @override
  String get homeIntro =>
      'Sagardotegiko mahai-erreserbak. Ikusi irekitako txandak eta erreserbatu mahaia.';

  @override
  String get bookCta => 'Erreserbatu mahaia';

  @override
  String get shiftsHeading => 'Txandak';

  @override
  String get emptyShifts => 'Ez dago txanda aktiborik.';

  @override
  String get shiftsError => 'Ezin izan dira txandak kargatu.';

  @override
  String get loading => 'Kargatzen';

  @override
  String get retry => 'Saiatu berriro';

  @override
  String get comingLater => 'Pantaila hau hurrengo urrats batean iritsiko da.';

  @override
  String get missingSupabase =>
      'Supabase ez dago konfiguratuta. Abiarazi --dart-define-from-file=env.json erabiliz eta ezarri SUPABASE_URL eta SUPABASE_ANON_KEY.';

  @override
  String get stepDate => 'Data';

  @override
  String get stepParty => 'Jendea';

  @override
  String get stepDetails => 'Xehetasunak';

  @override
  String get stepConfirm => 'Berretsi';

  @override
  String get buttonContinue => 'Jarraitu';

  @override
  String get buttonBack => 'Atzera';

  @override
  String get buttonConfirm => 'Berretsi erreserba';

  @override
  String get buttonCancel => 'Utzi';

  @override
  String get buttonCall => 'Deitu';

  @override
  String get languageLabel => 'Hizkuntza';

  @override
  String get bookTitle => 'Erreserbatu';

  @override
  String get confirmTitle => 'Berrespena';

  @override
  String get manageTitle => 'Zure erreserba';

  @override
  String manageToken(String token) {
    return 'Erreferentzia: $token';
  }

  @override
  String get loginTitle => 'Langileen sarbidea';

  @override
  String get dashboardTitle => 'Panela';

  @override
  String get waiterTitle => 'Aretoa';

  @override
  String get floorTitle => 'Planoa';

  @override
  String get calendarTitle => 'Egutegia';

  @override
  String get eventsTitle => 'Ekitaldiak';

  @override
  String get settingsTitle => 'Ezarpenak';

  @override
  String shiftSummary(
    String name,
    String day,
    String start,
    String last,
    int covers,
  ) {
    return '$name · $day · $start–$last · $covers estalki';
  }

  @override
  String get weekdaySunday => 'igandea';

  @override
  String get weekdayMonday => 'astelehena';

  @override
  String get weekdayTuesday => 'asteartea';

  @override
  String get weekdayWednesday => 'asteazkena';

  @override
  String get weekdayThursday => 'osteguna';

  @override
  String get weekdayFriday => 'ostirala';

  @override
  String get weekdaySaturday => 'larunbata';

  @override
  String get errorShiftFull => 'Txanda hau beteta dago.';

  @override
  String get errorClosedDay => 'Jatetxea itxita dago egun horretan.';

  @override
  String get errorWrongWeekday => 'Ostegunetik igandera irekitzen dugu.';

  @override
  String get errorTooLate => 'Ordu hori azken erreserba-orduaren ondoren da.';

  @override
  String get errorPartyTooSmall => 'Taldea gutxienekoa baino txikiagoa da.';

  @override
  String get errorPartyTooLarge => 'Taldea gehienekoa baino handiagoa da.';

  @override
  String get errorOnlineMax => 'Talde honen tamainarako, deitu iezaguzu.';

  @override
  String get errorBlacklisted => 'Ezin dugu data hau berretsi.';

  @override
  String get errorNotAllowed => 'Ez duzu hori egiteko baimenik.';

  @override
  String get errorNotCancellable => 'Erreserba hau ezin da gehiago ezeztatu.';

  @override
  String get errorTooManyBookings =>
      'Erreserba gehiegi telefono honekin. Saiatu geroago.';

  @override
  String get errorGeneric => 'Zerbait gaizki atera da. Saiatu berriro.';

  @override
  String get errorShiftMissing =>
      'Txanda hori ez dago erabilgarri. Aukeratu beste ordu bat.';

  @override
  String errorGroupRange(int min, int max) {
    return 'Txanda honetan $min eta $max pertsona arteko taldeek erreserbatzen dute.';
  }

  @override
  String get staffLink => 'Taldea';

  @override
  String seatsRemaining(int count) {
    return '$count leku libre';
  }

  @override
  String get dayClosedMessage =>
      'Egun horretan itxita gaude. Aukeratu beste data bat.';

  @override
  String get noShiftThatDay =>
      'Egun horretan ez dago txandarik. Ostegunetik igandera irekitzen dugu.';

  @override
  String get chooseTime => 'Aukeratu ordua';

  @override
  String get adults => 'Helduak';

  @override
  String get children => 'Haurrak';

  @override
  String get notes => 'Oharrak';

  @override
  String get notesHint => 'Alergiak, zeliakoa, begetarianoa';

  @override
  String get guestName => 'Izena';

  @override
  String get phone => 'Telefonoa';

  @override
  String get email => 'Posta';

  @override
  String get password => 'Pasahitza';

  @override
  String get totalLabel => 'Menuaren guztira';

  @override
  String get includesCider => 'Sagardoa barruan dago.';

  @override
  String depositLine(String amount) {
    return 'Seinalea $amount';
  }

  @override
  String callUsForGroup(String phone) {
    return 'Talde honen tamainarako, deitu $phone';
  }

  @override
  String get fieldRequired => 'Bete eremu hau.';

  @override
  String get invalidEmail => 'Idatzi baliozko posta bat.';

  @override
  String get invalidPhone => 'Idatzi gutxienez 9 digituko telefono bat.';

  @override
  String get bookingConfirmed => 'Mahaia erreserbatuta dago.';

  @override
  String get manageCta => 'Kudeatu erreserba hau';

  @override
  String get payDeposit => 'Ordaindu seinalea';

  @override
  String get paymentPending =>
      'Seinalea falta da. Erreserba 15 minutuz gordetzen da.';

  @override
  String get paymentNotConfigured =>
      'Txartel bidezko ordainketa ez dago prest. Deitu seinalea berresteko.';

  @override
  String get paymentPaid => 'Seinalea ordainduta.';

  @override
  String depositPolicy(int hours) {
    return 'Ezeztatzea doan da $hours ordu lehenago arte. Gero, seinalea etxean geratzen da.';
  }

  @override
  String get cancelBooking => 'Ezeztatu erreserba';

  @override
  String get changeDate => 'Aldatu data';

  @override
  String get bookingCancelled => 'Erreserba ezeztatuta dago.';

  @override
  String get bookingChanged => 'Erreserbak data berria du.';

  @override
  String get bookingMissing => 'Ezin izan dugu erreserba hau aurkitu.';

  @override
  String get waitlistPrompt =>
      'Txanda hau beteta dago. Idatzi itxaron-zerrendan eta lekua irekitzen bada eskainiko dizugu.';

  @override
  String get joinWaitlist => 'Itxaron-zerrendan sartu';

  @override
  String get waitlistSaved => 'Itxaron-zerrendan zaude.';

  @override
  String get signIn => 'Sartu';

  @override
  String get signOut => 'Irten';

  @override
  String get authFailed => 'Datu horiek ez datoz bat. Saiatu berriro.';

  @override
  String get noBookingsToday => 'Gaur oraindik ez dago erreserbarik.';

  @override
  String get showNextService => 'Erakutsi hurrengo txanda irekia';

  @override
  String get markSeated => 'Eserita';

  @override
  String get markCompleted => 'Amaituta';

  @override
  String get markNoShow => 'Ez da etorri';

  @override
  String get assignTable => 'Esleitu mahaia';

  @override
  String get phoneBooking => 'Telefonozko erreserba';

  @override
  String get save => 'Gorde';

  @override
  String get saved => 'Gordeta.';

  @override
  String get closedReason => 'Arrazoia';

  @override
  String get addClosedDay => 'Itxi egun hau';

  @override
  String get remove => 'Kendu';

  @override
  String affectedWarning(int count) {
    return 'Dagoeneko $count erreserba daude egun horretan.';
  }

  @override
  String get adultPrice => 'Helduen menua';

  @override
  String get childPrice => 'Haurren menua';

  @override
  String get depositEach => 'Seinalea pertsonako';

  @override
  String get depositFrom => 'Seinalea talde honetatik';

  @override
  String get onlineMax => 'Lineako talde handiena';

  @override
  String get freeCancelHours => 'Doako ezeztapena, ordu lehenago';

  @override
  String get contactPhone => 'Telefono publikoa';

  @override
  String get minGroup => 'Talde txikiena';

  @override
  String get maxGroup => 'Talde handiena';

  @override
  String get maxCovers => 'Estalkiak';

  @override
  String get lastBooking => 'Azken erreserba';

  @override
  String get startTime => 'Hasiera';

  @override
  String get endTime => 'Amaiera';

  @override
  String get addTable => 'Gehitu mahaia';

  @override
  String get saveFloor => 'Gorde planoa';

  @override
  String get noTables => 'Oraindik ez dago mahairik planoan.';

  @override
  String get tableLabel => 'Mahaiaren izena';

  @override
  String get capacity => 'Lekuak';

  @override
  String get coversToday => 'Gaurko estalkiak';

  @override
  String get coversTomorrow => 'Biharko estalkiak';

  @override
  String get bookingsToday => 'Gaurko erreserbak';

  @override
  String get noShows30 => 'Ez etorriak, 30 egun';

  @override
  String get depositsPaid => 'Seinaleak gaurdanik';

  @override
  String get staffHeading => 'Taldea';

  @override
  String get roleOwner => 'Jabea';

  @override
  String get roleManager => 'Arduraduna';

  @override
  String get roleWaiter => 'Zerbitzaria';

  @override
  String get auditHeading => 'Azken aldaketak';

  @override
  String get noAudit => 'Oraindik ez dago aldaketarik.';

  @override
  String get eventTitle => 'Izenburua';

  @override
  String get eventDescription => 'Azalpena';

  @override
  String get publishEvent => 'Argitaratuta';

  @override
  String get newEvent => 'Ekitaldi berria';

  @override
  String get noEvents => 'Oraindik ez dago ekitaldirik.';

  @override
  String get eventDate => 'Noiz';

  @override
  String get statusPending => 'Zain';

  @override
  String get statusConfirmed => 'Berretsita';

  @override
  String get statusSeated => 'Eserita';

  @override
  String get statusCompleted => 'Amaituta';

  @override
  String get statusCancelled => 'Ezeztatuta';

  @override
  String get statusNoShow => 'Ez da etorri';

  @override
  String get navService => 'Aretoa';

  @override
  String get navDashboard => 'Panela';

  @override
  String get navFloor => 'Planoa';

  @override
  String get navCalendar => 'Egutegia';

  @override
  String get navEvents => 'Ekitaldiak';

  @override
  String get navSettings => 'Ezarpenak';

  @override
  String guestCount(int adults, int children) {
    return '$adults heldu, $children haur';
  }

  @override
  String get fullShift => 'Beteta';

  @override
  String get selectShift => 'Aukeratu';

  @override
  String get dragHint => 'Arrastatu mahaia eta gorde.';

  @override
  String get bookingAdded => 'Telefonozko erreserba zerrendan dago.';

  @override
  String get emptyClosed => 'Ez dago egun itxirik.';

  @override
  String get confirmAnyway => 'Gorde halere';

  @override
  String get shiftHeading => 'Txandak';

  @override
  String get eventsPublic => 'Berriak';

  @override
  String get paidThanks => 'Eskerrik asko. Seinalea ordainduta dago.';

  @override
  String get copyLink => 'Kopiatu esteka';

  @override
  String get linkCopied => 'Esteka kopiatuta.';

  @override
  String get unassigned => 'Mahairik gabe';

  @override
  String get roleSaved => 'Rola eguneratuta.';

  @override
  String get nextOpen => 'Hurrengo egun irekia';

  @override
  String get partyHeading => 'Zenbat lagun?';

  @override
  String get detailsHeading => 'Nola aurkituko zaitugu?';

  @override
  String get sending => 'Bidaltzen';
}
