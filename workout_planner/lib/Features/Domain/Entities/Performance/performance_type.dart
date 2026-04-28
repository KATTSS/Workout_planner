import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

enum PerformanceType {
  weighted,
  bodyweight,
  duration;

  factory PerformanceType.fromExercise(Exercise exercise) {
    return exercise.performanceType;
  }
}
