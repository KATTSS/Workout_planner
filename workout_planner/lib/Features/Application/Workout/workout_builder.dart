import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';

class WorkoutBuilder {
  static int _creationId = 0;
  DateTime? _date;
  final List<ExercisePerformance> _exercises = [];
  String? _notes;
  bool _isDraft = true;

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

  WorkoutBuilder removeExercise(int exerciseId) {
    _exercises.removeWhere((ex) => ex.exerciseId == exerciseId);
    return this;
  }

  WorkoutBuilder setNotes(String? notes) {
    _notes = notes;
    return this;
  }

  WorkoutBuilder asDraft() {
    _isDraft = true;
    return this;
  }

  WorkoutBuilder asCompleted() {
    _isDraft = false;
    return this;
  }

  Workout build() {
    assert(_date != null, 'Date must be set');
    //assert(_exercises.isNotEmpty, 'At least one exercise is required');

    _creationId += 1;

    return Workout(
      id: _creationId,
      date: _date!,
      exercises: List.unmodifiable(_exercises),
      isCompleted: !_isDraft,
      notes: _notes,
    );
  }

  Workout buildFromTemplate(Workout template, DateTime newDate) {
    _date = newDate;
    _exercises.clear();
    _exercises.addAll(template.exercises);
    _notes = template.notes;
    _isDraft = !template.isCompleted;
    return build();
  }
}
