import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Presentation/Providers/history_providers.dart';
import 'package:workout_planner/Features/Presentation/Routing/app_router.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final int workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutByIdProvider(workoutId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(
                AppRouter.workoutEditor,
                extra: {'workoutId': workoutId},
              );
            },
          ),
        ],
      ),
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return const Center(child: Text('Workout not found'));
          }
          return _WorkoutDetailContent(workout: workout);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _WorkoutDetailContent extends StatelessWidget {
  final Workout workout;

  const _WorkoutDetailContent({required this.workout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        workout.date.toString().split(' ')[0],
                        style: theme.textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          workout.isCompleted ? 'Completed' : 'Draft',
                        ),
                        backgroundColor: workout.isCompleted
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                      ),
                    ],
                  ),
                  if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      workout.notes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${workout.exerciseCount} exercises • ${workout.totalSets} sets',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Список упражнений
          Text(
            'Exercises',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(workout.exercises.length, (index) {
            final exercise = workout.exercises[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${exercise.exercise.name}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Таблица сетов
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Text('Set', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              exercise.exercise.performanceType == PerformanceType.duration
                                  ? 'Duration'
                                  : 'Weight',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              exercise.exercise.performanceType == PerformanceType.duration
                                  ? ''
                                  : 'Reps',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ...List.generate(exercise.setsCount, (setIndex) {
                          final set = exercise.sets[setIndex];
                          return TableRow(
                            children: [
                              Text('${setIndex + 1}'),
                              Text(_formatSetValue(set, exercise.exercise.performanceType)),
                              Text(_formatSetReps(set, exercise.exercise.performanceType)),
                            ],
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatSetValue(SetData set, PerformanceType type) {
    switch (type) {
      case PerformanceType.weighted:
        return '${set.weight ?? 0} kg';
      case PerformanceType.bodyweight:
        return 'Bodyweight';
      case PerformanceType.duration:
        return '${set.duration ?? 0} min';
    }
  }

  String _formatSetReps(SetData set, PerformanceType type) {
    switch (type) {
      case PerformanceType.weighted:
      case PerformanceType.bodyweight:
        return '${set.reps ?? 0} reps';
      case PerformanceType.duration:
        return '';
    }
  }
}