import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_status.dart';

import '../../../../test_data/exercises_test_data.dart';


void main() {
  late WorkoutStatusManager statusManager;
  late Workout testWorkout;
  late DateTime fixedDateTime;

  setUp(() {
    fixedDateTime = DateTime(2024, 1, 15, 10, 0);
    
    // Используем кастомный провайдер даты для предсказуемых тестов
    statusManager = WorkoutStatusManager(
      dateTimeProvider: () => fixedDateTime,
    );
    
    final weightedExercise = PerformanceTestData.createWeightedBenchPress();
    final bodyweightExercise = PerformanceTestData.createBodyweightPullUp();
    
    testWorkout = Workout(
      id: 1,
      date: DateTime(2024, 1, 15),
      exercises: [weightedExercise, bodyweightExercise],
      isCompleted: false,
      notes: 'Initial notes',
    );
  });

  group('updateDate', () {
    test('should update date successfully for draft workout', () {
      final newDate = DateTime(2024, 1, 20);
      final result = statusManager.updateDate(testWorkout, newDate);
      
      expect(result.date, newDate);
      expect(result.id, testWorkout.id);
      expect(result.exercises, testWorkout.exercises);
      expect(result.isCompleted, testWorkout.isCompleted);
      expect(result.notes, testWorkout.notes);
    });

    test('should update date for completed workout with past or present date', () {
      final completedWorkout = Workout(
        id: 2,
        date: DateTime(2024, 1, 10),
        exercises: testWorkout.exercises,
        isCompleted: true,
        notes: null,
      );
      
      final pastDate = DateTime(2024, 1, 5);
      final result = statusManager.updateDate(completedWorkout, pastDate);
      
      expect(result.date, pastDate);
      expect(result.isCompleted, true);
    });

    test('should throw exception when setting future date for completed workout', () {
      final completedWorkout = Workout(
        id: 3,
        date: DateTime(2024, 1, 10),
        exercises: testWorkout.exercises,
        isCompleted: true,
        notes: null,
      );
      
      final futureDate = DateTime(2024, 1, 20);
      
      expect(
        () => statusManager.updateDate(completedWorkout, futureDate),
        throwsWorkoutValidationException,
      );
    });

    test('should allow setting same date for completed workout', () {
      final completedWorkout = Workout(
        id: 4,
        date: DateTime(2024, 1, 10),
        exercises: testWorkout.exercises,
        isCompleted: true,
        notes: null,
      );
      
      final sameDate = DateTime(2024, 1, 10);
      final result = statusManager.updateDate(completedWorkout, sameDate);
      
      expect(result.date, sameDate);
    });

    test('should maintain immutability when updating date', () {
      final newDate = DateTime(2024, 1, 20);
      final result = statusManager.updateDate(testWorkout, newDate);
      
      expect(testWorkout.date, DateTime(2024, 1, 15));
      expect(result.date, newDate);
    });
  });

  group('updateNotes', () {
    test('should update notes successfully', () {
      const newNotes = 'Updated workout notes';
      final result = statusManager.updateNotes(testWorkout, newNotes);
      
      expect(result.notes, newNotes);
      expect(result.id, testWorkout.id);
      expect(result.date, testWorkout.date);
      expect(result.exercises, testWorkout.exercises);
      expect(result.isCompleted, testWorkout.isCompleted);
    });

    test('should set notes to null when null provided', () {
      final result = statusManager.updateNotes(testWorkout, null);
      
      expect(result.notes, null);
    });

    test('should throw exception when notes exceed 1000 characters', () {
      final longNotes = 'a' * 1001;
      
      expect(
        () => statusManager.updateNotes(testWorkout, longNotes),
        throwsWorkoutValidationException,
      );
    });

    test('should accept notes with exactly 1000 characters', () {
      final exactLengthNotes = 'a' * 1000;
      final result = statusManager.updateNotes(testWorkout, exactLengthNotes);
      
      expect(result.notes, exactLengthNotes);
    });

    test('should accept empty string as notes', () {
      const emptyNotes = '';
      final result = statusManager.updateNotes(testWorkout, emptyNotes);
      
      expect(result.notes, emptyNotes);
    });

    test('should maintain immutability when updating notes', () {
      const newNotes = 'New notes';
      final result = statusManager.updateNotes(testWorkout, newNotes);
      
      expect(testWorkout.notes, 'Initial notes');
      expect(result.notes, newNotes);
    });
  });

  group('markAsCompleted', () {
    test('should mark workout as completed successfully', () {
      final result = statusManager.markAsCompleted(testWorkout);
      
      expect(result.isCompleted, true);
      expect(result.id, testWorkout.id);
      expect(result.date, testWorkout.date);
      expect(result.exercises, testWorkout.exercises);
      expect(result.notes, testWorkout.notes);
    });

    test('should throw exception when marking empty workout as completed', () {
      final emptyWorkout = Workout(
        id: 5,
        date: DateTime(2024, 1, 15),
        exercises: [],
        isCompleted: false,
        notes: null,
      );
      
      expect(
        () => statusManager.markAsCompleted(emptyWorkout),
        throwsWorkoutValidationException,
      );
    });

    test('should keep completed status when marking already completed workout', () {
      final completedWorkout = Workout(
        id: 6,
        date: DateTime(2024, 1, 15),
        exercises: testWorkout.exercises,
        isCompleted: true,
        notes: null,
      );
      
      final result = statusManager.markAsCompleted(completedWorkout);
      
      expect(result.isCompleted, true);
    });

    test('should preserve exercises when marking as completed', () {
      final result = statusManager.markAsCompleted(testWorkout);
      
      expect(result.exercises.length, testWorkout.exercises.length);
      expect(result.exercises, testWorkout.exercises);
    });

    test('should maintain immutability when marking as completed', () {
      final result = statusManager.markAsCompleted(testWorkout);
      
      expect(testWorkout.isCompleted, false);
      expect(result.isCompleted, true);
    });
  });

  group('markAsDraft', () {
    test('should mark completed workout as draft', () {
      final completedWorkout = Workout(
        id: 7,
        date: DateTime(2024, 1, 15),
        exercises: testWorkout.exercises,
        isCompleted: true,
        notes: 'Completed workout notes',
      );
      
      final result = statusManager.markAsDraft(completedWorkout);
      
      expect(result.isCompleted, false);
      expect(result.id, completedWorkout.id);
      expect(result.date, completedWorkout.date);
      expect(result.exercises, completedWorkout.exercises);
      expect(result.notes, completedWorkout.notes);
    });

    test('should keep draft status when marking draft workout as draft', () {
      final result = statusManager.markAsDraft(testWorkout);
      
      expect(result.isCompleted, false);
    });

    test('should preserve empty workout when marking as draft', () {
      final emptyWorkout = Workout(
        id: 8,
        date: DateTime(2024, 1, 15),
        exercises: [],
        isCompleted: false,
        notes: null,
      );
      
      final result = statusManager.markAsDraft(emptyWorkout);
      
      expect(result.isCompleted, false);
      expect(result.exercises, []);
    });

    test('should maintain immutability when marking as draft', () {
      final completedWorkout = Workout(
        id: 9,
        date: DateTime(2024, 1, 15),
        exercises: testWorkout.exercises,
        isCompleted: true,
        notes: null,
      );
      
      final result = statusManager.markAsDraft(completedWorkout);
      
      expect(completedWorkout.isCompleted, true);
      expect(result.isCompleted, false);
    });
  });

  group('Edge cases and integration', () {
    test('should handle multiple status changes', () {
      var workout = testWorkout;
      
      // Update notes
      workout = statusManager.updateNotes(workout, 'Updated notes');
      expect(workout.notes, 'Updated notes');
      
      // Mark as completed
      workout = statusManager.markAsCompleted(workout);
      expect(workout.isCompleted, true);
      
      // Update date (past date - allowed for completed)
      final pastDate = DateTime(2024, 1, 10);
      workout = statusManager.updateDate(workout, pastDate);
      expect(workout.date, pastDate);
      
      // Mark as draft
      workout = statusManager.markAsDraft(workout);
      expect(workout.isCompleted, false);
      
      // Update date to future (allowed for draft)
      final futureDate = DateTime(2024, 1, 20);
      workout = statusManager.updateDate(workout, futureDate);
      expect(workout.date, futureDate);
    });

    test('should handle chaining operations with validation', () {
      var workout = testWorkout;
      
      // Successfully complete workout
      workout = statusManager.markAsCompleted(workout);
      expect(workout.isCompleted, true);
      
      // Try to set future date (should throw)
      expect(
        () => statusManager.updateDate(workout, DateTime(2024, 1, 20)),
        throwsWorkoutValidationException,
      );
      
      // Can set past date
      expect(
        () => statusManager.updateDate(workout, DateTime(2024, 1, 10)),
        returnsNormally,
      );
      
      // Mark as draft and then set future date (should work)
      workout = statusManager.markAsDraft(workout);
      final futureDate = DateTime(2024, 1, 25);
      workout = statusManager.updateDate(workout, futureDate);
      expect(workout.date, futureDate);
    });

    test('should handle null notes correctly', () {
      var workout = testWorkout;
      
      // Set notes to null
      workout = statusManager.updateNotes(workout, null);
      expect(workout.notes, null);
      
      // Update notes from null to some value
      workout = statusManager.updateNotes(workout, 'New notes');
      expect(workout.notes, 'New notes');
      
      // Set back to null
      workout = statusManager.updateNotes(workout, null);
      expect(workout.notes, null);
    });

  });

  group('Date provider tests', () {
    test('should use custom date time provider', () {
      final customDateTime = DateTime(2025, 12, 25);
      final customManager = WorkoutStatusManager(
        dateTimeProvider: () => customDateTime,
      );
      
      final completedWorkout = Workout(
        id: 10,
        date: DateTime(2024, 1, 1),
        exercises: testWorkout.exercises,
        isCompleted: true,
        notes: null,
      );
      
      // Future date relative to custom provider
      final futureDate = DateTime(2025, 12, 30);
      
      expect(
        () => customManager.updateDate(completedWorkout, futureDate),
        throwsWorkoutValidationException,
      );
    });
  });
}

final Matcher throwsWorkoutValidationException = throwsA(
  isA<WorkoutValidationException>(),
);