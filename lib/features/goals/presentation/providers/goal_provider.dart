import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milestone_pro/features/goals/domain/models/goal.dart';
import 'package:milestone_pro/features/goals/data/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) => GoalRepository());

final goalListProvider = StreamProvider<List<Goal>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.watchGoals();
});

class GoalNotifier extends StateNotifier<GoalNotifierState> {
  final GoalRepository _repository;

  GoalNotifier(this._repository) : super(GoalNotifierState());

  Future<void> addGoal(Goal goal) async {
    state = state.copyWith(status: GoalNotifierStatus.loading);
    try {
      await _repository.saveGoal(goal);
      state = state.copyWith(status: GoalNotifierStatus.success);
    } catch (e, st) {
      state = state.copyWith(status: GoalNotifierStatus.error, error: e, stackTrace: st);
    }
  }

  Future<void> toggleGoal(int id) async {
    state = state.copyWith(status: GoalNotifierStatus.loading);
    try {
      await _repository.toggleGoalCompletion(id);
      state = state.copyWith(status: GoalNotifierStatus.success);
    } catch (e, st) {
      state = state.copyWith(status: GoalNotifierStatus.error, error: e, stackTrace: st);
    }
  }

  Future<void> deleteGoal(int id) async {
    state = state.copyWith(status: GoalNotifierStatus.loading);
    try {
      await _repository.deleteGoal(id);
      state = state.copyWith(status: GoalNotifierStatus.success);
    } catch (e, st) {
      state = state.copyWith(status: GoalNotifierStatus.error, error: e, stackTrace: st);
    }
  }
}

class GoalNotifierState {
  final GoalNotifierStatus status;
  final Object? error;
  final StackTrace? stackTrace;

  GoalNotifierState({
    this.status = GoalNotifierStatus.idle,
    this.error,
    this.stackTrace,
  });

  GoalNotifierState copyWith({
    GoalNotifierStatus? status,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return GoalNotifierState(
      status: status ?? this.status,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }
}

enum GoalNotifierStatus { idle, loading, success, error }

final goalNotifierProvider = StateNotifierProvider<GoalNotifier, GoalNotifierState>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return GoalNotifier(repository);
});
