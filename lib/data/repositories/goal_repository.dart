import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/isar_service.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/task_item.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final goalRepositoryProvider = Provider<GoalRepository?>((ref) {
  return ref.watch(isarProvider).whenOrNull(data: GoalRepository.new);
});

/// Live stream of non-archived goals, newest-first.
final goalsStreamProvider = StreamProvider<List<Goal>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.goals
      .filter()
      .isArchivedEqualTo(false)
      .sortByIsPinnedDesc()
      .thenByCreatedAtDesc()
      .watch(fireImmediately: true);
});

/// Live stream of ALL goals (including archived) for analytics.
final allGoalsStreamProvider = StreamProvider<List<Goal>>((ref) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.goals.where().watch(fireImmediately: true);
});

/// Live stream of a single goal by its Isar id.
final goalByIdProvider =
    StreamProvider.family<Goal?, int>((ref, goalId) async* {
  final isar = await ref.watch(isarProvider.future);
  yield* isar.goals.watchObject(goalId, fireImmediately: true);
});

// ── Repository ────────────────────────────────────────────────────────────────

class GoalRepository {
  const GoalRepository(this._isar);

  final Isar _isar;

  Future<Goal?> getById(int id) => _isar.goals.get(id);

  Future<Goal?> getByUid(String uid) =>
      _isar.goals.filter().uidEqualTo(uid).findFirst();

  Future<List<Goal>> getAll({bool includeArchived = false}) {
    if (includeArchived) return _isar.goals.where().findAll();
    return _isar.goals.filter().isArchivedEqualTo(false).findAll();
  }

  /// Insert or update a goal.
  Future<void> save(Goal goal) async {
    goal.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.goals.put(goal));
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.goals.delete(id));
  }

  Future<void> deleteRecursive(int id) async {
    final goal = await _isar.goals.get(id);
    if (goal == null) return;

    await _isar.writeTxn(() async {
      // 1. Get all milestones for this goal
      final milestones = await _isar.milestones
          .filter()
          .goalUidEqualTo(goal.uid)
          .findAll();

      // 2. Delete all tasks for these milestones
      for (final m in milestones) {
        await _isar.taskItems.filter().milestoneUidEqualTo(m.uid).deleteAll();
      }

      // 3. Delete all milestones
      await _isar.milestones.filter().goalUidEqualTo(goal.uid).deleteAll();

      // 4. Delete the goal
      await _isar.goals.delete(id);
    });
  }

  Future<void> archive(int id) async {
    final goal = await _isar.goals.get(id);
    if (goal == null) return;
    goal.isArchived = true;
    goal.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.goals.put(goal));
  }

  Future<void> togglePin(int id) async {
    final goal = await _isar.goals.get(id);
    if (goal == null) return;
    goal.isPinned = !goal.isPinned;
    goal.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.goals.put(goal));
  }

  /// Update denormalised progress counters and recalculate streak.
  Future<void> updateProgress({
    required String goalUid,
    required int completed,
    required int total,
  }) async {
    final goal =
        await _isar.goals.filter().uidEqualTo(goalUid).findFirst();
    if (goal == null) return;

    goal.completedMilestones = completed;
    goal.totalMilestones = total;
    // Recalculate streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = goal.lastActivityDate != null
        ? DateTime(goal.lastActivityDate!.year, goal.lastActivityDate!.month,
            goal.lastActivityDate!.day)
        : null;

    if (last == null) {
      goal.currentStreak = 1;
    } else {
      final daysSinceLast = today.difference(last).inDays;
      if (daysSinceLast == 1) {
        goal.currentStreak += 1;
      } else if (daysSinceLast > 1) {
        goal.currentStreak = 1;
      }
      // if daysSinceLast == 0, streak remains unchanged as it's the same day
    }

    if (goal.currentStreak > goal.longestStreak) {
      goal.longestStreak = goal.currentStreak;
    }

    goal.lastActivityDate = now;
    goal.updatedAt = now;
    await _isar.writeTxn(() => _isar.goals.put(goal));
  }
}
