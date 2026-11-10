import 'package:intl/intl.dart';

/// Formats a journey date.
/// Returns 'Today, 18 June' if today, or 'Mon, 17 June' format.
/// Returns '--' if [date] is null.
String formatJourneyDate(DateTime? date) {
  if (date == null) return '--';
  final localDate = date.toLocal();
  final now = DateTime.now();
  final isToday =
      localDate.year == now.year &&
      localDate.month == now.month &&
      localDate.day == now.day;

  if (isToday) {
    return 'Today, ${DateFormat('d MMMM').format(localDate)}';
  }
  return DateFormat('EEE, d MMMM').format(localDate);
}

/// Formats a time into '7:16 AM' format.
/// Returns '--' if [time] is null.
String formatTime(DateTime? time) {
  if (time == null) return '--';
  return DateFormat('h:mm a').format(time.toLocal());
}

/// Formats a time range into '7:16 AM – 7:52 AM'.
/// Handles null [start] and [end] gracefully.
String formatTimeRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return '--';
  final startStr = start != null ? formatTime(start) : '--';
  final endStr = end != null ? formatTime(end) : '--';
  return '$startStr – $endStr';
}

/// Formats last updated time into relative time like 'Just now',
/// '5 min ago', '1 hour ago', or formatted date.
/// Returns '' if [time] is null.
String formatLastUpdated(DateTime? time) {
  if (time == null) return '';
  final localTime = time.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localTime);

  if (difference.isNegative || difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final mins = difference.inMinutes;
    return mins == 1 ? '1 min ago' : '$mins min ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return hours == 1 ? '1 hour ago' : '$hours hours ago';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return days == 1 ? 'Yesterday' : '$days days ago';
  } else {
    return DateFormat('d MMM yyyy').format(localTime);
  }
}
