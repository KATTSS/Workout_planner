import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Presentation/Screens/workout_detail_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/statistics_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_catalog_screen.dart';
import 'package:workout_planner/Features/Presentation/Viewmodels/home_viewmodel.dart';
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
    final viewModel = ref.read(homeViewModelProvider);
    final workouts = await viewModel.loadWorkouts(limit: 10);
    setState(() {
      _recentWorkouts = workouts;
    });
  }

  Future<void> _createWorkout() async {
    final result = await Navigator.push<List<ExercisePerformance>>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExerciseCatalogScreen(isCreatingWorkout: true),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      final viewModel = ref.read(homeViewModelProvider);

      final createdWorkout = await viewModel.createWorkout(result);

      if (createdWorkout != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: createdWorkout),
          ),
        ).then((_) => _loadWorkouts());
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create workout')),
        );
      }
    }
  }

  Future<void> _deleteWorkout(Workout workout) async {
    final viewModel = ref.read(homeViewModelProvider);
    final formattedDate = viewModel.formatDate(workout.date);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: Text('Delete workout from $formattedDate?'),
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
      final success = await viewModel.deleteWorkout(workout.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.getDeleteSuccessMessage(workout))),
        );
        await _loadWorkouts();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete workout')),
        );
      }
    }
  }

  Future<void> _showWorkoutActionsMenu(Workout workout) async {
    final viewModel = ref.read(homeViewModelProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Options'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWorkout(workout);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Copy the workout
              final copiedWorkout = await viewModel.copyWorkout(workout);

              if (copiedWorkout != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailScreen(workout: copiedWorkout),
                  ),
                ).then((_) => _loadWorkouts());
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to copy workout')),
                );
              }
            },
            child: const Text('Copy Workout'),
          ),
        ],
      ),
    );
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
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first workout',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _createWorkout,
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
                    onLongPress: () => _showWorkoutActionsMenu(workout),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }
}
