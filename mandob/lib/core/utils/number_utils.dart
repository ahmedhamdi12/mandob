import 'package:intl/intl.dart';

class NumberUtils {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatNumber(double number) {
    final formatter = NumberFormat.decimalPattern('ar_EG');
    return formatter.format(number);
  }

  static String formatQuantity(double qty) {
    // If it's an integer, don't show decimals
    if (qty == qty.toInt()) {
      return qty.toInt().toString();
    }
    return qty.toStringAsFixed(2);
  }
}
