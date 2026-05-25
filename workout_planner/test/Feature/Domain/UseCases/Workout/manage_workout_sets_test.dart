import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_sets.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_no_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_weight_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_duration_perfomance.dart';

import '../../../../test_data/exercises_test_data.dart';

void main() {
  late SetManagement setManagement;
  late Workout testWorkout;
  late WeightedExercisePerformance weightedExercise;
  late BodyweightExercisePerformance bodyweightExercise;
  late DurationExercisePerformance durationExercise;

  setUp(() {
    setManagement = SetManagement();

    weightedExercise = PerformanceTestData.createWeightedBenchPress();
    bodyweightExercise = PerformanceTestData.createBodyweightPullUp();
    durationExercise = PerformanceTestData.createDurationRunning();

    testWorkout = Workout(
      id: 1,
      date: DateTime(2024, 1, 15),
      exercises: [weightedExercise, bodyweightExercise, durationExercise],
      isCompleted: false,
      notes: null,
    );
  });

  group('addSet', () {
    test('should throw exception when exercise not found', () {
      final newSet = SetData.weighted(weight: 50.0, reps: 10);

      expect(
        () => setManagement.addSet(testWorkout, 999, newSet),
        throwsWorkoutValidationException,
      );
    });

    test('should throw exception when set data is invalid for exercise type',
      () {
        final invalidSet = SetData.weighted(weight: 50.0, reps: 10);
        
        expect(
          () => setManagement.addSet(
            testWorkout,
            bodyweightExercise.exerciseId,
            invalidSet,
          ),
          throwsA(isA<WorkoutValidationException>()),
        );
      },
    );

    test('should throw exception when trying to exceed max sets (10)', () {
      var exerciseWithManySets = PerformanceTestData.createWeightedBenchPress();
      while (exerciseWithManySets.setsCount < 10) {
        exerciseWithManySets = exerciseWithManySets.addSet(
          SetData.weighted(weight: 60.0, reps: 10),
        );
      }

      final workoutWithManySets = Workout(
        id: 2,
        date: DateTime(2024, 1, 16),
        exercises: [exerciseWithManySets],
        isCompleted: false,
        notes: null,
      );

      final newSet = SetData.weighted(weight: 65.0, reps: 8);

      expect(
        () => setManagement.addSet(
          workoutWithManySets,
          exerciseWithManySets.exerciseId,
          newSet,
        ),
        throwsWorkoutValidationException,
      );
    });
  });
  group('updateSet', () {
    test('should update set in weighted exercise', () {
      final updatedSet = SetData.weighted(weight: 80.0, reps: 5);
      final result = setManagement.updateSet(
        testWorkout,
        weightedExercise.exerciseId,
        0,
        updatedSet,
      );

      final updatedExercise =
          result.exercises.firstWhere(
                (ex) => ex.exerciseId == weightedExercise.exerciseId,
              )
              as WeightedExercisePerformance;

      expect(updatedExercise.getWeightForSet(0), 80.0);
      expect(updatedExercise.getRepsForSet(0), 5);
    });

    test('should update set in bodyweight exercise', () {
      final updatedSet = SetData.bodyweight(reps: 15);
      final result = setManagement.updateSet(
        testWorkout,
        bodyweightExercise.exerciseId,
        1,
        updatedSet,
      );

      final updatedExercise =
          result.exercises.firstWhere(
                (ex) => ex.exerciseId == bodyweightExercise.exerciseId,
              )
              as BodyweightExercisePerformance;

      expect(updatedExercise.getRepsForSet(1), 15);
    });

    test('should update set in duration exercise', () {
      final updatedSet = SetData.duration(duration: 600.0);
      final result = setManagement.updateSet(
        testWorkout,
        durationExercise.exerciseId,
        0,
        updatedSet,
      );

      final updatedExercise =
          result.exercises.firstWhere(
                (ex) => ex.exerciseId == durationExercise.exerciseId,
              )
              as DurationExercisePerformance;

      expect(updatedExercise.getDurationForSet(0), 600.0);
    });

    test('should throw exception when exercise not found', () {
      final updatedSet = SetData.weighted(weight: 80.0, reps: 5);

      expect(
        () => setManagement.updateSet(testWorkout, 999, 0, updatedSet),
        throwsWorkoutValidationException,
      );
    });

    test('should throw exception when set index is out of range', () {
      final updatedSet = SetData.weighted(weight: 80.0, reps: 5);

      expect(
        () => setManagement.updateSet(
          testWorkout,
          weightedExercise.exerciseId,
          10,
          updatedSet,
        ),
        throwsA(isA<WorkoutValidationException>()),
      );
    });

    test('should throw exception when updated set data is invalid', () {
      final invalidSet = SetData.weighted(weight: 50.0, reps: 10);

      expect(
        () => setManagement.updateSet(
          testWorkout,
          bodyweightExercise.exerciseId,
          0,
          invalidSet,
        ),
        throwsWorkoutValidationException,
      );
    });
  });

  group('removeSet', () {
    test('should remove set from weighted exercise', () {
      final result = setManagement.removeSet(
        testWorkout,
        weightedExercise.exerciseId,
        0,
      );

      final updatedExercise =
          result.exercises.firstWhere(
                (ex) => ex.exerciseId == weightedExercise.exerciseId,
              )
              as WeightedExercisePerformance;

      expect(updatedExercise.setsCount, weightedExercise.setsCount - 1);
      expect(updatedExercise.getWeightForSet(0), 70.0);
      expect(updatedExercise.getRepsForSet(0), 8);
    });

    test('should remove set from bodyweight exercise', () {
      final result = setManagement.removeSet(
        testWorkout,
        bodyweightExercise.exerciseId,
        1,
      );

      final updatedExercise =
          result.exercises.firstWhere(
                (ex) => ex.exerciseId == bodyweightExercise.exerciseId,
              )
              as BodyweightExercisePerformance;

      expect(updatedExercise.setsCount, bodyweightExercise.setsCount - 1);
      expect(updatedExercise.getRepsForSet(1), 6);
    });

    test('should remove set from duration exercise', () {
      final result = setManagement.removeSet(
        testWorkout,
        durationExercise.exerciseId,
        0,
      );

      final updatedExercise =
          result.exercises.firstWhere(
                (ex) => ex.exerciseId == durationExercise.exerciseId,
              )
              as DurationExercisePerformance;

      expect(updatedExercise.setsCount, durationExercise.setsCount - 1);
    });

    test('should throw exception when exercise not found', () {
      expect(
        () => setManagement.removeSet(testWorkout, 999, 0),
        throwsWorkoutValidationException,
      );
    });

    test('should throw exception when set index is out of range', () {
      expect(
        () => setManagement.removeSet(
          testWorkout,
          weightedExercise.exerciseId,
          10,
        ),
        throwsA(isA<WorkoutValidationException>()),
      );
    });

    test('should throw exception when trying to remove last set', () {
      final singleSetExercise = TestScenarios.singleSetWeightedExercise;
      final workoutWithSingleSet = Workout(
        id: 3,
        date: DateTime(2024, 1, 17),
        exercises: [singleSetExercise],
        isCompleted: false,
        notes: null,
      );

      expect(
        () => setManagement.removeSet(
          workoutWithSingleSet,
          singleSetExercise.exerciseId,
          0,
        ),
        throwsWorkoutValidationException,
      );
    });
  });

  group('Edge cases and integration', () {
    test('should handle adding set to empty exercise', () {
      final emptyExercise = TestScenarios.emptyWeightedExercise;
      final workoutWithEmpty = Workout(
        id: 4,
        date: DateTime(2024, 1, 18),
        exercises: [emptyExercise],
        isCompleted: false,
        notes: null,
      );

      final newSet = SetData.weighted(weight: 50.0, reps: 10);
      final result = setManagement.addSet(
        workoutWithEmpty,
        emptyExercise.exerciseId,
        newSet,
      );

      final updatedExercise =
          result.exercises.first as WeightedExercisePerformance;
      expect(updatedExercise.setsCount, 1);
      expect(updatedExercise.getWeightForSet(0), 50.0);
    });

    test('should chain multiple set operations', () {
      var workout = testWorkout;

      final newSet = SetData.weighted(weight: 75.0, reps: 6);
      workout = setManagement.addSet(
        workout,
        weightedExercise.exerciseId,
        newSet,
      );
      expect(
        (workout.exercises.firstWhere(
          (ex) => ex.exerciseId == weightedExercise.exerciseId,
        )).setsCount,
        4,
      );

      final updatedSet = SetData.weighted(weight: 80.0, reps: 5);
      workout = setManagement.updateSet(
        workout,
        weightedExercise.exerciseId,
        3,
        updatedSet,
      );
      final updatedExercise =
          workout.exercises.firstWhere(
                (ex) => ex.exerciseId == weightedExercise.exerciseId,
              )
              as WeightedExercisePerformance;
      expect(updatedExercise.getWeightForSet(3), 80.0);

      workout = setManagement.removeSet(
        workout,
        weightedExercise.exerciseId,
        3,
      );
      expect(
        (workout.exercises.firstWhere(
          (ex) => ex.exerciseId == weightedExercise.exerciseId,
        )).setsCount,
        3,
      );
    });

    test('should maintain immutability - original workout unchanged', () {
      final originalExercises = testWorkout.exercises;
      final originalSetsCount = (testWorkout.exercises.firstWhere(
        (ex) => ex.exerciseId == weightedExercise.exerciseId,
      )).setsCount;

      final newSet = SetData.weighted(weight: 75.0, reps: 6);
      setManagement.addSet(testWorkout, weightedExercise.exerciseId, newSet);

      expect(testWorkout.exercises.length, originalExercises.length);
      expect(
        (testWorkout.exercises.firstWhere(
          (ex) => ex.exerciseId == weightedExercise.exerciseId,
        )).setsCount,
        originalSetsCount,
      );
    });

    test('should handle different performance types correctly', () {
      final weightedNewSet = SetData.weighted(weight: 90.0, reps: 5);
      final weightedResult = setManagement.addSet(
        testWorkout,
        weightedExercise.exerciseId,
        weightedNewSet,
      );
      expect(weightedResult, isNotNull);

      final bodyweightNewSet = SetData.bodyweight(reps: 20);
      final bodyweightResult = setManagement.addSet(
        testWorkout,
        bodyweightExercise.exerciseId,
        bodyweightNewSet,
      );
      expect(bodyweightResult, isNotNull);

      final durationNewSet = SetData.duration(duration: 500.0);
      final durationResult = setManagement.addSet(
        testWorkout,
        durationExercise.exerciseId,
        durationNewSet,
      );
      expect(durationResult, isNotNull);
    });

    test('should validate set data correctly for all types', () {
      expect(
        () => setManagement.addSet(
          testWorkout,
          weightedExercise.exerciseId,
          SetData.weighted(weight: 50.0, reps: 10),
        ),
        returnsNormally,
      );

      expect(
        () => setManagement.addSet(
          testWorkout,
          bodyweightExercise.exerciseId,
          SetData.bodyweight(reps: 10),
        ),
        returnsNormally,
      );

      expect(
        () => setManagement.addSet(
          testWorkout,
          durationExercise.exerciseId,
          SetData.duration(duration: 300.0),
        ),
        returnsNormally,
      );

      expect(
        () => setManagement.addSet(
          testWorkout,
          weightedExercise.exerciseId,
          SetData.bodyweight(reps: 10),
        ),
        throwsWorkoutValidationException,
      );

      expect(
        () => setManagement.addSet(
          testWorkout,
          bodyweightExercise.exerciseId,
          SetData.weighted(weight: 50.0, reps: 10),
        ),
        throwsWorkoutValidationException,
      );

      expect(
        () => setManagement.addSet(
          testWorkout,
          durationExercise.exerciseId,
          SetData.weighted(weight: 50.0, reps: 10),
        ),
        throwsWorkoutValidationException,
      );
    });
  });
}

final Matcher throwsWorkoutValidationException = throwsA(
  isA<WorkoutValidationException>(),
);
