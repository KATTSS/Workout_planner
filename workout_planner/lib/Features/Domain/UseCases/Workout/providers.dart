import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Data/Providers/data_providers.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_persistence.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_exercises.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_sets.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_status.dart';

final createWorkoutProvider = Provider<CreateWorkout>((ref) {
  return CreateWorkout(ref.watch(historyRepoProvider));
});

final saveWorkoutProvider = Provider<SaveWorkout>((ref) {
  return SaveWorkout(ref.watch(historyRepoProvider));
});

final deleteWorkoutProvider = Provider<DeleteWorkout>((ref) {
  return DeleteWorkout(ref.watch(historyRepoProvider));
});

final getWorkoutHistoryProvider = Provider<GetWorkoutHistory>((ref) {
  return GetWorkoutHistory(ref.watch(historyRepoProvider));
});

final manageWorkoutExercisesProvider = Provider<ManageWorkoutExercises>((ref) {
  return ManageWorkoutExercises();
});

final setManagementProvider = Provider<SetManagement>((ref) {
  return SetManagement();
});

final workoutStatusManagerProvider = Provider<WorkoutStatusManager>((ref) {
  return WorkoutStatusManager();
});
