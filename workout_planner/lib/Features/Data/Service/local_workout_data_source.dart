import 'package:workout_planner/Features/Data/Service/ilocal_workout_data_source.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Data/Service/query_builder.dart';

class LocalWorkoutDataSource implements ILocalWorkoutDataSource {
  final UserHistDb _db;

  LocalWorkoutDataSource(this._db);

  @override
  Future<int> insertWorkout(Map<String, dynamic> workoutMap) async {
    final builder = QueryBuilder().insert(workoutMap).from('workout_table');
    return _db.executeCommand(builder);
  }

  @override
  Future<int> insertWorkoutExercise(Map<String, dynamic> exerciseMap) async {
    final builder = QueryBuilder()
        .insert(exerciseMap)
        .from('workout_exercises');
    return _db.executeCommand(builder);
  }

  @override
  Future<int> insertExerciseSet(Map<String, dynamic> setMap) async {
    final builder = QueryBuilder().insert(setMap).from('exercise_sets');
    return _db.executeCommand(builder);
  }

  @override
  Future<void> deleteWorkoutExercises(int workoutId) async {
    final builder = QueryBuilder()
        .delete()
        .from('workout_exercises')
        .where('workout_id', '=', workoutId);
    await _db.executeCommand(builder);
  }

  @override
  Future<void> deleteExerciseSetsByWorkout(int workoutId) async {
    await _db.executeCommand(
      QueryBuilder().delete().from('exercise_sets').whereRaw(
        'workout_exercise_id IN (SELECT id FROM workout_exercises WHERE workout_id = ?)',
        [workoutId],
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> getWorkoutById(int id) async {
    final builder = QueryBuilder()
        .select()
        .from('workout_table')
        .where('workout_id', '=', id);
    return _db.executeQuerySingle(builder);
  }

  @override
  Future<List<Map<String, dynamic>>> getWorkoutExercises(int workoutId) async {
    final builder = QueryBuilder()
        .select()
        .from('workout_exercises')
        .where('workout_id', '=', workoutId)
        .orderBy('order_index');
    return _db.executeQuery(builder);
  }

  @override
  Future<List<Map<String, dynamic>>> getExerciseSets(
    int workoutExerciseId,
  ) async {
    final builder = QueryBuilder()
        .select()
        .from('exercise_sets')
        .where('workout_exercise_id', '=', workoutExerciseId)
        .orderBy('set_number');
    return _db.executeQuery(builder);
  }

  @override
  Future<List<Map<String, dynamic>>> getExerciseSetsForWorkout(
    int workoutId,
  ) async {
    final builder = QueryBuilder()
        .select(['exercise_sets.*'])
        .from('exercise_sets')
        .whereRaw(
          'workout_exercise_id IN (SELECT id FROM workout_exercises WHERE workout_id = ?)',
          [workoutId],
        )
        .orderBy('workout_exercise_id, set_number');
    return _db.executeQuery(builder);
  }

  @override
  Future<List<Map<String, dynamic>>> queryWorkouts(QueryBuilder query) async {
    return _db.executeQuery(query);
  }

  @override
  Future<void> updateWorkout(int id, Map<String, dynamic> workoutMap) async {
    final builder = QueryBuilder()
        .update(workoutMap)
        .from('workout_table')
        .where('workout_id', '=', id);
    await _db.executeCommand(builder);
  }

  @override
  Future<void> deleteWorkout(int id) async {
  final builder = QueryBuilder()
      .delete()
      .from('workout_table')
      .where('workout_id', '=', id);
  await _db.executeCommand(builder);
}
}
