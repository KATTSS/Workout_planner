// lib/Features/Presentation/widgets/workout_card.dart

import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
    required this.onLongPress,
  });

  String _getMainMuscleGroup() {
    final muscleGroups = <String, int>{};
    for (final exPerf in workout.exercises) {
      final group = exPerf.exercise.muscle;
      muscleGroups[group] = (muscleGroups[group] ?? 0) + 1;
    }
    if (muscleGroups.isEmpty) return 'None';
    return muscleGroups.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _getTotalSets() {
    return workout.exercises.fold(0, (sum, ex) => sum + ex.setsCount);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDate = DateTime(date.year, date.month, date.day);

    if (workoutDate == today) return 'Today';
    if (workoutDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    workout.isCompleted ? Icons.check_circle : Icons.edit_note,
                    color: workout.isCompleted ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(workout.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getMainMuscleGroup(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (workout.notes != null && workout.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  workout.notes!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStat(Icons.fitness_center, '${workout.exercises.length} exercises'),
                  const SizedBox(width: 16),
                  _buildStat(Icons.repeat, '${_getTotalSets()} sets'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}