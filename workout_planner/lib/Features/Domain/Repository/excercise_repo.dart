import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

abstract class IExerciseRepo {
  Future<Exercise?> getById(int id);

  Future<List<Exercise>> getByIds(List<int> ids);

  Future<List<Exercise>> getByLevel(int level);

  Future<List<Exercise>> getByCategory(String category);

  Future<List<Exercise>> getByName(String query);

  Future<List<Exercise>> getAll();

  Future<List<Exercise>> getByMuscleGroup(String muscleGroup);
}
