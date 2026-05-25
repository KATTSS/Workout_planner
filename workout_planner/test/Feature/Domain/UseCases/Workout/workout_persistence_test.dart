import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:workout_planner/Features/Domain/Repository/history_repo.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_persistence.dart';
import '../../../../test_data/exercises_test_data.dart';

// Генерируем мок для репозитория
@GenerateMocks([IHistoryRepo])
import 'workout_persistence_test.mocks.dart';

void main() {
  late MockIHistoryRepo mockHistoryRepo;
  late CreateWorkout createWorkout;
  late SaveWorkout saveWorkout;
  late DeleteWorkout deleteWorkout;
  late GetWorkoutHistory getWorkoutHistory;
  late Workout testWorkout;

  setUp(() {
    mockHistoryRepo = MockIHistoryRepo();
    createWorkout = CreateWorkout(mockHistoryRepo);
    saveWorkout = SaveWorkout(mockHistoryRepo);
    deleteWorkout = DeleteWorkout(mockHistoryRepo);
    getWorkoutHistory = GetWorkoutHistory(mockHistoryRepo);
    
    final weightedExercise = PerformanceTestData.createWeightedBenchPress();
    final bodyweightExercise = PerformanceTestData.createBodyweightPullUp();
    
    testWorkout = Workout(
      id: 1,
      date: DateTime(2024, 1, 15),
      exercises: [weightedExercise, bodyweightExercise],
      isCompleted: false,
      notes: 'Test workout',
    );
  });

  group('CreateWorkout', () {
    test('should create workout successfully', () async {
      // Arrange
      when(mockHistoryRepo.saveWorkout(testWorkout)).thenAnswer((_) async => 1);
      
      // Act
      final result = await createWorkout(testWorkout);
      
      // Assert
      expect(result, 1);
      verify(mockHistoryRepo.saveWorkout(testWorkout)).called(1);
    });

    test('should throw ArgumentError when workout has no exercises', () async {
      // Arrange
      final emptyWorkout = Workout(
        id: 2,
        date: DateTime(2024, 1, 15),
        exercises: [],
        isCompleted: false,
        notes: null,
      );
      
      // Act & Assert
      expect(
        () => createWorkout(emptyWorkout),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockHistoryRepo.saveWorkout(any));
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(mockHistoryRepo.saveWorkout(testWorkout))
          .thenThrow(Exception('Database error'));
      
      // Act & Assert
      expect(
        () => createWorkout(testWorkout),
        throwsA(isA<Exception>()),
      );
      verify(mockHistoryRepo.saveWorkout(testWorkout)).called(1);
    });

    test('should handle workout with minimum required data', () async {
      // Arrange
      final minWorkout = Workout(
        id: 3,
        date: DateTime(2024, 1, 15),
        exercises: [PerformanceTestData.createWeightedBenchPress()],
        isCompleted: false,
        notes: null,
      );
      
      when(mockHistoryRepo.saveWorkout(minWorkout)).thenAnswer((_) async => 3);
      
      // Act
      final result = await createWorkout(minWorkout);
      
      // Assert
      expect(result, 3);
      verify(mockHistoryRepo.saveWorkout(minWorkout)).called(1);
    });
  });

  group('SaveWorkout', () {
    test('should save workout successfully', () async {
      // Arrange
      when(mockHistoryRepo.saveWorkout(testWorkout)).thenAnswer((_) async => 1);
      
      // Act
      final result = await saveWorkout(testWorkout);
      
      // Assert
      expect(result, 1);
      verify(mockHistoryRepo.saveWorkout(testWorkout)).called(1);
    });

    test('should throw WorkoutValidationException when saving empty workout', () async {
      // Arrange
      final emptyWorkout = Workout(
        id: 4,
        date: DateTime(2024, 1, 15),
        exercises: [],
        isCompleted: false,
        notes: null,
      );
      
      // Act & Assert
      expect(
        () => saveWorkout(emptyWorkout),
        throwsA(isA<WorkoutValidationException>()),
      );
      verifyNever(mockHistoryRepo.saveWorkout(any));
    });

    test('should propagate repository errors on save', () async {
      // Arrange
      when(mockHistoryRepo.saveWorkout(testWorkout))
          .thenThrow(Exception('Database error'));
      
      // Act & Assert
      expect(
        () => saveWorkout(testWorkout),
        throwsA(isA<Exception>()),
      );
      verify(mockHistoryRepo.saveWorkout(testWorkout)).called(1);
    });

    test('should handle saving completed workout', () async {
      // Arrange
      final completedWorkout = Workout(
        id: 5,
        date: DateTime(2024, 1, 15),
        exercises: [PerformanceTestData.createWeightedBenchPress()],
        isCompleted: true,
        notes: 'Completed workout',
      );
      
      when(mockHistoryRepo.saveWorkout(completedWorkout)).thenAnswer((_) async => 5);
      
      // Act
      final result = await saveWorkout(completedWorkout);
      
      // Assert
      expect(result, 5);
      verify(mockHistoryRepo.saveWorkout(completedWorkout)).called(1);
    });

    test('should handle workout with many exercises', () async {
      // Arrange
      final manyExercisesWorkout = Workout(
        id: 6,
        date: DateTime(2024, 1, 15),
        exercises: [
          PerformanceTestData.createWeightedBenchPress(),
          PerformanceTestData.createWeightedSquat(),
          PerformanceTestData.createBodyweightPullUp(),
          PerformanceTestData.createBodyweightPushUp(),
          PerformanceTestData.createDurationRunning(),
        ],
        isCompleted: false,
        notes: null,
      );
      
      when(mockHistoryRepo.saveWorkout(manyExercisesWorkout))
          .thenAnswer((_) async => 6);
      
      // Act
      final result = await saveWorkout(manyExercisesWorkout);
      
      // Assert
      expect(result, 6);
      verify(mockHistoryRepo.saveWorkout(manyExercisesWorkout)).called(1);
    });
  });

  group('DeleteWorkout', () {
    test('should delete workout successfully', () async {
      // Arrange
      const workoutId = 1;
      when(mockHistoryRepo.deleteWorkout(workoutId))
          .thenAnswer((_) async => Future.value());
      
      // Act
      await deleteWorkout(workoutId);
      
      // Assert
      verify(mockHistoryRepo.deleteWorkout(workoutId)).called(1);
    });

    test('should propagate repository errors on delete', () async {
      // Arrange
      const workoutId = 2;
      when(mockHistoryRepo.deleteWorkout(workoutId))
          .thenThrow(Exception('Workout not found'));
      
      // Act & Assert
      expect(
        () => deleteWorkout(workoutId),
        throwsA(isA<Exception>()),
      );
      verify(mockHistoryRepo.deleteWorkout(workoutId)).called(1);
    });

    test('should handle deleting non-existent workout', () async {
      // Arrange
      const nonExistentId = 999;
      when(mockHistoryRepo.deleteWorkout(nonExistentId))
          .thenThrow(Exception('Workout with id $nonExistentId not found'));
      
      // Act & Assert
      expect(
        () => deleteWorkout(nonExistentId),
        throwsA(isA<Exception>()),
      );
      verify(mockHistoryRepo.deleteWorkout(nonExistentId)).called(1);
    });
  });

  group('GetWorkoutHistory', () {
    late List<Workout> workoutList;
    
    setUp(() {
      workoutList = [
        Workout(
          id: 1,
          date: DateTime(2024, 1, 15),
          exercises: [PerformanceTestData.createWeightedBenchPress()],
          isCompleted: true,
          notes: 'First workout',
        ),
        Workout(
          id: 2,
          date: DateTime(2024, 1, 14),
          exercises: [PerformanceTestData.createBodyweightPullUp()],
          isCompleted: true,
          notes: 'Second workout',
        ),
        Workout(
          id: 3,
          date: DateTime(2024, 1, 13),
          exercises: [PerformanceTestData.createDurationRunning()],
          isCompleted: false,
          notes: 'Third workout',
        ),
      ];
    });

    group('getRecentWorkouts', () {
      test('should get recent workouts with default limit', () async {
        // Arrange
        when(mockHistoryRepo.getAll(limit: 10, newestFirst: true))
            .thenAnswer((_) async => workoutList);
        
        // Act
        final result = await getWorkoutHistory.getRecentWorkouts();
        
        // Assert
        expect(result.length, 3);
        expect(result, workoutList);
        verify(mockHistoryRepo.getAll(limit: 10, newestFirst: true)).called(1);
      });

      test('should get recent workouts with custom limit', () async {
        // Arrange
        const customLimit = 5;
        when(mockHistoryRepo.getAll(limit: customLimit, newestFirst: true))
            .thenAnswer((_) async => workoutList.take(2).toList());
        
        // Act
        final result = await getWorkoutHistory.getRecentWorkouts(limit: customLimit);
        
        // Assert
        expect(result.length, 2);
        verify(mockHistoryRepo.getAll(limit: customLimit, newestFirst: true)).called(1);
      });

      test('should return empty list when no workouts exist', () async {
        // Arrange
        when(mockHistoryRepo.getAll(limit: 10, newestFirst: true))
            .thenAnswer((_) async => []);
        
        // Act
        final result = await getWorkoutHistory.getRecentWorkouts();
        
        // Assert
        expect(result, []);
        verify(mockHistoryRepo.getAll(limit: 10, newestFirst: true)).called(1);
      });

      test('should propagate repository errors', () async {
        // Arrange
        when(mockHistoryRepo.getAll(limit: 10, newestFirst: true))
            .thenThrow(Exception('Failed to fetch workouts'));
        
        // Act & Assert
        expect(
          () => getWorkoutHistory.getRecentWorkouts(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getWorkoutsByDateRange', () {
      test('should get workouts by date range', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 13);
        final endDate = DateTime(2024, 1, 15);
        final expectedWorkouts = workoutList;
        
        when(mockHistoryRepo.getAfterDate(startDate))
            .thenAnswer((_) async => expectedWorkouts);
        
        // Act
        final result = await getWorkoutHistory.getWorkoutsByDateRange(startDate, endDate);
        
        // Assert
        expect(result, expectedWorkouts);
        verify(mockHistoryRepo.getAfterDate(startDate)).called(1);
      });

      test('should return empty list for date range with no workouts', () async {
        // Arrange
        final startDate = DateTime(2025, 1, 1);
        final endDate = DateTime(2025, 12, 31);
        
        when(mockHistoryRepo.getAfterDate(startDate))
            .thenAnswer((_) async => []);
        
        // Act
        final result = await getWorkoutHistory.getWorkoutsByDateRange(startDate, endDate);
        
        // Assert
        expect(result, []);
        verify(mockHistoryRepo.getAfterDate(startDate)).called(1);
      });

      test('should handle date range with same start and end date', () async {
        // Arrange
        final date = DateTime(2024, 1, 15);
        final workoutsOnDate = workoutList.where((w) => w.date == date).toList();
        
        when(mockHistoryRepo.getAfterDate(date))
            .thenAnswer((_) async => workoutsOnDate);
        
        // Act
        final result = await getWorkoutHistory.getWorkoutsByDateRange(date, date);
        
        // Assert
        expect(result, workoutsOnDate);
        verify(mockHistoryRepo.getAfterDate(date)).called(1);
      });

      test('should propagate repository errors for date range', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);
        
        when(mockHistoryRepo.getAfterDate(startDate))
            .thenThrow(Exception('Database connection failed'));
        
        // Act & Assert
        expect(
          () => getWorkoutHistory.getWorkoutsByDateRange(startDate, endDate),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('Integration scenarios', () {
    test('should create, save, and delete workout in sequence', () async {
      // Arrange
      final newWorkout = Workout(
        id: 10,
        date: DateTime(2024, 1, 20),
        exercises: [PerformanceTestData.createWeightedBenchPress()],
        isCompleted: false,
        notes: 'New workout',
      );
      
      when(mockHistoryRepo.saveWorkout(newWorkout))
          .thenAnswer((_) async => 10);
      when(mockHistoryRepo.deleteWorkout(10))
          .thenAnswer((_) async => Future.value());
      
      // Act
      final createdId = await createWorkout(newWorkout);
      expect(createdId, 10);
      
      await deleteWorkout(createdId);
      
      // Assert
      verify(mockHistoryRepo.saveWorkout(newWorkout)).called(1);
      verify(mockHistoryRepo.deleteWorkout(10)).called(1);
    });

    test('should handle workout lifecycle with updates', () async {
      // Arrange
      var workout = Workout(
        id: 11,
        date: DateTime(2024, 1, 20),
        exercises: [PerformanceTestData.createWeightedBenchPress()],
        isCompleted: false,
        notes: 'Initial',
      );
      
      when(mockHistoryRepo.saveWorkout(workout))
          .thenAnswer((_) async => 11);
      
      // Act - Create
      final createdId = await createWorkout(workout);
      expect(createdId, 11);
      
      // Update workout
      final updatedWorkout = workout.copyWith(
        notes: 'Updated',
        isCompleted: true,
      );
      
      when(mockHistoryRepo.saveWorkout(updatedWorkout))
          .thenAnswer((_) async => 11);
      
      // Save updated version
      final savedId = await saveWorkout(updatedWorkout);
      expect(savedId, 11);
      
      // Delete
      when(mockHistoryRepo.deleteWorkout(11))
          .thenAnswer((_) async => Future.value());
      await deleteWorkout(11);
      
      // Assert
      verify(mockHistoryRepo.saveWorkout(workout)).called(1);
      verify(mockHistoryRepo.saveWorkout(updatedWorkout)).called(1);
      verify(mockHistoryRepo.deleteWorkout(11)).called(1);
    });

    test('should get workouts after creating multiple', () async {
      // Arrange
      final workouts = [
        Workout(
          id: 20,
          date: DateTime(2024, 1, 20),
          exercises: [PerformanceTestData.createWeightedBenchPress()],
          isCompleted: true,
          notes: null,
        ),
        Workout(
          id: 21,
          date: DateTime(2024, 1, 21),
          exercises: [PerformanceTestData.createBodyweightPullUp()],
          isCompleted: true,
          notes: null,
        ),
      ];
      
      for (final workout in workouts) {
        when(mockHistoryRepo.saveWorkout(workout))
            .thenAnswer((_) async => workout.id);
        await createWorkout(workout);
      }
      
      when(mockHistoryRepo.getAll(limit: 10, newestFirst: true))
          .thenAnswer((_) async => workouts.reversed.toList());
      
      // Act
      final recentWorkouts = await getWorkoutHistory.getRecentWorkouts();
      
      // Assert
      expect(recentWorkouts.length, 2);
      expect(recentWorkouts.first.date, DateTime(2024, 1, 21));
      verify(mockHistoryRepo.getAll(limit: 10, newestFirst: true)).called(1);
    });
  });

  group('Error handling', () {
    test('should handle network errors gracefully', () async {
      // Arrange
      when(mockHistoryRepo.saveWorkout(testWorkout))
          .thenThrow(Exception('Network error'));
      
      // Act & Assert
      expect(
        () => createWorkout(testWorkout),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle database constraint violations', () async {
      // Arrange
      when(mockHistoryRepo.saveWorkout(testWorkout))
          .thenThrow(Exception('Duplicate key violation'));
      
      // Act & Assert
      expect(
        () => saveWorkout(testWorkout),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle concurrent operations', () async {
      // Arrange
      final workout1 = testWorkout;
      final workout2 = testWorkout.copyWith(id: 2, date: DateTime(2024, 1, 16));
      
      when(mockHistoryRepo.saveWorkout(workout1)).thenAnswer((_) async => 1);
      when(mockHistoryRepo.saveWorkout(workout2)).thenAnswer((_) async => 2);
      
      // Act
      final results = await Future.wait([
        createWorkout(workout1),
        createWorkout(workout2),
      ]);
      
      // Assert
      expect(results, [1, 2]);
      verify(mockHistoryRepo.saveWorkout(workout1)).called(1);
      verify(mockHistoryRepo.saveWorkout(workout2)).called(1);
    });
  });
}