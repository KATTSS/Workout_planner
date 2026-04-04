import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

abstract class Memento {}

class WorkoutMemento implements Memento {
  final List<Excercise> _excercises;
  final DateTime _workoutDate;
  final bool _isCompleted;

  WorkoutMemento(this._excercises, this._workoutDate, this._isCompleted);

  List<Excercise> get excercises => List.unmodifiable(_excercises);
  DateTime get workoutDate => _workoutDate;
  bool get isCompleted => _isCompleted;
}

class WorkoutManager {
  List<Excercise> _excercises = [];
  DateTime _workoutDate = DateTime.now();
  bool _isCompleted = false;

  WorkoutManager(this._excercises, this._workoutDate, this._isCompleted);

  void addExcercise(Excercise excercise) {
    _excercises.add(excercise);
  }

  void removeExcercise(Excercise excercise) {
    _excercises.remove(excercise);
  }

  void clearExcercises() {
    _excercises.clear();
  }

  void setDateTime(DateTime workoutDate) {
    this._workoutDate = workoutDate;
  }

  void changeDateTime(DateTime workoutDate) {
    this._workoutDate = workoutDate;
  }

  void changeExcercise(Excercise oldExcercise, Excercise newExcercise) {
    int index = _excercises.indexOf(oldExcercise);
    if (index != -1) {
      _excercises[index] = newExcercise;
    }
  }

  Memento save() {
    return WorkoutMemento(List.from(_excercises), _workoutDate, _isCompleted);
  }

  void restore(Memento memento) {
    if (memento is WorkoutMemento) {
      _excercises = List.from(memento.excercises);
      _workoutDate = memento.workoutDate;
      _isCompleted = memento.isCompleted;
    }
  }
}

// Caretaker
class WorkoutCaretaker {
  List<Memento> _mementos = [];

  void save(Memento memento) {
    _mementos.add(memento);
  }

  Memento? undo() {
    if (_mementos.isNotEmpty) {
      return _mementos.removeLast();
    }
    return null;
  }
}
// import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

// class WorkoutManager {
//   List<Excercise> _excercises = [];
//   DateTime _workoutDate = DateTime.now();
//   bool _isCompleted = false;

//   WorkoutManager(this._excercises, this._workoutDate, this._isCompleted);

//   void addExcercise(Excercise excercise) {
//     _excercises.add(excercise);
//   }

//   void removeExcercise(Excercise excercise) {
//     _excercises.remove(excercise);
//   }

//   void clearExcercises() {
//     _excercises.clear();
//   }

//   void setDateTime(DateTime _workoutDate) {
//     this._workoutDate = _workoutDate;
//   }

//   void changeDateTime(DateTime _workoutDate) {
//     this._workoutDate = _workoutDate;
//   }

//   void changeExcercise(Excercise oldExcercise, Excercise newExcercise) {
//     int index = _excercises.indexOf(oldExcercise);
//     if (index != -1) {
//       _excercises[index] = newExcercise;
//     }
//   }

//   Memento saveWorkoutState(){
//     return new Memento(_excercises, _workoutDate, _isCompleted);
//   }
// }

// class Memento {}

// class WorkoutMemento implements Memento {
//   final List<Excercise> _excercises;
//   final DateTime _workoutTime;
//   final bool _isCompleted;

//   WorkoutMemento(this._excercises, this._workoutTime, this._isCompleted);
//   WorkoutManager getState() {
//     return new WorkoutManager(_excercises, _workoutTime, _isCompleted);
//   }
// }
