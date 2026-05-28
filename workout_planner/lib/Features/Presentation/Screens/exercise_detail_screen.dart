// lib/Features/Presentation/screens/exercise_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExercisePerformance exercisePerf;
  final bool isEditing;
  final void Function(int setIndex, SetData newSet)? onSetChanged;
  final void Function(SetData newSet)? onSetAdded;
  final void Function(int setIndex)? onSetRemoved;

  const ExerciseDetailScreen({
    super.key,
    required this.exercisePerf,
    this.isEditing = false,
    this.onSetChanged,
    this.onSetAdded,
    this.onSetRemoved,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late List<SetData> _sets;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _sets = widget.exercisePerf.sets.toList();
  }

  String _getDifficultyString(int? difficulty) {
    if (difficulty == null) return 'Not specified';
    switch (difficulty) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Not specified';
    }
  }

  void _updateSet(int index, SetData newSet) {
    setState(() {
      _sets[index] = newSet;
      _hasChanges = true;
    });
    widget.onSetChanged?.call(index, newSet);
  }

  void _addSet() {
    final exercise = widget.exercisePerf.exercise;
    final newSet = SetData.empty(exercise.performanceType);
    setState(() {
      _sets.add(newSet);
      _hasChanges = true;
    });
    widget.onSetAdded?.call(newSet);
  }

  void _removeSet(int index) {
    setState(() {
      _sets.removeAt(index);
      _hasChanges = true;
    });
    widget.onSetRemoved?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercisePerf.exercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          if (widget.isEditing && _hasChanges)
            TextButton(
              onPressed: () => Navigator.pop(context, _sets),
              child: const Text('Save'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Exercise details header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      exercise.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.fitness_center, exercise.muscle),
                    _buildInfoChip(
                      Icons.trending_up,
                      _getDifficultyString(exercise.level),
                    ),
                    _buildInfoChip(Icons.category, exercise.category.name),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Performance Type: ${_getPerformanceTypeString(exercise.performanceType)}',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sets list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _sets.length,
              itemBuilder: (context, index) {
                final set = _sets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${set.weight != null ? '${set.weight} kg' : '—'} × ${set.reps ?? '—'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (set.duration != null) Text('${set.duration} sec'),
                      ],
                    ),
                    trailing: widget.isEditing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditSetDialog(index, set),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _removeSet(index),
                              ),
                            ],
                          )
                        : null,
                    onTap: widget.isEditing
                        ? () => _showEditSetDialog(index, set)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isEditing
          ? FloatingActionButton(
              onPressed: _addSet,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  String _getPerformanceTypeString(dynamic type) {
    // Based on your PerformanceType enum
    return type.toString().split('.').last;
  }

  void _showEditSetDialog(int index, SetData currentSet) {
    final exercise = widget.exercisePerf.exercise;
    final type = exercise.performanceType;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type.toString().contains('weight'))
              TextFormField(
                initialValue: currentSet.weight?.toString(),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Handle change
                },
              ),
            if (type.toString().contains('reps'))
              TextFormField(
                initialValue: currentSet.reps?.toString(),
                decoration: const InputDecoration(labelText: 'Reps'),
                keyboardType: TextInputType.number,
              ),
            if (type.toString().contains('duration'))
              TextFormField(
                initialValue: currentSet.duration?.toString(),
                decoration: const InputDecoration(
                  labelText: 'Duration (seconds)',
                ),
                keyboardType: TextInputType.number,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update set with new values
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
