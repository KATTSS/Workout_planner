// lib/Features/Application/providers/workout_states.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_session.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_builder.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

// Состояние сессии тренировки
class WorkoutSessionState {
  final WorkoutSession? session;
  final bool isLoading;
  final String? error;
  final bool hasUnsavedChanges;

  WorkoutSessionState({
    this.session,
    this.isLoading = false,
    this.error,
    this.hasUnsavedChanges = false,
  });

  WorkoutSessionState copyWith({
    WorkoutSession? session,
    bool? isLoading,
    String? error,
    bool? hasUnsavedChanges,
  }) {
    return WorkoutSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
  WorkoutSessionNotifier() : super(WorkoutSessionState());

  void loadWorkout(Workout workout) {
    final session = WorkoutSession(workout);
    state = WorkoutSessionState(
      session: session,
      hasUnsavedChanges: session.isModified,
    );
  }

  void updateDate(DateTime newDate) {
    try {
      state.session?.updateDate(newDate);
      _updateState();
    } on WorkoutValidationException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  void updateNotes(String? notes) {
    state.session?.updateNotes(notes);
    _updateState();
  }

  void completeWorkout() {
    state.session?.completeWorkout();
    _updateState();
  }

  void uncompleteWorkout() {
    state.session?.uncompleteWorkout();
    _updateState();
  }

  void addExercise(ExercisePerformance exercise) {
    state.session?.addExercise(exercise);
    _updateState();
  }

  void removeExercise(int exerciseId) {
    state.session?.removeExercise(exerciseId);
    _updateState();
  }

  void replaceExercise(int oldExerciseId, ExercisePerformance newExercise) {
    state.session?.replaceExercise(oldExerciseId, newExercise);
    _updateState();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    state.session?.reorderExercises(oldIndex, newIndex);
    _updateState();
  }

  void addSet(int exerciseId, SetData set) {
    state.session?.addSetToExercise(exerciseId, set);
    _updateState();
  }

  void updateSet(int exerciseId, int setIndex, SetData newSet) {
    state.session?.updateSetInExercise(exerciseId, setIndex, newSet);
    _updateState();
  }

  void removeSet(int exerciseId, int setIndex) {
    state.session?.removeSetFromExercise(exerciseId, setIndex);
    _updateState();
  }

  void undo() {
    if (state.session?.undo() == true) {
      _updateState();
    }
  }

  void redo() {
    if (state.session?.redo() == true) {
      _updateState();
    }
  }

  void save() {
    state.session?.markAsSaved();
    _updateState();
  }

  void _updateState() {
    state = state.copyWith(
      hasUnsavedChanges: state.session?.isModified ?? false,
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Состояние билдера тренировки
class WorkoutBuilderState {
  final WorkoutBuilder builder;
  final Workout? builtWorkout;
  final bool isValid;

  WorkoutBuilderState({
    required this.builder,
    this.builtWorkout,
    this.isValid = false,
  });

  WorkoutBuilderState copyWith({
    WorkoutBuilder? builder,
    Workout? builtWorkout,
    bool? isValid,
  }) {
    return WorkoutBuilderState(
      builder: builder ?? this.builder,
      builtWorkout: builtWorkout ?? this.builtWorkout,
      isValid: isValid ?? this.isValid,
    );
  }
}

class WorkoutBuilderNotifier extends StateNotifier<WorkoutBuilderState> {
  WorkoutBuilderNotifier()
    : super(WorkoutBuilderState(builder: WorkoutBuilder()));

  void setId(int id) {
    try {
      state.builder.setId(id);
      _validate();
    } on WorkoutValidationException catch (e) {
      debugPrint('Exseption in set id in WorkoutBuilderNotifier: ${e.message}');
    }
  }

  void setDate(DateTime date) {
    state.builder.setDate(date);
    _validate();
  }

  void addExercise(ExercisePerformance exercise) {
    state.builder.addExercise(exercise);
    _validate();
  }

  void addExercises(List<ExercisePerformance> exercises) {
    state.builder.addExercises(exercises);
    _validate();
  }

  void removeExercise(int exerciseId) {
    state.builder.removeExercise(exerciseId);
    _validate();
  }

  void setNotes(String? notes) {
    state.builder.setNotes(notes);
    _validate();
  }

  void markAsCompleted() {
    state.builder.asCompleted();
    _validate();
  }

  void markAsDraft() {
    state.builder.asDraft();
    _validate();
  }

  Workout build() {
    try {
      final workout = state.builder.build();
      state = state.copyWith(builtWorkout: workout, isValid: true);
      return workout;
    } on WorkoutValidationException catch (e) {
      state = state.copyWith(isValid: false);
      rethrow;
    }
  }

  Workout buildFromTemplate(Workout template, DateTime newDate) {
    final workout = state.builder.buildFromTemplate(template, newDate);
    state = state.copyWith(builtWorkout: workout, isValid: true);
    return workout;
  }

  void reset() {
    state.builder.reset();
    state = WorkoutBuilderState(builder: WorkoutBuilder());
  }

  void _validate() {
    try {
      state = state.copyWith(
        isValid:
            state.builder.id != -1 &&
            state.builder.date != DateTime(1979, 1, 1),
      );
    } catch (e) {
      state = state.copyWith(isValid: false);
    }
  }
}

// Состояние фильтров упражнений
class ExerciseFiltersState {
  final String? muscleGroup;
  final String? difficulty;
  final String? category;
  final String searchQuery;

  ExerciseFiltersState({
    this.muscleGroup,
    this.difficulty,
    this.category,
    this.searchQuery = '',
  });

  ExerciseFiltersState copyWith({
    String? muscleGroup,
    String? difficulty,
    String? category,
    String? searchQuery,
  }) {
    return ExerciseFiltersState(
      muscleGroup: muscleGroup ?? this.muscleGroup,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ExerciseFiltersNotifier extends StateNotifier<ExerciseFiltersState> {
  ExerciseFiltersNotifier() : super(ExerciseFiltersState());

  void setMuscleGroup(String? group) {
    state = state.copyWith(muscleGroup: group);
  }

  void setDifficulty(String? difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void resetFilters() {
    state = ExerciseFiltersState();
  }
}

// Статистика
class WorkoutStatistics {
  final Map<String, int> mostUsedMuscleGroups;
  final Map<String, int> mostFrequentExercises;
  final double averageExercisesPerWorkout;
  final int totalWorkouts;

  WorkoutStatistics({
    required this.mostUsedMuscleGroups,
    required this.mostFrequentExercises,
    required this.averageExercisesPerWorkout,
    required this.totalWorkouts,
  });

  static WorkoutStatistics calculate(List<Workout> workouts) {
    final muscleGroups = <String, int>{};
    final exercises = <String, int>{};
    int totalExercises = 0;

    for (final workout in workouts) {
      totalExercises += workout.exercises.length;

      for (final exPerf in workout.exercises) {
        final muscleGroup = exPerf.exercise.muscle ?? 'Other';
        muscleGroups[muscleGroup] = (muscleGroups[muscleGroup] ?? 0) + 1;

        final exerciseName = exPerf.exercise.name;
        exercises[exerciseName] = (exercises[exerciseName] ?? 0) + 1;
      }
    }

    return WorkoutStatistics(
      mostUsedMuscleGroups: muscleGroups,
      mostFrequentExercises: exercises,
      averageExercisesPerWorkout: workouts.isEmpty
          ? 0
          : totalExercises / workouts.length,
      totalWorkouts: workouts.length,
    );
  }
}
