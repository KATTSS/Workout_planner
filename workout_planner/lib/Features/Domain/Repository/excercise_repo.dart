import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

// abstract class IExerciseRepo {
//   Future<Excercise?> getExcercise(int id);
//   Future<List<Excercise?>> getExcerciseByLevel(int level);
//   Future<List<Excercise?>> getExcerciseByString(String column, String value);
// }

abstract class IExerciseRepo {
  Future<Exercise?> getById(int id);

  Future<List<Exercise>> getByLevel(int level);

  Future<List<Exercise>> getByCategory(String category);

  Future<List<Exercise>> searchByName(String query);

  Future<List<Exercise>> getAll();

  Future<List<Exercise>> getByMuscleGroup(String muscleGroup);
}
