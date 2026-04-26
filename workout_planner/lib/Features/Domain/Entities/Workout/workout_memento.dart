import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

class WorkoutMemento {
  final Workout _state;

  WorkoutMemento(this._state);

  Workout get state => _state;
}
