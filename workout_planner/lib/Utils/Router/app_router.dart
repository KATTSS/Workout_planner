// lib/routes/app_router.dart (опционально)

import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Presentation/Screens/home_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/workout_detail_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_catalog_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/statistics_screen.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/workout-detail':
        final workout = settings.arguments as Workout;
        return MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workout: workout),
        );
      case '/exercise-catalog':
        final isCreatingWorkout = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) =>
              ExerciseCatalogScreen(isCreatingWorkout: isCreatingWorkout),
        );
      case '/statistics':
        return MaterialPageRoute(builder: (_) => const StatisticsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
