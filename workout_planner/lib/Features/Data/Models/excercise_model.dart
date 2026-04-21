import 'package:workout_planner/Features/Data/Models/base_db_model.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

class ExcerciseModel implements BaseDBModel {
  @override
  final int id;
  final String name;
  final int level;
  final String category;
  final String equipment;
  final String description;
  final String primaryMusclesList;
  final String? secondaryMusclesList;

  ExcerciseModel({
    required this.id,
    required this.name,
    required this.level,
    required this.category,
    required this.equipment,
    required this.description,
    required this.primaryMusclesList,
    this.secondaryMusclesList = '',
  });

  factory ExcerciseModel.fromMap(Map<String, dynamic> map) =>
      _$ExcerciseModelFromMap(map);

  static ExcerciseModel _$ExcerciseModelFromMap(Map<String, dynamic> map) =>
      ExcerciseModel(
        id: map['id'] as int,
        name: map['name'] as String,
        level: map['level'] as int,
        category: map['category'] as String,
        equipment: map['equipment'] as String,
        description: map['description'] as String,
        primaryMusclesList: map['primary_muscles'] as String,
        secondaryMusclesList: map['secondary_muscles'] as String? ?? '',
      );

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'index': id,
      'name': name,
      'level': level,
      'category': category,
      'equipment': equipment,
      'description': description,
      'primary_muscles': primaryMusclesList,
      'secondary_muscles': secondaryMusclesList ?? '',
    };
  }

  Excercise toDomain() {
    return Excercise(
      id,
      name,
      level,
      category,
      equipment,
      description,
      primaryMusclesList,
      secondaryMusclesList ?? '',
    );
  }
}
