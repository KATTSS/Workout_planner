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
}
