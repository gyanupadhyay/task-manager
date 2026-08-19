import 'package:intl/intl.dart';

abstract final class DateFormatting {
  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy · h:mm a');

  static String date(DateTime value) => _dateFormat.format(value);

  static String dateTime(DateTime value) => _dateTimeFormat.format(value);

  static bool isOverdue(DateTime dueDate, {required bool isCompleted}) {
    if (isCompleted) return false;
    final today = DateTime.now();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return dueDay.isBefore(todayDay);
  }
}
