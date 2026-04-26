// data/repositories/history_repo_impl.dart
import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
// import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';
import 'package:workout_planner/Features/Data/Repository/Mappers/workout_mapper.dart';

class HistoryRepo implements IHistoryRepo {
  final UserHistDb _db;

  HistoryRepo(this._db);

  @override
  Future<int> saveWorkout(Workout workout) async {
    final model = WorkoutMapper.toModel(workout);

    if (workout.id <= 0) {
      final id = await _db.insert(model);
      return id;
    } else {
      await _db.update(model);
      return workout.id;
    }
  }

  @override
  Future<Workout?> getWorkout(int id) async {
    final map = await _db.get(id);
    if (map == null) return null;
    return WorkoutMapper.toDomain(map);
  }

  @override
  Future<void> deleteWorkout(int id) async {
    await _db.delete(id);
  }

  @override
  Future<List<Workout>> getByDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await _db.getByDate(dateStr, limit: limit);
    return maps.map((map) => WorkoutMapper.toDomain(map)).toList();
  }

  @override
  Future<List<Workout>> getBeforeDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await _db.getBeforeDate(dateStr, limit: limit);
    return maps.map((map) => WorkoutMapper.toDomain(map)).toList();
  }

  @override
  Future<List<Workout>> getAfterDate(DateTime date, {int? limit}) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final maps = await _db.getAfterDate(dateStr, limit: limit);
    return maps.map((map) => WorkoutMapper.toDomain(map)).toList();
  }

  @override
  Future<List<Workout>> getAll({int? limit, bool newestFirst = true}) async {
    final maps = await _db.getAll(limit: limit, orderDesc: newestFirst);
    return maps.map((map) => WorkoutMapper.toDomain(map)).toList();
  }

  @override
  Future<Workout> duplicateWorkout(int id, {DateTime? newDate}) async {
    final original = await getWorkout(id);
    if (original == null) throw Exception('Workout not found');

    final duplicated = Workout(
      id: 0, // New workout gets ID 0, database will assign new ID
      date: newDate ?? DateTime.now(),
      exercises: List.from(original.exercises),
      isCompleted: false,
      notes: original.notes,
    );

    final newId = await saveWorkout(duplicated);
    return duplicated.copyWith(id: newId);
  }
}

// class HistoryRepo implements IHistoryRepo {
//   final UserHistDb _db;

//   HistoryRepo(this._db);

//   @override
//   Future<int> saveWorkout(Workout workout) async {
//     final model = UserHistModel.fromWorkout(workout);

//     if (workout.id == null) {
//       final id = await _db.insert(model);
//       return id;
//     } else {
//       await _db.update(model);
//       return workout.id!;
//     }
//   }

//   @override
//   Future<Workout?> getWorkout(int id) async {
//     final model = await _db.get<UserHistModel>(id);
//     if (model == null) return null;
//     return model.toWorkout();
//   }

//   @override
//   Future<void> deleteWorkout(int id) async {
//     await _db.delete<UserHistModel>(id);
//   }

//   @override
//   Future<List<Workout>> getByDate(DateTime date, {int? limit}) async {
//     final dateStr = date.toIso8601String().split('T')[0];
//     final models = await _db.getByDate<UserHistModel>(dateStr, limit: limit);
//     return models.map((model) => model.toWorkout()).toList();
//   }

//   @override
//   Future<List<Workout>> getBeforeDate(DateTime date, {int? limit}) async {
//     final dateStr = date.toIso8601String().split('T')[0];
//     final models = await _db.getBeforeDate<UserHistModel>(
//       dateStr,
//       limit: limit,
//     );
//     return models.map((model) => model.toWorkout()).toList();
//   }

//   @override
//   Future<List<Workout>> getAfterDate(DateTime date, {int? limit}) async {
//     final dateStr = date.toIso8601String().split('T')[0];
//     final models = await _db.getAfterDate<UserHistModel>(dateStr, limit: limit);
//     return models.map((model) => model.toWorkout()).toList();
//   }

//   @override
//   Future<List<Workout>> getAll({int? limit, bool newestFirst = true}) async {
//     final models = await _db.getAll<UserHistModel>(
//       limit: limit,
//       orderDesc: newestFirst,
//     );
//     return models.map((model) => model.toWorkout()).toList();
//   }

//   @override
//   Future<Workout> duplicateWorkout(int id, {DateTime? newDate}) async {
//     final original = await getWorkout(id);
//     if (original == null) throw Exception('Workout not found');

//     return Workout(
//       id: original.id,
//       date: newDate ?? DateTime.now(),
//       exercises: List.from(original.exercises),
//       isCompleted: false,
//       notes: original.notes,
//     );
//   }
// }
