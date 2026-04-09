import 'package:isar/isar.dart';
import '../../domain/models/goal.dart';
import '../../../../core/services/database_service.dart';

class GoalRepository {
  final Isar _isar = DatabaseService.isar;

  Future<List<Goal>> getAllGoals() async {
    return _isar.goals.where().findAll();
  }

  Stream<List<Goal>> watchGoals() {
    return _isar.goals.where().watch(fireImmediately: true);
  }

  Future<void> saveGoal(Goal goal) async {
    await _isar.writeTxn(() async {
      await _isar.goals.put(goal);
    });
  }

  Future<void> deleteGoal(int id) async {
    await _isar.writeTxn(() async {
      await _isar.goals.delete(id);
    });
  }

  Future<void> toggleGoalCompletion(int id) async {
    await _isar.writeTxn(() async {
      final goal = await _isar.goals.get(id);
      if (goal != null) {
        goal.isCompleted = !goal.isCompleted;
        await _isar.goals.put(goal);
      }
    });
  }
}
