import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Data/Repository/history_repo_realisation.dart';
import 'package:workout_planner/Features/Data/Repository/excercise_repo_realisation.dart';
import 'package:workout_planner/Features/Data/Service/excercise_db.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout_builder.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
// import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
// import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserHistDb.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout DB Check',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Database Diagnostics'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final HistoryRepo _historyRepo;
  late final ExcerciseRepo _excerciseRepo;

  String _exerciseDbStatus = 'Testing...';
  String _historyDbStatus = 'Testing...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _historyRepo = HistoryRepo(UserHistDb.instance);
    _excerciseRepo = ExcerciseRepo(ExcerciseDb.instance);
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() => _isLoading = true);

    try {
      final exercise = await _excerciseRepo.searchByName(
        'Advanced Kettlebell Windmill',
      );
      if (exercise != null) {
        _exerciseDbStatus =
            '✅ Success! Found Exercise ID: ${exercise.toString()}';
      } else {
        _exerciseDbStatus =
            '⚠️ Connected, but Exercise ID 1 not found (DB might be empty).';
      }

      // final testId = DateTime.now().millisecondsSinceEpoch % 100000;
      // final ex = Exercise(
      //   id: testId,
      //   name: "test ex",
      //   level: 2,
      //   category: ExerciseCategory.cardio,
      //   equipment: Equipment.bodyOnly,
      //   description: "jump and run",
      //   muscle: "legs",
      //   secondaryMuscle: "arms",
      // );
      // final set = SetData.duration(duration: 2.5);
      // var exx = ExercisePerformance.create(exercise: ex, sets: [set]);
      // final testWorkout = WorkoutBuilder()
      //     .addExercise(exx)
      //     .setNotes("testing")
      //     .setDate(DateTime.now())
      //     .build();
      // final testWorkout = Workout(
      //   id: testId,
      //   date: DateTime.now(),
      //   muscleGroup: 'Test Group',
      //   exercisesJson: 'Test Push-up',
      //   isDone: true,
      // );

      // final saved_id = await _historyRepo.saveWorkout(testWorkout);

      // final retrieved = await _historyRepo.getWorkout(saved_id);

      // if (retrieved != null && retrieved.primaryMuscleGroup == 'legs') {
      //   _historyDbStatus =
      //       '✅ Success! Test record saved and retrieved (ID: $testId).';
      // } else {
      //   _historyDbStatus = '❌ Failed to retrieve the record after saving.';
      // }
    } catch (e) {
      _exerciseDbStatus = '❌ Error: $e';
      //  _historyDbStatus = '❌ Error: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exercise Database (ReadOnly Assets):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBox(_exerciseDbStatus),
                  const SizedBox(height: 24),
                  const Text(
                    'User History Database (Read/Write):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBox(_historyDbStatus),
                  const Spacer(),
                  const Text(
                    'Note: If Exercise DB fails, check if assets/databases/excercise_data.db is in pubspec.yaml',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusBox(String text) {
    bool isError = text.contains('❌');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isError ? Colors.red : Colors.green),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isError ? Colors.red.shade900 : Colors.green.shade900,
        ),
      ),
    );
  }
}
