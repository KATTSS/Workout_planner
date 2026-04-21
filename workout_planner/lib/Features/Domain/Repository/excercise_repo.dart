import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

// abstract class IExcerciseRepo {
//   Future<Excercise?> getExcercise(int id);
//   Future<List<Excercise?>> getExcerciseByLevel(int level);
//   Future<List<Excercise?>> getExcerciseByString(String column, String value);
// }

abstract class IExcerciseRepo {
  Future<Excercise?> getById(int id);

  Future<List<Excercise>> getByLevel(int level);

  Future<List<Excercise>> getByCategory(String category);

  Future<List<Excercise>> searchByName(String query);

  Future<List<Excercise>> getAll();

  Future<List<Excercise>> getByMuscleGroup(String muscleGroup);
}
