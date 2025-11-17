import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  static final DateFormat _timeFormatter = DateFormat('hh:mm a');

  static String formatDate(DateTime date) => _dateFormatter.format(date);

  static String formatDateTime(DateTime dateTime) =>
      '${_dateFormatter.format(dateTime)} · ${_timeFormatter.format(dateTime)}';
}

