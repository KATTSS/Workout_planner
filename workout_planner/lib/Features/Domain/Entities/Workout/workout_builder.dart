import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

class WorkoutBuilder {
  static int _creationId = 0;
  DateTime? _date;
  final List<ExercisePerformance> _exercises = [];
  String? _notes;

  WorkoutBuilder setDate(DateTime date) {
    _date = date;
    return this;
  }

  WorkoutBuilder addExercise(ExercisePerformance exercise) {
    _exercises.add(exercise);
    return this;
  }

  WorkoutBuilder addExercises(List<ExercisePerformance> exercises) {
    _exercises.addAll(exercises);
    return this;
  }

  WorkoutBuilder setNotes(String? notes) {
    _notes = notes;
    return this;
  }

  Workout build() {
    assert(_date != null, 'Date must be set');
    assert(_exercises.isNotEmpty, 'At least one exercise is required');

    _creationId += 1;

    return Workout(
      id: _creationId,
      date: _date!,
      exercises: List.unmodifiable(_exercises),
      notes: _notes,
    );
  }

  Workout buildDraft() {
    _date ??= DateTime.now();
    return build();
  }
}
