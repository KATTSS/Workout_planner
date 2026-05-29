import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_detail_screen.dart';
import 'package:workout_planner/Features/Presentation/Viewmodels/exercise_catalog_viewmodel.dart';

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
    final params = ExerciseCatalogViewModelParams(
      isCreatingWorkout: widget.isCreatingWorkout,
      isAddingToWorkout: widget.isAddingToWorkout,
    );

    final viewModel = ref.watch(exerciseCatalogViewModelProvider(params));
    final exercisesAsync = viewModel.getExercises();

    final filteredExercises = exercisesAsync.when(
      data: (exercises) =>
          viewModel.filterExercises(exercises, viewModel.filters),
      loading: () => [],
      error: (_, _) => [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.close : Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          if ((viewModel.isCreatingWorkout || viewModel.isAddingToWorkout) &&
              _selectedExercises.isNotEmpty)
            TextButton(
              onPressed: () {
                final exercisePerformances = viewModel
                    .createExercisePerformances(_selectedExercises);
                Navigator.pop(context, exercisePerformances);
              },
              child: Text('Add (${_selectedExercises.length})'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilters) _buildFiltersPanel(viewModel),
          _buildSearchBar(viewModel),
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
                        '${exercise.muscle ?? 'Any'} • ${viewModel.getDifficultyString(exercise.level)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        if (viewModel.isCreatingWorkout ||
                            viewModel.isAddingToWorkout) {
                          setState(() {
                            if (isSelected) {
                              _selectedExercises.remove(exercise);
                            } else {
                              _selectedExercises.add(exercise);
                            }
                          });
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
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
                        },
                      ),
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

  Widget _buildFiltersPanel(ExerciseCatalogViewModel viewModel) {
    final muscleGroups = viewModel.getMuscleGroups();
    final difficulties = viewModel.getDifficulties();
    final currentFilters = viewModel.filters;

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
                onPressed: () => viewModel.resetFilters(),
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
                  selected: currentFilters.muscleGroup == group,
                  onSelected: (_) => viewModel.setMuscleGroup(
                    currentFilters.muscleGroup == group ? null : group,
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
                  selected: currentFilters.difficulty == diff.toLowerCase(),
                  onSelected: (_) => viewModel.setDifficulty(
                    currentFilters.difficulty == diff.toLowerCase()
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

  Widget _buildSearchBar(ExerciseCatalogViewModel viewModel) {
    final currentFilters = viewModel.filters;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: currentFilters.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => viewModel.setSearchQuery(''),
                )
              : null,
        ),
        onChanged: (value) => viewModel.setSearchQuery(value),
      ),
    );
  }
}
