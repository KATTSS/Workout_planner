import 'package:workout_planner/Features/Domain/Entities/Workout/workout_memento.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

class WorkoutCaretaker {
  final List<WorkoutMemento> _history = [];
  int _currentIndex = -1;
  final int maxHistorySize;

  WorkoutCaretaker({this.maxHistorySize = 50});

  void save(Workout workout) {
    // Удаляем все состояния после текущего (если были undo и потом новое изменение)
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    _history.add(WorkoutMemento(workout));
    _currentIndex++;

    // Ограничиваем размер истории
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }

  Workout? undo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      return _history[_currentIndex].state;
    }
    return null;
  }

  Workout? redo() {
    if (_currentIndex < _history.length - 1) {
      _currentIndex++;
      return _history[_currentIndex].state;
    }
    return null;
  }

  bool get canUndo => _currentIndex > 0;
  bool get canRedo => _currentIndex < _history.length - 1;

  void clear() {
    _history.clear();
    _currentIndex = -1;
  }
}
