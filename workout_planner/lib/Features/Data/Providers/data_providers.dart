import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Data/Service/exercise_db.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Data/Service/local_workout_data_source.dart';
import 'package:workout_planner/Features/Data/Service/ilocal_workout_data_source.dart';
import 'package:workout_planner/Features/Data/Repository/exercise_repo_realisation.dart';
import 'package:workout_planner/Features/Data/Repository/history_repo_realisation.dart';
import 'package:workout_planner/Features/Domain/Repository/excercise_repo.dart';
import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';

final exerciseDbProvider = Provider<ExerciseDb>((ref) {
  return ExerciseDb.instance;
});

final userHistDbProvider = Provider<UserHistDb>((ref) {
  return UserHistDb.instance;
});

final localWorkoutDataSourceProvider = Provider<ILocalWorkoutDataSource>((ref) {
  return LocalWorkoutDataSource(ref.watch(userHistDbProvider));
});

final exerciseRepoProvider = Provider<IExerciseRepo>((ref) {
  return ExerciseRepo(ref.watch(exerciseDbProvider));
});

final historyRepoProvider = Provider<IHistoryRepo>((ref) {
  return HistoryRepo(
    ref.watch(localWorkoutDataSourceProvider),
    ref.watch(exerciseRepoProvider),
  );
});
