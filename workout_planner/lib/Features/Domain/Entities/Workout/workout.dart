import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';

class Workout {
  final int id;
  final DateTime date;
  final List<ExercisePerformance> exercises;
  final bool isCompleted;
  final String? notes;

  const Workout({
    required this.id,
    required this.date,
    required this.exercises,
    this.isCompleted = false,
    this.notes,
  });

  String get primaryMuscleGroup {
    if (exercises.isEmpty) return 'Full Body';

    final muscleCount = <String, int>{};
    for (final exercise in exercises) {
      final muscle = exercise.exercise.muscle;
      muscleCount[muscle] = (muscleCount[muscle] ?? 0) + 1;
    }
    return muscleCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Set<String> get involvedMuscleGroups {
    final muscles = <String>{};
    for (final exercise in exercises) {
      muscles.add(exercise.exercise.muscle);
      if (exercise.exercise.secondaryMuscle.isNotEmpty) {
        muscles.add(exercise.exercise.secondaryMuscle);
      }
    }
    return muscles;
  }

  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.setsCount);

  int get exerciseCount => exercises.length;

  Workout updateDate(DateTime newDate) {
    return Workout(
      id: id,
      date: newDate,
      exercises: exercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout updateNotes(String? newNotes) {
    return Workout(
      id: id,
      date: date,
      exercises: exercises,
      isCompleted: isCompleted,
      notes: newNotes,
    );
  }

  Workout markAsCompleted() {
    return Workout(
      id: id,
      date: date,
      exercises: exercises,
      isCompleted: true,
      notes: notes,
    );
  }

  Workout markAsDraft() {
    return Workout(
      id: id,
      date: date,
      exercises: exercises,
      isCompleted: false,
      notes: notes,
    );
  }

  Workout copyWith({
    int? id,
    DateTime? date,
    List<ExercisePerformance>? exercises,
    bool? isCompleted,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  Workout addExercise(ExercisePerformance exercise) {
    final updatedExercises = List<ExercisePerformance>.from(exercises)
      ..add(exercise);
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout removeExercise(int exerciseId) {
    final updatedExercises = exercises
        .where((ex) => ex.exerciseId != exerciseId)
        .toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout replaceExercise(int oldExerciseId, ExercisePerformance newExercise) {
    final updatedExercises = exercises.map((ex) {
      return ex.exerciseId == oldExerciseId ? newExercise : ex;
    }).toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout updateExercise(int exerciseId, ExercisePerformance newExercise) {
    return replaceExercise(exerciseId, newExercise);
  }

  Workout addSet(int exerciseId, SetData set) {
    final updatedExercises = exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      return ex.addSet(set);
    }).toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout removeSet(int exerciseId, int setIndex) {
    final updatedExercises = exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      return ex.removeSet(setIndex);
    }).toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout updateSet(int exerciseId, int setIndex, SetData newSet) {
    final updatedExercises = exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      return ex.updateSet(setIndex, newSet);
    }).toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout updateSetWeight(int exerciseId, int setIndex, double weight) {
    final updatedExercises = exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      return ex.updateSetWeight(setIndex, weight);
    }).toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout updateSetReps(int exerciseId, int setIndex, int reps) {
    final updatedExercises = exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      return ex.updateSetReps(setIndex, reps);
    }).toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout updateSetDuration(int exerciseId, int setIndex, double duration) {
    final updatedExercises = exercises.map((ex) {
      if (ex.exerciseId != exerciseId) return ex;
      return ex.updateSetDuration(setIndex, duration);
    }).toList();
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  Workout reorderExercises(int oldIndex, int newIndex) {
    final updatedExercises = List<ExercisePerformance>.from(exercises);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final exercise = updatedExercises.removeAt(oldIndex);
    updatedExercises.insert(newIndex, exercise);
    return Workout(
      id: id,
      date: date,
      exercises: updatedExercises,
      isCompleted: isCompleted,
      notes: notes,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Workout #$id - ${date.toString().split(' ')[0]}');
    buffer.writeln('Status: ${isCompleted ? "Done" : "Draft"}');
    if (notes != null) buffer.writeln('Notes: $notes');
    buffer.writeln('Exercises:');

    for (var i = 0; i < exercises.length; i++) {
      final ex = exercises[i];
      buffer.writeln('  ${i + 1}. ${ex.exercise.name} (${ex.setsCount} sets)');
      for (var j = 0; j < ex.sets.length; j++) {
        buffer.writeln('     Set ${j + 1}: ${ex.sets[j]}');
      }
    }

    buffer.writeln('Total: $exerciseCount exercises, $totalSets sets');
    return buffer.toString();
  }
}
