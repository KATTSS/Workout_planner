import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';

class CreateWorkout {
  final IHistoryRepo _historyRepo;

  CreateWorkout(this._historyRepo);

  Future<int> call(Workout workout) async {
    if (workout.exercises.isEmpty) {
      throw ArgumentError('Workout must have at least one exercise');
    }
    return _historyRepo.saveWorkout(workout);
  }
}

class SaveWorkout {
  final IHistoryRepo _historyRepo;
  SaveWorkout(this._historyRepo);

  Future<int> call(Workout workout) async {
    if (workout.exercises.isEmpty) {
      throw WorkoutValidationException(
        'Тренировка не может быть пустой. Используйте удаление, если хотите полностью стереть её.',
      );
    }
    // If workout already has an id (existing record) - update it, otherwise insert a new one.
    if (workout.id != -1 && workout.id > 0) {
      await _historyRepo.updateWorkout(workout);
      return workout.id;
    }

    return _historyRepo.saveWorkout(workout);
  }
}

class DeleteWorkout {
  final IHistoryRepo _historyRepo;

  DeleteWorkout(this._historyRepo);

  Future<void> call(int workoutId) async {
    await _historyRepo.deleteWorkout(workoutId);
  }
}

class GetWorkoutHistory {
  final IHistoryRepo _historyRepo;

  GetWorkoutHistory(this._historyRepo);

  Future<List<Workout>> getRecentWorkouts({int limit = 10}) {
    return _historyRepo.getAll(limit: limit, newestFirst: true);
  }

  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final afterStart = await _historyRepo.getAfterDate(start);
    final beforeEnd = await _historyRepo.getBeforeDate(end);
    return afterStart.where((w) => beforeEnd.contains(w)).toList();
  }
}
