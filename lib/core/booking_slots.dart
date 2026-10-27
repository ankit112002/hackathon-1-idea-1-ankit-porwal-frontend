/// Quarter-hour times from the shift start through the last booking time.
List<String> bookingSlots(String start, String last) {
  final from = _minutes(start);
  final until = _minutes(last);
  if (from == null || until == null || until < from) return const [];
  final slots = <String>[];
  for (var minute = from; minute <= until; minute += 15) {
    final hour = (minute ~/ 60).toString().padLeft(2, '0');
    final rest = (minute % 60).toString().padLeft(2, '0');
    slots.add('$hour:$rest');
  }
  return slots;
}

int? _minutes(String value) {
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}

enum PartyDecision { ok, tooSmall, tooBigForShift, callUs }

/// Client-side party check. The database still decides.
PartyDecision partyDecision({
  required int party,
  required int minGroup,
  required int maxGroup,
  required int onlineMax,
}) {
  if (party < minGroup) return PartyDecision.tooSmall;
  if (party > maxGroup) return PartyDecision.tooBigForShift;
  if (party > onlineMax) return PartyDecision.callUs;
  return PartyDecision.ok;
}
