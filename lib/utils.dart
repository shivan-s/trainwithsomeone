import 'package:intl/intl.dart';

int numberOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOf28 = int.parse(DateFormat("D").format(dec28));
  return ((dayOf28 - dec28.weekday + 10) / 7).floor();
}

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  int weekOfYear = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (weekOfYear < 1) {
    weekOfYear = numberOfWeeks(date.year - 1);
  } else if (weekOfYear > numberOfWeeks(date.year)) {
    weekOfYear = 1;
  }
  return weekOfYear;
}

String weekRange(DateTime date) {
  DateTime startOfWeek =
      DateTime(date.year, date.month, date.day - date.weekday);
  DateTime endOfWeek =
      DateTime(date.year, date.month, date.day + (7 - date.weekday));
  return "$startOfWeek--$endOfWeek";
}
