import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_visitor.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';
import 'package:collection/collection.dart';

class BodyweightExercisePerformance extends ExercisePerformance {
  final List<SetData> _sets;

  BodyweightExercisePerformance({
    required super.exerciseId,
    required super.exercise,
    required List<SetData> sets,
  }) : _sets = sets {
    for (var set in sets) {
      if (!set.isValidFor(PerformanceType.bodyweight)) {
        throw ArgumentError(
          'Invalid set data for bodyweight exercise: reps must be > 0',
        );
      }
    }
  }

  @override
  int get setsCount => _sets.length;

  @override
  List<SetData> get sets => List.unmodifiable(_sets);

  @override
  double? getWeightForSet(int setIndex) => null;

  @override
  int? getRepsForSet(int setIndex) =>
      setIndex < _sets.length ? _sets[setIndex].reps : null;

  @override
  double? getDurationForSet(int setIndex) => null;

  List<int> get reps => _sets.map((s) => s.reps!).toList();

  int get totalReps => _sets.fold(0, (sum, set) => sum + set.reps!);

  @override
  BodyweightExercisePerformance addSet(SetData set) {
    if (!set.isValidFor(PerformanceType.bodyweight)) {
      throw ArgumentError('Invalid set data for bodyweight exercise');
    }
    return BodyweightExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: [..._sets, set],
    );
  }

  @override
  BodyweightExercisePerformance removeSet(int setIndex) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }
    return BodyweightExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: [..._sets]..removeAt(setIndex),
    );
  }

  @override
  BodyweightExercisePerformance updateSet(int setIndex, SetData newSet) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }
    if (!newSet.isValidFor(PerformanceType.bodyweight)) {
      throw ArgumentError('Invalid set data for bodyweight exercise');
    }

    final updatedSets = List<SetData>.from(_sets);
    updatedSets[setIndex] = newSet;

    return BodyweightExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: updatedSets,
    );
  }

  @override
  BodyweightExercisePerformance updateSetReps(int setIndex, int reps) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }

    final updatedSet = SetData.bodyweight(reps: reps);
    return updateSet(setIndex, updatedSet);
  }

  @override
  BodyweightExercisePerformance updateSetWeight(int setIndex, double weight) {
    throw UnsupportedError('Bodyweight exercises do not support weight');
  }

  @override
  BodyweightExercisePerformance updateSetDuration(
    int setIndex,
    double duration,
  ) {
    throw UnsupportedError('Bodyweight exercises do not support duration');
  }

  @override
  T accept<T>(ExercisePerformanceVisitor<T> visitor) {
    return visitor.visitBodyweight(this);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BodyweightExercisePerformance &&
        other.exerciseId == exerciseId &&
        other.exercise == exercise &&
        const ListEquality().equals(other._sets, _sets);
  }

  @override
  int get hashCode => Object.hash(exerciseId, exercise, Object.hashAll(_sets));
}
