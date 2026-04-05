import 'package:workout_planner/Features/Domain/Entities/workout_history.dart';

abstract class UserHistoryDBModel {
  int get id;
  Map<String, dynamic> toMap();
}

class UserHistModel implements UserHistoryDBModel {
  @override
  final int id;
  final String muscleGroup;
  final String excerciseList;
  final String date;
  final bool isDone;

  UserHistModel({
    required this.id,
    required this.date,
    required this.excerciseList,
    required this.muscleGroup,
    this.isDone = false,
  });

  factory UserHistModel.fromMap(Map<String, dynamic> map) =>
      _$UserHistModelFromMap(map);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'workout_id': id,
      'muscle_group': muscleGroup,
      'excercise_list': excerciseList,
      'date': date,
      'isDone': isDone ? 1 : 0,
    };
  }

  static UserHistModel toModel(WorkoutHistory workout) {
    return UserHistModel(
      id: workout.id,
      date: workout.date,
      excerciseList: workout.excerciseList,
      muscleGroup: workout.muscleGroup,
      isDone: workout.isDone,
    );
  }

  static UserHistModel _$UserHistModelFromMap(Map<String, dynamic> map) =>
      UserHistModel(
        id: map['workout_id'] as int,
        muscleGroup: map['muscle_group'] as String,
        excerciseList: map['excercise_list'] as String,
        date: map['date'] as String,
        isDone: (map['isDone'] as int) == 1,
      );
}
