import 'Performance/performance_type.dart';

enum ExerciseCategory {
  strength,
  bodyweight,
  cardio,
  stretching,
  plyometrics,
  strongman,
  powerlifting,
  olympicWeightlifting;

  bool get requiresWeight {
    switch (this) {
      case strength:
      case strongman:
      case powerlifting:
      case olympicWeightlifting:
        return true;
      default:
        return false;
    }
  }

  bool get isTimed {
    switch (this) {
      case cardio:
      case stretching:
        return true;
      default:
        return false;
    }
  }
}

enum Equipment {
  bodyOnly,
  machine,
  other,
  foamRoll,
  kettlebells,
  dumbbell,
  cable,
  barbell,
  bands,
  medicineBall,
  exerciseBall,
  eZCurlBar;

  bool get isBodyweight => this == Equipment.bodyOnly;

  static Equipment fromString(String? value) {
    if (value == null) return Equipment.other;
    switch (value.toLowerCase().replaceAll(' ', '')) {
      case 'bodyonly':
        return Equipment.bodyOnly;
      case 'machine':
        return Equipment.machine;
      case 'foamroll':
        return Equipment.foamRoll;
      case 'kettlebells':
        return Equipment.kettlebells;
      case 'dumbbell':
        return Equipment.dumbbell;
      case 'cable':
        return Equipment.cable;
      case 'barbell':
        return Equipment.barbell;
      case 'bands':
        return Equipment.bands;
      case 'medicineball':
        return Equipment.medicineBall;
      case 'exerciseball':
        return Equipment.exerciseBall;
      case 'e-zcurlbar':
        return Equipment.eZCurlBar;
      default:
        return Equipment.other;
    }
  }
}

class Exercise {
  final int id;
  final String name;
  final int level;
  final ExerciseCategory category;
  final Equipment equipment;
  final String description;
  final String muscle;
  final String secondaryMuscle;

  const Exercise({
    required this.id,
    required this.name,
    required this.level,
    required this.category,
    required this.equipment,
    required this.description,
    required this.muscle,
    required this.secondaryMuscle,
  });

  PerformanceType get performanceType {
    if (category.isTimed) {
      return PerformanceType.duration;
    } else if (category.requiresWeight && !equipment.isBodyweight) {
      return PerformanceType.weighted;
    } else {
      return PerformanceType.bodyweight;
    }
  }
}
