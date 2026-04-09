import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/goal.dart';
import '../../data/models/milestone.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/milestone_repository.dart';

// ── Analytics data model ───────────────────────────────────────────────────────

class AnalyticsData {
  const AnalyticsData({
    required this.totalGoals,
    required this.completedGoals,
    required this.totalMilestones,
    required this.completedMilestones,
    required this.longestStreak,
    required this.currentStreak,
    required this.velocityByWeek,
    required this.categoryBreakdown,
    required this.activityByDayOfWeek,
    required this.activityByFullDate,
    required this.suggestedPeakHour,
  });

  final int totalGoals;
  final int completedGoals;
  final int totalMilestones;
  final int completedMilestones;
  final int longestStreak;
  final int currentStreak;

  /// Milestones completed per week (last 12 weeks). Index 0 = oldest.
  final List<int> velocityByWeek;

  /// category → milestone count
  final Map<String, int> categoryBreakdown;

  /// day-of-week (0=Mon…6=Sun) → completion count
  final Map<int, int> activityByDayOfWeek;

  /// Full Date → completion count (for heatmap)
  final Map<DateTime, int> activityByFullDate;

  /// Hour of day (0–23) when the user most often completes milestones.
  final int suggestedPeakHour;

  double get completionRate =>
      totalMilestones == 0 ? 0 : completedMilestones / totalMilestones;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final goalRepo = ref.watch(goalRepositoryProvider);
  final milestoneRepo = ref.watch(milestoneRepositoryProvider);
  return AnalyticsUseCases(goalRepo: goalRepo, milestoneRepo: milestoneRepo)
      .compute();
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

class AnalyticsUseCases {
  const AnalyticsUseCases(
      {required this.goalRepo, required this.milestoneRepo});

  final GoalRepository? goalRepo;
  final MilestoneRepository? milestoneRepo;

  Future<AnalyticsData> compute() async {
    final goals = await goalRepo?.getAll(includeArchived: true) ?? <Goal>[];
    final goalUids = goals.map((g) => g.uid).toList();
    final milestones = await milestoneRepo?.getForGoals(goalUids) ?? <Milestone>[];

    final completed = milestones.where((m) => m.isCompleted).toList();
    final now = DateTime.now();

    // ── Velocity by week (last 12) ─────────────────────────────────────────
    final velocity = List<int>.filled(12, 0);
    for (final m in completed) {
      final weeksAgo = now.difference(m.completedAt!).inDays ~/ 7;
      if (weeksAgo >= 0 && weeksAgo < 12) {
        velocity[11 - weeksAgo]++;
      }
    }

    // ── Category breakdown ────────────────────────────────────────────────
    final categoryMap = <String, int>{};
    for (final g in goals) {
      if (!g.isArchived) {
        categoryMap[g.category] = (categoryMap[g.category] ?? 0) + 1;
      }
    }

    // ── Activity by day (heatmap & day-of-week) ──────────────────────────
    final dayOfWeekMap = <int, int>{};
    final fullDateMap = <DateTime, int>{};
    for (final m in completed) {
      if (m.completedAt == null) continue;
      
      // day-of-week: 1=Mon…7=Sun → convert to 0-indexed
      final dow = (m.completedAt!.weekday - 1) % 7;
      dayOfWeekMap[dow] = (dayOfWeekMap[dow] ?? 0) + 1;

      // full-date: strip time
      final date = DateTime(
          m.completedAt!.year, m.completedAt!.month, m.completedAt!.day);
      fullDateMap[date] = (fullDateMap[date] ?? 0) + 1;
    }

    // ── Peak hour (smart scheduling hook) ────────────────────────────────
    final hourMap = <int, int>{};
    for (final m in completed) {
      final h = m.completedAt!.hour;
      hourMap[h] = (hourMap[h] ?? 0) + 1;
    }
    int peakHour = 9; // default: 9 AM
    if (hourMap.isNotEmpty) {
      peakHour = hourMap.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    // ── Streaks ───────────────────────────────────────────────────────────
    final longestStreak =
        goals.fold<int>(0, (max, g) => g.longestStreak > max ? g.longestStreak : max);
    final currentStreak =
        goals.fold<int>(0, (max, g) => g.currentStreak > max ? g.currentStreak : max);

    return AnalyticsData(
      totalGoals: goals.where((g) => !g.isArchived).length,
      completedGoals: goals.where((g) => g.isCompleted).length,
      totalMilestones: milestones.length,
      completedMilestones: completed.length,
      longestStreak: longestStreak,
      currentStreak: currentStreak,
      velocityByWeek: velocity,
      categoryBreakdown: categoryMap,
      activityByDayOfWeek: dayOfWeekMap,
      activityByFullDate: fullDateMap,
      suggestedPeakHour: peakHour,
    );
  }
}
