import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/task_item.dart';

/// Riverpod provider that opens (and caches) the Isar database.
/// Use `ref.watch(isarProvider.future)` or `ref.watch(isarProvider)` inside
/// AsyncNotifiers and StreamProviders.
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [GoalSchema, MilestoneSchema, TaskItemSchema],
    directory: dir.path,
    name: 'milestone_pro',
  );
  ref.onDispose(isar.close);
  return isar;
});
