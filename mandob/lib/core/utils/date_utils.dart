import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatToDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd', 'ar').format(date);
    } catch (e) {
      return isoString;
    }
  }

  static String formatToTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('hh:mm a', 'ar').format(date);
    } catch (e) {
      return isoString;
    }
  }

  static String formatToDateTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd hh:mm a', 'ar').format(date);
    } catch (e) {
      return isoString;
    }
  }

  static String getCurrentIso() {
    return DateTime.now().toIso8601String();
  }

  static bool isToday(String isoString) {
    if (isoString.isEmpty) return false;
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } catch (e) {
      return false;
    }
  }

  static bool isThisMonth(String isoString) {
    if (isoString.isEmpty) return false;
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      return date.year == now.year && date.month == now.month;
    } catch (e) {
      return false;
    }
  }
}
