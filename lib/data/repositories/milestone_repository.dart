import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/isar_service.dart';
import '../models/milestone.dart';
import '../models/task_item.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final milestoneRepositoryProvider = Provider<MilestoneRepository?>((ref) {
  return ref.watch(isarProvider).whenOrNull(data: MilestoneRepository.new);
});

/// Live stream of milestones belonging to a goal uid, ordered by due date.
final milestonesForGoalProvider =
    StreamProvider.family<List<Milestone>, String>((ref, goalUid) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.milestones
      .filter()
      .goalUidEqualTo(goalUid)
      .sortByIsCompleted()
      .thenByDueDate()
      .watch(fireImmediately: true);
});

/// Live stream of all upcoming (incomplete, not overdue) milestones across all
/// goals — used by the dashboard to show "due soon" items.
final upcomingMilestonesProvider =
    StreamProvider<List<Milestone>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.milestones
      .filter()
      .isCompletedEqualTo(false)
      // Include overdue items as well as upcoming ones
      .sortByDueDate()
      .limit(10)
      .watch(fireImmediately: true);
});

final milestoneByIdProvider =
    StreamProvider.family<Milestone?, int>((ref, id) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.milestones.watchObject(id, fireImmediately: true);
});

// ── Repository ────────────────────────────────────────────────────────────────

class MilestoneRepository {
  const MilestoneRepository(this._isar);

  final Isar _isar;

  Future<Milestone?> getById(int id) => _isar.milestones.get(id);

  Future<Milestone?> getByUid(String uid) =>
      _isar.milestones.filter().uidEqualTo(uid).findFirst();

  Future<List<Milestone>> getForGoal(String goalUid) =>
      _isar.milestones.filter().goalUidEqualTo(goalUid).findAll();

  Future<List<Milestone>> getForGoals(List<String> goalUids) {
    if (goalUids.isEmpty) return Future.value([]);
    return _isar.milestones
        .filter()
        .anyOf(goalUids, (q, uid) => q.goalUidEqualTo(uid))
        .findAll();
  }

  Future<void> save(Milestone milestone) async {
    milestone.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.milestones.put(milestone));
  }

  Future<void> delete(int id) async {
    final m = await _isar.milestones.get(id);
    if (m == null) return;

    await _isar.writeTxn(() async {
      // 1. Delete child tasks
      await _isar.taskItems.filter().milestoneUidEqualTo(m.uid).deleteAll();
      // 2. Delete the milestone
      await _isar.milestones.delete(id);
    });
  }

  Future<void> markComplete(int id) async {
    final m = await _isar.milestones.get(id);
    if (m == null) return;
    m.isCompleted = true;
    m.completedAt = DateTime.now();
    m.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.milestones.put(m));
  }

  Future<void> markIncomplete(int id) async {
    final m = await _isar.milestones.get(id);
    if (m == null) return;
    m.isCompleted = false;
    m.completedAt = null;
    m.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.milestones.put(m));
  }

  /// Update task counters after a task is added/completed/deleted.
  Future<void> updateTaskProgress({
    required String milestoneUid,
    required int completed,
    required int total,
  }) async {
    final m =
        await _isar.milestones.filter().uidEqualTo(milestoneUid).findFirst();
    if (m == null) return;
    m.completedTasks = completed;
    m.totalTasks = total;
    m.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.milestones.put(m));
  }

  /// Count completed milestones for a goal (for streak/analytics).
  Future<int> countCompleted(String goalUid) => _isar.milestones
      .filter()
      .goalUidEqualTo(goalUid)
      .isCompletedEqualTo(true)
      .count();

  Future<int> countTotal(String goalUid) =>
      _isar.milestones.filter().goalUidEqualTo(goalUid).count();
}
