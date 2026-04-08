import 'package:isar/isar.dart';

part 'goal.g.dart';

@collection
class Goal {
  Id id = Isar.autoIncrement;

  /// UUID — used as the stable cross-collection foreign-key.
  @Index(unique: true)
  late String uid;

  late String title;
  String? description;
  late String category;

  late DateTime startDate;
  DateTime? targetDate;

  /// Index into AppColors.goalColors.
  int colorIndex = 0;

  /// Material icon code point (e.g. 0xe25a for fitness_center).
  int iconCode = 0xe87d;

  // Progress (denormalised for fast dashboard reads)
  int completedMilestones = 0;
  int totalMilestones = 0;

  // Streaks
  int currentStreak = 0;
  int longestStreak = 0;

  DateTime? lastActivityDate;
  bool isArchived = false;
  bool isPinned = false;

  late DateTime createdAt;
  DateTime? updatedAt;

  // ── Computed helpers (not stored) ──────────────────────────────────────────

  double get progressPercent =>
      totalMilestones == 0 ? 0.0 : completedMilestones / totalMilestones;

  bool get isCompleted =>
      totalMilestones > 0 && completedMilestones >= totalMilestones;

  bool get isOverdue =>
      targetDate != null &&
      targetDate!.isBefore(DateTime.now()) &&
      !isCompleted;

  int get daysRemaining =>
      targetDate != null ? targetDate!.difference(DateTime.now()).inDays : -1;
}
