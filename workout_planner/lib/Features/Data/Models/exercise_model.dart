import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

// class ExerciseModel implements BaseDBModel {
// @override
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

  // @override
  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'index': id,
  //     'name': name,
  //     'level': level,
  //     'category': category,
  //     'equipment': equipment,
  //     'description': description,
  //     'primary_muscles': primaryMusclesList,
  //     'secondary_muscles': secondaryMusclesList ?? '',
  //   };
  // }

  Exercise toDomain() {
    return Exercise(
      id: id,
      name: name,
      level: level,
      category: _parseCategory(category),
      equipment: Equipment.fromString(equipment),
      description: description,
      muscle: primaryMusclesList,
      secondaryMuscle: secondaryMusclesList ?? '',
    );
  }

  // Создание из доменной модели
  // factory ExerciseModel.fromDomain(Exercise exercise) {
  //   return ExerciseModel(
  //     id: exercise.id,
  //     name: exercise.name,
  //     level: exercise.level,
  //     category: exercise.category.name,
  //     equipment: exercise.equipment.name,
  //     description: exercise.description,
  //     primaryMusclesList: exercise.muscle,
  //     secondaryMusclesList: exercise.secondaryMuscle,
  //   );
  // }

  static ExerciseCategory _parseCategory(String category) {
    try {
      return ExerciseCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == category.toLowerCase(),
      );
    } catch (_) {
      // Маппинг для специальных случаев
      switch (category.toLowerCase()) {
        case 'olympic weightlifting':
          return ExerciseCategory.olympicWeightlifting;
        default:
          return ExerciseCategory.strength;
      }
    }
  }
}
