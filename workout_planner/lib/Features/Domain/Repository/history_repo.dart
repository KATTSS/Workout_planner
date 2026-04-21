import 'package:workout_planner/Features/Domain/Entities/workout_history.dart';

abstract class IHistoryRepo {
  Future<void> saveHistory(WorkoutHistory workout);
  Future<WorkoutHistory?> getHistory(int id);
  Future<List<WorkoutHistory>> getByDate(DateTime date, {int? limit});
  Future<List<WorkoutHistory>> getBeforeDate(DateTime date, {int? limit});
  Future<List<WorkoutHistory>> getAfterDate(DateTime date, {int? limit});
  Future<List<WorkoutHistory>> getAll({int? limit, bool newestFirst = true});
  Future<void> updateHistory(WorkoutHistory workout);
  Future<void> deleteHistory(int id);
}
