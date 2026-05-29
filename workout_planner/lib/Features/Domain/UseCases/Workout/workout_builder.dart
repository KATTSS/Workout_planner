import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';

class WorkoutBuilder {
  int? _id;
  DateTime? _date;
  final List<ExercisePerformance> _exercises = [];
  String? _notes;
  bool _isCompleted = false;
  bool _isBuilt = false;

  int get id => _id ?? -1;
  DateTime get date => _date ?? DateTime(1979, 1, 1);
  List<ExercisePerformance> get exercises => List.unmodifiable(_exercises);
  String? get notes => _notes;
  bool get isCompleted => _isCompleted;
  bool get isBuilt => _isBuilt;

  WorkoutBuilder setId(int id) {
    if (id <= 0) {
      throw WorkoutValidationException('Workout ID must be positive');
    }
    _id = id;
    return this;
  }

  WorkoutBuilder setDate(DateTime date) {
    // _validateDate(date);
    _date = date;
    return this;
  }

  WorkoutBuilder addExercise(ExercisePerformance exercise) {
    _exercises.add(exercise);
    return this;
  }

  WorkoutBuilder addExercises(List<ExercisePerformance> exercises) {
    // if (exercises.isEmpty) {
    //   throw WorkoutValidationException('Exercises list cannot be empty');
    // }
    if (exercises.isEmpty) {
      return this;
    }
    _exercises.addAll(exercises.toList());
    return this;
  }

  bool removeExercise(int exerciseId) {
    final initialLength = _exercises.length;
    _exercises.removeWhere((ex) => ex.exerciseId == exerciseId);
    return _exercises.length < initialLength;
  }

  WorkoutBuilder setNotes(String? notes) {
    if (notes != null && notes.isEmpty) {
      _notes = null;
    } else {
      _notes = notes;
    }
    return this;
  }

  WorkoutBuilder asCompleted() {
    _isCompleted = true;
    return this;
  }

  WorkoutBuilder asDraft() {
    _isCompleted = false;
    return this;
  }

  Workout build() {
    _validateBeforeBuild();
    _isBuilt = true;

    return Workout(
      id: _id!,
      date: _date!,
      exercises: List.unmodifiable(_exercises.toList()),
      isCompleted: _isCompleted,
      notes: _notes,
    );
  }

  Workout buildFromTemplate(Workout template, DateTime newDate) {
    //_validateDate(newDate);

    _exercises.clear();
    _notes = null;
    _isBuilt = false;

    _date = newDate;
    _exercises.addAll(template.exercises.toList());
    _notes = template.notes;
    _isCompleted = template.isCompleted;

    return build();
  }

  void reset() {
    _id = null;
    _date = null;
    _exercises.clear();
    _notes = null;
    _isCompleted = false;
    _isBuilt = false;
  }

  void _validateBeforeBuild() {
    if (_isBuilt) {
      throw WorkoutValidationException(
        'Builder has already been built. Call reset() to reuse.',
      );
    }

    if (_id == null) {
      throw WorkoutValidationException(
        'Workout ID must be set before building',
      );
    }

    if (_date == null) {
      throw WorkoutValidationException(
        'Workout date must be set before building',
      );
    }

    // if (_exercises.isEmpty) {
    //   throw WorkoutValidationException(
    //     'At least one exercise is required in the workout',
    //   );
    // }
  }

  //   // void _validateDate(DateTime date) {
  //   // No null check needed - date is non-nullable parameter
  // }
}
