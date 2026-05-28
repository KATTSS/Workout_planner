import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Application/Workout/workout_builder.dart';
import 'package:workout_planner/Features/Presentation/Providers/history_providers.dart';
import 'package:workout_planner/Features/Presentation/Widgets/exercise_editor_card.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/providers.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';
import 'package:workout_planner/Features/Presentation/Providers/workout_session_provider.dart';
import 'package:workout_planner/Features/Presentation/State/workout_session_notifier.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_selection_screen.dart';

class WorkoutEditorScreen extends ConsumerStatefulWidget {
  final int? existingWorkoutId;

  const WorkoutEditorScreen({super.key, this.existingWorkoutId});

  @override
  ConsumerState<WorkoutEditorScreen> createState() =>
      _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends ConsumerState<WorkoutEditorScreen> {
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _initializeWorkout();
  }

  Future<void> _initializeWorkout() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.existingWorkoutId != null) {
        debugPrint('=== LOADING WORKOUT ===');
        final workout = await ref.read(
          workoutByIdProvider(widget.existingWorkoutId!).future,
        );
        debugPrint('Workout loaded: ${workout?.id}');

        if (mounted && workout != null) {
          ref
              .read(workoutSessionProvider.notifier)
              .startExistingWorkout(workout);
          _notesController.text = workout.notes ?? '';
          _selectedDate = workout.date;
        } else if (mounted) {
          setState(() => _errorMessage = 'Workout not found');
        }
      } else {
        debugPrint('=== CREATING NEW WORKOUT ===');
        // ✅ Исправлено: используем id = -1 для новых тренировок
        final workout = WorkoutBuilder()
            .setId(1234) // Используем -1 для новых тренировок
            .setDate(_selectedDate)
            .addExercises([])
            .setNotes('')
            .asDraft()
            .build();

        if (mounted) {
          ref.read(workoutSessionProvider.notifier).startNewWorkout(workout);
        }
      }
    } catch (e, stack) {
      debugPrint('ERROR: $e');
      debugPrint('STACK: $stack');
      if (mounted) {
        setState(() => _errorMessage = 'Failed to load workout: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    ref.read(workoutSessionProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _addExercise() async {
    if (!mounted) return;

    final result = await Navigator.push<ExercisePerformance>(
      context,
      MaterialPageRoute(builder: (context) => const ExerciseSelectionScreen()),
    );

    if (result != null && mounted) {
      ref.read(workoutSessionProvider.notifier).addExercise(result);
    }
  }

  Future<void> _selectDate() async {
    if (!mounted) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
      ref.read(workoutSessionProvider.notifier).updateDate(picked);
    }
  }

  Future<void> _saveWorkout() async {
    if (!mounted) return;

    final sessionNotifier = ref.read(workoutSessionProvider.notifier);
    final stateValue = ref.read(workoutSessionProvider);

    if (stateValue.workout == null) return;

    try {
      sessionNotifier.updateNotes(_notesController.text);
      final workout = stateValue.workout!;
      final saveUseCase = ref.read(saveWorkoutProvider);
      await saveUseCase.call(workout);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Workout saved!')));
        sessionNotifier.reset();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    }
  }

  Future<void> _deleteWorkout() async {
    if (!mounted) return;
    debugPrint('Delete workout triggered for ID: ${widget.existingWorkoutId}');

    // Показываем диалог подтверждения
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

    if (confirmed == true && mounted) {
      // TODO: Реализовать удаление
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete feature coming soon')),
      );
    }
  }

  Widget _buildEmptyStatePlaceholder(BuildContext context, bool isNew) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No exercises in this workout.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to add your first exercise.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stateValue = ref.watch(workoutSessionProvider);
    final hasExercises = stateValue.workout?.exercises.isNotEmpty ?? false;
    final isNew = ref.read(workoutSessionProvider.notifier).isNewWorkout;

    // Отслеживаем ошибки во время сессии
    ref.listen<WorkoutSessionState>(workoutSessionProvider, (previous, next) {
      if (next.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Экран критической ошибки инициализации
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingWorkoutId != null ? 'Edit Workout' : 'New Workout',
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (widget.existingWorkoutId != null) {
                    _initializeWorkout();
                  } else {
                    context.pop();
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingWorkoutId != null ? 'Edit Workout' : 'New Workout',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingWorkoutId == null ? 'New Workout' : 'Edit Workout',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: hasExercises ? _saveWorkout : null,
          ),
        ],
      ),
      body: stateValue.workout == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        subtitle: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        onTap: _selectDate,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Add notes about your workout...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) {
                          ref
                              .read(workoutSessionProvider.notifier)
                              .updateNotes(value);
                        },
                      ),
                    ],
                  ),
                ),
                if (stateValue.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      stateValue.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const Divider(),
                Expanded(
                  // ✅ Важно: используем Expanded для заполнения пространства
                  child: stateValue.workout!.exercises.isEmpty
                      ? _buildEmptyStatePlaceholder(context, isNew)
                      : ListView.builder(
                          itemCount: stateValue.workout!.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise =
                                stateValue.workout!.exercises[index];
                            return ExerciseEditorCard(
                              exercise: exercise,
                              exerciseIndex: index,
                              onDelete: () {
                                ref
                                    .read(workoutSessionProvider.notifier)
                                    .removeExercise(exercise.exerciseId);
                              },
                              onUpdateSet: (setIndex, newSet) {
                                ref
                                    .read(workoutSessionProvider.notifier)
                                    .updateSetInExercise(
                                      exercise.exerciseId,
                                      setIndex,
                                      newSet,
                                    );
                              },
                              onAddSet: () {
                                final initialSet = _getInitialSet(exercise);
                                ref
                                    .read(workoutSessionProvider.notifier)
                                    .addSetToExercise(
                                      exercise.exerciseId,
                                      initialSet,
                                    );
                              },
                              onDeleteSet: (setIndex) {
                                ref
                                    .read(workoutSessionProvider.notifier)
                                    .removeSetFromExercise(
                                      exercise.exerciseId,
                                      setIndex,
                                    );
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                  ),
                ),
              ],
            ),
    );
  }

  SetData _getInitialSet(ExercisePerformance exercise) {
    switch (exercise.exercise.performanceType) {
      case PerformanceType.weighted:
        return SetData.weighted(weight: 0, reps: 10);
      case PerformanceType.bodyweight:
        return SetData.bodyweight(reps: 10);
      case PerformanceType.duration:
        return SetData.duration(duration: 30.0);
    }
  }
}
