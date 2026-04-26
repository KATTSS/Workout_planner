import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_visitor.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';

class DurationExercisePerformance extends ExercisePerformance {
  final List<SetData> _sets;

  DurationExercisePerformance({
    required super.exerciseId,
    required super.exercise,
    required List<SetData> sets,
  }) : _sets = sets,
       assert(sets.every((s) => s.isValidFor(PerformanceType.duration)));

  @override
  int get setsCount => _sets.length;

  @override
  List<SetData> get sets => List.unmodifiable(_sets);

  @override
  double? getWeightForSet(int setIndex) => null;

  @override
  int? getRepsForSet(int setIndex) => null;

  @override
  double? getDurationForSet(int setIndex) => 
      setIndex < _sets.length ? _sets[setIndex].duration : null;

  List<double> get durations => _sets.map((s) => s.duration!).toList();

  double get totalDuration =>
      _sets.fold(0.0, (sum, set) => sum + set.duration!);

  @override
  DurationExercisePerformance addSet(SetData set) {
    if (!set.isValidFor(PerformanceType.duration)) {
      throw ArgumentError('Invalid set data for duration exercise');
    }
    return DurationExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: [..._sets, set],
    );
  }

  @override
  DurationExercisePerformance removeSet(int setIndex) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }
    return DurationExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: [..._sets]..removeAt(setIndex),
    );
  }

  @override
  DurationExercisePerformance updateSet(int setIndex, SetData newSet) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }
    if (!newSet.isValidFor(PerformanceType.duration)) {
      throw ArgumentError('Invalid set data for duration exercise');
    }
    
    final updatedSets = List<SetData>.from(_sets);
    updatedSets[setIndex] = newSet;
    
    return DurationExercisePerformance(
      exerciseId: exerciseId,
      exercise: exercise,
      sets: updatedSets,
    );
  }

  @override
  DurationExercisePerformance updateSetDuration(int setIndex, double duration) {
    if (setIndex < 0 || setIndex >= _sets.length) {
      throw RangeError.index(setIndex, _sets);
    }
    
    final updatedSet = SetData.duration(duration: duration);
    return updateSet(setIndex, updatedSet);
  }

  @override
  DurationExercisePerformance updateSetWeight(int setIndex, double weight) {
    throw UnsupportedError('Duration exercises do not support weight');
  }

  @override
  DurationExercisePerformance updateSetReps(int setIndex, int reps) {
    throw UnsupportedError('Duration exercises do not support reps');
  }

  @override
  T accept<T>(ExercisePerformanceVisitor<T> visitor) {
    return visitor.visitDuration(this);
  }
}