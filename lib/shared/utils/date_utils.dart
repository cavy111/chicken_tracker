import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Number of whole calendar days between two dates, ignoring the time of day.
  static int _calendarDaysBetween(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }

  /// Calculate batch age in a human-readable format (e.g., "1 week", "2 weeks", "3 days")
  static String getBatchAge(DateTime startDate) {
    final totalDays = getBatchAgeInDays(startDate);

    final weeks = totalDays ~/ 7;
    final days = totalDays % 7;

    if (weeks > 0) {
      if (days > 0) {
        return '$weeks week${weeks == 1 ? '' : 's'}, $days day${days == 1 ? '' : 's'}';
      }
      return '$weeks week${weeks == 1 ? '' : 's'}';
    } else if (totalDays > 0) {
      return '$totalDays day${totalDays == 1 ? '' : 's'}';
    } else {
      return 'Today';
    }
  }

  /// Get the age in days (useful for milestone checks)
  static int getBatchAgeInDays(DateTime startDate) {
    return _calendarDaysBetween(startDate, DateTime.now());
  }

  /// Get the age in weeks (useful for milestone checks)
  static int getBatchAgeInWeeks(DateTime startDate) {
    return getBatchAgeInDays(startDate) ~/ 7;
  }

  /// Check if batch just reached a week milestone
  static bool reachedWeekMilestone(DateTime startDate) {
    final ageInDays = getBatchAgeInDays(startDate);
    return ageInDays > 0 && ageInDays % 7 == 0;
  }
}
