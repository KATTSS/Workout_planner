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
      isDone: workout.isCompleted,
      notes: workout.notes,
    );
  }

  static Workout toDomain(
    UserHistModel model, {
    Map<int, Exercise>? exerciseMap,
  }) {
    final exercises = _deserializeExercises(model.exercisesJson, exerciseMap);
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

  static List<ExercisePerformance> _deserializeExercises(
    String exercisesJson,
    Map<int, Exercise>? exerciseMap,
  ) {
    if (exercisesJson.isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(exercisesJson);

    return jsonList.map((item) {
      final exerciseId = item['exerciseId'] as int;
      final setsJson = item['sets'] as List<dynamic>;

      // Get Exercise from mapping or create temporary one
      Exercise exercise;
      if (exerciseMap != null && exerciseMap.containsKey(exerciseId)) {
        exercise = exerciseMap[exerciseId]!;
      } else {
        // Placeholder when mapping is not provided
        final category = _parseCategory(item['category'] as String?);
        final equipment = _parseEquipment(item['equipment'] as String?);

        exercise = Exercise(
          id: exerciseId,
          name: 'Exercise #$exerciseId',
          level: 1,
          category: category,
          equipment: equipment,
          description: '',
          muscle: '',
          secondaryMuscle: '',
        );
      }

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

  static ExerciseCategory _parseCategory(String? category) {
    if (category == null) return ExerciseCategory.strength;
    try {
      return ExerciseCategory.values.firstWhere((e) => e.name == category);
    } catch (_) {
      return ExerciseCategory.strength;
    }
  }

  static Equipment _parseEquipment(String? equipment) {
    if (equipment == null) return Equipment.other;
    return Equipment.fromString(equipment);
  }
}
