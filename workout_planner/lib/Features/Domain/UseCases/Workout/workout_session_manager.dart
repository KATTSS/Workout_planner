import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

class WorkoutSessionManager {
  Workout _currentWorkout;
  final List<Workout> _history = [];
  int _historyIndex = -1;
  final int maxHistorySize;
  bool _isModified = false;

  WorkoutSessionManager(this._currentWorkout, {this.maxHistorySize = 50}) {
    _saveToHistory(_currentWorkout);
  }

  Workout get currentWorkout => _currentWorkout;
  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;
  bool get isModified => _isModified;

  void updateState(Workout newWorkout) {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _currentWorkout = newWorkout;
    _isModified = true;
    _saveToHistory(_currentWorkout);
  }

  void markAsSaved() {
    _isModified = false;
  }

  bool undo() {
    if (!canUndo) return false;
    _historyIndex--;
    _currentWorkout = _history[_historyIndex];
    _isModified = true;
    return true;
  }

  bool redo() {
    if (!canRedo) return false;
    _historyIndex++;
    _currentWorkout = _history[_historyIndex];
    _isModified = true;
    return true;
  }

  void _saveToHistory(Workout workout) {
    _history.add(workout);
    _historyIndex++;
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }
}
