import 'package:workout_planner/Features/Data/Service/query_builder.dart';

abstract class ILocalWorkoutDataSource {
  Future<int> insertWorkout(Map<String, dynamic> workoutMap);
  Future<int> insertWorkoutExercise(Map<String, dynamic> exerciseMap);
  Future<int> insertExerciseSet(Map<String, dynamic> setMap);

  Future<void> updateWorkout(int id, Map<String, dynamic> workoutMap);
  Future<void> deleteWorkoutExercises(int workoutId);
  Future<void> deleteExerciseSetsByWorkout(int workoutId);
  Future<void> deleteWorkout(int id);

  Future<Map<String, dynamic>?> getWorkoutById(int id);
  Future<List<Map<String, dynamic>>> getWorkoutExercises(int workoutId);
  Future<List<Map<String, dynamic>>> getExerciseSets(int workoutExerciseId);
  Future<List<Map<String, dynamic>>> getExerciseSetsForWorkout(int workoutId);

  Future<List<Map<String, dynamic>>> queryWorkouts(QueryBuilder query);
}
