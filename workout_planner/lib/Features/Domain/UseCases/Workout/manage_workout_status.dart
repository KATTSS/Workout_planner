import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';

class WorkoutStatusManager {
  final DateTime Function() _dateTimeProvider;

  WorkoutStatusManager({DateTime Function()? dateTimeProvider})
    : _dateTimeProvider = dateTimeProvider ?? (() => DateTime.now());

  Workout updateDate(Workout workout, DateTime newDate) {
    if (workout.isCompleted && newDate.isAfter(_dateTimeProvider())) {
      throw WorkoutValidationException(
        'Cannot set future date for completed workout',
      );
    }
    return Workout(
      id: workout.id,
      date: newDate,
      exercises: workout.exercises,
      isCompleted: workout.isCompleted,
      notes: workout.notes,
    );
  }

  Workout updateNotes(Workout workout, String? newNotes) {
    if (newNotes != null && newNotes.length > 1000) {
      throw WorkoutValidationException('Notes cannot exceed 1000 characters');
    }
    return Workout(
      id: workout.id,
      date: workout.date,
      exercises: workout.exercises,
      isCompleted: workout.isCompleted,
      notes: newNotes,
    );
  }

  Workout markAsCompleted(Workout workout) {
    if (workout.exercises.isEmpty) {
      throw WorkoutValidationException('Cannot complete empty workout');
    }
    return Workout(
      id: workout.id,
      date: workout.date,
      exercises: workout.exercises,
      isCompleted: true,
      notes: workout.notes,
    );
  }

  Workout markAsDraft(Workout workout) {
    return Workout(
      id: workout.id,
      date: workout.date,
      exercises: workout.exercises,
      isCompleted: false,
      notes: workout.notes,
    );
  }
}
