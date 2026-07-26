import '../../features/tasks/business/models/task_model.dart';

class AppDateUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isTomorrow(DateTime date) {
    return isSameDay(date, DateTime.now().add(const Duration(days: 1)));
  }

  static bool isNight([DateTime? date]) {
    final checkDate = date ?? DateTime.now();
    return checkDate.hour >= 18 || checkDate.hour < 6;
  }

  static bool isOverdue(DateTime date, bool isCompleted) {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  static String getFriendlyDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      if (isSameDay(date, yesterday)) {
        return 'Yesterday';
      }
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute $period';
  }

  static String getFriendlyTimeRangeString({required DateTime dueDate, DateTime? startTime}) {
    final dateStr = getFriendlyDateString(dueDate);
    if (startTime == null) {
      return dateStr;
    }
    if (isSameDay(startTime, dueDate)) {
      return '$dateStr, ${formatTime(startTime)} - ${formatTime(dueDate)}';
    }
    return '${getFriendlyDateString(startTime)} ${formatTime(startTime)} - $dateStr ${formatTime(dueDate)}';
  }

  static DateTime getNextOccurrence(DateTime date, RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.daily:
        return date.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return date.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        int year = date.year;
        int month = date.month + 1;
        if (month > 12) {
          month = 1;
          year += 1;
        }
        int day = date.day;
        int maxDaysInNextMonth = DateTime(year, month + 1, 0).day;
        if (day > maxDaysInNextMonth) {
          day = maxDaysInNextMonth;
        }
        return DateTime(
          year,
          month,
          day,
          date.hour,
          date.minute,
          date.second,
          date.millisecond,
          date.microsecond,
        );
      case RecurrenceType.none:
        return date;
    }
  }

  static String getRecurrenceLabel(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.none:
        return 'Does not repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }
}
