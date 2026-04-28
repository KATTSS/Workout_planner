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
