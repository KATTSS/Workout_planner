// lib/Features/Presentation/screens/workout_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_catalog_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_detail_screen.dart';
import 'package:workout_planner/Features/Presentation/Widgets/exercise_perfomance_widget.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  late bool _isEditing;
  late TextEditingController _notesController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _notesController = TextEditingController(text: widget.workout.notes);
    _selectedDate = widget.workout.date;

    // Загружаем тренировку в сессию
    Future.microtask(() {
      ref.read(workoutSessionProvider.notifier).loadWorkout(widget.workout);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getMainMuscleGroup() {
    final workout = ref.read(workoutSessionProvider).session?.currentWorkout;
    if (workout == null) return 'None';

    final muscleGroups = <String, int>{};
    for (final exPerf in workout.exercises) {
      final group = exPerf.exercise.muscle ?? 'Other';
      muscleGroups[group] = (muscleGroups[group] ?? 0) + 1;
    }
    if (muscleGroups.isEmpty) return 'None';
    return muscleGroups.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Future<void> _saveWorkout() async {
    final session = ref.read(workoutSessionProvider).session;
    if (session == null) return;

    final saveWorkout = ref.read(saveWorkoutProvider);
    final currentWorkout = session.currentWorkout;

    try {
      await saveWorkout(currentWorkout);
      session.markAsSaved();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Workout saved')));
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
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
      final workoutId = widget.workout.id;
      await deleteWorkout(workoutId);
      if (mounted) {
        Navigator.pop(context);
      }
        }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(workoutSessionProvider);
    final session = sessionState.session;
    final workout = session?.currentWorkout;
    final error = sessionState.error;
    final hasUnsavedChanges = sessionState.hasUnsavedChanges;

    if (workout == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Workout' : 'Workout Details'),
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: session?.canUndo == true
                  ? () => ref.read(workoutSessionProvider.notifier).undo()
                  : null,
              tooltip: 'Undo',
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: session?.canRedo == true
                  ? () => ref.read(workoutSessionProvider.notifier).redo()
                  : null,
              tooltip: 'Redo',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveWorkout,
              tooltip: 'Save',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                if (hasUnsavedChanges) {
                  _showUnsavedChangesDialog();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteWorkout,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Workout header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Date picker
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  trailing: _isEditing
                      ? TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                              ref
                                  .read(workoutSessionProvider.notifier)
                                  .updateDate(date);
                            }
                          },
                          child: Text(_formatDate(_selectedDate)),
                        )
                      : Text(_formatDate(workout.date)),
                ),
                // Main muscle group
                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text('Main Muscle Group'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getMainMuscleGroup(),
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                ),
                // Notes
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Notes'),
                  subtitle: _isEditing
                      ? TextField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            hintText: 'Add notes...',
                            border: OutlineInputBorder(),
                          ),
                          maxLength: 1000,
                          onChanged: (value) {
                            ref
                                .read(workoutSessionProvider.notifier)
                                .updateNotes(value);
                          },
                        )
                      : workout.notes?.isNotEmpty == true
                      ? Text(workout.notes!)
                      : const Text(
                          'No notes',
                          style: TextStyle(color: Colors.grey),
                        ),
                ),
                // Status
                if (_isEditing)
                  SwitchListTile(
                    title: const Text('Mark as completed'),
                    value: workout.isCompleted,
                    onChanged: (value) {
                      if (value) {
                        ref
                            .read(workoutSessionProvider.notifier)
                            .completeWorkout();
                      } else {
                        ref
                            .read(workoutSessionProvider.notifier)
                            .uncompleteWorkout();
                      }
                    },
                  ),
              ],
            ),
          ),
          // Exercises list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercisePerf = workout.exercises[index];
                return ExercisePerformanceWidget(
                  exercisePerf: exercisePerf,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(
                          exercisePerf: exercisePerf,
                          isEditing: _isEditing,
                          onSetChanged: _isEditing
                              ? (setIndex, newSet) {
                                  ref
                                      .read(workoutSessionProvider.notifier)
                                      .updateSet(
                                        exercisePerf.exerciseId,
                                        setIndex,
                                        newSet,
                                      );
                                }
                              : null,
                          onSetAdded: _isEditing
                              ? (newSet) {
                                  ref
                                      .read(workoutSessionProvider.notifier)
                                      .addSet(exercisePerf.exerciseId, newSet);
                                }
                              : null,
                          onSetRemoved: _isEditing
                              ? (setIndex) {
                                  ref
                                      .read(workoutSessionProvider.notifier)
                                      .removeSet(
                                        exercisePerf.exerciseId,
                                        setIndex,
                                      );
                                }
                              : null,
                        ),
                      ),
                    );
                  },
                  isEditing: _isEditing,
                  onAddSet: _isEditing
                      ? () {
                          // TODO: Show dialog to add set
                        }
                      : null,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to add exercise
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExerciseCatalogScreen(
                      isCreatingWorkout: true,
                      isAddingToWorkout: true,
                    ),
                  ),
                ).then((selectedExercises) {
                  if (selectedExercises != null && selectedExercises is List) {
                    for (final ex in selectedExercises) {
                      ref.read(workoutSessionProvider.notifier).addExercise(ex);
                    }
                  }
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to continue editing?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isEditing = true);
            },
            child: const Text('Continue Editing'),
          ),
        ],
      ),
    );
  }
}
