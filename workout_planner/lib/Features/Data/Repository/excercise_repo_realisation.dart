import 'package:workout_planner/Features/Data/Models/excercise_model.dart';
import 'package:workout_planner/Features/Data/Service/excercise_db.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Repository/excercise_repo.dart';

class ExcerciseRepo implements IExcerciseRepo {
  final ExcerciseDb db;
  ExcerciseRepo(this.db);

  @override
  Future<Excercise?> getExcercise(int id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'excercise_table',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final model = ExcerciseModel.fromMap(maps.first);
      return Excercise(model.id, model.level);
    }
    return null;
  }
}
