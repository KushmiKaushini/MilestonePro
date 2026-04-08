import 'package:isar/isar.dart';

part 'milestone.g.dart';

@collection
class Milestone {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  /// Foreign key → Goal.uid
  @Index()
  late String goalUid;

  late String title;
  String? notes;

  late DateTime dueDate;
  bool isCompleted = false;
  DateTime? completedAt;

  /// 0 = Low · 1 = Medium · 2 = High · 3 = Critical
  int priority = 1;

  // Alarm / notification settings
  bool alarmEnabled = false;
  DateTime? alarmDateTime;
  bool requiresPuzzleDismiss = false;

  // Task progress (denormalised)
  int completedTasks = 0;
  int totalTasks = 0;

  late DateTime createdAt;
  DateTime? updatedAt;

  // ── Computed ───────────────────────────────────────────────────────────────

  double get taskProgress =>
      totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && !isCompleted;

  bool get isDueSoon {
    if (isCompleted || isOverdue) return false;
    return dueDate.difference(DateTime.now()).inDays <= 3;
  }
}
