import 'package:workout_planner/Features/Data/Models/exercise_model.dart';
import 'package:workout_planner/Features/Data/Service/exercise_db.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Repository/excercise_repo.dart';

class ExerciseRepo implements IExerciseRepo {
  final ExerciseDb _db;
  ExerciseRepo(this._db);

  @override
  Future<Exercise?> getById(int id) async {
    try {
      final maps = await _db.query(
        'excercise_table',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      final model = ExerciseModel.fromMap(maps.first);
      return model.toDomain();
    } catch (e) {
      print('Error getting exercise by id: $e');
      return null;
    }
  }

  @override
  Future<List<Exercise>> getByLevel(int level) async {
    try {
      final maps = await _db.query(
        'excercise_table',
        where: 'level = ?',
        whereArgs: [level],
      );

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting exercises by level: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> getByCategory(String category) async {
    try {
      final maps = await _db.query(
        'excercise_table',
        where: 'category LIKE ?',
        whereArgs: ['%$category%'],
      );

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting exercises by category: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> searchByName(String query) async {
    try {
      final maps = await _db.query(
        'excercise_table',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error searching exercises: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> getAll() async {
    try {
      final maps = await _db.query('excercise_table');
      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting all exercises: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> getByMuscleGroup(String muscleGroup) async {
    try {
      final maps = await _db.query(
        'excercise_table',
        where: 'primary_muscles LIKE ? OR secondary_muscles LIKE ?',
        whereArgs: ['%$muscleGroup%', '%$muscleGroup%'],
      );

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting exercises by muscle group: $e');
      return [];
    }
  }

  List<Exercise> _mapToEntityList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => ExerciseModel.fromMap(map).toDomain()).toList();
  }
}
