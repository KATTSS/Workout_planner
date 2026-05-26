import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Presentation/State/workout_session_notifier.dart';

final workoutSessionProvider =
    StateNotifierProvider.autoDispose<WorkoutSessionNotifier, WorkoutSessionState>(
      (ref) => WorkoutSessionNotifier(),
    );