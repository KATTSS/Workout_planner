// lib/Features/Presentation/ViewModels/exercise_catalog_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Application/Providers/workout_states.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

class ExerciseCatalogViewModel {
  final Ref _ref;
  final bool _isCreatingWorkout;
  final bool _isAddingToWorkout;
  
  ExerciseCatalogViewModel(this._ref, this._isCreatingWorkout, this._isAddingToWorkout);
  
  // Геттеры
  bool get isCreatingWorkout => _isCreatingWorkout;
  bool get isAddingToWorkout => _isAddingToWorkout;
  
  // Фильтры
  ExerciseFiltersState get filters => _ref.watch(exerciseFiltersProvider);
  
  void setMuscleGroup(String? group) {
    _ref.read(exerciseFiltersProvider.notifier).setMuscleGroup(group);
  }
  
  void setDifficulty(String? difficulty) {
    _ref.read(exerciseFiltersProvider.notifier).setDifficulty(difficulty);
  }
  
  void setSearchQuery(String query) {
    _ref.read(exerciseFiltersProvider.notifier).setSearchQuery(query);
  }
  
  void resetFilters() {
    _ref.read(exerciseFiltersProvider.notifier).resetFilters();
  }
  
  // Загрузка упражнений
  AsyncValue<List<Exercise>> getExercises() {
    return _ref.watch(exerciseCatalogProvider);
  }
  
  // Фильтрация упражнений (бизнес-логика)
  List<Exercise> filterExercises(List<Exercise> exercises, ExerciseFiltersState filters) {
    return exercises.where((ex) {
      if (filters.muscleGroup != null && ex.muscle != filters.muscleGroup) {
        return false;
      }
      if (filters.difficulty != null) {
        final diffString = getDifficultyString(ex.level).toLowerCase();
        if (diffString != filters.difficulty) return false;
      }
      if (filters.searchQuery.isNotEmpty) {
        if (!ex.name.toLowerCase().contains(filters.searchQuery.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }
  
  // Получение строки сложности (UI логика)
  String getDifficultyString(int? difficulty) {
    switch (difficulty) {
      case 0: return 'Beginner';
      case 1: return 'Intermediate';
      case 2: return 'Advanced';
      default: return 'Any';
    }
  }
  
  // Создание ExercisePerformance из выбранных упражнений
  List<ExercisePerformance> createExercisePerformances(Set<Exercise> selectedExercises) {
    return selectedExercises.map((ex) {
      return ExercisePerformance.create(
        exercise: ex,
        sets: [SetData.empty(ex.performanceType)],
      );
    }).toList();
  }
  
  // Получение доступных групп мышц (для фильтров)
  List<String> getMuscleGroups() {
    return [
      'abdominals', 'hamstrings', 'adductors', 'quadriceps',
      'biceps', 'shoulders', 'chest', 'middle back', 'calves',
      'glutes', 'lower back', 'lats', 'triceps', 'traps',
      'forearms', 'neck', 'abductors',
    ];
  }
  
  // Получение уровней сложности для фильтров
  List<String> getDifficulties() {
    return ['Beginner', 'Intermediate', 'Advanced'];
  }
}

// Провайдер для ViewModel
final exerciseCatalogViewModelProvider = Provider.family<ExerciseCatalogViewModel, ExerciseCatalogViewModelParams>((ref, params) {
  return ExerciseCatalogViewModel(
    ref,
    params.isCreatingWorkout,
    params.isAddingToWorkout,
  );
});

class ExerciseCatalogViewModelParams {
  final bool isCreatingWorkout;
  final bool isAddingToWorkout;
  
  ExerciseCatalogViewModelParams({
    required this.isCreatingWorkout,
    required this.isAddingToWorkout,
  });
}