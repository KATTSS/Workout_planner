import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_no_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_duration_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

/// Factory для создания тестовых упражнений (Domain Entities)
class ExerciseTestData {
  // Базовые упражнения (шаблоны)
  static const Exercise benchPress = Exercise(
    id: 1,
    name: 'Bench Press',
    level: 2,
    category: ExerciseCategory.strength,
    equipment: Equipment.barbell,
    description: 'Classic chest exercise',
    muscle: 'Chest',
    secondaryMuscle: 'Triceps',
  );

  static const Exercise squat = Exercise(
    id: 2,
    name: 'Squat',
    level: 3,
    category: ExerciseCategory.strength,
    equipment: Equipment.barbell,
    description: 'Leg exercise',
    muscle: 'Quadriceps',
    secondaryMuscle: 'Glutes',
  );

  static const Exercise pullUp = Exercise(
    id: 3,
    name: 'Pull Up',
    level: 3,
    category: ExerciseCategory.bodyweight,
    equipment: Equipment.bodyOnly,
    description: 'Back exercise',
    muscle: 'Back',
    secondaryMuscle: 'Biceps',
  );

  static const Exercise running = Exercise(
    id: 4,
    name: 'Running',
    level: 1,
    category: ExerciseCategory.cardio,
    equipment: Equipment.bodyOnly,
    description: 'Cardio exercise',
    muscle: 'Legs',
    secondaryMuscle: 'Cardiovascular',
  );

  static const Exercise pushUp = Exercise(
    id: 5,
    name: 'Push Up',
    level: 1,
    category: ExerciseCategory.bodyweight,
    equipment: Equipment.bodyOnly,
    description: 'Chest exercise',
    muscle: 'Chest',
    secondaryMuscle: 'Triceps',
  );

  static const Exercise deadlift = Exercise(
    id: 6,
    name: 'Deadlift',
    level: 3,
    category: ExerciseCategory.strength,
    equipment: Equipment.barbell,
    description: 'Full body exercise',
    muscle: 'Back',
    secondaryMuscle: 'Hamstrings',
  );
}

/// Factory для создания тестовых перформансов упражнений
class PerformanceTestData {
  // Weighted exercises
  static WeightedExercisePerformance createWeightedBenchPress({
    List<SetData>? sets,
  }) {
    return WeightedExercisePerformance(
      exerciseId: ExerciseTestData.benchPress.id,
      exercise: ExerciseTestData.benchPress,
      sets: sets ?? [
        SetData.weighted(weight: 60.0, reps: 10),
        SetData.weighted(weight: 70.0, reps: 8),
        SetData.weighted(weight: 70.0, reps: 8),
      ],
    );
  }

  static WeightedExercisePerformance createWeightedSquat({
    List<SetData>? sets,
  }) {
    return WeightedExercisePerformance(
      exerciseId: ExerciseTestData.squat.id,
      exercise: ExerciseTestData.squat,
      sets: sets ?? [
        SetData.weighted(weight: 100.0, reps: 8),
        SetData.weighted(weight: 110.0, reps: 6),
        SetData.weighted(weight: 110.0, reps: 6),
      ],
    );
  }

  // Bodyweight exercises
  static BodyweightExercisePerformance createBodyweightPullUp({
    List<SetData>? sets,
  }) {
    return BodyweightExercisePerformance(
      exerciseId: ExerciseTestData.pullUp.id,
      exercise: ExerciseTestData.pullUp,
      sets: sets ?? [
        SetData.bodyweight(reps: 8),
        SetData.bodyweight(reps: 7),
        SetData.bodyweight(reps: 6),
      ],
    );
  }

  static BodyweightExercisePerformance createBodyweightPushUp({
    List<SetData>? sets,
  }) {
    return BodyweightExercisePerformance(
      exerciseId: ExerciseTestData.pushUp.id,
      exercise: ExerciseTestData.pushUp,
      sets: sets ?? [
        SetData.bodyweight(reps: 15),
        SetData.bodyweight(reps: 12),
        SetData.bodyweight(reps: 10),
      ],
    );
  }

  // Duration exercises
  static DurationExercisePerformance createDurationRunning({
    List<SetData>? sets,
  }) {
    return DurationExercisePerformance(
      exerciseId: ExerciseTestData.running.id,
      exercise: ExerciseTestData.running,
      sets: sets ?? [
        SetData.duration(duration: 300.0), // 5 min
        SetData.duration(duration: 300.0),
      ],
    );
  }

  // Гибкие методы создания с кастомными параметрами
  static WeightedExercisePerformance createWeightedExercise({
    required Exercise exercise,
    required List<({double weight, int reps})> setsData,
  }) {
    final sets = setsData.map((set) => 
      SetData.weighted(weight: set.weight, reps: set.reps)
    ).toList();
    
    return WeightedExercisePerformance(
      exerciseId: exercise.id,
      exercise: exercise,
      sets: sets,
    );
  }

  static BodyweightExercisePerformance createBodyweightExercise({
    required Exercise exercise,
    required List<int> repsList,
  }) {
    final sets = repsList.map((reps) => 
      SetData.bodyweight(reps: reps)
    ).toList();
    
    return BodyweightExercisePerformance(
      exerciseId: exercise.id,
      exercise: exercise,
      sets: sets,
    );
  }

  static DurationExercisePerformance createDurationExercise({
    required Exercise exercise,
    required List<double> durations,
  }) {
    final sets = durations.map((duration) => 
      SetData.duration(duration: duration)
    ).toList();
    
    return DurationExercisePerformance(
      exerciseId: exercise.id,
      exercise: exercise,
      sets: sets,
    );
  }
}

/// Предопределенные сценарии для тестирования
class TestScenarios {
  // Пустые упражнения (для тестирования ошибок)
  static WeightedExercisePerformance get emptyWeightedExercise {
    return WeightedExercisePerformance(
      exerciseId: ExerciseTestData.benchPress.id,
      exercise: ExerciseTestData.benchPress,
      sets: [],
    );
  }

  static BodyweightExercisePerformance get emptyBodyweightExercise {
    return BodyweightExercisePerformance(
      exerciseId: ExerciseTestData.pullUp.id,
      exercise: ExerciseTestData.pullUp,
      sets: [],
    );
  }

  // Упражнения с экстремальными значениями
  static WeightedExercisePerformance get extremeWeightedExercise {
    return WeightedExercisePerformance(
      exerciseId: ExerciseTestData.deadlift.id,
      exercise: ExerciseTestData.deadlift,
      sets: [
        SetData.weighted(weight: 200.0, reps: 1),
        SetData.weighted(weight: 180.0, reps: 3),
        SetData.weighted(weight: 0, reps: 10), // Негативный вес? (должно вызвать ошибку)
      ],
    );
  }

  // Упражнения для тестирования граничных случаев
  static WeightedExercisePerformance get singleSetWeightedExercise {
    return WeightedExercisePerformance(
      exerciseId: ExerciseTestData.benchPress.id,
      exercise: ExerciseTestData.benchPress,
      sets: [SetData.weighted(weight: 70.0, reps: 8)],
    );
  }
}