import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';
import 'package:workout_planner/Features/Domain/Repository/excercise_repo.dart';
import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Data/Repository/Mappers/workout_mapper.dart';
import 'package:workout_planner/Features/Data/Service/ilocal_workout_data_source.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Data/Service/query_builder.dart';

class HistoryRepo implements IHistoryRepo {
  final ILocalWorkoutDataSource _workoutDataSource;
  final IExerciseRepo _exerciseRepo;

  HistoryRepo(this._workoutDataSource, this._exerciseRepo);

  @override
  Future<int> saveWorkout(Workout workout) async {
    final workoutMap = WorkoutMapper.toModel(workout).toMap();
    final workoutId = await _workoutDataSource.insertWorkout(workoutMap);

    for (var i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];

      final exerciseMap = {
        'workout_id': workoutId,
        'exercise_id': exercise.exerciseId,
        'order_index': i,
      };
      final weId = await _workoutDataSource.insertWorkoutExercise(exerciseMap);

      final setMaps = WorkoutMapper.setsToMaps(
        workoutExerciseId: weId,
        sets: exercise.sets,
      );

      for (final setMap in setMaps) {
        await _workoutDataSource.insertExerciseSet(setMap);
      }
    }

    return workoutId;
  }

  @override
  Future<Workout?> getWorkout(int id) async {
    final workoutMap = await _workoutDataSource.getWorkoutById(id);
    if (workoutMap == null) return null;

    final model = UserHistModel.fromMap(workoutMap);

    final exercises = await _getWorkoutExercises(id);

    return WorkoutMapper.toDomain(workoutModel: model, exercises: exercises);
  }

  @override
  Future<int> updateWorkout(Workout workout) async {
    await _workoutDataSource.updateWorkout(
      workout.id,
      WorkoutMapper.toModel(workout).toMap(),
    );

    await _workoutDataSource.deleteExerciseSetsByWorkout(workout.id);
    await _workoutDataSource.deleteWorkoutExercises(workout.id);

    await _saveExercisesData(workout);

    return workout.id;
  }

  Future<List<ExercisePerformance>> _getWorkoutExercises(int workoutId) async {
    final exerciseMaps = await _workoutDataSource.getWorkoutExercises(
      workoutId,
    );
    if (exerciseMaps.isEmpty) return [];

    final exerciseIds = exerciseMaps
        .map((m) => m['exercise_id'] as int)
        .toSet()
        .toList();
    final exercises = await _exerciseRepo.getByIds(exerciseIds);
    final exercisesById = {for (var e in exercises) e.id: e};

    final setMaps = await _workoutDataSource.getExerciseSetsForWorkout(
      workoutId,
    );
    final setsByWE = _groupSetsByWorkoutExercise(setMaps);

    return exerciseMaps
        .map(
          (em) => WorkoutMapper.assembleExercise(
            exerciseMap: em,
            exercisesById: exercisesById,
            setsByWorkoutExercise: setsByWE,
          ),
        )
        .whereType<ExercisePerformance>()
        .toList();
  }

  Map<int, List<SetData>> _groupSetsByWorkoutExercise(
    List<Map<String, dynamic>> setMaps,
  ) {
    final groups = <int, List<SetData>>{};
    for (final map in setMaps) {
      final weId = map['workout_exercise_id'] as int;
      groups.putIfAbsent(weId, () => []).add(WorkoutMapper.mapToSetData(map));
    }
    return groups;
  }

  Future<void> _saveExercisesData(Workout workout) async {
    for (var i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];

      final exerciseMap = {
        'workout_id': workout.id,
        'exercise_id': exercise.exerciseId,
        'order_index': i,
      };
      final weId = await _workoutDataSource.insertWorkoutExercise(exerciseMap);

      final setMaps = WorkoutMapper.setsToMaps(
        workoutExerciseId: weId,
        sets: exercise.sets,
      );

      for (final setMap in setMaps) {
        await _workoutDataSource.insertExerciseSet(setMap);
      }
    }
  }

  @override
  Future<void> deleteWorkout(int id) async {
    await _workoutDataSource.deleteExerciseSetsByWorkout(id);
    await _workoutDataSource.deleteWorkoutExercises(id);
    await _workoutDataSource.deleteWorkout(id);
  }

  @override
  Future<List<Workout>> getByDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final builder = QueryBuilder()
        .select()
        .from('workout_table')
        .where('date', '=', dateStr)
        .orderBy('date', descending: false);

    if (limit != null) {
      builder.limit(limit);
    }

    return _getWorkoutsFromQuery(builder);
  }

  @override
  Future<List<Workout>> getBeforeDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final builder = QueryBuilder()
        .select()
        .from('workout_table')
        .whereRaw('date < ?', [dateStr])
        .orderBy('date', descending: true);

    if (limit != null) {
      builder.limit(limit);
    }

    return _getWorkoutsFromQuery(builder);
  }

  @override
  Future<List<Workout>> getAfterDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final builder = QueryBuilder()
        .select()
        .from('workout_table')
        .whereRaw('date > ?', [dateStr])
        .orderBy('date', descending: false);

    if (limit != null) {
      builder.limit(limit);
    }

    return _getWorkoutsFromQuery(builder);
  }

  @override
  Future<List<Workout>> getAll({int? limit, bool newestFirst = true}) async {
    final builder = QueryBuilder()
        .select()
        .from('workout_table')
        .orderBy('date', descending: newestFirst);

    if (limit != null) {
      builder.limit(limit);
    }

    return _getWorkoutsFromQuery(builder);
  }

  Future<List<Workout>> _getWorkoutsFromQuery(QueryBuilder builder) async {
    final workoutMaps = await _workoutDataSource.queryWorkouts(builder);
    if (workoutMaps.isEmpty) return [];

    final workouts = <Workout>[];
    for (final workoutMap in workoutMaps) {
      final model = UserHistModel.fromMap(workoutMap);
      final exercises = await _getWorkoutExercises(model.id);
      workouts.add(
        WorkoutMapper.toDomain(workoutModel: model, exercises: exercises),
      );
    }

    return workouts;
  }
}
