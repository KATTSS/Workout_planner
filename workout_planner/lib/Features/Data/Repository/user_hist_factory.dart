import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';

final Map<Type, dynamic Function(Map<String, dynamic>)> dbFactories = {
  UserHistModel: (map) => UserHistModel.fromMap(map),
};
