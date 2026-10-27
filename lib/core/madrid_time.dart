/// Wall-clock time in Europe/Madrid, without a timezone package.
///
/// Dates and times in the database are the restaurant's local clock.
/// Compare them with [madridNow], not with the device clock.
int madridOffsetHours(DateTime utc) {
  final startDay = _lastSunday(utc.year, 3);
  final endDay = _lastSunday(utc.year, 10);
  final start = DateTime.utc(utc.year, 3, startDay, 1);
  final end = DateTime.utc(utc.year, 10, endDay, 1);
  final inSummer = !utc.isBefore(start) && utc.isBefore(end);
  return inSummer ? 2 : 1;
}

DateTime madridNow([DateTime? utcNow]) {
  final utc = utcNow ?? DateTime.now().toUtc();
  final shifted = utc.add(Duration(hours: madridOffsetHours(utc)));
  return DateTime(
    shifted.year,
    shifted.month,
    shifted.day,
    shifted.hour,
    shifted.minute,
  );
}

/// Next Thursday-to-Sunday on or after [now]. The house is closed Monday to Wednesday.
DateTime nextOpenDay(DateTime now) {
  var day = DateTime(now.year, now.month, now.day);
  for (var i = 0; i < 7; i++) {
    final open = day.weekday == DateTime.thursday ||
        day.weekday == DateTime.friday ||
        day.weekday == DateTime.saturday ||
        day.weekday == DateTime.sunday;
    if (open) return day;
    day = day.add(const Duration(days: 1));
  }
  return day;
}

String madridDateString(DateTime day) {
  final y = day.year.toString().padLeft(4, '0');
  final m = day.month.toString().padLeft(2, '0');
  final d = day.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime parseDate(Object? value) {
  final raw = value?.toString() ?? '';
  final date = DateTime.tryParse(raw);
  if (date == null) return madridNow();
  return DateTime(date.year, date.month, date.day);
}

/// `HH:mm` from a Postgres `time` value.
String clockLabel(Object? value) {
  final raw = value?.toString() ?? '';
  if (raw.length >= 5) return raw.substring(0, 5);
  return raw;
}

/// Postgres `time` parameter.
String clockParam(String hhmm) => hhmm.length == 5 ? '$hhmm:00' : hhmm;

int _lastSunday(int year, int month) {
  var day = DateTime.utc(year, month + 1, 0);
  while (day.weekday != DateTime.sunday) {
    day = day.subtract(const Duration(days: 1));
  }
  return day.day;
}
