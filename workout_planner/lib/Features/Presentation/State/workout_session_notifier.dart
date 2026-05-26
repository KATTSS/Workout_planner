import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Application/Workout/workout_session.dart';

class WorkoutSessionState {
  final Workout? workout;
  final bool canUndo;
  final bool canRedo;
  final String? errorMessage;

  const WorkoutSessionState({
    this.workout,
    this.canUndo = false,
    this.canRedo = false,
    this.errorMessage,
  });

  WorkoutSessionState copyWith({
    Workout? workout,
    bool? canUndo,
    bool? canRedo,
    String? errorMessage,
  }) {
    return WorkoutSessionState(
      workout: workout ?? this.workout,
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
      errorMessage: errorMessage,
    );
  }
}

class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
  WorkoutSession? _session;

  WorkoutSessionNotifier() : super(const WorkoutSessionState());

  void startNewWorkout(Workout initialWorkout) {
    _session = WorkoutSession(initialWorkout);
    _updateState();
  }

  void startExistingWorkout(Workout workout) {
    _session = WorkoutSession(workout);
    _updateState();
  }

  void _updateState({String? error}) {
    if (_session == null) return;
    
    state = WorkoutSessionState(
      workout: _session!.currentWorkout,
      canUndo: _session!.canUndo,
      canRedo: _session!.canRedo, // Исправлено: ранее вызывался redo()
      errorMessage: error,
    );
  }

  void addExercise(ExercisePerformance exercise) {
    try {
      _session?.addExercise(exercise);
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void removeExercise(int exerciseId) {
    try {
      _session?.removeExercise(exerciseId);
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void addSetToExercise(int exerciseId, SetData set) {
    try {
      _session?.addSetToExercise(exerciseId, set);
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void removeSetFromExercise(int exerciseId, int setIndex) {
    try {
      _session?.removeSetFromExercise(exerciseId, setIndex);
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void updateSetInExercise(int exerciseId, int setIndex, SetData newSet) {
    try {
      _session?.updateSetInExercise(exerciseId, setIndex, newSet);
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void updateDate(DateTime newDate) {
    try {
      _session?.updateDate(newDate);
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void updateNotes(String? notes) {
    try {
      _session?.updateNotes(notes);
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void undo() {
    try {
      _session?.undo();
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void redo() {
    try {
      _session?.redo();
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }

  void completeWorkout() {
    try {
      _session?.completeWorkout();
      _updateState();
    } catch (e) {
      _updateState(error: e.toString());
    }
  }
  
  void reset() {
    _session = null;
    state = const WorkoutSessionState();
  }
}
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
// import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
// import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
// import 'package:workout_planner/Features/Application/Workout/workout_session.dart';

// class WorkoutSessionState {
//   final WorkoutSession? session;
//   final bool isLoading;
//   final String? errorMessage;
//   final int updateVersion;

//   const WorkoutSessionState({
//     this.session,
//     this.isLoading = false,
//     this.errorMessage,
//     this.updateVersion = 0, // Изначально 0
//   });

//   WorkoutSessionState copyWith({
//     WorkoutSession? session,
//     bool? isLoading,
//     String? errorMessage,
//     int? updateVersion,
//   }) {
//     return WorkoutSessionState(
//       session: session ?? this.session,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage,
//       // Если updateVersion не передан явно, увеличиваем текущий на 1 при изменении сессии
//       updateVersion:
//           updateVersion ??
//           (session != null ? this.updateVersion + 1 : this.updateVersion),
//     );
//   }
// }

// class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
//   WorkoutSessionNotifier() : super(const WorkoutSessionState());

//   void startNewWorkout(Workout initialWorkout) {
//     state = WorkoutSessionState(
//       // Сбрасываем версию при старте
//       session: WorkoutSession(initialWorkout),
//     );
//   }

//   void startExistingWorkout(Workout workout) {
//     state = WorkoutSessionState(session: WorkoutSession(workout));
//   }

//   void addExercise(ExercisePerformance exercise) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.addExercise(exercise);
//       // Явно увеличиваем версию, чтобы state изменился для Riverpod
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void removeExercise(int exerciseId) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.removeExercise(exerciseId);
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void addSetToExercise(int exerciseId, SetData set) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.addSetToExercise(exerciseId, set);
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void removeSetFromExercise(int exerciseId, int setIndex) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.removeSetFromExercise(exerciseId, setIndex);
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void updateSetInExercise(int exerciseId, int setIndex, SetData newSet) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.updateSetInExercise(exerciseId, setIndex, newSet);
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void updateDate(DateTime newDate) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.updateDate(newDate);
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void updateNotes(String? notes) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.updateNotes(notes);
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void completeWorkout() {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.completeWorkout();
//       state = state.copyWith(
//         session: session,
//         updateVersion: state.updateVersion + 1,
//         errorMessage: null,
//       );
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void undo() {
//     final session = state.session;
//     if (session == null) return;

//     session.undo();
//     state = state.copyWith(
//       session: session,
//       updateVersion: state.updateVersion + 1,
//     );
//   }

//   void redo() {
//     final session = state.session;
//     if (session == null) return;

//     session.redo();
//     state = state.copyWith(
//       session: session,
//       updateVersion: state.updateVersion + 1,
//     );
//   }

//   void reset() {
//     state = const WorkoutSessionState();
//   }
// }
