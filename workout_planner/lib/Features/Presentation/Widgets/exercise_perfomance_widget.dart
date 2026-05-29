import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

class ExercisePerformanceWidget extends StatelessWidget {
  final ExercisePerformance exercisePerf;
  final VoidCallback onTap;
  final bool isEditing;
  final VoidCallback? onAddSet;

  const ExercisePerformanceWidget({
    super.key,
    required this.exercisePerf,
    required this.onTap,
    this.isEditing = false,
    this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = exercisePerf.exercise;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isEditing && onAddSet != null)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 24),
                      onPressed: onAddSet,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: exercisePerf.sets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final set = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatSet(set),
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
              if (exercisePerf.sets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No sets added',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSet(SetData set) {
    final parts = <String>[];
    if (set.weight != null) parts.add('${set.weight}kg');
    if (set.reps != null) parts.add('×${set.reps}');
    if (set.duration != null) parts.add('${set.duration}s');
    return parts.isNotEmpty ? parts.join(' ') : '—';
  }
}
