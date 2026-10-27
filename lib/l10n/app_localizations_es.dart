// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Iturrieta Book';

  @override
  String get motto => 'Sagarretik txotxera';

  @override
  String get homeIntro =>
      'Reservas de la sidrería. Consulta los turnos abiertos y reserva mesa.';

  @override
  String get bookCta => 'Reservar mesa';

  @override
  String get shiftsHeading => 'Turnos';

  @override
  String get emptyShifts => 'No hay turnos activos.';

  @override
  String get shiftsError => 'No se han podido cargar los turnos.';

  @override
  String get loading => 'Cargando';

  @override
  String get retry => 'Reintentar';

  @override
  String get comingLater => 'Esta pantalla llega en un paso posterior.';

  @override
  String get missingSupabase =>
      'Supabase no está configurado. Arranca con --dart-define-from-file=env.json y define SUPABASE_URL y SUPABASE_ANON_KEY.';

  @override
  String get stepDate => 'Fecha';

  @override
  String get stepParty => 'Comensales';

  @override
  String get stepDetails => 'Datos';

  @override
  String get stepConfirm => 'Confirmar';

  @override
  String get buttonContinue => 'Continuar';

  @override
  String get buttonBack => 'Atrás';

  @override
  String get buttonConfirm => 'Confirmar reserva';

  @override
  String get buttonCancel => 'Cancelar';

  @override
  String get buttonCall => 'Llámanos';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get bookTitle => 'Reservar';

  @override
  String get confirmTitle => 'Confirmación';

  @override
  String get manageTitle => 'Tu reserva';

  @override
  String manageToken(String token) {
    return 'Referencia: $token';
  }

  @override
  String get loginTitle => 'Acceso del equipo';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get waiterTitle => 'Sala';

  @override
  String get floorTitle => 'Plano';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get eventsTitle => 'Eventos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String shiftSummary(
    String name,
    String day,
    String start,
    String last,
    int covers,
  ) {
    return '$name · $day · $start–$last · $covers cubiertos';
  }

  @override
  String get weekdaySunday => 'domingo';

  @override
  String get weekdayMonday => 'lunes';

  @override
  String get weekdayTuesday => 'martes';

  @override
  String get weekdayWednesday => 'miércoles';

  @override
  String get weekdayThursday => 'jueves';

  @override
  String get weekdayFriday => 'viernes';

  @override
  String get weekdaySaturday => 'sábado';

  @override
  String get errorShiftFull => 'Este turno está completo.';

  @override
  String get errorClosedDay => 'El restaurante está cerrado ese día.';

  @override
  String get errorWrongWeekday => 'Abrimos de jueves a domingo.';

  @override
  String get errorTooLate => 'Esa hora es posterior a la última reserva.';

  @override
  String get errorPartyTooSmall => 'El grupo es más pequeño que el mínimo.';

  @override
  String get errorPartyTooLarge => 'El grupo es más grande que el máximo.';

  @override
  String get errorOnlineMax => 'Para un grupo de este tamaño, llámanos.';

  @override
  String get errorBlacklisted => 'No podemos confirmar esta fecha.';

  @override
  String get errorNotAllowed => 'No tienes permiso para hacer eso.';

  @override
  String get errorNotCancellable => 'Esta reserva ya no se puede cancelar.';

  @override
  String get errorTooManyBookings =>
      'Demasiadas reservas con este teléfono. Inténtalo más tarde.';

  @override
  String get errorGeneric => 'Algo ha ido mal. Inténtalo de nuevo.';

  @override
  String get errorShiftMissing =>
      'Ese turno ya no está disponible. Elige otra hora.';

  @override
  String errorGroupRange(int min, int max) {
    return 'En este turno reservan grupos de $min a $max personas.';
  }

  @override
  String get staffLink => 'Equipo';

  @override
  String seatsRemaining(int count) {
    return '$count plazas libres';
  }

  @override
  String get dayClosedMessage => 'Ese día estamos cerrados. Elige otra fecha.';

  @override
  String get noShiftThatDay =>
      'No hay turno ese día. Abrimos de jueves a domingo.';

  @override
  String get chooseTime => 'Elige una hora';

  @override
  String get adults => 'Adultos';

  @override
  String get children => 'Niños';

  @override
  String get notes => 'Notas';

  @override
  String get notesHint => 'Alergias, celiaquía, vegetariano';

  @override
  String get guestName => 'Nombre';

  @override
  String get phone => 'Teléfono';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get totalLabel => 'Total del menú';

  @override
  String get includesCider => 'La sidra va incluida.';

  @override
  String depositLine(String amount) {
    return 'Señal $amount';
  }

  @override
  String callUsForGroup(String phone) {
    return 'Para un grupo así, llámanos al $phone';
  }

  @override
  String get fieldRequired => 'Rellena este campo.';

  @override
  String get invalidEmail => 'Escribe un correo válido.';

  @override
  String get invalidPhone => 'Escribe un teléfono con al menos 9 dígitos.';

  @override
  String get bookingConfirmed => 'La mesa está reservada.';

  @override
  String get manageCta => 'Gestionar esta reserva';

  @override
  String get payDeposit => 'Pagar la señal';

  @override
  String get paymentPending =>
      'Falta la señal. La reserva se guarda 15 minutos.';

  @override
  String get paymentNotConfigured =>
      'El pago con tarjeta aún no está listo. Llámanos para confirmar la señal.';

  @override
  String get paymentPaid => 'Señal pagada.';

  @override
  String depositPolicy(int hours) {
    return 'Cancelar es gratis hasta $hours horas antes. Después, la señal se queda en la casa.';
  }

  @override
  String get cancelBooking => 'Cancelar reserva';

  @override
  String get changeDate => 'Cambiar fecha';

  @override
  String get bookingCancelled => 'La reserva está cancelada.';

  @override
  String get bookingChanged => 'La reserva tiene una fecha nueva.';

  @override
  String get bookingMissing => 'No encontramos esta reserva.';

  @override
  String get waitlistPrompt =>
      'Este turno está completo. Apúntate a la lista de espera y te ofreceremos sitio si se libera.';

  @override
  String get joinWaitlist => 'Apuntarme a la espera';

  @override
  String get waitlistSaved => 'Estás en la lista de espera.';

  @override
  String get signIn => 'Entrar';

  @override
  String get signOut => 'Salir';

  @override
  String get authFailed => 'Esos datos no coinciden. Inténtalo de nuevo.';

  @override
  String get noBookingsToday => 'Hoy todavía no hay reservas.';

  @override
  String get showNextService => 'Ver el siguiente turno abierto';

  @override
  String get markSeated => 'Sentados';

  @override
  String get markCompleted => 'Terminado';

  @override
  String get markNoShow => 'No presentado';

  @override
  String get assignTable => 'Asignar mesa';

  @override
  String get phoneBooking => 'Reserva por teléfono';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'Guardado.';

  @override
  String get closedReason => 'Motivo';

  @override
  String get addClosedDay => 'Cerrar este día';

  @override
  String get remove => 'Quitar';

  @override
  String affectedWarning(int count) {
    return 'Ya hay $count reservas ese día.';
  }

  @override
  String get adultPrice => 'Menú adulto';

  @override
  String get childPrice => 'Menú infantil';

  @override
  String get depositEach => 'Señal por persona';

  @override
  String get depositFrom => 'Señal a partir de este grupo';

  @override
  String get onlineMax => 'Grupo máximo en línea';

  @override
  String get freeCancelHours => 'Cancelación gratis, horas antes';

  @override
  String get contactPhone => 'Teléfono público';

  @override
  String get minGroup => 'Grupo mínimo';

  @override
  String get maxGroup => 'Grupo máximo';

  @override
  String get maxCovers => 'Cubiertos';

  @override
  String get lastBooking => 'Última reserva';

  @override
  String get startTime => 'Empieza';

  @override
  String get endTime => 'Termina';

  @override
  String get addTable => 'Añadir mesa';

  @override
  String get saveFloor => 'Guardar plano';

  @override
  String get noTables => 'Todavía no hay mesas en el plano.';

  @override
  String get tableLabel => 'Nombre de la mesa';

  @override
  String get capacity => 'Plazas';

  @override
  String get coversToday => 'Cubiertos hoy';

  @override
  String get coversTomorrow => 'Cubiertos mañana';

  @override
  String get bookingsToday => 'Reservas hoy';

  @override
  String get noShows30 => 'No presentados, 30 días';

  @override
  String get depositsPaid => 'Señales desde hoy';

  @override
  String get staffHeading => 'Equipo';

  @override
  String get roleOwner => 'Dueño';

  @override
  String get roleManager => 'Encargado';

  @override
  String get roleWaiter => 'Camarero';

  @override
  String get auditHeading => 'Cambios recientes';

  @override
  String get noAudit => 'Todavía no hay cambios.';

  @override
  String get eventTitle => 'Título';

  @override
  String get eventDescription => 'Descripción';

  @override
  String get publishEvent => 'Publicado';

  @override
  String get newEvent => 'Nuevo evento';

  @override
  String get noEvents => 'Todavía no hay eventos.';

  @override
  String get eventDate => 'Cuándo';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusConfirmed => 'Confirmada';

  @override
  String get statusSeated => 'Sentados';

  @override
  String get statusCompleted => 'Terminada';

  @override
  String get statusCancelled => 'Cancelada';

  @override
  String get statusNoShow => 'No presentado';

  @override
  String get navService => 'Sala';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navFloor => 'Plano';

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navEvents => 'Eventos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String guestCount(int adults, int children) {
    return '$adults adultos, $children niños';
  }

  @override
  String get fullShift => 'Completo';

  @override
  String get selectShift => 'Elegir';

  @override
  String get dragHint => 'Arrastra una mesa y guarda.';

  @override
  String get bookingAdded => 'La reserva de teléfono ya está en la lista.';

  @override
  String get emptyClosed => 'No hay días cerrados.';

  @override
  String get confirmAnyway => 'Guardar igualmente';

  @override
  String get shiftHeading => 'Turnos';

  @override
  String get eventsPublic => 'Noticias';

  @override
  String get paidThanks => 'Gracias. La señal está pagada.';

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get linkCopied => 'Enlace copiado.';

  @override
  String get unassigned => 'Sin mesa';

  @override
  String get roleSaved => 'Rol actualizado.';

  @override
  String get nextOpen => 'Siguiente día abierto';

  @override
  String get partyHeading => '¿Cuántas personas?';

  @override
  String get detailsHeading => '¿Cómo te localizamos?';

  @override
  String get sending => 'Enviando';
}
