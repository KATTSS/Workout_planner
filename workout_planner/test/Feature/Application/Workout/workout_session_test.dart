import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/Features/Domain/Entities/Workout/workout.dart';
import 'package:workout_planner/Features/Application/Workout/workout_session.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/ex_perfomance.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

void main() {
  group('WorkoutSession Tests', () {
    late Workout baseWorkout;
    late Exercise dummyExercise;

    setUp(() {
      dummyExercise = Exercise(
        id: 1,
        name: 'Bench Press',
        muscle: 'Chest',
        category: ExerciseCategory.strength,
        level: 1,
        equipment: Equipment.bodyOnly,
        description: "Base press",
        secondaryMuscle: "sec muscle",
      );

      baseWorkout = Workout(
        id: 1,
        date: DateTime.now(),
        exercises: [],
        isCompleted: false,
      );
    });

    test('Добавление упражнения увеличивает счетчик ровно на 1', () {
      // 1. Создаем сессию
      final session = WorkoutSession(baseWorkout);

      // 2. Создаем перформанс для упражнения
      final exPerformance = ExercisePerformance.create(
        exercise: dummyExercise,
        sets: [SetData.weighted(weight: 50, reps: 10)],
      );

      // 3. Вызываем тестируемый метод
      session.addExercise(exPerformance);

      // 4. Проверяем ожидания (Assertions)
      expect(session.currentWorkout.exercises.length, 1);
      expect(session.currentWorkout.exerciseCount, 1);
    });

    test('Добавление сета к упражнению не дублирует упражнения', () {
      final session = WorkoutSession(baseWorkout);
      final exPerformance = ExercisePerformance.create(
        exercise: dummyExercise,
        sets: [SetData.weighted(weight: 50, reps: 10)],
      );

      session.addExercise(exPerformance);

      // Пытаемся добавить еще один сет
      final newSet = SetData.weighted(weight: 60, reps: 8);

      // Предполагаем, что у exPerformance внутри есть свой id, либо берем из dummyExercise
      session.addSetToExercise(exPerformance.exerciseId, newSet);

      // 🔴 Проверяем, не «размножились» ли упражнения или сеты неверным образом
      expect(
        session.currentWorkout.exercises.length,
        1,
        reason: 'Количество упражнений должно остаться равным 1!',
      );

      expect(
        session.currentWorkout.exercises.first.setsCount,
        2,
        reason: 'У этого упражнения теперь должно быть ровно 2 сета!',
      );
    });
  });
}
