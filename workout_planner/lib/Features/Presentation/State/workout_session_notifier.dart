import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Application/Workout/workout_session.dart';

class WorkoutSessionState {
  final WorkoutSession? session;
  final bool isLoading;
  final String? errorMessage;
  final int updateVersion; 

  const WorkoutSessionState({
    this.session,
    this.isLoading = false,
    this.errorMessage,
    this.updateVersion = 0, // Изначально 0
  });

  WorkoutSessionState copyWith({
    WorkoutSession? session,
    bool? isLoading,
    String? errorMessage,
    int? updateVersion,
  }) {
    return WorkoutSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      // Если updateVersion не передан явно, увеличиваем текущий на 1 при изменении сессии
      updateVersion:
          updateVersion ??
          (session != null ? this.updateVersion + 1 : this.updateVersion),
    );
  }
}

class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
  WorkoutSessionNotifier() : super(const WorkoutSessionState());

  void startNewWorkout(Workout initialWorkout) {
    state = WorkoutSessionState(
      // Сбрасываем версию при старте
      session: WorkoutSession(initialWorkout),
    );
  }

  void startExistingWorkout(Workout workout) {
    state = WorkoutSessionState(session: WorkoutSession(workout));
  }

  void addExercise(ExercisePerformance exercise) {
    final session = state.session;
    if (session == null) return;

    try {
      session.addExercise(exercise);
      // Явно увеличиваем версию, чтобы state изменился для Riverpod
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void removeExercise(int exerciseId) {
    final session = state.session;
    if (session == null) return;

    try {
      session.removeExercise(exerciseId);
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void addSetToExercise(int exerciseId, SetData set) {
    final session = state.session;
    if (session == null) return;

    try {
      session.addSetToExercise(exerciseId, set);
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void removeSetFromExercise(int exerciseId, int setIndex) {
    final session = state.session;
    if (session == null) return;

    try {
      session.removeSetFromExercise(exerciseId, setIndex);
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void updateSetInExercise(int exerciseId, int setIndex, SetData newSet) {
    final session = state.session;
    if (session == null) return;

    try {
      session.updateSetInExercise(exerciseId, setIndex, newSet);
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void updateDate(DateTime newDate) {
    final session = state.session;
    if (session == null) return;

    try {
      session.updateDate(newDate);
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void updateNotes(String? notes) {
    final session = state.session;
    if (session == null) return;

    try {
      session.updateNotes(notes);
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void completeWorkout() {
    final session = state.session;
    if (session == null) return;

    try {
      session.completeWorkout();
      state = state.copyWith(
        session: session,
        updateVersion: state.updateVersion + 1,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void undo() {
    final session = state.session;
    if (session == null) return;

    session.undo();
    state = state.copyWith(
      session: session,
      updateVersion: state.updateVersion + 1,
    );
  }

  void redo() {
    final session = state.session;
    if (session == null) return;

    session.redo();
    state = state.copyWith(
      session: session,
      updateVersion: state.updateVersion + 1,
    );
  }

  void reset() {
    state = const WorkoutSessionState();
  }
}

// class WorkoutSessionState {
//   final WorkoutSession? session;
//   final bool isLoading;
//   final String? errorMessage;

//   const WorkoutSessionState({
//     this.session,
//     this.isLoading = false,
//     this.errorMessage,
//   });

//   WorkoutSessionState copyWith({
//     WorkoutSession? session,
//     bool? isLoading,
//     String? errorMessage,
//   }) {
//     return WorkoutSessionState(
//       session: session ?? this.session,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage,
//     );
//   }
// }

// class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
//   WorkoutSessionNotifier() : super(const WorkoutSessionState());

//   void startNewWorkout(Workout initialWorkout) {
//     state = state.copyWith(
//       session: WorkoutSession(initialWorkout),
//       errorMessage: null,
//     );
//   }

//   void startExistingWorkout(Workout workout) {
//     state = state.copyWith(
//       session: WorkoutSession(workout),
//       errorMessage: null,
//     );
//   }

//   void addExercise(ExercisePerformance exercise) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.addExercise(exercise);
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void removeExercise(int exerciseId) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.removeExercise(exerciseId);
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void addSetToExercise(int exerciseId, SetData set) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.addSetToExercise(exerciseId, set);
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void removeSetFromExercise(int exerciseId, int setIndex) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.removeSetFromExercise(exerciseId, setIndex);
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//  void updateSetInExercise(int exerciseId, int setIndex, SetData newSet) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.updateSetInExercise(exerciseId, setIndex, newSet);
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void updateDate(DateTime newDate) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.updateDate(newDate);
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void updateNotes(String? notes) {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.updateNotes(notes);
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void completeWorkout() {
//     final session = state.session;
//     if (session == null) return;

//     try {
//       session.completeWorkout();
//       state = state.copyWith(session: session, errorMessage: null);
//     } catch (e) {
//       state = state.copyWith(errorMessage: e.toString());
//     }
//   }

//   void undo() {
//     final session = state.session;
//     if (session == null) return;

//     session.undo();
//     state = state.copyWith(session: session);
//   }

//   void redo() {
//     final session = state.session;
//     if (session == null) return;

//     session.redo();
//     state = state.copyWith(session: session);
//   }

//   void reset() {
//     state = const WorkoutSessionState();
//   }
// }
