import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Data/Providers/data_providers.dart';

final workoutForEditingProvider = FutureProvider.autoDispose
    .family<Workout?, int?>((ref, workoutId) async {
      if (workoutId == null) {
        return Workout(
          id: -1,
          date: DateTime.now(),
          exercises: [],
          isCompleted: false,
        );
      }

      final historyRepo = ref.watch(historyRepoProvider);
      return historyRepo.getWorkout(workoutId);
    });
