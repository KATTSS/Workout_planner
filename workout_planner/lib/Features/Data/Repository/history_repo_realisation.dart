import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';
import 'package:workout_planner/Features/Data/Service/query_builder.dart';
import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Data/Repository/Mappers/workout_mapper.dart';

class HistoryRepo implements IHistoryRepo {
  final UserHistDb _db;

  HistoryRepo(this._db);

  @override
  Future<int> saveWorkout(Workout workout) async {
    final model = WorkoutMapper.toModel(workout);
    final builder = QueryBuilder()
        .insert(model.toMap())
        .from('UserHistoryItem');
    final id = await _db.executeCommand(builder);
    return id;
  }

  @override
  Future<Workout?> getWorkout(int id) async {
    final builder = QueryBuilder()
        .select()
        .from('UserHistoryItem')
        .where('workout_id', '=', id);

    final map = await _db.executeQuerySingle(builder);
    if (map == null) return null;
    final UserHistModel model = UserHistModel.fromMap(map);
    return WorkoutMapper.toDomain(model);
  }

  @override
  Future<void> deleteWorkout(int id) async {
    final builder = QueryBuilder()
        .delete()
        .from('UserHistoryItem')
        .where('workout_id', '=', id);

    await _db.executeCommand(builder);
  }

  @override
  Future<int> updateWorkout(Workout workout) async {
    final model = WorkoutMapper.toModel(workout);

    final builder = QueryBuilder()
        .update(model.toMap())
        .from('UserHistoryItem')
        .where('workout_id', '=', model.id);

    final id = await _db.executeCommand(builder);
    return id;
  }

  @override
  Future<List<Workout>> getByDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final builder = QueryBuilder()
        .select()
        .from('UserHistoryItem')
        .where('date', '=', dateStr)
        .orderBy('workout_id');

    if (limit != null) builder.limit(limit);

    final maps = await _db.executeQuery(builder);
    return maps
        .map((map) => WorkoutMapper.toDomain(UserHistModel.fromMap(map)))
        .toList();
  }

  @override
  Future<List<Workout>> getBeforeDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final builder = QueryBuilder()
        .select()
        .from('UserHistoryItem')
        .where('date', '<', dateStr)
        .orderBy('date', descending: true)
        .orderBy('workout_id', descending: true);

    if (limit != null) builder.limit(limit);

    final maps = await _db.executeQuery(builder);
    return maps
        .map((map) => WorkoutMapper.toDomain(UserHistModel.fromMap(map)))
        .toList();
  }

  @override
  Future<List<Workout>> getAfterDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final builder = QueryBuilder()
        .select()
        .from('UserHistoryItem')
        .where('date', '>', dateStr)
        .orderBy('date')
        .orderBy('workout_id');

    if (limit != null) builder.limit(limit);
    final maps = await _db.executeQuery(builder);
    return maps
        .map((map) => WorkoutMapper.toDomain(UserHistModel.fromMap(map)))
        .toList();
  }

  @override
  Future<List<Workout>> getAll({int? limit, bool newestFirst = true}) async {
    final builder = QueryBuilder()
        .select()
        .from('UserHistoryItem')
        .orderBy('date', descending: newestFirst)
        .orderBy('workout_id', descending: newestFirst);

    if (limit != null) builder.limit(limit);

    final maps = await _db.executeQuery(builder);
    return maps
        .map((map) => WorkoutMapper.toDomain(UserHistModel.fromMap(map)))
        .toList();
  }
}
