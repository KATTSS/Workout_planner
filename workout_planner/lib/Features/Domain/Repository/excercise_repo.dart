import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

abstract class IExcerciseRepo {
  Future<Excercise?> getExcercise(int id);
}
