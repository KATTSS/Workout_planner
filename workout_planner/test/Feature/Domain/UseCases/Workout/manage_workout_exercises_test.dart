import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_exercises.dart';
import '../../../../test_data/exercises_test_data.dart';
void main() {
  late ManageWorkoutExercises manageWorkoutExercises;
  late Workout testWorkout;
  late ExercisePerformance exercise1;
  late ExercisePerformance exercise2;
  late ExercisePerformance exercise3;

  setUp(() {
    manageWorkoutExercises = ManageWorkoutExercises();
    
    exercise1 = PerformanceTestData.createWeightedBenchPress();
    exercise2 = PerformanceTestData.createWeightedSquat();
    exercise3 = PerformanceTestData.createBodyweightPullUp();
    
    testWorkout = Workout(
      id: 1,
      date: DateTime(2024, 1, 15),
      exercises: [exercise1, exercise2],
      isCompleted: false,
      notes: null,
    );
  });

  group('addExercise', () {
    test('should add exercise successfully', () {
      final result = manageWorkoutExercises.addExercise(testWorkout, exercise3);
      
      expect(result.exercises.length, 3);
      expect(result.exercises, contains(exercise3));
      expect(result.exercises[0].exerciseId, exercise1.exerciseId);
      expect(result.exercises[1].exerciseId, exercise2.exerciseId);
      expect(result.exercises[2].exerciseId, exercise3.exerciseId);
    });

    test('should throw exception when adding duplicate exercise', () {
      expect(
        () => manageWorkoutExercises.addExercise(testWorkout, exercise1),
        throwsA(isA<WorkoutValidationException>()),
      );
    });
  });

  group('removeExercise', () {
    test('should remove exercise successfully', () {
      final result = manageWorkoutExercises.removeExercise(testWorkout, exercise1.exerciseId);
      
      expect(result.exercises.length, 1);
      expect(result.exercises.first.exerciseId, exercise2.exerciseId);
    });

    test('should remove exercise when multiple exercises exist', () {
      final workoutWithThree = Workout(
        id: 2,
        date: DateTime(2024, 1, 16),
        exercises: [exercise1, exercise2, exercise3],
        isCompleted: false,
        notes: null,
      );
      
      final result = manageWorkoutExercises.removeExercise(workoutWithThree, exercise2.exerciseId);
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, exercise1.exerciseId);
      expect(result.exercises[1].exerciseId, exercise3.exerciseId);
    });

    test('should throw exception when removing last exercise from completed workout', () {
      final singleExercise = PerformanceTestData.createWeightedBenchPress();
      final completedWorkout = Workout(
        id: 3,
        date: DateTime(2024, 1, 17),
        exercises: [singleExercise],
        isCompleted: true,
        notes: null,
      );
      
      expect(
        () => manageWorkoutExercises.removeExercise(completedWorkout, singleExercise.exerciseId),
        throwsA(isA<WorkoutValidationException>()),
      );
    });

    test('should allow removing last exercise from incomplete workout', () {
      final singleExercise = PerformanceTestData.createWeightedBenchPress();
      var incompleteWorkout = Workout(
        id: 5,
        date: DateTime(2024, 1, 19),
        exercises: [singleExercise],
        isCompleted: false,
        notes: null,
      );
      
      final result = manageWorkoutExercises.removeExercise(incompleteWorkout, singleExercise.exerciseId);
      
      expect(result.exercises.length, 0);
    });

    test('should do nothing when exercise id not found', () {
      final result = manageWorkoutExercises.removeExercise(testWorkout, 999);
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, exercise1.exerciseId);
      expect(result.exercises[1].exerciseId, exercise2.exerciseId);
    });
  });

  group('reorderExercises', () {
    test('should reorder exercise moving forward (decreasing index)', () {
      final result = manageWorkoutExercises.reorderExercises(testWorkout, 1, 0);
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, exercise2.exerciseId);
      expect(result.exercises[1].exerciseId, exercise1.exerciseId);
    });

    test('should reorder exercise moving backward (increasing index)', () {
      final result = manageWorkoutExercises.reorderExercises(testWorkout, 0, 1);
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, exercise2.exerciseId);
      expect(result.exercises[1].exerciseId, exercise1.exerciseId);
    });

    test('should reorder with three exercises - moving first to last', () {
      final workoutWithThree = Workout(
        id: 6,
        date: DateTime(2024, 1, 20),
        exercises: [exercise1, exercise2, exercise3],
        isCompleted: false,
        notes: null,
      );
      
      final result = manageWorkoutExercises.reorderExercises(workoutWithThree, 0, 2);
      
      expect(result.exercises.length, 3);
      expect(result.exercises[0].exerciseId, exercise2.exerciseId);
      expect(result.exercises[1].exerciseId, exercise3.exerciseId);
      expect(result.exercises[2].exerciseId, exercise1.exerciseId);
    });

    test('should reorder with three exercises - moving last to first', () {
      final workoutWithThree = Workout(
        id: 7,
        date: DateTime(2024, 1, 21),
        exercises: [exercise1, exercise2, exercise3],
        isCompleted: false,
        notes: null,
      );
      
      final result = manageWorkoutExercises.reorderExercises(workoutWithThree, 2, 0);
      
      expect(result.exercises.length, 3);
      expect(result.exercises[0].exerciseId, exercise3.exerciseId);
      expect(result.exercises[1].exerciseId, exercise1.exerciseId);
      expect(result.exercises[2].exerciseId, exercise2.exerciseId);
    });

    test('should throw RangeError when oldIndex is negative', () {
      expect(
        () => manageWorkoutExercises.reorderExercises(testWorkout, -1, 0),
        throwsA(isA<RangeError>()),
      );
    });

    test('should throw RangeError when oldIndex is out of bounds', () {
      expect(
        () => manageWorkoutExercises.reorderExercises(testWorkout, 5, 0),
        throwsA(isA<RangeError>()),
      );
    });

    test('should handle reorder to same index (no change)', () {
      final result = manageWorkoutExercises.reorderExercises(testWorkout, 0, 0);
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, exercise1.exerciseId);
      expect(result.exercises[1].exerciseId, exercise2.exerciseId);
    });

    test('should throw RangeError with newIndex greater than length', () {
      expect(
        () => manageWorkoutExercises.reorderExercises(testWorkout, 0, 5),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('replaceExercise', () {
    late ExercisePerformance newExercise;
    
    setUp(() {
      newExercise = PerformanceTestData.createBodyweightPushUp();
    });

    test('should replace exercise successfully', () {
      final result = manageWorkoutExercises.replaceExercise(
        testWorkout,
        exercise1.exerciseId,
        newExercise,
      );
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, newExercise.exerciseId);
      expect(result.exercises[1].exerciseId, exercise2.exerciseId);
    });

    test('should replace exercise when multiple exercises exist', () {
      final workoutWithThree = Workout(
        id: 8,
        date: DateTime(2024, 1, 22),
        exercises: [exercise1, exercise2, exercise3],
        isCompleted: false,
        notes: null,
      );
      
      final result = manageWorkoutExercises.replaceExercise(
        workoutWithThree,
        exercise2.exerciseId,
        newExercise,
      );
      
      expect(result.exercises.length, 3);
      expect(result.exercises[0].exerciseId, exercise1.exerciseId);
      expect(result.exercises[1].exerciseId, newExercise.exerciseId);
      expect(result.exercises[2].exerciseId, exercise3.exerciseId);
    });

    test('should throw exception when replacing with duplicate exercise id', () {
      expect(
        () => manageWorkoutExercises.replaceExercise(
          testWorkout,
          exercise1.exerciseId,
          exercise2,
        ),
        throwsA(isA<WorkoutValidationException>()),
      );
    });

    test('should not throw exception when replacing exercise with same id', () {
      final result = manageWorkoutExercises.replaceExercise(
        testWorkout,
        exercise1.exerciseId,
        exercise1,
      );
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, exercise1.exerciseId);
    });

    test('should handle replacement when oldExerciseId not found', () {
      final result = manageWorkoutExercises.replaceExercise(
        testWorkout,
        999,
        newExercise,
      );
      
      expect(result.exercises.length, 2);
      expect(result.exercises[0].exerciseId, exercise1.exerciseId);
      expect(result.exercises[1].exerciseId, exercise2.exerciseId);
    });

    test('should maintain exercise properties after replacement', () {
      final result = manageWorkoutExercises.replaceExercise(
        testWorkout,
        exercise1.exerciseId,
        newExercise,
      );
      
      final replacedExercise = result.exercises[0];
      expect(replacedExercise.exerciseId, newExercise.exerciseId);
      expect(replacedExercise.exercise.name, 'Push Up');
      expect(replacedExercise.setsCount, newExercise.setsCount);
    });
  });

  group('Integration tests with test scenarios', () {
    test('should handle empty workout', () {
      final emptyWorkout = Workout(
        id: 9,
        date: DateTime(2024, 1, 23),
        exercises: [],
        isCompleted: false,
        notes: null,
      );
      
      final newExercise = PerformanceTestData.createWeightedBenchPress();
      final result = manageWorkoutExercises.addExercise(emptyWorkout, newExercise);
      
      expect(result.exercises.length, 1);
      expect(result.exercises.first.exerciseId, newExercise.exerciseId);
    });

    test('should handle replacing with different performance types', () {
      final weightedExercise = PerformanceTestData.createWeightedBenchPress();
      final bodyweightExercise = PerformanceTestData.createBodyweightPullUp();
      
      final workout = Workout(
        id: 10,
        date: DateTime(2024, 1, 24),
        exercises: [weightedExercise],
        isCompleted: false,
        notes: null,
      );
      
      final result = manageWorkoutExercises.replaceExercise(
        workout,
        weightedExercise.exerciseId,
        bodyweightExercise,
      );
      
      expect(result.exercises.first.exerciseId, bodyweightExercise.exerciseId);
      expect(result.exercises.first.exercise.name, 'Pull Up');
    });

    test('should chain multiple operations', () {
      var workout = testWorkout;
      
      final newExercise = PerformanceTestData.createDurationRunning();
      workout = manageWorkoutExercises.addExercise(workout, newExercise);
      expect(workout.exercises.length, 3);
      
      final replacementExercise = PerformanceTestData.createBodyweightPushUp();
      workout = manageWorkoutExercises.replaceExercise(
        workout,
        exercise2.exerciseId,
        replacementExercise,
      );
      expect(workout.exercises[1].exerciseId, replacementExercise.exerciseId);
      
      workout = manageWorkoutExercises.reorderExercises(workout, 0, 2);
      expect(workout.exercises[2].exerciseId, exercise1.exerciseId);
      
      workout = manageWorkoutExercises.removeExercise(workout, newExercise.exerciseId);
      expect(workout.exercises.length, 2);
    });
  });
}