// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Presentation/Screens/home_screen.dart';
import 'package:workout_planner/Features/Data/Service/user_hist_db.dart';
import 'package:workout_planner/Features/Data/Service/exercise_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация баз данных
  await UserHistDb.instance.init();
  // ExerciseDb инициализируется автоматически при первом обращении
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// Провайдер для отслеживания инициализации БД
final databaseInitProvider = FutureProvider<bool>((ref) async {
  await UserHistDb.instance.init();
  // Trigger exercise DB initialization
  final exerciseDb = ExerciseDb.instance;
  await exerciseDb.database;
  return true;
});