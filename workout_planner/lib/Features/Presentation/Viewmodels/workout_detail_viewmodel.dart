// lib/Features/Presentation/ViewModels/workout_detail_viewmodel.dart

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Application/Providers/workout_states.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_session.dart';

class WorkoutDetailViewModel {
  final Ref _ref;
  final Workout _initialWorkout;

  WorkoutDetailViewModel(this._ref, this._initialWorkout);

  // Состояние сессии
  WorkoutSessionState get sessionState => _ref.watch(workoutSessionProvider);
  WorkoutSession? get session => sessionState.session;
  Workout? get currentWorkout => session?.currentWorkout;
  bool get hasUnsavedChanges => sessionState.hasUnsavedChanges;
  String? get error => sessionState.error;

  // Загрузка тренировки
  void loadWorkout() {
    _ref.read(workoutSessionProvider.notifier).loadWorkout(_initialWorkout);
  }

  // Получение основной группы мышц
  String getMainMuscleGroup() {
    final workout = currentWorkout;
    if (workout == null) return 'None';

    final muscleGroups = <String, int>{};
    for (final exPerf in workout.exercises) {
      final group = exPerf.exercise.muscle;
      muscleGroups[group] = (muscleGroups[group] ?? 0) + 1;
    }
    if (muscleGroups.isEmpty) return 'None';
    return muscleGroups.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // Форматирование даты (UI логика, остается в ViewModel)
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);

    if (workoutDate == today) {
      return 'Today';
    }
    if (workoutDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  // Сохранение тренировки
  Future<bool> saveWorkout() async {
    final currentSession = session;
    if (currentSession == null) return false;

    final saveWorkout = _ref.read(saveWorkoutProvider);
    final currentWorkout = currentSession.currentWorkout;
    final sessionNotifier = _ref.read(workoutSessionProvider.notifier);
    final historyNotifier = _ref.read(workoutHistoryChangeProvider.notifier);

    try {
      await saveWorkout(currentWorkout);
      currentSession.markAsSaved();
      sessionNotifier.save();
      historyNotifier.state++;
      return true;
    } catch (e) {
      debugPrint('Error in saving(viewmodel): $e');
      return false;
    }
  }

  Future<bool> deleteWorkout() async {
    final workoutId = _initialWorkout.id;
    final deleteWorkout = _ref.read(deleteWorkoutProvider);
    final historyNotifier = _ref.read(workoutHistoryChangeProvider.notifier);
    try {
      await deleteWorkout(workoutId);
      historyNotifier.state++;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Обновление даты
  void updateDate(DateTime newDate) {
    _ref.read(workoutSessionProvider.notifier).updateDate(newDate);
  }

  // Обновление заметок
  void updateNotes(String? notes) {
    _ref.read(workoutSessionProvider.notifier).updateNotes(notes);
  }

  // Изменение статуса завершения
  void toggleCompleted(bool isCompleted) {
    final current = session?.currentWorkout;
    if (isCompleted && current != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final workoutDate = DateTime(
        current.date.year,
        current.date.month,
        current.date.day,
      );
      if (workoutDate.isAfter(today)) {
        // Do not allow marking a future-dated workout as completed
        return;
      }
    }

    if (isCompleted) {
      _ref.read(workoutSessionProvider.notifier).completeWorkout();
    } else {
      _ref.read(workoutSessionProvider.notifier).uncompleteWorkout();
    }
  }

  // Управление упражнениями
  void addExercise(ExercisePerformance exercise) {
    _ref.read(workoutSessionProvider.notifier).addExercise(exercise);
  }

  void removeExercise(int exerciseId) {
    _ref.read(workoutSessionProvider.notifier).removeExercise(exerciseId);
  }

  void reorderExercises(int oldIndex, int newIndex) {
    _ref
        .read(workoutSessionProvider.notifier)
        .reorderExercises(oldIndex, newIndex);
  }

  // Управление сетами
  void addSet(int exerciseId, SetData set) {
    _ref.read(workoutSessionProvider.notifier).addSet(exerciseId, set);
  }

  void updateSet(int exerciseId, int setIndex, SetData newSet) {
    _ref
        .read(workoutSessionProvider.notifier)
        .updateSet(exerciseId, setIndex, newSet);
  }

  void removeSet(int exerciseId, int setIndex) {
    _ref.read(workoutSessionProvider.notifier).removeSet(exerciseId, setIndex);
  }

  // Undo/Redo
  void undo() {
    _ref.read(workoutSessionProvider.notifier).undo();
  }

  void redo() {
    _ref.read(workoutSessionProvider.notifier).redo();
  }

  bool get canUndo => session?.canUndo ?? false;
  bool get canRedo => session?.canRedo ?? false;

  // Очистка ошибки
  void clearError() {
    _ref.read(workoutSessionProvider.notifier).clearError();
  }
}

// Провайдер для ViewModel
final workoutDetailViewModelProvider =
    Provider.family<WorkoutDetailViewModel, Workout>((ref, workout) {
      return WorkoutDetailViewModel(ref, workout);
    });
