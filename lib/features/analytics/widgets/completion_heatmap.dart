import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_date_utils.dart';

/// GitHub-style contribution heatmap showing the last 12 weeks of activity.
class CompletionHeatmap extends StatelessWidget {
  const CompletionHeatmap({
    super.key,
    required this.activityByDay,
  });

  /// Maps a DateTime (day-precision) to a completion count.
  final Map<DateTime, int> activityByDay;

  // Build a 12-week grid (Mon–Sun columns)
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final weekStarts = AppDateUtils.last12WeekStarts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Row(
          children: [
            const SizedBox(width: 24), // offset for week numbers
            ..._days.map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 10),
                    ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 6),

        // Grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: weekStarts.asMap().entries.map((entry) {
            final weekIndex = entry.key;
            final weekStart = entry.value;

            return Expanded(
              child: Column(
                children: List.generate(7, (dow) {
                  final day =
                      weekStart.add(Duration(days: dow));
                  final key = DateTime(day.year, day.month, day.day);
                  final count = activityByDay[key] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Tooltip(
                        message: count == 0
                            ? 'No activity'
                            : '$count milestone${count > 1 ? 's' : ''} on ${AppDateUtils.formatShortDate(day)}',
                        child: Container(
                          decoration: BoxDecoration(
                            color: _cellColor(count),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }).toList(),
        ),

        // Legend
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Less',
                style: TextStyle(color: AppColors.textHint, fontSize: 10)),
            const SizedBox(width: 4),
            ...[0, 1, 2, 4, 6].map((c) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _cellColor(c),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
            const SizedBox(width: 4),
            const Text('More',
                style: TextStyle(color: AppColors.textHint, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Color _cellColor(int count) {
    if (count == 0) return AppColors.border;
    if (count == 1) return AppColors.primary.withValues(alpha: 0.25);
    if (count == 2) return AppColors.primary.withValues(alpha: 0.45);
    if (count <= 4) return AppColors.primary.withValues(alpha: 0.65);
    return AppColors.primary;
  }
}
