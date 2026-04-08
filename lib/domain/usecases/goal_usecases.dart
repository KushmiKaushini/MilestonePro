import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/goal.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/milestone_repository.dart';

const _uuid = Uuid();

final goalUseCasesProvider = Provider<GoalUseCases>((ref) {
  final goalRepo = ref.watch(goalRepositoryProvider);
  final milestoneRepo = ref.watch(milestoneRepositoryProvider);
  return GoalUseCases(goalRepo: goalRepo, milestoneRepo: milestoneRepo);
});

class GoalUseCases {
  const GoalUseCases({
    required this.goalRepo,
    required this.milestoneRepo,
  });

  final GoalRepository? goalRepo;
  final MilestoneRepository? milestoneRepo;

  Future<Goal> createGoal({
    required String title,
    String? description,
    required String category,
    required DateTime startDate,
    DateTime? targetDate,
    int colorIndex = 0,
    int iconCode = 0xe87d,
  }) async {
    final goal = Goal()
      ..uid = _uuid.v4()
      ..title = title
      ..description = description
      ..category = category
      ..startDate = startDate
      ..targetDate = targetDate
      ..colorIndex = colorIndex
      ..iconCode = iconCode
      ..createdAt = DateTime.now();

    await goalRepo?.save(goal);
    return goal;
  }

  Future<void> updateGoal(Goal goal) async {
    await goalRepo?.save(goal);
  }

  Future<void> deleteGoal(int goalId) async {
    await goalRepo?.deleteRecursive(goalId);
  }

  Future<void> refreshGoalProgress(String goalUid) async {
    final completed = await milestoneRepo?.countCompleted(goalUid) ?? 0;
    final total = await milestoneRepo?.countTotal(goalUid) ?? 0;
    await goalRepo?.updateProgress(
      goalUid: goalUid,
      completed: completed,
      total: total,
    );
  }
}
