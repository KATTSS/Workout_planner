// lib/Features/Presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Presentation/Screens/workout_detail_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/statistics_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_catalog_screen.dart';
import 'package:workout_planner/Features/Presentation/Widgets/workout_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Workout> _recentWorkouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final getHistory = ref.read(getWorkoutHistoryProvider);
    final workouts = await getHistory.getRecentWorkouts(limit: 10);
    setState(() {
      _recentWorkouts = workouts;
    });
  }

  Future<void> _deleteWorkout(Workout workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Delete workout from ${_formatDate(workout.date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deleteWorkout = ref.read(deleteWorkoutProvider);
      await deleteWorkout(workout.id);
      _loadWorkouts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: _recentWorkouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No workouts yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first workout',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExerciseCatalogScreen(isCreatingWorkout: true),
                        ),
                      ).then((_) => _loadWorkouts());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Workout'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadWorkouts,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _recentWorkouts.length,
                itemBuilder: (context, index) {
                  final workout = _recentWorkouts[index];
                  return WorkoutCard(
                    workout: workout,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workout: workout),
                        ),
                      ).then((_) => _loadWorkouts());
                    },
                    onLongPress: () => _deleteWorkout(workout),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExerciseCatalogScreen(isCreatingWorkout: true),
            ),
          ).then((_) => _loadWorkouts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}