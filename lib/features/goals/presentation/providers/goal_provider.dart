import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/goal.dart';
import '../../data/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider((ref) => GoalRepository());

final goalListProvider = StreamProvider<List<Goal>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.watchGoals();
});

class GoalNotifier extends StateNotifier<AsyncValue<void>> {
  final GoalRepository _repository;

  GoalNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addGoal(Goal goal) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveGoal(goal);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleGoal(int id) async {
    try {
      await _repository.toggleGoalCompletion(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGoal(int id) async {
    try {
      await _repository.deleteGoal(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final goalNotifierProvider = StateNotifierProvider<GoalNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return GoalNotifier(repository);
});
