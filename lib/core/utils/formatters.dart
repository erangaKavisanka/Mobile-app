import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final DateFormat _time = DateFormat.Hm();
  static final DateFormat _dateTime = DateFormat('d MMM, HH:mm');

  static String time(DateTime value) => _time.format(value.toLocal());

  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());

  /// Short relative description such as "just now" or "5 min ago".
  static String relative(DateTime value, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(value);
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return dateTime(value);
  }

  static String coordinates(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  static String accuracy(double? meters) =>
      meters == null ? 'accuracy unknown' : '±${meters.round()} m';
}
