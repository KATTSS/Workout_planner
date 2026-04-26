import 'package:workout_planner/Features/Domain/Entities/Performance/ex_no_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_duration_perfomance.dart';

abstract class ExercisePerformanceVisitor<T> {
  T visitWeighted(WeightedExercisePerformance performance);
  T visitBodyweight(BodyweightExercisePerformance performance);
  T visitDuration(DurationExercisePerformance performance);
}
