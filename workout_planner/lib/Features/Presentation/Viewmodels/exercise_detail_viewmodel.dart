// lib/Features/Presentation/ViewModels/exercise_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

class ExerciseDetailViewModel extends ChangeNotifier {
  final ExercisePerformance _exercisePerf;
  final bool _isEditing;
  final void Function(int setIndex, SetData newSet)? _onSetChanged;
  final void Function(SetData newSet)? _onSetAdded;
  final void Function(int setIndex)? _onSetRemoved;

  late List<SetData> _sets;
  bool _hasChanges = false;

  ExerciseDetailViewModel({
    required ExercisePerformance exercisePerf,
    required bool isEditing,
    void Function(int setIndex, SetData newSet)? onSetChanged,
    void Function(SetData newSet)? onSetAdded,
    void Function(int setIndex)? onSetRemoved,
  }) : _exercisePerf = exercisePerf,
       _isEditing = isEditing,
       _onSetChanged = onSetChanged,
       _onSetAdded = onSetAdded,
       _onSetRemoved = onSetRemoved {
    _sets = exercisePerf.sets.toList();
  }

  // Геттеры для состояния
  List<SetData> get sets => _sets;
  bool get hasChanges => _hasChanges;
  bool get isEditing => _isEditing;
  Exercise get exercise => _exercisePerf.exercise;

  // Получение строки сложности (UI логика)
  String getDifficultyString() {
    final difficulty = _exercisePerf.exercise.level;
    switch (difficulty) {
      case 0:
        return 'Beginner';
      case 1:
        return 'Intermediate';
      case 2:
        return 'Advanced';
      default:
        return 'Not specified';
    }
  }

  // Получение информации о сете (UI логика)
  String getSetInfo(SetData set) {
    if (set.duration != null) return '${set.duration} sec';
    return '${set.weight != null ? '${set.weight} kg' : '—'} × ${set.reps ?? '—'}';
  }

  // Получение типа производительности (UI логика)
  String getPerformanceTypeString() {
    return _exercisePerf.exercise.performanceType.toString().split('.').last;
  }

  // Обновление сета
  void updateSet(int index, SetData newSet) {
    _sets[index] = newSet;
    _hasChanges = true;
    _onSetChanged?.call(index, newSet);
    notifyListeners();
  }

  // Добавление сета
  void addSet(SetData newSet) {
    _sets.add(newSet);
    _hasChanges = true;
    _onSetAdded?.call(newSet);
    notifyListeners();
  }

  // Удаление сета
  void removeSet(int index) {
    _sets.removeAt(index);
    _hasChanges = true;
    _onSetRemoved?.call(index);
    notifyListeners();
  }

  // Создание пустого сета для диалога
  SetData createEmptySet() {
    return SetData.empty(_exercisePerf.exercise.performanceType);
  }

  // Получение текущих сетов для сохранения
  List<SetData> getCurrentSets() {
    return _sets;
  }
}

// Провайдер для ViewModel (требует параметры)
final exerciseDetailViewModelProvider =
    ChangeNotifierProvider.family<
      ExerciseDetailViewModel,
      ExerciseDetailViewModelParams
    >((ref, params) {
      return ExerciseDetailViewModel(
        exercisePerf: params.exercisePerf,
        isEditing: params.isEditing,
        onSetChanged: params.onSetChanged,
        onSetAdded: params.onSetAdded,
        onSetRemoved: params.onSetRemoved,
      );
    });

class ExerciseDetailViewModelParams {
  final ExercisePerformance exercisePerf;
  final bool isEditing;
  final void Function(int setIndex, SetData newSet)? onSetChanged;
  final void Function(SetData newSet)? onSetAdded;
  final void Function(int setIndex)? onSetRemoved;

  ExerciseDetailViewModelParams({
    required this.exercisePerf,
    required this.isEditing,
    this.onSetChanged,
    this.onSetAdded,
    this.onSetRemoved,
  });
}
