import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_session_manager.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import '../../../../test_data/exercises_test_data.dart';

void main() {
  late WorkoutSessionManager sessionManager;
  late Workout initialWorkout;
  late Workout updatedWorkout1;
  late Workout updatedWorkout2;

  setUp(() {
    final weightedExercise = PerformanceTestData.createWeightedBenchPress();
    final bodyweightExercise = PerformanceTestData.createBodyweightPullUp();
    final durationExercise = PerformanceTestData.createDurationRunning();

    initialWorkout = Workout(
      id: 1,
      date: DateTime(2024, 1, 15),
      exercises: [weightedExercise, bodyweightExercise],
      isCompleted: false,
      notes: 'Initial workout',
    );

    updatedWorkout1 = Workout(
      id: 1,
      date: DateTime(2024, 1, 16),
      exercises: [weightedExercise, bodyweightExercise, durationExercise],
      isCompleted: false,
      notes: 'Added running',
    );

    updatedWorkout2 = Workout(
      id: 1,
      date: DateTime(2024, 1, 17),
      exercises: [weightedExercise, durationExercise],
      isCompleted: true,
      notes: 'Completed with running',
    );

    sessionManager = WorkoutSessionManager(initialWorkout);
  });

  group('Constructor and initialization', () {
    test('should initialize with provided workout', () {
      expect(sessionManager.currentWorkout, initialWorkout);
      expect(sessionManager.canUndo, false);
      expect(sessionManager.canRedo, false);
      expect(sessionManager.isModified, false);
    });

    test('should initialize with custom maxHistorySize', () {
      final customManager = WorkoutSessionManager(
        initialWorkout,
        maxHistorySize: 10,
      );

      expect(customManager.maxHistorySize, 10);
    });

    test('should initialize with default maxHistorySize (50)', () {
      expect(sessionManager.maxHistorySize, 50);
    });
  });

  group('updateState', () {
    test('should update workout state', () {
      sessionManager.updateState(updatedWorkout1);

      expect(sessionManager.currentWorkout, updatedWorkout1);
      expect(sessionManager.isModified, true);
    });

    test('should clear future history after update', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);

      sessionManager.undo();
      sessionManager.undo();

      final newWorkout = Workout(
        id: 1,
        date: DateTime(2024, 1, 18),
        exercises: [PerformanceTestData.createWeightedBenchPress()],
        isCompleted: false,
        notes: 'New path',
      );
      sessionManager.updateState(newWorkout);

      expect(sessionManager.canRedo, false);
      expect(sessionManager.currentWorkout, newWorkout);
    });

    test('should add to history on update', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);

      expect(sessionManager.canUndo, true);
      expect(sessionManager.canRedo, false);
    });

    test('should handle multiple updates', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);

      expect(sessionManager.currentWorkout, updatedWorkout2);
      expect(sessionManager.isModified, true);
    });
  });

  group('markAsSaved', () {
    test('should mark as saved after update', () {
      sessionManager.updateState(updatedWorkout1);
      expect(sessionManager.isModified, true);

      sessionManager.markAsSaved();
      expect(sessionManager.isModified, false);
    });

    test('should reset modified flag without affecting history', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.markAsSaved();

      expect(sessionManager.canUndo, true);

      sessionManager.updateState(updatedWorkout2);
      expect(sessionManager.isModified, true);
    });
  });

  group('undo', () {
    test('should undo to previous state', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);

      final result = sessionManager.undo();

      expect(result, true);
      expect(sessionManager.currentWorkout, updatedWorkout1);
      expect(sessionManager.isModified, true);
      expect(sessionManager.canUndo, true);
      expect(sessionManager.canRedo, true);
    });

    test('should undo multiple steps', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);

      sessionManager.undo();
      sessionManager.undo();

      expect(sessionManager.currentWorkout, initialWorkout);
      expect(sessionManager.canUndo, false);
      expect(sessionManager.canRedo, true);
    });

    test('should return false when cannot undo', () {
      expect(sessionManager.canUndo, false);
      final result = sessionManager.undo();

      expect(result, false);
      expect(sessionManager.currentWorkout, initialWorkout);
    });

    test('should maintain modified flag after undo', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.markAsSaved();
      sessionManager.updateState(updatedWorkout2);

      sessionManager.undo();

      expect(sessionManager.isModified, true);
    });
  });

  group('redo', () {
    test('should redo to next state', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);
      sessionManager.undo();

      final result = sessionManager.redo();

      expect(result, true);
      expect(sessionManager.currentWorkout, updatedWorkout2);
      expect(sessionManager.isModified, true);
      expect(sessionManager.canUndo, true);
      expect(sessionManager.canRedo, false);
    });

    test('should redo multiple steps', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);
      sessionManager.undo();
      sessionManager.undo();

      sessionManager.redo();
      sessionManager.redo();

      expect(sessionManager.currentWorkout, updatedWorkout2);
      expect(sessionManager.canUndo, true);
      expect(sessionManager.canRedo, false);
    });

    test('should return false when cannot redo', () {
      expect(sessionManager.canRedo, false);
      final result = sessionManager.redo();

      expect(result, false);
      expect(sessionManager.currentWorkout, initialWorkout);
    });

    test('should maintain modified flag after redo', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.markAsSaved();
      sessionManager.updateState(updatedWorkout2);
      sessionManager.undo();

      sessionManager.redo();

      expect(sessionManager.isModified, true);
    });
  });

  group('History management', () {
    test('should limit history size', () {
      final limitedManager = WorkoutSessionManager(
        initialWorkout,
        maxHistorySize: 3,
      );

      limitedManager.updateState(updatedWorkout1);
      limitedManager.updateState(updatedWorkout2);

      final newWorkout3 = Workout(
        id: 1,
        date: DateTime(2024, 1, 18),
        exercises: [PerformanceTestData.createBodyweightPullUp()],
        isCompleted: false,
        notes: 'Workout 3',
      );
      limitedManager.updateState(newWorkout3);

      expect(limitedManager.canUndo, true);
      expect(limitedManager.canRedo, false);

      limitedManager.undo();
      expect(limitedManager.currentWorkout, updatedWorkout2);

      limitedManager.undo();
      expect(limitedManager.currentWorkout, updatedWorkout1);

      var res = limitedManager.undo();
      expect(res, false);
      expect(limitedManager.currentWorkout, updatedWorkout1);
    });

    test('should maintain history integrity after multiple operations', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);
      sessionManager.undo();
      sessionManager.redo();
      sessionManager.undo();

      expect(sessionManager.currentWorkout, updatedWorkout1);
      expect(sessionManager.canUndo, true);
      expect(sessionManager.canRedo, true);
    });

    test('should handle rapid undo/redo operations', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.updateState(updatedWorkout2);

      for (int i = 0; i < 5; i++) {
        sessionManager.undo();
        sessionManager.redo();
      }

      expect(sessionManager.currentWorkout, updatedWorkout2);
      expect(sessionManager.isModified, true);
    });
  });

  group('Complex workout operations', () {
    test('should handle adding exercises in session', () {
      var workout = sessionManager.currentWorkout;
      final newExercise = PerformanceTestData.createDurationRunning();
      
      final updatedExercises = [...workout.exercises, newExercise];
      final newWorkout = workout.copyWith(exercises: updatedExercises);
      
      sessionManager.updateState(newWorkout);
      
      expect(sessionManager.currentWorkout.exercises.length, 
             initialWorkout.exercises.length + 1);
      expect(sessionManager.isModified, true);
    });

    test('should handle removing exercises in session', () {
      var workout = sessionManager.currentWorkout;
      
      final updatedExercises = workout.exercises
          .where((ex) => ex.exercise.name != 'Bench Press')
          .toList();
      final newWorkout = workout.copyWith(exercises: updatedExercises);
      
      sessionManager.updateState(newWorkout);
      
      expect(sessionManager.currentWorkout.exercises.length, 
             initialWorkout.exercises.length - 1);
      expect(sessionManager.isModified, true);
    });

    test('should handle updating exercise sets', () {
      var workout = sessionManager.currentWorkout;
      final firstExercise = workout.exercises.first;
      
      final newSet = SetData.weighted(weight: 80.0, reps: 5);
      final updatedExercise = firstExercise.addSet(newSet);
      
      final updatedExercises = workout.exercises.map((ex) {
        return ex.exerciseId == firstExercise.exerciseId ? updatedExercise : ex;
      }).toList();
      
      final newWorkout = workout.copyWith(exercises: updatedExercises);
      sessionManager.updateState(newWorkout);
      
      expect(sessionManager.currentWorkout.exercises.first.setsCount, 
             firstExercise.setsCount + 1);
      expect(sessionManager.isModified, true);
    });

    test('should handle changing workout status', () {
      var workout = sessionManager.currentWorkout;
      final completedWorkout = workout.copyWith(isCompleted: true);
      
      sessionManager.updateState(completedWorkout);
      
      expect(sessionManager.currentWorkout.isCompleted, true);
      expect(sessionManager.isModified, true);
    });

    test('should handle changing workout date', () {
      var workout = sessionManager.currentWorkout;
      final newDate = DateTime(2024, 1, 20);
      const newNotes = 'Updated date';
      final updatedWorkout = workout.copyWith(date: newDate, notes: newNotes);
      
      sessionManager.updateState(updatedWorkout);
      
      expect(sessionManager.currentWorkout.date, newDate);
      expect(sessionManager.currentWorkout.notes, newNotes);
      expect(sessionManager.isModified, true);
    });

    test('should handle replacing exercise in session', () {
      var workout = sessionManager.currentWorkout;
      final newExercise = PerformanceTestData.createBodyweightPushUp();
      final exerciseToReplace = workout.exercises.first;
      
      final updatedExercises = workout.exercises.map((ex) {
        return ex.exerciseId == exerciseToReplace.exerciseId ? newExercise : ex;
      }).toList();
      
      final newWorkout = workout.copyWith(exercises: updatedExercises);
      sessionManager.updateState(newWorkout);
      
      expect(sessionManager.currentWorkout.exercises.first.exerciseId, 
             newExercise.exerciseId);
      expect(sessionManager.isModified, true);
    });

    test('should handle reordering exercises in session', () {
      var workout = sessionManager.currentWorkout;
      
      final updatedExercises = [
        workout.exercises[1],
        workout.exercises[0],
      ];
      
      final newWorkout = workout.copyWith(exercises: updatedExercises);
      sessionManager.updateState(newWorkout);
      
      expect(sessionManager.currentWorkout.exercises[0].exerciseId, 
             workout.exercises[1].exerciseId);
      expect(sessionManager.currentWorkout.exercises[1].exerciseId, 
             workout.exercises[0].exerciseId);
      expect(sessionManager.isModified, true);
    });

    test('should handle multiple operations in sequence', () {
      var workout = sessionManager.currentWorkout;
            
      final newExercise = PerformanceTestData.createDurationRunning();
      var updatedExercises = [...workout.exercises, newExercise];
      workout = workout.copyWith(exercises: updatedExercises);
      sessionManager.updateState(workout);
      
      expect(sessionManager.currentWorkout.exercises.length, 3);
      
      workout = sessionManager.currentWorkout.copyWith(isCompleted: true);
      sessionManager.updateState(workout);
      
      expect(sessionManager.currentWorkout.isCompleted, true);
      
      workout = sessionManager.currentWorkout.copyWith(notes: 'Completed with notes');
      sessionManager.updateState(workout);
      
      expect(sessionManager.currentWorkout.notes, 'Completed with notes');
      expect(sessionManager.isModified, true);
      
      sessionManager.undo();
      expect(sessionManager.currentWorkout.isCompleted, true);
      expect(sessionManager.currentWorkout.notes, 'Initial workout');
      
      sessionManager.undo();
      expect(sessionManager.currentWorkout.exercises.length, 3);
      expect(sessionManager.currentWorkout.isCompleted, false);
    });
  });
  
  group('Edge cases', () {
    test('should handle multiple saves and modifications', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.markAsSaved();

      expect(sessionManager.isModified, false);

      sessionManager.updateState(updatedWorkout2);
      expect(sessionManager.isModified, true);

      sessionManager.undo();
      expect(sessionManager.currentWorkout, updatedWorkout1);
      expect(sessionManager.isModified, true);

      sessionManager.markAsSaved();
      expect(sessionManager.isModified, false);
    });

    test('should handle undo after save', () {
      sessionManager.updateState(updatedWorkout1);
      sessionManager.markAsSaved();
      sessionManager.updateState(updatedWorkout2);
      sessionManager.undo();

      expect(sessionManager.currentWorkout, updatedWorkout1);
      expect(sessionManager.isModified, true);
    });

    test('should handle session with identical workouts', () {
      final sameWorkout = initialWorkout.copyWith(notes: 'Same notes');
      sessionManager.updateState(sameWorkout);

      expect(sessionManager.currentWorkout, sameWorkout);
      expect(sessionManager.canUndo, true);
      expect(sessionManager.canRedo, false);
    });

    test('should handle session with many operations near history limit', () {
      final smallManager = WorkoutSessionManager(
        initialWorkout,
        maxHistorySize: 3,
      );

      var currentWorkout = initialWorkout;
      for (int i = 0; i < 10; i++) {
        currentWorkout = currentWorkout.copyWith(notes: 'Workout $i');
        smallManager.updateState(currentWorkout);
      }

      for (int i = 0; i < 5; i++) {
        smallManager.undo();
      }

      expect(smallManager.currentWorkout.notes, isNot(initialWorkout.notes));
    });
  });

  group('Getters', () {
    test('should return correct currentWorkout', () {
      expect(sessionManager.currentWorkout, initialWorkout);

      sessionManager.updateState(updatedWorkout1);
      expect(sessionManager.currentWorkout, updatedWorkout1);
    });

    test('should return correct canUndo value', () {
      expect(sessionManager.canUndo, false);

      sessionManager.updateState(updatedWorkout1);
      expect(sessionManager.canUndo, true);

      sessionManager.undo();
      expect(sessionManager.canUndo, false);
    });

    test('should return correct canRedo value', () {
      expect(sessionManager.canRedo, false);

      sessionManager.updateState(updatedWorkout1);
      expect(sessionManager.canRedo, false);

      sessionManager.undo();
      expect(sessionManager.canRedo, true);

      sessionManager.redo();
      expect(sessionManager.canRedo, false);
    });

    test('should return correct isModified value', () {
      expect(sessionManager.isModified, false);

      sessionManager.updateState(updatedWorkout1);
      expect(sessionManager.isModified, true);

      sessionManager.markAsSaved();
      expect(sessionManager.isModified, false);

      sessionManager.undo();
      expect(sessionManager.isModified, true);
    });
  });
}
