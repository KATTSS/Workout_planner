import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/workout_session_manager.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_exercises.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_sets.dart';
import 'package:workout_planner/Features/Domain/UseCases/Workout/manage_workout_status.dart';
import 'package:workout_planner/Utils/Exceptions/workout_validation_exception.dart';

class WorkoutSession {
  final WorkoutSessionManager _stateManager;
  final WorkoutStatusManager _statusManagement;
  final ManageWorkoutExercises _exerciseManagement;
  final SetManagement _setManagement;

  WorkoutSession(
    Workout initialWorkout, {
    DateTime Function()? dateTimeProvider,
  }) : _stateManager = WorkoutSessionManager(initialWorkout),
       _statusManagement = WorkoutStatusManager(
         dateTimeProvider: dateTimeProvider,
       ),
       _exerciseManagement = ManageWorkoutExercises(),
       _setManagement = SetManagement();

  Workout get currentWorkout => _stateManager.currentWorkout;
  bool get canUndo => _stateManager.canUndo;
  bool get canRedo => _stateManager.canRedo;
  bool get isModified => _stateManager.isModified;

  void updateDate(DateTime newDate) {
    _executeOperation(
      () => _statusManagement.updateDate(currentWorkout, newDate),
    );
  }

  void updateNotes(String? notes) {
    _executeOperation(
      () => _statusManagement.updateNotes(currentWorkout, notes),
    );
  }

  void completeWorkout() {
    _executeOperation(() => _statusManagement.markAsCompleted(currentWorkout));
  }

  void uncompleteWorkout() {
    _executeOperation(() => _statusManagement.markAsDraft(currentWorkout));
  }

  void addExercise(ExercisePerformance exercise) {
    _executeOperation(
      () => _exerciseManagement.addExercise(currentWorkout, exercise),
    );
  }

  void removeExercise(int exerciseId) {
    _executeOperation(
      () => _exerciseManagement.removeExercise(currentWorkout, exerciseId),
    );
  }

  void replaceExercise(int oldExerciseId, ExercisePerformance newExercise) {
    _executeOperation(
      () => _exerciseManagement.replaceExercise(
        currentWorkout,
        oldExerciseId,
        newExercise,
      ),
    );
  }

  void reorderExercises(int oldIndex, int newIndex) {
    _executeOperation(
      () => _exerciseManagement.reorderExercises(
        currentWorkout,
        oldIndex,
        newIndex,
      ),
    );
  }

  void addSetToExercise(int exerciseId, SetData set) {
    _executeOperation(
      () => _setManagement.addSet(currentWorkout, exerciseId, set),
    );
  }

  void updateSetInExercise(int exerciseId, int setIndex, SetData newSet) {
    _executeOperation(
      () => _setManagement.updateSet(
        currentWorkout,
        exerciseId,
        setIndex,
        newSet,
      ),
    );
  }

  void removeSetFromExercise(int exerciseId, int setIndex) {
    _executeOperation(
      () => _setManagement.removeSet(currentWorkout, exerciseId, setIndex),
    );
  }

  bool undo() => _stateManager.undo();
  bool redo() => _stateManager.redo();

  void markAsSaved() {
    _stateManager.markAsSaved();
  }

  void _executeOperation(Workout Function() operation) {
    try {
      final updatedWorkout = operation();
      _stateManager.updateState(updatedWorkout);
    } on WorkoutValidationException {
      rethrow;
    }
  }
}
