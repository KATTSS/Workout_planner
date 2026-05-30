// lib/Features/Presentation/ViewModels/statistics_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Application/Providers/workout_states.dart';

class StatisticsViewModel {
  final Ref _ref;
  
  StatisticsViewModel(this._ref);
  
  // Получение статистики
  AsyncValue<WorkoutStatistics> get statistics {
    return _ref.watch(statisticsProvider);
  }
  
  // Форматирование для отображения (UI логика)
  String getAverageExercisesString(double average) {
    return average.toStringAsFixed(1);
  }
  
  // Получение топ-N групп мышц
  List<MapEntry<String, int>> getTopMuscleGroups(Map<String, int> data, {int limit = 5}) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }
  
  // Получение топ-N упражнений
  List<MapEntry<String, int>> getTopExercises(Map<String, int> data, {int limit = 10}) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }
  
  // Расчет процента для графика
  double calculatePercentage(int value, int maxValue) {
    if (maxValue == 0) return 0;
    return value / maxValue;
  }
}

// Провайдер для ViewModel
final statisticsViewModelProvider = Provider<StatisticsViewModel>((ref) {
  return StatisticsViewModel(ref);
});