import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/isar_service.dart';
import '../models/task_item.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final taskRepositoryProvider = Provider<TaskRepository?>((ref) {
  return ref.watch(isarProvider).whenOrNull(data: TaskRepository.new);
});

/// Live stream of tasks for a given milestone uid.
final tasksForMilestoneProvider =
    StreamProvider.family<List<TaskItem>, String>((ref, milestoneUid) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.taskItems
      .filter()
      .milestoneUidEqualTo(milestoneUid)
      .sortByIsCompleted()
      .thenByCreatedAt()
      .watch(fireImmediately: true);
});

// ── Repository ────────────────────────────────────────────────────────────────

class TaskRepository {
  const TaskRepository(this._isar);

  final Isar _isar;

  Future<List<TaskItem>> getForMilestone(String milestoneUid) =>
      _isar.taskItems
          .filter()
          .milestoneUidEqualTo(milestoneUid)
          .findAll();

  Future<void> save(TaskItem task) async {
    await _isar.writeTxn(() => _isar.taskItems.put(task));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.taskItems.delete(id));
  }

  Future<void> toggle(int id) async {
    final task = await _isar.taskItems.get(id);
    if (task == null) return;
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await _isar.writeTxn(() => _isar.taskItems.put(task));
  }

  Future<int> countCompleted(String milestoneUid) => _isar.taskItems
      .filter()
      .milestoneUidEqualTo(milestoneUid)
      .isCompletedEqualTo(true)
      .count();

  Future<int> countTotal(String milestoneUid) =>
      _isar.taskItems.filter().milestoneUidEqualTo(milestoneUid).count();
}
