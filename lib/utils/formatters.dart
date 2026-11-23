import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String date(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(dateTime);
  }

  static String dateShort(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final formatter = DateFormat('d MMM yyyy', 'id_ID');
    return formatter.format(dateTime);
  }

  static String timeOnly(DateTime? dateTime) {
    if (dateTime == null) return '-';
    final formatter = DateFormat('HH:mm', 'id_ID');
    return formatter.format(dateTime);
  }
}
