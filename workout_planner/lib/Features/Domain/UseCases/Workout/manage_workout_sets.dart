import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';

class SetManagement {
  Workout addSet(Workout workout, int exerciseId, SetData set) {
    final exercise = _findExercise(workout, exerciseId);
    _validateSetData(exercise, set);
    _validateMaxSets(exercise);

    try {
      final updatedExercises = workout.exercises.map((ex) {
        if (ex.exerciseId != exerciseId) return ex;
        return ex.addSet(set);
      }).toList();
      return workout.copyWith(exercises: updatedExercises);
    } catch (e) {
      if (e is ArgumentError) {
        throw WorkoutValidationException(e.message ?? 'Invalid set data');
      }
      rethrow;
    }
  }

  Workout updateSet(
    Workout workout,
    int exerciseId,
    int setIndex,
    SetData newSet,
  ) {
    final exercise = _findExercise(workout, exerciseId);
    _validateSetData(exercise, newSet);

    try {
      final updatedExercises = workout.exercises.map((ex) {
        if (ex.exerciseId != exerciseId) return ex;
        return ex.updateSet(setIndex, newSet);
      }).toList();
      return workout.copyWith(exercises: updatedExercises);
    } catch (e) {
      if (e is ArgumentError) {
        throw WorkoutValidationException(e.message ?? 'Invalid set data');
      }
      rethrow;
    }
  }

  Workout removeSet(Workout workout, int exerciseId, int setIndex) {
    final exercise = _findExercise(workout, exerciseId);
    _validateMinSets(exercise);

    try {
      final updatedExercises = workout.exercises.map((ex) {
        if (ex.exerciseId != exerciseId) return ex;
        return ex.removeSet(setIndex);
      }).toList();
      return workout.copyWith(exercises: updatedExercises);
    } catch (e) {
      if (e is RangeError) {
        throw WorkoutValidationException('Invalid set index: $setIndex');
      }
      rethrow;
    }
  }

  ExercisePerformance _findExercise(Workout workout, int exerciseId) {
    try {
      final exercise = workout.exercises.firstWhere(
        (ex) => ex.exerciseId == exerciseId,
      );
      return exercise;
    } catch (e) {
      throw WorkoutValidationException('Exercise not found');
    }
  }

  void _validateSetData(ExercisePerformance exercise, SetData set) {
    final type = exercise.exercise.performanceType;
    print('Validating set: $set for type: $type');
    if (!set.isValidFor(type)) {
      throw WorkoutValidationException(
        'Invalid set data for ${exercise.exercise.name}',
      );
    }
  }

  void _validateMaxSets(ExercisePerformance exercise) {
    if (exercise.setsCount >= 10) {
      throw WorkoutValidationException('Maximum 10 sets per exercise');
    }
  }

  void _validateMinSets(ExercisePerformance exercise) {
    if (exercise.setsCount <= 1) {
      throw WorkoutValidationException('Cannot remove last set');
    }
  }
}