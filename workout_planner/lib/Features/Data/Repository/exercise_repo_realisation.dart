import 'package:workout_planner/Features/Data/Models/exercise_model.dart';
import 'package:workout_planner/Features/Data/Repository/Mappers/exercise_mapper.dart';
import 'package:workout_planner/Features/Data/Service/exercise_db.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Repository/excercise_repo.dart';
import 'package:workout_planner/Features/Data/Service/query_builder.dart';

class ExerciseRepo implements IExerciseRepo {
  final ExerciseDb _db;
  ExerciseRepo(this._db);

  @override
  Future<Exercise?> getById(int id) async {
    final builder = QueryBuilder()
        .select()
        .from('excercise_table')
        .where('id', '=', id);

    try {
      final map = await _db.executeQuerySingle(builder);

      if (map == null) return null;

      final model = ExerciseModel.fromMap(map);
      return ExerciseMapper.toDomain(model);
    } catch (e) {
      print('Error getting exercise by id: $e');
      return null;
    }
  }

  @override
  Future<List<Exercise>> getByLevel(int level) async {
    final builder = QueryBuilder()
        .select()
        .from('excercise_table')
        .where('level', '=', level);
    try {
      final maps = await _db.executeQuery(builder);

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting exercises by level: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> getByCategory(String category) async {
    final builder = QueryBuilder()
        .select()
        .from('excercise_table')
        .where('category', '=', category);

    try {
      final maps = await _db.executeQuery(builder);

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting exercises by category: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> getByName(String query) async {
    final builder = QueryBuilder()
        .select()
        .from('excercise_table')
        .whereRaw('name LIKE ?', ['%$query%'])
        .orderBy('name');

    try {
      final maps = await _db.executeQuery(builder);

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error searching exercises: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> getAll() async {
    final builder = QueryBuilder().select().from('excercise_table');

    try {
      final maps = await _db.executeQuery(builder);
      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting all exercises: $e');
      return [];
    }
  }

  @override
  Future<List<Exercise>> getByMuscleGroup(String muscleGroup) async {
    final builder = QueryBuilder()
        .select()
        .from('excercise_table')
        .where('primary_muscles', '=', muscleGroup)
        .orderBy('name');

    try {
      final maps = await _db.executeQuery(builder);

      return _mapToEntityList(maps);
    } catch (e) {
      print('Error getting exercises by muscle group: $e');
      return [];
    }
  }

  List<Exercise> _mapToEntityList(List<Map<String, dynamic>> maps) {
    return maps
        .map((map) => ExerciseMapper.toDomain(ExerciseModel.fromMap(map)))
        .toList();
  }
}
