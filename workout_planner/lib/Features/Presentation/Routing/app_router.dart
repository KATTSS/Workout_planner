import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_planner/Features/Presentation/Screens/workout_list_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/workout_detail_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/workout_editor_screen.dart';
import 'package:workout_planner/Features/Presentation/Screens/exercise_selection_screen.dart';

class AppRouter {
  static const String workoutList = '/';
  static const String workoutDetail = '/workout/detail';
  static const String workoutEditor = '/workout/edit';
  static const String exerciseSelection = '/exercises/select';

  // Используем path параметры вместо query (более надёжно)
  static String workoutDetailPath(int id) => '/workout/detail/$id';
  
  // Для editor используем extra параметры (сложные объекты)

  static final GoRouter router = GoRouter(
    initialLocation: workoutList,
    routes: [
      GoRoute(
        path: workoutList,
        name: 'workout_list',
        builder: (context, state) => const WorkoutListScreen(),
      ),
      GoRoute(
        path: '$workoutDetail/:id',
        name: 'workout_detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Invalid workout ID')),
            );
          }
          return WorkoutDetailScreen(workoutId: id);
        },
      ),
      GoRoute(
        path: workoutEditor,
        name: 'workout_editor',
        builder: (context, state) {
          // Поддержка обоих способов передачи данных
          final extra = state.extra as Map<String, dynamic>?;
          final workoutId = extra?['workoutId'] as int?;
          return WorkoutEditorScreen(existingWorkoutId: workoutId);
        },
      ),
      GoRoute(
        path: exerciseSelection,
        name: 'exercise_selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final preselectedCategory = extra?['category'] as String?;
          return ExerciseSelectionScreen(preselectedCategory: preselectedCategory);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      );
    },
  );
}

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:workout_planner/Features/Presentation/Screens/workout_list_screen.dart';
// import 'package:workout_planner/Features/Presentation/Screens/workout_detail_screen.dart';
// import 'package:workout_planner/Features/Presentation/Screens/workout_editor_screen.dart';
// import 'package:workout_planner/Features/Presentation/Screens/exercise_selection_screen.dart';

// class AppRouter {
//   static const String workoutList = '/';
//   static const String workoutDetail = '/workout/detail'; 
//   static const String workoutEditor = '/workout/edit';
//   static const String exerciseSelection = '/exercises/select';

//   // Используем query параметры вместо path параметров
//   static String workoutDetailPath(int id) => '/workout/detail?id=$id';

//   static final GoRouter router = GoRouter(
//     initialLocation: workoutList,
//     routes: [
//       GoRoute(
//         path: workoutList,
//         name: 'workout_list',
//         builder: (context, state) => const WorkoutListScreen(),
//       ),
//       GoRoute(
//         path: workoutDetail,
//         name: 'workout_detail',
//         builder: (context, state) {
//           // Получаем id из query параметров
//           final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
//           if (id == null) {
//             return const Scaffold(
//               body: Center(child: Text('Invalid workout ID')),
//             );
//           }
//           return WorkoutDetailScreen(workoutId: id);
//         },
//       ),
//       GoRoute(
//         path: workoutEditor,
//         name: 'workout_editor',
//         builder: (context, state) {
//           final extra = state.extra as Map<String, dynamic>?;
//           final workoutId = extra?['workoutId'] as int?;
//           return WorkoutEditorScreen(existingWorkoutId: workoutId);
//         },
//       ),
//       GoRoute(
//         path: exerciseSelection,
//         name: 'exercise_selection',
//         builder: (context, state) {
//           return const ExerciseSelectionScreen();
//         },
//       ),
//     ],
//     // Обработка ошибок
//     errorBuilder: (context, state) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Error')),
//         body: Center(
//           child: Text('Page not found: ${state.uri}'),
//         ),
//       );
//     },
//   );
// }