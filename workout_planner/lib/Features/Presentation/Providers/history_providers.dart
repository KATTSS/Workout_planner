import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/providers.dart';
import 'package:workout_planner/Features/Data/Providers/data_providers.dart';

final recentWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final getHistory = ref.watch(getWorkoutHistoryProvider);
  return getHistory.getRecentWorkouts(limit: 20);
});

final workoutByIdProvider = FutureProvider.family<Workout?, int>((
  ref,
  id,
) async {
  final historyRepo = ref.watch(historyRepoProvider);
  return historyRepo.getWorkout(id);
});
