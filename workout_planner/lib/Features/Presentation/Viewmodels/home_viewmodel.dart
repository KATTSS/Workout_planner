// lib/Features/Presentation/ViewModels/home_viewmodel.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

class HomeViewModel {
  final Ref _ref;
  
  HomeViewModel(this._ref);
  
  // Загрузка тренировок
  Future<List<Workout>> loadWorkouts({int limit = 10}) async {
    final getHistory = _ref.read(getWorkoutHistoryProvider);
    return await getHistory.getRecentWorkouts(limit: limit);
  }
  
  // Удаление тренировки
  Future<bool> deleteWorkout(int? workoutId) async {
    if (workoutId == null) return false;
    
    final deleteWorkout = _ref.read(deleteWorkoutProvider);
    try {
      await deleteWorkout(workoutId);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Форматирование даты (UI логика)
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);
    
    if (workoutDate == today) return 'Today';
    if (workoutDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Получение названия для SnackBar
  String getDeleteSuccessMessage(Workout workout) {
    return 'Workout from ${formatDate(workout.date)} deleted';
  }
}

// Провайдер для ViewModel
final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModel(ref);
});