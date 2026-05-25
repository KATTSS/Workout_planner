import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Application/Workout/workout_builder.dart';
import 'package:workout_planner/Features/Presentation/Providers/history_providers.dart';
import 'package:workout_planner/Features/Presentation/Widgets/exercise_editor_card.dart';
import 'package:workout_planner/Features/Presentation/Routing/app_router.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/providers.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';
import 'package:workout_planner/Features/Presentation/Providers/workout_session_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _initializeWorkout();
  }

  Future<void> _initializeWorkout() async {
    if (widget.existingWorkoutId != null) {
      final workoutAsync = ref.read(
        workoutByIdProvider(widget.existingWorkoutId!),
      );
      workoutAsync.whenData((workout) {
        if (workout != null && mounted) {
          ref
              .read(workoutSessionProvider.notifier)
              .startExistingWorkout(workout);
          _notesController.text = workout.notes ?? '';
          _selectedDate = workout.date;
        }
      });
    } else {
      // Создаем пустую тренировку
      final workout = WorkoutBuilder()
          .setDate(_selectedDate)
          .addExercises([])
          .build();
      ref.read(workoutSessionProvider.notifier).startNewWorkout(workout);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final result = await context.push<ExercisePerformance>(
      AppRouter.exerciseSelection,
    );

    if (result != null && mounted) {
      ref.read(workoutSessionProvider.notifier).addExercise(result);
    }
  }

  Future<void> _selectDate() async {
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
    final session = ref.read(workoutSessionProvider.notifier);
    final state = ref.read(workoutSessionProvider);

    if (state.session == null) return;

    try {
      // Сохраняем заметки
      session.updateNotes(_notesController.text);

      // Сохраняем тренировку
      final workout = state.session!.currentWorkout;
      final saveUseCase = ref.read(saveWorkoutProvider);
      await saveUseCase.call(workout);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Workout saved!')));
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutSessionProvider);
    final session = state.session;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingWorkoutId != null ? 'Edit Workout' : 'New Workout',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: session?.canUndo == true
                ? () => ref.read(workoutSessionProvider.notifier).undo()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: session?.canRedo == true
                ? () => ref.read(workoutSessionProvider.notifier).redo()
                : null,
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveWorkout),
        ],
      ),
      body: session == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Дата и заметки
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
                const Divider(),
                // Список упражнений
                Expanded(
                  child: session.currentWorkout.exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No exercises added yet'),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _addExercise,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Exercise'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: session.currentWorkout.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise =
                                session.currentWorkout.exercises[index];
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
                // Кнопка добавления упражнения
                if (session.currentWorkout.exercises.isNotEmpty)
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
