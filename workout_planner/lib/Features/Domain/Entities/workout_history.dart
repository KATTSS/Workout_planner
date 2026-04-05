class WorkoutHistory {
  final int id;
  final String date;
  final String muscleGroup;
  final String excerciseList;
  final bool isDone;

  WorkoutHistory({
    required this.id,
    required this.date,
    required this.muscleGroup,
    required this.excerciseList,
    this.isDone = false,
  });
}
