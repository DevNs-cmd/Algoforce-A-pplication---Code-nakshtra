import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final NumberFormat _inr = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );
  static final NumberFormat _usd = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 0,
  );
  static final NumberFormat _number = NumberFormat.decimalPattern('en_IN');
  static final DateFormat _shortDate = DateFormat('d MMM yyyy');
  static final DateFormat _time = DateFormat('d MMM, h:mm a');

  static String inr(num value) => _inr.format(value);
  static String usd(num value) => _usd.format(value);
  static String number(num value) => _number.format(value);
  static String percent(num value) =>
      '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}%';
  static String shortDate(DateTime value) => _shortDate.format(value);
  static String timestamp(DateTime value) => _time.format(value);

  static String compactInr(num value) {
    if (value >= 10000000) {
      return '\u20B9${(value / 10000000).toStringAsFixed(value % 10000000 == 0 ? 0 : 1)}Cr';
    }
    if (value >= 100000) {
      return '\u20B9${(value / 100000).toStringAsFixed(value % 100000 == 0 ? 0 : 1)}L';
    }
    return inr(value);
  }

  static String timeAgo(DateTime value) {
    final delta = DateTime.now().difference(value);
    if (delta.inMinutes < 1) {
      return 'just now';
    }
    if (delta.inHours < 1) {
      return '${delta.inMinutes}m ago';
    }
    if (delta.inDays < 1) {
      return '${delta.inHours}h ago';
    }
    return '${delta.inDays}d ago';
  }
}
