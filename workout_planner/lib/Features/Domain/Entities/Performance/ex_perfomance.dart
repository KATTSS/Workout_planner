import 'package:workout_planner/Features/Domain/Entities/Performance/ex_visitor.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_no_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_duration_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';

abstract class ExercisePerformance {
  final int exerciseId;
  final Exercise exercise;

  const ExercisePerformance({required this.exerciseId, required this.exercise});

  int get setsCount;

  List<SetData> get sets;

  double? getWeightForSet(int setIndex);
  int? getRepsForSet(int setIndex);
  double? getDurationForSet(int setIndex);

  ExercisePerformance addSet(SetData set);
  ExercisePerformance removeSet(int setIndex);
  ExercisePerformance updateSet(int setIndex, SetData newSet);
  ExercisePerformance updateSetWeight(int setIndex, double weight);
  ExercisePerformance updateSetReps(int setIndex, int reps);
  ExercisePerformance updateSetDuration(int setIndex, double duration);

  static ExercisePerformance create({
    required Exercise exercise,
    required List<SetData> sets,
  }) {
    switch (exercise.performanceType) {
      case PerformanceType.weighted:
        return WeightedExercisePerformance(
          exerciseId: exercise.id,
          exercise: exercise,
          sets: sets,
        );
      case PerformanceType.bodyweight:
        return BodyweightExercisePerformance(
          exerciseId: exercise.id,
          exercise: exercise,
          sets: sets,
        );
      case PerformanceType.duration:
        return DurationExercisePerformance(
          exerciseId: exercise.id,
          exercise: exercise,
          sets: sets,
        );
    }
  }

  T accept<T>(ExercisePerformanceVisitor<T> visitor);
}
