import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Presentation/Providers/exercise_providers.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  final String? preselectedCategory;
  
  const ExerciseSelectionScreen({super.key, this.preselectedCategory});

  @override
  ConsumerState<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState
    extends ConsumerState<ExerciseSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectExercise(Exercise exercise) {
    final initialSet = _getInitialSet(exercise);
    final performance = ExercisePerformance.create(
      exercise: exercise,
      sets: [initialSet],
    );
    Navigator.pop(context, performance);
  }

  SetData _getInitialSet(Exercise exercise) {
    switch (exercise.performanceType) {
      case PerformanceType.weighted:
        return SetData.weighted(weight: 0, reps: 10);
      case PerformanceType.bodyweight:
        return SetData.bodyweight(reps: 10);
      case PerformanceType.duration:
        return SetData.duration(duration: 30.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exercise'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
        ),
      ),
      body: exercisesAsync.when(
        data: (exercises) => exercises.isEmpty
            ? const Center(child: Text('No exercises found'))
            : ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return _ExerciseListTile(
                    exercise: exercise,
                    onTap: () => _selectExercise(exercise),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(exerciseSearchProvider(_searchQuery));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseListTile({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Text(
          '${exercise.muscle} • ${exercise.category.name} • Level ${exercise.level}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Chip(
          label: Text(
            exercise.performanceType.name,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
// import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
// import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
// import 'package:workout_planner/Features/Presentation/Providers/exercise_providers.dart';
// import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';

// class ExerciseSelectionScreen extends ConsumerStatefulWidget {
//   const ExerciseSelectionScreen({super.key});

//   @override
//   ConsumerState<ExerciseSelectionScreen> createState() =>
//       _ExerciseSelectionScreenState();
// }

// class _ExerciseSelectionScreenState
//     extends ConsumerState<ExerciseSelectionScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _selectExercise(Exercise exercise) {
//     final initialSet = _getInitialSet(exercise);
//     final performance = ExercisePerformance.create(
//       exercise: exercise,
//       sets: [initialSet],
//     );
//     context.pop(performance);
//   }

//   SetData _getInitialSet(Exercise exercise) {
//     switch (exercise.performanceType) {
//       case PerformanceType.weighted:
//         return SetData.weighted(weight: 0, reps: 10);
//       case PerformanceType.bodyweight:
//         return SetData.bodyweight(reps: 10);
//       case PerformanceType.duration:
//         return SetData.duration(duration: 30.0);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final exercisesAsync = ref.watch(exerciseSearchProvider(_searchQuery));

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Exercise'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search exercises...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 suffixIcon: _searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           _searchController.clear();
//                           setState(() => _searchQuery = '');
//                         },
//                       )
//                     : null,
//               ),
//               onChanged: (value) {
//                 setState(() => _searchQuery = value);
//               },
//             ),
//           ),
//         ),
//       ),
//       body: exercisesAsync.when(
//         data: (exercises) => exercises.isEmpty
//             ? const Center(child: Text('No exercises found'))
//             : ListView.builder(
//                 itemCount: exercises.length,
//                 itemBuilder: (context, index) {
//                   final exercise = exercises[index];
//                   return _ExerciseListTile(
//                     exercise: exercise,
//                     onTap: () => _selectExercise(exercise),
//                   );
//                 },
//               ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) => Center(child: Text('Error: $error')),
//       ),
//     );
//   }
// }

// class _ExerciseListTile extends StatelessWidget {
//   final Exercise exercise;
//   final VoidCallback onTap;

//   const _ExerciseListTile({required this.exercise, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ListTile(
//         title: Text(exercise.name),
//         subtitle: Text(
//           '${exercise.muscle} • ${exercise.category.name} • Level ${exercise.level}',
//           style: theme.textTheme.bodySmall,
//         ),
//         trailing: Chip(
//           label: Text(
//             exercise.performanceType.name,
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//         onTap: onTap,
//       ),
//     );
//   }
// }
