import 'package:workout_planner/Features/Data/Models/user_model.dart';

abstract class ILocalUserDataSource {
  Future<UserModel?> getUser();
  Future<int> upsertUser(UserModel user);
  Future<int> insertWeightHistory(String date, double weight);
  Future<List<Map<String, dynamic>>> getWeightHistory({int? limit});
}
