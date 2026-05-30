// lib/Features/Application/providers/app_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_states.dart';
import 'package:workout_planner/Features/Data/Service/exercise_db.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Data/Service/local_workout_data_source.dart';
import 'package:workout_planner/Features/Data/Service/ilocal_workout_data_source.dart';
import 'package:workout_planner/Features/Data/Repository/exercise_repo_realisation.dart';
import 'package:workout_planner/Features/Data/Repository/history_repo_realisation.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Repository/excercise_repo.dart';
import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_persistence.dart';
import 'package:workout_planner/Features/Domain/UseCases/statistics_manager.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

// ============ Data Sources & Databases ============

final exerciseDbProvider = Provider<ExerciseDb>((ref) {
  return ExerciseDb.instance;
});

final userHistDbProvider = Provider<UserHistDb>((ref) {
  return UserHistDb.instance;
});

final localWorkoutDataSourceProvider = Provider<ILocalWorkoutDataSource>((ref) {
  final db = ref.watch(userHistDbProvider);
  return LocalWorkoutDataSource(db);
});

// ============ Repositories ============

final exerciseRepoProvider = Provider<IExerciseRepo>((ref) {
  final db = ref.watch(exerciseDbProvider);
  return ExerciseRepo(db);
});

final historyRepoProvider = Provider<IHistoryRepo>((ref) {
  final dataSource = ref.watch(localWorkoutDataSourceProvider);
  final exerciseRepo = ref.watch(exerciseRepoProvider);
  return HistoryRepo(dataSource, exerciseRepo);
});

// ============ Use Cases ============

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

final statisticsManagerProvider = Provider<StatisticsManager>((ref) {
  return StatisticsManager();
});

// ============ Exercise Catalog ============

final exerciseCatalogProvider = FutureProvider<List<Exercise>>((ref) async {
  final exerciseRepo = ref.watch(exerciseRepoProvider);
  try {
    final exercises = await exerciseRepo.getAll();
    return exercises;
  } catch (e) {
    debugPrint('Error loading exercises: $e');
    return [];
  }
});

// Поиск упражнений с дебаунсом
final exerciseSearchProvider = FutureProvider.family<List<Exercise>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  final exerciseRepo = ref.watch(exerciseRepoProvider);
  return await exerciseRepo.getByName(query);
});

// ============ Workout Session State ============

final workoutSessionProvider =
    StateNotifierProvider<WorkoutSessionNotifier, WorkoutSessionState>((ref) {
      return WorkoutSessionNotifier();
    });

// ============ Workout Builder ============

final workoutBuilderProvider =
    StateNotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>((ref) {
      return WorkoutBuilderNotifier();
    });

// ============ Exercise Filters ============

final exerciseFiltersProvider =
    StateNotifierProvider<ExerciseFiltersNotifier, ExerciseFiltersState>((ref) {
      return ExerciseFiltersNotifier();
    });

// ============ Statistics ============

final workoutHistoryChangeProvider = StateProvider<int>((ref) {
  return 0;
});

final statisticsProvider = FutureProvider<WorkoutStatistics>((ref) async {
  ref.watch(workoutHistoryChangeProvider);
  final historyRepo = ref.watch(historyRepoProvider);
  final workouts = await historyRepo.getAll(limit: null, newestFirst: false);
  return WorkoutStatistics.calculate(workouts);
});

// ============ Workout by ID ============

final workoutByIdProvider = FutureProvider.family<Workout?, int>((
  ref,
  id,
) async {
  final historyRepo = ref.watch(historyRepoProvider);
  return await historyRepo.getWorkout(id);
});

// // lib/Features/Application/providers/workout_providers.dart

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:workout_planner/Features/Application/Providers/workout_states.dart';
// import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
// import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_persistence.dart';
// import 'package:workout_planner/Features/Domain/UseCases/statistics_manager.dart';
// import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

// // Репозиторий (нужно реализовать)
// final historyRepoProvider = Provider<IHistoryRepo>((ref) {
//   throw UnimplementedError('Implement IHistoryRepo with database/network');
// });

// // Use Cases
// final createWorkoutProvider = Provider<CreateWorkout>((ref) {
//   return CreateWorkout(ref.watch(historyRepoProvider));
// });

// final saveWorkoutProvider = Provider<SaveWorkout>((ref) {
//   return SaveWorkout(ref.watch(historyRepoProvider));
// });

// final deleteWorkoutProvider = Provider<DeleteWorkout>((ref) {
//   return DeleteWorkout(ref.watch(historyRepoProvider));
// });

// final getWorkoutHistoryProvider = Provider<GetWorkoutHistory>((ref) {
//   return GetWorkoutHistory(ref.watch(historyRepoProvider));
// });

// final statisticsManagerProvider = Provider<StatisticsManager>((ref) {
//   return StatisticsManager();
// });

// // Провайдер для списка всех упражнений (каталог)
// final exerciseCatalogProvider = FutureProvider<List<Exercise>>((ref) async {
//   // TODO: Загрузить из репозитория упражнений
//   return [];
// });

// // Провайдер для текущей сессии тренировки
// final workoutSessionProvider =
//     StateNotifierProvider<WorkoutSessionNotifier, WorkoutSessionState>((ref) {
//       return WorkoutSessionNotifier();
//     });

// // Провайдер для билдера тренировки (создание новой)
// final workoutBuilderProvider =
//     StateNotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>((ref) {
//       return WorkoutBuilderNotifier();
//     });

// // Провайдер для фильтров упражнений
// final exerciseFiltersProvider =
//     StateNotifierProvider<ExerciseFiltersNotifier, ExerciseFiltersState>((ref) {
//       return ExerciseFiltersNotifier();
//     });

// // Провайдер для статистики
// final statisticsProvider = FutureProvider<WorkoutStatistics>((ref) async {
//   final historyRepo = ref.watch(historyRepoProvider);
//   final workouts = await historyRepo.getAll(limit: 100, newestFirst: false);
//   final statsManager = ref.watch(statisticsManagerProvider);

//   return WorkoutStatistics.calculate(workouts);
// });
