import 'package:isar/isar.dart';

part 'goal.g.dart';

@collection
class Goal {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
  
  @Enumerated(EnumType.name)
  late GoalCategory category;

  DateTime? createdAt;
  DateTime? deadline;

  bool isCompleted = false;

  final milestones = IsarLinks<Milestone>();
}

@collection
class Milestone {
  Id id = Isar.autoIncrement;

  late String title;
  bool isCompleted = false;
  DateTime? completedAt;
}

enum GoalCategory {
  fitness,
  learning,
  finance,
  career,
  personal,
  other
}
