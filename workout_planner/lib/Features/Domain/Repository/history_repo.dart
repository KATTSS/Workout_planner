import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

abstract class IHistoryRepo {
  Future<int> saveWorkout(Workout workout);
  Future<Workout?> getWorkout(int id);
  Future<void> deleteWorkout(int id);
  Future<int> updateWorkout(Workout workout);

  Future<List<Workout>> getByDate(DateTime date, {int? limit});
  Future<List<Workout>> getBeforeDate(DateTime date, {int? limit});
  Future<List<Workout>> getAfterDate(DateTime date, {int? limit});
  Future<List<Workout>> getAll({int? limit, bool newestFirst = true});
}
