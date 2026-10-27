import 'package:intl/intl.dart';

String formatEur(num amount, String locale) {
  return NumberFormat.simpleCurrency(name: 'EUR', locale: locale).format(amount);
}

double asMoney(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
