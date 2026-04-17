import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Data/Repository/history_repo_realisation.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
import 'package:workout_planner/Features/Domain/Entities/workout_history.dart';
import 'Features/Data/Service/user_hist_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация базы данных
  await UserHistDb.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Workout History'),
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
  final UserHistDb _db = UserHistDb.instance;
  late final HistoryRepo _historyRepo;

  WorkoutHistory? _workout;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _historyRepo = HistoryRepo(_db);
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Создаем тестовую тренировку
      final testWorkout = WorkoutHistory(
        id: 1,
        date: "01.02.2026",
        muscleGroup: "biceps",
        excerciseList: "bicep curls, tricep curls",
        isDone: true,
      );

      // Сохраняем в БД
      await _historyRepo.saveHistory(testWorkout);

      // Получаем из БД
      final gottenWorkout = await _historyRepo.getHistory(1);

      setState(() {
        _workout = gottenWorkout;
        _isLoading = false;
      });

      if (_workout != null) {
        print("Данные успешно загружены");
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: $e';
        _isLoading = false;
      });
      print('Ошибка при работе с БД: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadWorkoutData();
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
            onPressed: _refreshData,
            tooltip: 'Обновить данные',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewWorkout,
        tooltip: 'Добавить тренировку',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка данных...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (_workout == null) {
      return const Center(child: Text('Нет данных о тренировках'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Тренировка #${_workout!.id}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _workout!.isDone
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _workout!.isDone ? 'Выполнено' : 'В процессе',
                      style: TextStyle(
                        color: _workout!.isDone ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Детали тренировки
              _buildInfoRow(Icons.calendar_today, 'Дата', _workout!.date),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.fitness_center,
                'Группа мышц',
                _workout!.muscleGroup,
              ),
              const SizedBox(height: 12),

              // Список упражнений
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.list, size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    'Упражнения:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._workout!.excerciseList.split(',').map((exercise) {
                return Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 8),
                      Text(exercise.trim()),
                    ],
                  ),
                );
              }),

              const Spacer(),

              // Кнопка обновления
              Center(
                child: ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Обновить данные'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Future<void> _addNewWorkout() async {
    try {
      setState(() => _isLoading = true);

      // Создаем новую тренировку с уникальным ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newWorkout = WorkoutHistory(
        id: timestamp,
        date: _formatDate(DateTime.now()),
        muscleGroup: "Новая группа мышц",
        excerciseList: "новое упражнение 1, новое упражнение 2",
        isDone: false,
      );

      await _historyRepo.saveHistory(newWorkout);
      await _loadWorkoutData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Новая тренировка добавлена!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при добавлении: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
// import 'package:flutter/material.dart';
// import 'package:workout_planner/Features/Data/Repository/history_repo_realisation.dart';
// import 'package:workout_planner/Features/Domain/Entities/excercise.dart';
// import 'package:workout_planner/Features/Domain/Entities/workout_history.dart';
// import 'Features/Data/Service/user_hist_db.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   //??????????????????????????????????????????
//   await UserHistDb.instance.init();

//   final userHistDb = UserHistDb.instance;
//   final historyRepo = HistoryRepo(userHistDb);

//   final ex = Excercise(1, 1, description: "curl dumpbels", muscle: "biceps");
//   final testWorkout = WorkoutHistory(
//     id: 01,
//     date: "01.02.2026",
//     muscleGroup: "biceps",
//     excerciseList: "bicep curls, tricep curls",
//     isDone: true,
//   );

//   historyRepo.saveHistory(testWorkout);

//   final gottenWorkout = historyRepo.getHistory(01);
//   if (gottenWorkout is WorkoutHistory) {
//     print("OKKKKKIIIIIIIIIIIIIIII");
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: .fromSeed(seedColor: Colors.deepOrangeAccent),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
