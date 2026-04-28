import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';

class ManageWorkoutExercises {
  Workout addExercise(Workout workout, ExercisePerformance exercise) {
    _validateNoDuplicate(workout, exercise.exerciseId);
    final updatedExercises = List<ExercisePerformance>.from(workout.exercises)
      ..add(exercise);
    return workout.copyWith(exercises: updatedExercises);
  }

  Workout removeExercise(Workout workout, int exerciseId) {
    if (workout.isCompleted && workout.exercises.length <= 1) {
      throw WorkoutValidationException(
        'Cannot remove last exercise from completed workout',
      );
    }
    final updatedExercises = workout.exercises
        .where((ex) => ex.exerciseId != exerciseId)
        .toList();
    return workout.copyWith(exercises: updatedExercises);
  }

  Workout reorderExercises(Workout workout, int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= workout.exercises.length) {
      throw RangeError('Invalid exercise index');
    }

    final updatedExercises = List<ExercisePerformance>.from(workout.exercises);
    if (oldIndex < newIndex) newIndex -= 1;
    final exercise = updatedExercises.removeAt(oldIndex);
    updatedExercises.insert(newIndex, exercise);
    return workout.copyWith(exercises: updatedExercises);
  }

  Workout replaceExercise(
    Workout workout,
    int oldExerciseId,
    ExercisePerformance newExercise,
  ) {
    _validateNoDuplicate(
      workout,
      newExercise.exerciseId,
      exceptId: oldExerciseId,
    );

    final updatedExercises = workout.exercises.map((ex) {
      return ex.exerciseId == oldExerciseId ? newExercise : ex;
    }).toList();
    return workout.copyWith(exercises: updatedExercises);
  }

  void _validateNoDuplicate(Workout workout, int exerciseId, {int? exceptId}) {
    final exists = workout.exercises.any(
      (ex) => ex.exerciseId == exerciseId && ex.exerciseId != exceptId,
    );
    if (exists) {
      throw WorkoutValidationException('Exercise already exists in workout');
    }
  }
}
