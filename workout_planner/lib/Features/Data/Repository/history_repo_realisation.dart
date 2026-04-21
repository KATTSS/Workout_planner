import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
import 'package:workout_planner/Features/Domain/Entities/workout_history.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';

class HistoryRepo implements IHistoryRepo {
  final UserHistDb _db;

  HistoryRepo(this._db);

  @override
  Future<void> saveHistory(WorkoutHistory workout) async {
    final model = UserHistModel.toModel(workout);
    await _db.insert(model);
  }

  @override
  Future<WorkoutHistory?> getHistory(int id) async {
    final model = await _db.get<UserHistModel>(id);
    if (model == null) return null;

    DateTime parsedDate;
    try {
      if (model.date.length == 10 && model.date.contains('-')) {
        parsedDate = DateTime.parse('${model.date}T00:00:00.000');
      } else {
        parsedDate = DateTime.parse(model.date);
      }
    } catch (e) {
      parsedDate = DateTime.now();
    }
    return WorkoutHistory(
      id: model.id,
      date: parsedDate,
      muscleGroup: model.muscleGroup,
      excerciseList: model.excerciseList,
      isDone: model.isDone,
    );
  }

  @override
  Future<List<WorkoutHistory>> getByDate(DateTime date, {int? limit}) async {
    final dateStr = date.toString();
    final models = await _db.getByDate<UserHistModel>(dateStr, limit: limit);
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<List<WorkoutHistory>> getBeforeDate(
    DateTime date, {
    int? limit,
  }) async {
    final dateStr = date.toString();
    final models = await _db.getBeforeDate<UserHistModel>(
      dateStr,
      limit: limit,
    );
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<List<WorkoutHistory>> getAfterDate(DateTime date, {int? limit}) async {
    final dateStr = date.toString();
    final models = await _db.getAfterDate<UserHistModel>(dateStr, limit: limit);
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<List<WorkoutHistory>> getAll({
    int? limit,
    bool newestFirst = true,
  }) async {
    final models = await _db.getAll<UserHistModel>(
      limit: limit,
      orderDesc: newestFirst,
    );
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<void> updateHistory(WorkoutHistory workout) async {
    final model = UserHistModel.toModel(workout);
    await _db.update(model);
  }

  @override
  Future<void> deleteHistory(int id) async {
    await _db.delete<UserHistModel>(id);
  }
}
