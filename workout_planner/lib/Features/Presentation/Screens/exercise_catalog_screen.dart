// lib/Features/Presentation/screens/exercise_catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Application/Providers/workout_states.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_detail_screen.dart';

class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  final bool isCreatingWorkout;
  final bool isAddingToWorkout;

  const ExerciseCatalogScreen({
    super.key,
    this.isCreatingWorkout = false,
    this.isAddingToWorkout = false,
  });

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends ConsumerState<ExerciseCatalogScreen> {
  final Set<Exercise> _selectedExercises = {};
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(exerciseFiltersProvider);
    final exercisesAsync = ref.watch(exerciseCatalogProvider);
    final filteredExercises = exercisesAsync.when(
      data: (exercises) => _filterExercises(exercises, filters),
      loading: () => [],
      error: (_, __) => [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.close : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          if (widget.isCreatingWorkout && _selectedExercises.isNotEmpty)
            TextButton(
              onPressed: () {
                final exercisePerformances = _selectedExercises.map((ex) {
                  return ExercisePerformance.create(
                    exercise: ex,
                    sets: [SetData.empty(ex.performanceType)],
                  );
                }).toList();
                Navigator.pop(context, exercisePerformances);
              },
              child: Text('Add (${_selectedExercises.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFiltersPanel(),
          _buildSearchBar(),
          Expanded(
            child: exercisesAsync.when(
              data: (_) => ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = filteredExercises[index];
                  final isSelected = _selectedExercises.contains(exercise);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Colors.green
                            : Colors.grey.shade300,
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : Text('${index + 1}'),
                      ),
                      title: Text(exercise.name),
                      subtitle: Text(
                        '${exercise.muscle ?? 'Any'} • ${_getDifficultyString(exercise.level)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (widget.isCreatingWorkout &&
                            !widget.isAddingToWorkout) {
                          setState(() {
                            if (isSelected) {
                              _selectedExercises.remove(exercise);
                            } else {
                              _selectedExercises.add(exercise);
                            }
                          });
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExerciseDetailScreen(
                                exercisePerf: ExercisePerformance.create(
                                  exercise: exercise,
                                  sets: [],
                                ),
                                isEditing: true,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    final filters = ref.watch(exerciseFiltersProvider);
    final muscleGroups = [
      'abdominals',
      'hamstrings',
      'adductors',
      'quadriceps',
      'biceps',
      'shoulders',
      'chest',
      'middle back',
      'calves',
      'glutes',
      'lower back',
      'lats',
      'triceps',
      'traps',
      'forearms',
      'neck',
      'abductors',
    ];
    final difficulties = ['Beginner', 'Intermediate', 'Advanced'];

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(exerciseFiltersProvider.notifier).resetFilters(),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              const Text('Muscle Group:'),
              ...muscleGroups.map(
                (group) => FilterChip(
                  label: Text(group),
                  selected: filters.muscleGroup == group,
                  onSelected: (_) => ref
                      .read(exerciseFiltersProvider.notifier)
                      .setMuscleGroup(
                        filters.muscleGroup == group ? null : group,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              const Text('Difficulty:'),
              ...difficulties.map(
                (diff) => FilterChip(
                  label: Text(diff),
                  selected: filters.difficulty == diff.toLowerCase(),
                  onSelected: (_) => ref
                      .read(exerciseFiltersProvider.notifier)
                      .setDifficulty(
                        filters.difficulty == diff.toLowerCase()
                            ? null
                            : diff.toLowerCase(),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final filters = ref.watch(exerciseFiltersProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: filters.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => ref
                      .read(exerciseFiltersProvider.notifier)
                      .setSearchQuery(''),
                )
              : null,
        ),
        onChanged: (value) =>
            ref.read(exerciseFiltersProvider.notifier).setSearchQuery(value),
      ),
    );
  }

  List<Exercise> _filterExercises(
    List<Exercise> exercises,
    ExerciseFiltersState filters,
  ) {
    return exercises.where((ex) {
      if (filters.muscleGroup != null && ex.muscle != filters.muscleGroup) {
        return false;
      }
      if (filters.difficulty != null) {
        final diffString = _getDifficultyString(ex.level).toLowerCase();
        if (diffString != filters.difficulty) return false;
      }
      if (filters.searchQuery.isNotEmpty) {
        if (!ex.name.toLowerCase().contains(
          filters.searchQuery.toLowerCase(),
        )) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  String _getDifficultyString(int? difficulty) {
    switch (difficulty) {
      case 0:
        return 'Beginner';
      case 1:
        return 'Intermediate';
      case 2:
        return 'Advanced';
      default:
        return 'Any';
    }
  }
}
