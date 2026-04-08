import 'package:intl/intl.dart';

abstract final class AppDateUtils {
  static String formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  static String formatShortDate(DateTime date) =>
      DateFormat('MMM d').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('MMM d, yyyy • h:mm a').format(date);

  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  static String formatMonth(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String formatDayOfWeek(DateTime date) =>
      DateFormat('EEE').format(date);

  /// Human-readable relative date (e.g., "Tomorrow", "In 3 days", "2 days ago").
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1 && diff <= 7) return 'In $diff days';
    if (diff < -1 && diff >= -7) return '${-diff} days ago';
    if (diff > 7 && diff <= 30) return 'In ${(diff / 7).ceil()} weeks';
    if (diff < -7 && diff >= -30) return '${(-diff / 7).ceil()} weeks ago';
    return formatShortDate(date);
  }

  static bool isOverdue(DateTime date) => date.isBefore(DateTime.now());

  static bool isDueSoon(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 3;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns the number of consecutive days of activity ending on today.
  static int calcStreak(List<DateTime> activityDates) {
    if (activityDates.isEmpty) return 0;

    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Normalize to day-only and deduplicate
    final days = activityDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // descending

    if (days.isEmpty) return 0;

    // Allow streak to include today or yesterday as starting point
    if (days.first.isBefore(today.subtract(const Duration(days: 1)))) return 0;

    int streak = 0;
    DateTime? prev;
    for (final day in days) {
      if (prev == null) {
        streak = 1;
        prev = day;
      } else {
        final gap = prev.difference(day).inDays;
        if (gap == 1) {
          streak++;
          prev = day;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  /// Last N weeks as (startOfWeek, count) pairs for heatmap.
  static List<DateTime> last12WeekStarts() {
    final now = DateTime.now();
    final thisMonday =
        now.subtract(Duration(days: now.weekday - 1));
    return List.generate(12, (i) {
      return DateTime(thisMonday.year, thisMonday.month,
          thisMonday.day - (11 - i) * 7);
    });
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }
}
