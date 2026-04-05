import 'package:workout_planner/Features/Domain/Entities/workout_history.dart';

abstract class IHistoryRepo {
  Future<void> saveHistory(WorkoutHistory workout);
}
