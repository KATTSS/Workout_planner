import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Presentation/State/history_providers.dart';

class WorkoutListScreen extends ConsumerWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Переход к созданию новой тренировки
        },
        child: const Icon(Icons.add),
      ),
      body: workoutsAsync.when(
        data: (workouts) => workouts.isEmpty
            ? const Center(child: Text('No workouts yet'))
            : ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return ListTile(
                    title: Text(workout.date.toString().split(' ')[0]),
                    subtitle: Text(
                      '${workout.exerciseCount} exercises • ${workout.totalSets} sets',
                    ),
                    trailing: Icon(
                      workout.isCompleted ? Icons.check_circle : Icons.edit,
                    ),
                    onTap: () {
                      // TODO: Переход к деталям тренировки
                    },
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
