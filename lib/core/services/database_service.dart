import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/goals/domain/models/goal.dart';

class DatabaseService {
  static late Isar _isar;

  static Isar get isar => _isar;

  static Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [GoalSchema, MilestoneSchema],
        directory: dir.path,
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }
}
