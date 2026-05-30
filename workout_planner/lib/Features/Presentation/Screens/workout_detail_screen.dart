import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_catalog_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_detail_screen.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Presentation/Viewmodels/workout_detail_viewmodel.dart';
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

    Future.microtask(() {
      final viewModel = ref.read(
        workoutDetailViewModelProvider(widget.workout),
      );
      viewModel.loadWorkout();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    final viewModel = ref.read(workoutDetailViewModelProvider(widget.workout));
    final success = await viewModel.saveWorkout();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Workout saved')));
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error saving workout')));
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
      final viewModel = ref.read(
        workoutDetailViewModelProvider(widget.workout),
      );
      final success = await viewModel.deleteWorkout();

      if (mounted && success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(workoutDetailViewModelProvider(widget.workout));
    final workout = viewModel.currentWorkout;
    final hasUnsavedChanges = viewModel.hasUnsavedChanges;

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
              onPressed: viewModel.canUndo ? viewModel.undo : null,
              tooltip: 'Undo',
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: viewModel.canRedo ? viewModel.redo : null,
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
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
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
                              lastDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                              viewModel.updateDate(date);
                            }
                          },
                          child: Text(viewModel.formatDate(_selectedDate)),
                        )
                      : Text(viewModel.formatDate(workout.date)),
                ),
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
                      viewModel.getMainMuscleGroup(),
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                ),
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
                          onChanged: viewModel.updateNotes,
                        )
                      : workout.notes?.isNotEmpty == true
                      ? Text(workout.notes!)
                      : const Text(
                          'No notes',
                          style: TextStyle(color: Colors.grey),
                        ),
                ),
                if (_isEditing) ...{
                  () {
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final workoutDate = DateTime(
                      workout.date.year,
                      workout.date.month,
                      workout.date.day,
                    );
                    final isFuture = workoutDate.isAfter(today);

                    return SwitchListTile(
                      title: const Text('Mark as completed'),
                      value: workout.isCompleted,
                      onChanged: isFuture
                          ? null
                          : (val) => viewModel.toggleCompleted(val),
                      subtitle: isFuture
                          ? const Text(
                              'Cannot mark a future workout as completed',
                            )
                          : null,
                    );
                  }(),
                },
              ],
            ),
          ),
          Expanded(
            child: _isEditing
                ? ReorderableListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: workout.exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      viewModel.reorderExercises(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final exercisePerf = workout.exercises[index];
                      return Container(
                        key: ValueKey(exercisePerf.exerciseId),
                        child: ExercisePerformanceWidget(
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
                                          viewModel.updateSet(
                                            exercisePerf.exerciseId,
                                            setIndex,
                                            newSet,
                                          );
                                        }
                                      : null,
                                  onSetAdded: _isEditing
                                      ? (newSet) {
                                          viewModel.addSet(
                                            exercisePerf.exerciseId,
                                            newSet,
                                          );
                                        }
                                      : null,
                                  onSetRemoved: _isEditing
                                      ? (setIndex) {
                                          viewModel.removeSet(
                                            exercisePerf.exerciseId,
                                            setIndex,
                                          );
                                        }
                                      : null,
                                ),
                              ),
                            ).then((result) {
                              if (result != null && result is List<SetData>) {
                                final updated = ExercisePerformance.create(
                                  exercise: exercisePerf.exercise,
                                  sets: result.cast<SetData>(),
                                );
                                viewModel.session!.replaceExercise(
                                  exercisePerf.exerciseId,
                                  updated,
                                );
                              }
                            });
                          },
                          isEditing: _isEditing,
                          onAddSet: _isEditing
                              ? () {
                                  _showAddSetDialog(exercisePerf.exerciseId);
                                }
                              : null,
                          onDeleteExercise: _isEditing
                              ? () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Exercise'),
                                      content: const Text(
                                        'Remove this exercise from the workout?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    viewModel.removeExercise(
                                      exercisePerf.exerciseId,
                                    );
                                  }
                                }
                              : null,
                        ),
                      );
                    },
                  )
                : ListView.builder(
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
                                        viewModel.updateSet(
                                          exercisePerf.exerciseId,
                                          setIndex,
                                          newSet,
                                        );
                                      }
                                    : null,
                                onSetAdded: _isEditing
                                    ? (newSet) {
                                        viewModel.addSet(
                                          exercisePerf.exerciseId,
                                          newSet,
                                        );
                                      }
                                    : null,
                                onSetRemoved: _isEditing
                                    ? (setIndex) {
                                        viewModel.removeSet(
                                          exercisePerf.exerciseId,
                                          setIndex,
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ).then((result) {
                            if (result != null && result is List<SetData>) {
                              final updated = ExercisePerformance.create(
                                exercise: exercisePerf.exercise,
                                sets: result.cast<SetData>(),
                              );
                              viewModel.session!.replaceExercise(
                                exercisePerf.exerciseId,
                                updated,
                              );
                            }
                          });
                        },
                        isEditing: _isEditing,
                        onAddSet: _isEditing
                            ? () {
                                _showAddSetDialog(exercisePerf.exerciseId);
                              }
                            : null,
                        onDeleteExercise: _isEditing
                            ? () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Exercise'),
                                    content: const Text(
                                      'Remove this exercise from the workout?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  viewModel.removeExercise(
                                    exercisePerf.exerciseId,
                                  );
                                }
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
                      viewModel.addExercise(ex);
                    }
                  }
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddSetDialog(int exerciseId) {
    final viewModel = ref.read(workoutDetailViewModelProvider(widget.workout));
    final currentWorkout = viewModel.currentWorkout;
    if (currentWorkout == null) return;

    final exercisePerf = currentWorkout.exercises
        .where((exercise) => exercise.exerciseId == exerciseId)
        .toList();

    if (exercisePerf.isEmpty) return;
    final selectedExercisePerf = exercisePerf.first;

    final type = selectedExercisePerf.exercise.performanceType;
    final weightController = TextEditingController();
    final repsController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Set'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == PerformanceType.weighted)
                TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              if (type == PerformanceType.weighted) const SizedBox(height: 12),
              if (type != PerformanceType.duration)
                TextFormField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              if (type == PerformanceType.duration)
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (seconds)',
                    border: OutlineInputBorder(),
                    suffixText: 'sec',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final double? weight = weightController.text.isEmpty
                  ? null
                  : double.tryParse(weightController.text);
              final int? reps = repsController.text.isEmpty
                  ? null
                  : int.tryParse(repsController.text);
              final double? duration = durationController.text.isEmpty
                  ? null
                  : double.tryParse(durationController.text);

              if (type == PerformanceType.weighted) {
                if (weight == null || weight <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid weight value')),
                  );
                  return;
                }
                if (reps == null || reps <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid reps value')),
                  );
                  return;
                }
                viewModel.addSet(
                  exerciseId,
                  SetData.weighted(weight: weight, reps: reps),
                );
              } else if (type == PerformanceType.bodyweight) {
                if (reps == null || reps <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid reps value')),
                  );
                  return;
                }
                viewModel.addSet(exerciseId, SetData.bodyweight(reps: reps));
              } else if (type == PerformanceType.duration) {
                if (duration == null || duration <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid duration value')),
                  );
                  return;
                }
                viewModel.addSet(
                  exerciseId,
                  SetData.duration(duration: duration),
                );
              }

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
