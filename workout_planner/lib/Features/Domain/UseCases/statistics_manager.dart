import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/user.dart';

class StatisticsManager {
  String getUserStatistics(User user) {
    return "user stats";
  }

  String getExcerciseStatistics(Excercise ex) {
    return "ex stats";
  }

  String getProgressStatistics() {
    return "progress";
  }
}
