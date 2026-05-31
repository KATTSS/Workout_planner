import 'package:workout_planner/Features/Data/Models/user_model.dart';
import 'package:workout_planner/Features/Data/Service/ilocal_user_data_source.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Data/Service/query_builder.dart';

class LocalUserDataSource implements ILocalUserDataSource {
  final UserHistDb _db;

  LocalUserDataSource(this._db);

  @override
  Future<UserModel?> getUser() async {
    final builder = QueryBuilder().select().from('user_table').limit(1);
    final map = await _db.executeQuerySingle(builder);
    if (map == null) return null;
    return UserModel.fromMap(map);
  }

  @override
  Future<int> upsertUser(UserModel user) async {
    final updateBuilder = QueryBuilder()
        .update(user.toMap())
        .from('user_table')
        .where('id', '=', user.id);
    try {
      final updated = await _db.executeCommand(updateBuilder);
      if (updated > 0) return updated;
    } catch (_) {}

    final insertBuilder = QueryBuilder()
        .insert(user.toMap())
        .from('user_table');
    return _db.executeCommand(insertBuilder);
  }

  @override
  Future<int> insertWeightHistory(String date, double weight) async {
    final builder = QueryBuilder()
        .insert({'date': date, 'weight': weight})
        .from('weight_history');
    return _db.executeCommand(builder);
  }

  @override
  Future<List<Map<String, dynamic>>> getWeightHistory({int? limit}) async {
    final builder = QueryBuilder()
        .select()
        .from('weight_history')
        .orderBy('date', descending: false);
    if (limit != null) builder.limit(limit);
    return _db.executeQuery(builder);
  }
}
