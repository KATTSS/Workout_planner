class ExerciseModel {
  final int id;
  final String name;
  final int level;
  final String category;
  final String equipment;
  final String description;
  final String primaryMusclesList;
  final String? secondaryMusclesList;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.level,
    required this.category,
    required this.equipment,
    required this.description,
    required this.primaryMusclesList,
    this.secondaryMusclesList = '',
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) =>
      _$ExerciseModelFromMap(map);

  static ExerciseModel _$ExerciseModelFromMap(Map<String, dynamic> map) =>
      ExerciseModel(
        id: map['id'] as int,
        name: map['name'] as String,
        level: map['level'] as int,
        category: map['category'] as String,
        equipment: map['equipment'] as String,
        description: map['description'] as String,
        primaryMusclesList: map['primary_muscles'] as String,
        secondaryMusclesList: map['secondary_muscles'] as String? ?? '',
      );
}
