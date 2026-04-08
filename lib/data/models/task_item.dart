import 'package:isar/isar.dart';

part 'task_item.g.dart';

/// Named TaskItem to avoid conflict with Dart's built-in Task concept.
@collection
class TaskItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  /// Foreign key → Milestone.uid
  @Index()
  late String milestoneUid;

  late String title;
  String? notes;

  bool isCompleted = false;
  DateTime? completedAt;
  DateTime? scheduledAt;

  late DateTime createdAt;
}
