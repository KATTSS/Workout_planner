import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/providers.dart';
import 'package:workout_planner/Features/Data/Providers/data_providers.dart';

final recentWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  try {
    final getHistory = ref.watch(getWorkoutHistoryProvider);
    return await getHistory.getRecentWorkouts(limit: 20);
  } catch (e) {
    debugPrint('Error loading recent workouts: $e');
    return []; // Возвращаем пустой список вместо ошибки
  }
});
// final recentWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
//   final getHistory = ref.watch(getWorkoutHistoryProvider);
//   return getHistory.getRecentWorkouts(limit: 20);
// });

final workoutByIdProvider = FutureProvider.autoDispose.family<Workout?, int>((
  ref,
  id,
) async {
  try {
    final historyRepo = ref.watch(historyRepoProvider);
    return await historyRepo.getWorkout(id);
  } catch (e) {
    debugPrint('Error loading workout $id: $e');
    return null; // Возвращаем null при ошибке
  }
});
// final workoutByIdProvider = FutureProvider.family<Workout?, int>((
//   ref,
//   id,
// ) async {
//   final historyRepo = ref.watch(historyRepoProvider);
//   return historyRepo.getWorkout(id);
// });
