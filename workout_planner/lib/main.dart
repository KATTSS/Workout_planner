import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Presentation/Routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserHistDb.instance.init();

  // await ExerciseDb.instance.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Workout Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData.dark().copyWith(),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Альтернативный простой экран для проверки работы приложения
class TestHomeScreen extends ConsumerWidget {
  const TestHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Planner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Workout Planner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your personal workout tracker',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Навигация будет работать через GoRouter
                // Пока просто тестируем
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Training'),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:workout_planner/Features/Data/Repository/history_repo_realisation.dart';
// import 'package:workout_planner/Features/Data/Repository/exercise_repo_realisation.dart';
// import 'package:workout_planner/Features/Data/Service/exercise_db.dart';
// import 'package:workout_planner/Features/Data/Service/local_workout_data_source.dart';
// import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
// import 'package:workout_planner/Features/Domain/Entities/Performance/ex_no_weight_perfomance.dart';
// import 'Features/Domain/Entities/Performance/set_data.dart';
// import 'Features/Domain/Entities/Performance/ex_perfomance.dart';
// import 'Features/Application/Workout/workout_builder.dart';
// import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await UserHistDb.instance.init();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Workout DB Check',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Database Diagnostics'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late final HistoryRepo _historyRepo;
//   late final ExerciseRepo _exerciseRepo;
//   late final LocalWorkoutDataSource _localWorkoutDataSource;

//   String _exerciseDbStatus = 'Testing...';
//   String _historyDbStatus = 'Testing...';
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _localWorkoutDataSource = LocalWorkoutDataSource(UserHistDb.instance);
//     _exerciseRepo = ExerciseRepo(ExerciseDb.instance);
//     _historyRepo = HistoryRepo(_localWorkoutDataSource, _exerciseRepo);
//     _runDiagnostics();
//   }

//   Future<void> _runDiagnostics() async {
//     setState(() => _isLoading = true);

//     Exercise pushUp = Exercise(
//       id: 5,
//       name: 'Push Up',
//       level: 1,
//       category: ExerciseCategory.bodyweight,
//       equipment: Equipment.bodyOnly,
//       description: 'Chest exercise',
//       muscle: 'Chest',
//       secondaryMuscle: 'Triceps',
//     );

//     ExercisePerformance exercisePerformance = BodyweightExercisePerformance(
//       exerciseId: 0,
//       exercise: pushUp,
//       sets: [SetData.bodyweight(reps: 8), SetData.bodyweight(reps: 7)],
//     );

//     try {
//       final exercises = await _exerciseRepo.getByName('Advanced Kettlebell');

//       if (exercises.isNotEmpty) {
//         _exerciseDbStatus =
//             'Success! Found ${exercises.length} exercise(s): ${exercises.first.toString()}';
//       } else {
//         _exerciseDbStatus = 'No exercises found with that name';
//       }

//       if (exercises.isNotEmpty) {
//         final testExercise = exercises.first;

//         final testSet = SetData(reps: 10, weight: 1.0);
//         final secondSet = SetData(reps: 12, weight: 1.2);

//         exercisePerformance = ExercisePerformance.create(
//           exercise: testExercise,
//           sets: [testSet, secondSet],
//         );
//       }
//     } catch (e) {
//       _exerciseDbStatus = 'Error: $e';
//     } finally {
//       debugPrint('ex block finished');
//     }

//     try {
//       final testWorkout = WorkoutBuilder()
//           .setId(1)
//           .addExercise(exercisePerformance)
//           .setNotes("Testing database functionality")
//           .setDate(DateTime.now())
//           .build();

//       final savedId = await _historyRepo.saveWorkout(testWorkout);

//       if (savedId > 0) {
//         _historyDbStatus = 'Success! Record saved with ID: $savedId. ';

//         final retrieved = await _historyRepo.getWorkout(savedId);

//         if (retrieved != null) {
//           _historyDbStatus +=
//               'Retrieved: ${retrieved.exercises.length} exercise(s), Date: ${retrieved.date.toString().split(' ')[0]}, Total sets: ${retrieved.totalSets}.\n ${retrieved.toString()}';

//           final allWorkouts = await _historyRepo.getAll(limit: 2);
//           _historyDbStatus += '\nTotal workouts in DB: ${allWorkouts.length}.';
//         } else {
//           _historyDbStatus += 'Failed to retrieve the record after saving.';
//         }
//       } else {
//         _historyDbStatus = 'Failed to save workout (returned ID: $savedId).';
//       }
//     } catch (e) {
//       _historyDbStatus = 'Error: ${e.toString()}';
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _runDiagnostics,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Exercise Database (ReadOnly Assets):',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildStatusBox(_exerciseDbStatus),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'User History Database (Read/Write):',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _buildStatusBox(_historyDbStatus),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Note: If Exercise DB fails, check if assets/databases/excercise_data.db is in pubspec.yaml',
//                       style: TextStyle(
//                         fontStyle: FontStyle.italic,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildStatusBox(String text) {
//     bool isError = text.contains('Error');
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isError ? Colors.red.shade50 : Colors.green.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: isError ? Colors.red : Colors.green),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: isError ? Colors.red.shade900 : Colors.green.shade900,
//         ),
//       ),
//     );
//   }
// }
