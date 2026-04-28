import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

class WorkoutMapper {
  static UserHistModel toModel(Workout workout) {
    return UserHistModel(
      id: workout.id,
      date: workout.date.toIso8601String().split('T')[0],
      muscleGroup: workout.primaryMuscleGroup,
      isDone: workout.isCompleted,
      notes: workout.notes,
    );
  }

  static List<Map<String, dynamic>> exercisesToMaps(Workout workout) {
    return workout.exercises.asMap().entries.map((entry) {
      return {
        'workout_id': workout.id,
        'exercise_id': entry.value.exerciseId,
        'order_index': entry.key,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> setsToMaps({
    required int workoutExerciseId,
    required List<SetData> sets,
  }) {
    return sets.asMap().entries.map((entry) {
      return {
        'workout_exercise_id': workoutExerciseId,
        'set_number': entry.key,
        'weight': entry.value.weight,
        'reps': entry.value.reps,
        'duration': entry.value.duration,
      };
    }).toList();
  }

  static Workout toDomain({
    required UserHistModel workoutModel,
    required List<ExercisePerformance> exercises,
  }) {
    return Workout(
      id: workoutModel.id,
      date: DateTime.parse(workoutModel.date),
      exercises: exercises,
      isCompleted: workoutModel.isDone,
      notes: workoutModel.notes,
    );
  }

  static ExercisePerformance? assembleExercise({
    required Map<String, dynamic> exerciseMap,
    required Map<int, Exercise> exercisesById,
    required Map<int, List<SetData>> setsByWorkoutExercise,
  }) {
    final exerciseId = exerciseMap['exercise_id'] as int;
    final workoutExerciseId = exerciseMap['id'] as int;
    final exercise = exercisesById[exerciseId];

    if (exercise == null) return null;

    final sets = setsByWorkoutExercise[workoutExerciseId] ?? [];

    return ExercisePerformance.create(exercise: exercise, sets: sets);
  }

  static SetData mapToSetData(Map<String, dynamic> map) {
    return SetData(
      weight: map['weight'] as double?,
      reps: map['reps'] as int?,
      duration: map['duration'] as double?,
    );
  }
}
