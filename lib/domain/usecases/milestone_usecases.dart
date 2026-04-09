import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/milestone.dart';
import '../../data/models/task_item.dart';
import '../../data/repositories/milestone_repository.dart';
import '../../data/repositories/task_repository.dart';
import 'goal_usecases.dart';

const _uuid = Uuid();

final milestoneUseCasesProvider = Provider<MilestoneUseCases>((ref) {
  return MilestoneUseCases(
    milestoneRepo: ref.watch(milestoneRepositoryProvider),
    taskRepo: ref.watch(taskRepositoryProvider),
    goalUseCases: ref.watch(goalUseCasesProvider),
  );
});

class MilestoneUseCases {
  const MilestoneUseCases({
    required this.milestoneRepo,
    required this.taskRepo,
    required this.goalUseCases,
  });

  final MilestoneRepository? milestoneRepo;
  final TaskRepository? taskRepo;
  final GoalUseCases goalUseCases;

  Future<Milestone> createMilestone({
    required String goalUid,
    required String title,
    String? notes,
    required DateTime dueDate,
    int priority = 1,
    bool alarmEnabled = false,
    DateTime? alarmDateTime,
    bool requiresPuzzleDismiss = false,
  }) async {
    final milestone = Milestone()
      ..uid = _uuid.v4()
      ..goalUid = goalUid
      ..title = title
      ..notes = notes
      ..dueDate = dueDate
      ..priority = priority
      ..alarmEnabled = alarmEnabled
      ..alarmDateTime = alarmDateTime
      ..requiresPuzzleDismiss = requiresPuzzleDismiss
      ..createdAt = DateTime.now();

    await milestoneRepo?.save(milestone);
    await goalUseCases.refreshGoalProgress(goalUid);
    return milestone;
  }

  Future<void> completeMilestone(int milestoneId) async {
    final m = await milestoneRepo?.getById(milestoneId);
    if (m == null) return;
    await milestoneRepo?.markComplete(milestoneId);
    await goalUseCases.refreshGoalProgress(m.goalUid);
  }

  Future<void> incompleteMilestone(int milestoneId) async {
    final m = await milestoneRepo?.getById(milestoneId);
    if (m == null) return;
    await milestoneRepo?.markIncomplete(milestoneId);
    await goalUseCases.refreshGoalProgress(m.goalUid);
  }

  Future<void> deleteMilestone(int milestoneId) async {
    final m = await milestoneRepo?.getById(milestoneId);
    if (m == null) return;
    await milestoneRepo?.delete(milestoneId);
    await goalUseCases.refreshGoalProgress(m.goalUid);
  }

  Future<TaskItem> createTask({
    required String milestoneUid,
    required String title,
    String? notes,
    DateTime? scheduledAt,
  }) async {
    final task = TaskItem()
      ..uid = _uuid.v4()
      ..milestoneUid = milestoneUid
      ..title = title
      ..notes = notes
      ..scheduledAt = scheduledAt
      ..createdAt = DateTime.now();

    await taskRepo?.save(task);
    await _refreshMilestoneTaskProgress(milestoneUid);
    return task;
  }

  Future<void> toggleTask(int taskId) async {
    final task = await taskRepo?.getById(taskId);
    if (task == null) return;

    await taskRepo?.toggle(taskId);
    await _refreshMilestoneTaskProgress(task.milestoneUid);
  }

  Future<void> deleteTask(int taskId, String milestoneUid) async {
    await taskRepo?.delete(taskId);
    await _refreshMilestoneTaskProgress(milestoneUid);
  }

  Future<void> refreshMilestoneTaskProgress(String milestoneUid) =>
      _refreshMilestoneTaskProgress(milestoneUid);

  Future<void> _refreshMilestoneTaskProgress(String milestoneUid) async {
    final completed = await taskRepo?.countCompleted(milestoneUid) ?? 0;
    final total = await taskRepo?.countTotal(milestoneUid) ?? 0;
    await milestoneRepo?.updateTaskProgress(
      milestoneUid: milestoneUid,
      completed: completed,
      total: total,
    );
  }
}
