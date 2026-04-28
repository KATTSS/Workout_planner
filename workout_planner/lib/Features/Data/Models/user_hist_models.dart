class UserHistModel {
  final int id;
  final String date;
  final String muscleGroup;
  final bool isDone;
  final String? notes;

  UserHistModel({
    required this.id,
    required this.date,
    required this.muscleGroup,
    this.isDone = false,
    this.notes,
  });

  factory UserHistModel.fromMap(Map<String, dynamic> map) {
    return UserHistModel(
      id: map['workout_id'] as int,
      date: map['date'] as String,
      muscleGroup: map['muscle_group'] as String,
      isDone: (map['isDone'] as int) == 1,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'workout_id': id,
      'muscle_group': muscleGroup,
      'date': date,
      'isDone': isDone ? 1 : 0,
      'notes': notes,
    };
  }
}
