import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_visitor.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';
import 'package:collection/collection.dart';

class WeightedExercisePerformance extends ExercisePerformance {
  final List<SetData> _sets;

  WeightedExercisePerformance({
    required super.exerciseId,
    required super.exercise,
    required List<SetData> sets,
  }) : _sets = sets {
    for (var set in sets) {
      if (!set.isValidFor(PerformanceType.weighted)) {
        throw ArgumentError(
          'Invalid set data for weighted exercise: weight >= 0 and reps > 0 required',
        );
      }
    }
  }

  @override
  int get setsCount => _sets.length;

  @override
  List<SetData> get sets => List.unmodifiable(_sets);

  @override
  double? getWeightForSet(int setIndex) =>
      setIndex < _sets.length ? _sets[setIndex].weight : null;

  @override
  int? getRepsForSet(int setIndex) =>
      setIndex < _sets.length ? _sets[setIndex].reps : null;

  @override
  double? getDurationForSet(int setIndex) => null;

  List<double> get weights => _sets.map((s) => s.weight!).toList();
  List<int> get reps => _sets.map((s) => s.reps!).toList();

  double get totalVolume =>
      _sets.fold(0.0, (sum, set) => sum + (set.weight! * set.reps!));

  @override
  WeightedExercisePerformance addSet(SetData set) {
    if (!set.isValidFor(PerformanceType.weighted)) {
      throw ArgumentError('Invalid set data for weighted exercise');
    }
    return WeightedExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: [..._sets, set],
    );
  }

  @override
  WeightedExercisePerformance removeSet(int setIndex) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }
    return WeightedExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: [..._sets]..removeAt(setIndex),
    );
  }

  @override
  WeightedExercisePerformance updateSet(int setIndex, SetData newSet) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }
    if (!newSet.isValidFor(PerformanceType.weighted)) {
      throw ArgumentError('Invalid set data for weighted exercise');
    }

    final updatedSets = List<SetData>.from(_sets);
    updatedSets[setIndex] = newSet;

    return WeightedExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: updatedSets,
    );
  }

  @override
  WeightedExercisePerformance updateSetWeight(int setIndex, double weight) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }

    final currentSet = _sets[setIndex];
    final updatedSet = SetData.weighted(weight: weight, reps: currentSet.reps!);

    return updateSet(setIndex, updatedSet);
  }

  @override
  WeightedExercisePerformance updateSetReps(int setIndex, int reps) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }

    final currentSet = _sets[setIndex];
    final updatedSet = SetData.weighted(weight: currentSet.weight!, reps: reps);

    return updateSet(setIndex, updatedSet);
  }

  @override
  WeightedExercisePerformance updateSetDuration(int setIndex, double duration) {
    throw UnsupportedError('Weighted exercises do not support duration');
  }

  @override
  T accept<T>(ExercisePerformanceVisitor<T> visitor) {
    return visitor.visitWeighted(this);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeightedExercisePerformance &&
        other.exerciseId == exerciseId &&
        other.exercise == exercise &&
        const ListEquality().equals(other._sets, _sets);
  }

  @override
  int get hashCode => Object.hash(exerciseId, exercise, Object.hashAll(_sets));
}
