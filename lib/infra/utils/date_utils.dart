import 'package:intl/intl.dart';

class DateUtil {
  static String formatServerDate(String? serverDate, {String format = 'MMM dd, yyyy'}) {
    if (serverDate == null || serverDate.isEmpty) return '';
    
    try {
      final dateTime = DateTime.parse(serverDate);
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  static String formatServerDateTime(String? serverDate, {String format = 'MMM dd, yyyy hh:mm a'}) {
    if (serverDate == null || serverDate.isEmpty) return '';
    
    try {
      final dateTime = DateTime.parse(serverDate);
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  static String getTimeFromServerDate(String? serverDate) {
    if (serverDate == null || serverDate.isEmpty) return getCurrentTime();
    
    try {
      final dateTime = DateTime.parse(serverDate);
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return getCurrentTime();
    }
  }

  static String getDateFromServerDate(String? serverDate) {
    if (serverDate == null || serverDate.isEmpty) return getCurrentDate();
    
    try {
      final dateTime = DateTime.parse(serverDate);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return getCurrentDate();
    }
  }

  static String getCurrentDate() {
    return DateFormat('MMM dd, yyyy').format(DateTime.now());
  }

  static String getCurrentTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  static String getCurrentDateTime() {
    return DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.now());
  }
} 