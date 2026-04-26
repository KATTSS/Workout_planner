// workout_session.dart
import 'package:workout_planner/Features/Domain/Entities/Workout/workout_caretaker.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

class WorkoutSession {
  Workout _workout;
  final WorkoutCaretaker _caretaker;
  bool _isModified = false;

  WorkoutSession(this._workout) : _caretaker = WorkoutCaretaker() {
    // Сохраняем начальное состояние
    _caretaker.save(_workout);
  }

  Workout get currentWorkout => _workout;
  bool get isModified => _isModified;
  bool get canUndo => _caretaker.canUndo;
  bool get canRedo => _caretaker.canRedo;

  // Методы для изменения тренировки
  void updateDate(DateTime newDate) {
    _saveState();
    _workout = _workout.updateDate(newDate);
    _isModified = true;
  }

  void updateNotes(String? notes) {
    _saveState();
    _workout = _workout.updateNotes(notes);
    _isModified = true;
  }

  void addExercise(ExercisePerformance exercise) {
    _saveState();
    _workout = _workout.addExercise(exercise);
    _isModified = true;
  }

  void removeExercise(int exerciseId) {
    _saveState();
    _workout = _workout.removeExercise(exerciseId);
    _isModified = true;
  }

  void replaceExercise(int oldExerciseId, ExercisePerformance newExercise) {
    _saveState();
    _workout = _workout.replaceExercise(oldExerciseId, newExercise);
    _isModified = true;
  }

  void addSetToExercise(int exerciseId, SetData set) {
    _saveState();
    _workout = _workout.addSet(exerciseId, set);
    _isModified = true;
  }

  void removeSetFromExercise(int exerciseId, int setIndex) {
    _saveState();
    _workout = _workout.removeSet(exerciseId, setIndex);
    _isModified = true;
  }

  void updateSetInExercise(int exerciseId, int setIndex, SetData newSet) {
    _saveState();
    _workout = _workout.updateSet(exerciseId, setIndex, newSet);
    _isModified = true;
  }

  void updateSetWeight(int exerciseId, int setIndex, double weight) {
    _saveState();
    _workout = _workout.updateSetWeight(exerciseId, setIndex, weight);
    _isModified = true;
  }

  void updateSetReps(int exerciseId, int setIndex, int reps) {
    _saveState();
    _workout = _workout.updateSetReps(exerciseId, setIndex, reps);
    _isModified = true;
  }

  void updateSetDuration(int exerciseId, int setIndex, double duration) {
    _saveState();
    _workout = _workout.updateSetDuration(exerciseId, setIndex, duration);
    _isModified = true;
  }

  void completeWorkout() {
    _saveState();
    _workout = _workout.markAsCompleted();
    _isModified = true;
  }

  // Отмена/повтор изменений
  bool undo() {
    final previous = _caretaker.undo();
    if (previous != null) {
      _workout = previous;
      _isModified = true;
      return true;
    }
    return false;
  }

  bool redo() {
    final next = _caretaker.redo();
    if (next != null) {
      _workout = next;
      _isModified = true;
      return true;
    }
    return false;
  }

  void _saveState() {
    _caretaker.save(_workout);
  }
}