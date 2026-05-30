import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Presentation/Viewmodels/exercise_detail_viewmodel.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
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
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  late final ExerciseDetailViewModelParams _params;

  @override
  void initState() {
    super.initState();

    _params = ExerciseDetailViewModelParams(
      exercisePerf: widget.exercisePerf,
      isEditing: widget.isEditing,
      onSetChanged: widget.onSetChanged,
      onSetAdded: widget.onSetAdded,
      onSetRemoved: widget.onSetRemoved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(exerciseDetailViewModelProvider(_params));

    final exercise = viewModel.exercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          if (viewModel.isEditing && viewModel.hasChanges)
            TextButton(
              onPressed: () {
                //=>
                final updatedPerf = ExercisePerformance.create(
                  exercise: viewModel.exercise,
                  sets: viewModel.getCurrentSets(),
                );
                Navigator.pop(
                  context,
                  updatedPerf,
                ); //viewModel.getCurrentSets());
              },
              child: const Text('Save'),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (exercise.description.isNotEmpty)
                // Padding(
                // padding: const EdgeInsets.only(bottom: 12),
                //child: Text(
                // exercise.description,
                ///style: const TextStyle(fontSize: 14),
                // ),
                // ),
                if (exercise.description.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: () {
                      final steps = viewModel.getDescriptionFormated();
                      if (steps.length == 1) {
                        // Если только один шаг - показываем без нумерации
                        return Text(
                          steps.first,
                          style: const TextStyle(fontSize: 14),
                        );
                      } else {
                        // Если несколько шагов - показываем нумерованный список
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: steps.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key + 1}. ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      }
                    }(),
                  ),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.fitness_center, exercise.muscle),
                    _buildInfoChip(
                      Icons.trending_up,
                      viewModel.getDifficultyString(),
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
                          'Performance Type: ${viewModel.getPerformanceTypeString()}',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: viewModel.sets.length,
              itemBuilder: (context, index) {
                final set = viewModel.sets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(viewModel.getSetInfo(set)),
                    trailing: viewModel.isEditing
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showEditSetDialog(
                                  context,
                                  index,
                                  set,
                                  viewModel,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => viewModel.removeSet(index),
                              ),
                            ],
                          )
                        : null,
                    onTap: viewModel.isEditing
                        ? () =>
                              _showEditSetDialog(context, index, set, viewModel)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: viewModel.isEditing
          ? FloatingActionButton(
              onPressed: () => _showAddSetDialog(context, viewModel),
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

  void _showEditSetDialog(
    BuildContext context,
    int index,
    SetData currentSet,
    ExerciseDetailViewModel viewModel,
  ) {
    final exercise = viewModel.exercise;
    final type = exercise.performanceType;

    final weightController = TextEditingController(
      text: currentSet.weight?.toString() ?? '',
    );
    final repsController = TextEditingController(
      text: currentSet.reps?.toString() ?? '',
    );
    final durationController = TextEditingController(
      text: currentSet.duration?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Set'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (type == PerformanceType.weighted) ...[
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ] else if (type == PerformanceType.bodyweight) ...[
                    TextFormField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ] else if (type == PerformanceType.duration) ...[
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
                  const SizedBox(height: 16),
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
                  } else if (type == PerformanceType.bodyweight) {
                    if (reps == null || reps <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid reps value')),
                      );
                      return;
                    }
                  } else if (type == PerformanceType.duration) {
                    if (duration == null || duration <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid duration value')),
                      );
                      return;
                    }
                  }

                  final updatedSet = type == PerformanceType.weighted
                      ? SetData.weighted(weight: weight!, reps: reps!)
                      : type == PerformanceType.bodyweight
                      ? SetData.bodyweight(reps: reps!)
                      : SetData.duration(duration: duration!);

                  viewModel.updateSet(index, updatedSet);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddSetDialog(
    BuildContext context,
    ExerciseDetailViewModel viewModel,
  ) {
    final exercise = viewModel.exercise;
    final type = exercise.performanceType;

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
              if (type == PerformanceType.weighted) ...[
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else if (type == PerformanceType.bodyweight) ...[
                TextFormField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ] else if (type == PerformanceType.duration) ...[
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
                viewModel.addSet(SetData.weighted(weight: weight, reps: reps));
              } else if (type == PerformanceType.bodyweight) {
                if (reps == null || reps <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid reps value')),
                  );
                  return;
                }
                viewModel.addSet(SetData.bodyweight(reps: reps));
              } else if (type == PerformanceType.duration) {
                if (duration == null || duration <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid duration value')),
                  );
                  return;
                }
                viewModel.addSet(SetData.duration(duration: duration));
              }

              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
