import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'dart:convert';

class WorkoutMapper {
  static UserHistModel toModel(Workout workout) {
    return UserHistModel(
      id: workout.id,
      date: workout.date.toIso8601String().split('T')[0],
      exercisesJson: _serializeExercises(workout.exercises),
      muscleGroup: workout.primaryMuscleGroup,
      isDone: workout.isCompleted,
      notes: workout.notes,
    );
  }

  static Workout toDomain(UserHistModel model) {
    final exercises = _deserializeExercises(model.exercisesJson);
    return Workout(
      id: model.id,
      date: DateTime.parse(model.date),
      exercises: exercises,
      isCompleted: model.isDone,
      notes: model.notes,
    );
  }

  static String _serializeExercises(List<ExercisePerformance> exercises) {
    final List<Map<String, dynamic>> jsonList = exercises.map((e) {
      return {
        'exerciseId': e.exerciseId,
        'category': e.exercise.category.name,
        'equipment': e.exercise.equipment.name,
        'sets': _serializeSets(e.sets),
      };
    }).toList();

    return jsonEncode(jsonList);
  }

  static List<Map<String, dynamic>> _serializeSets(List<SetData> sets) {
    return sets.map((set) {
      final map = <String, dynamic>{};
      if (set.weight != null) map['w'] = set.weight;
      if (set.reps != null) map['r'] = set.reps;
      if (set.duration != null) map['d'] = set.duration;
      return map;
    }).toList();
  }

  static List<ExercisePerformance> _deserializeExercises(String exercisesJson) {
    if (exercisesJson.isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(exercisesJson);

    return jsonList.map((item) {
      final exerciseId = item['exerciseId'] as int;
      final setsJson = item['sets'] as List<dynamic>;
      final exerciseCat = item['category'] as String;
      final exerciseEq = Equipment.fromString(item['equipment'] as String);

      Exercise exercise = Exercise(
        id: exerciseId,
        name: "ex",
        level: 0,
        category: _parseCategory(exerciseCat),
        equipment: exerciseEq,
        description: "",
        muscle: "",
        secondaryMuscle: "",
      );

      final sets = _deserializeSets(setsJson);

      return ExercisePerformance.create(exercise: exercise, sets: sets);
    }).toList();
  }

  static List<SetData> _deserializeSets(List<dynamic> setsJson) {
    return setsJson.map((setJson) {
      return SetData(
        weight: setJson['w'] as double?,
        reps: setJson['r'] as int?,
        duration: setJson['d'] as double?,
      );
    }).toList();
  }

  static ExerciseCategory _parseCategory(String category) {
    try {
      return ExerciseCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == category.toLowerCase(),
      );
    } catch (_) {
      switch (category.toLowerCase()) {
        case 'olympic weightlifting':
          return ExerciseCategory.olympicWeightlifting;
        default:
          return ExerciseCategory.strength;
      }
    }
  }
}
