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
    return WorkoutHistory(
      id: model.id,
      date: model.date,
      muscleGroup: model.muscleGroup,
      excerciseList: model.excerciseList,
      isDone: model.isDone,
    );
  }
}
