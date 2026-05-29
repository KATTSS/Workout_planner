import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';

class HomeViewModel {
  final Ref _ref;

  HomeViewModel(this._ref);

  Future<List<Workout>> loadWorkouts({int limit = 10}) async {
    final getHistory = _ref.read(getWorkoutHistoryProvider);
    return await getHistory.getRecentWorkouts(limit: limit);
  }

  Future<bool> deleteWorkout(int? workoutId) async {
    if (workoutId == null) return false;

    final deleteWorkout = _ref.read(deleteWorkoutProvider);
    try {
      await deleteWorkout(workoutId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Workout?> createWorkout(
    List<ExercisePerformance> selectedExercises,
  ) async {
    try {
      final workoutBuilder = _ref.read(workoutBuilderProvider.notifier);
      final createWorkout = _ref.read(createWorkoutProvider);

      workoutBuilder.reset();

      final now = DateTime.now();
      final newId = now.millisecondsSinceEpoch ~/ 1000;

      workoutBuilder.setId(newId);
      workoutBuilder.setDate(DateTime.now());
      workoutBuilder.addExercises(selectedExercises);
      workoutBuilder.markAsDraft();

      final workout = workoutBuilder.build();

      final savedId = await createWorkout(workout);

      workoutBuilder.reset();

      return workout.copyWith(id: savedId);
    } catch (e) {
      return null;
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);

    if (workoutDate == today) return 'Today';
    if (workoutDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String getDeleteSuccessMessage(Workout workout) {
    return 'Workout from ${formatDate(workout.date)} deleted';
  }
}

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModel(ref);
});
