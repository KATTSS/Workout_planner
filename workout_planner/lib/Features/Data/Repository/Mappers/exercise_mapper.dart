import 'package:workout_planner/Features/Data/Models/exercise_model.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

class ExerciseMapper {
  static Exercise toDomain(ExerciseModel model) {
    return Exercise(
      id: model.id,
      name: model.name,
      level: model.level,
      category: _parseCategory(model.category),
      equipment: Equipment.fromString(model.equipment),
      description: model.description,
      muscle: model.primaryMusclesList,
      secondaryMuscle: model.secondaryMusclesList ?? '',
    );
  }

  static ExerciseCategory _parseCategory(String category) {
    try {
      return ExerciseCategory.values.firstWhere(
        (e) => e.name.toLowerCase() == category.toLowerCase(),
      );
    } catch (_) {
      switch (category.toLowerCase()) {
        case 'olympic weightlifting':
          return ExerciseCategory.olympicWeightlifting;
        default:
          return ExerciseCategory.strength;
      }
    }
  }
}
