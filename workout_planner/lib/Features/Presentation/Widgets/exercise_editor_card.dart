import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Presentation/Widgets/set_row.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';

class ExerciseEditorCard extends StatelessWidget {
  final ExercisePerformance exercise;
  final int exerciseIndex;
  final VoidCallback onDelete;
  final Function(int setIndex, SetData newSet) onUpdateSet;
  final VoidCallback onAddSet;
  final Function(int setIndex) onDeleteSet;

  const ExerciseEditorCard({
    super.key,
    required this.exercise,
    required this.exerciseIndex,
    required this.onDelete,
    required this.onUpdateSet,
    required this.onAddSet,
    required this.onDeleteSet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${exerciseIndex + 1}. ${exercise.exercise.name}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${exercise.exercise.muscle} • ${exercise.exercise.performanceType.name}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Заголовки колонок
            Row(
              children: [
                const SizedBox(width: 30, child: Text('Set')),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.exercise.performanceType ==
                            PerformanceType.duration
                        ? 'Duration'
                        : 'Weight / Reps',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const Divider(),
            // Список сетов
            ...List.generate(exercise.setsCount, (setIndex) {
              return SetRowWidget(
                setNumber: setIndex,
                set: exercise.sets[setIndex],
                type: exercise.exercise.performanceType,
                onDelete: () => onDeleteSet(setIndex),
                onUpdate: (newSet) => onUpdateSet(setIndex, newSet),
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
