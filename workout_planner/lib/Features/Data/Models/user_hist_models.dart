class UserHistModel {
  final int id;
  final String exercisesJson;
  final String date;
  final bool isDone;
  final String? notes;

  UserHistModel({
    required this.id,
    required this.date,
    required this.exercisesJson,
    this.isDone = false,
    this.notes,
  });

  factory UserHistModel.fromMap(Map<String, dynamic> map) =>
      _$UserHistModelFromMap(map);

  // @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'workout_id': id,
      'exercises_json': exercisesJson,
      'date': date,
      'isDone': isDone ? 1 : 0,
      'notes': notes,
    };
  }

  static UserHistModel _$UserHistModelFromMap(Map<String, dynamic> map) =>
      UserHistModel(
        id: map['workout_id'] as int,
        exercisesJson: map['exercises_json'] as String,
        date: map['date'] as String,
        isDone: (map['isDone'] as int) == 1,
        notes: map['notes'] as String?,
      );
}














// class UserHistModel implements BaseDBModel {
//   @override
//   final int id;
//   final String exercisesJson; 
//   final String date;
//   final bool isDone;
//   final String? notes;

//   UserHistModel({
//     required this.id,
//     required this.date,
//     required this.exercisesJson,
//     this.isDone = false,
//     this.notes,
//   });

//   factory UserHistModel.fromMap(Map<String, dynamic> map) =>
//       _$UserHistModelFromMap(map);

//   @override
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'workout_id': id,
//       'exercises_json': exercisesJson,
//       'date': date,
//       'isDone': isDone ? 1 : 0,
//       'notes': notes,
//     };
//   }

//   static UserHistModel _$UserHistModelFromMap(Map<String, dynamic> map) =>
//       UserHistModel(
//         id: map['workout_id'] as int,
//         exercisesJson: map['exercises_json'] as String,
//         date: map['date'] as String,
//         isDone: (map['isDone'] as int) == 1,
//         notes: map['notes'] as String?,
//       );
// }













  // // Из доменной модели в DTO
  // static UserHistModel fromWorkout(Workout workout) {
  //   return UserHistModel(
  //     id: workout.id,
  //     date: workout.date.toIso8601String().split('T')[0],
  //     exercisesJson: _serializeExercises(workout.exercises),
  //     isDone: workout.isCompleted,
  //     notes: workout.notes,
  //   );
  // }

  // // Из DTO в доменную модель (требует маппинг упражнений)
  // Workout toWorkout({Map<int, Exercise>? exerciseMap}) {
  //   final exercises = _deserializeExercises(exercisesJson, exerciseMap);
  //   return Workout(
  //     id: id,
  //     date: DateTime.parse(date),
  //     exercises: exercises,
  //     isCompleted: isDone,
  //     notes: notes,
  //   );
  // }

  // СЕРИАЛИЗАЦИЯ: Сохраняем ТОЛЬКО ID упражнений и данные сетов
  // static String _serializeExercises(List<ExercisePerformance> exercises) {
  //   final List<Map<String, dynamic>> jsonList = exercises.map((e) {
  //     return {
  //       'exerciseId': e.exerciseId,
  //       'category': e.exercise.category.name,
  //       'equipment': e.exercise.equipment.name,
  //       'sets': _serializeSets(e.sets),
  //     };
  //   }).toList();

  //   return jsonEncode(jsonList);
  // }

  // static List<Map<String, dynamic>> _serializeSets(List<SetData> sets) {
  //   return sets.map((set) {
  //     final map = <String, dynamic>{};
  //     if (set.weight != null) map['w'] = set.weight;
  //     if (set.reps != null) map['r'] = set.reps;
  //     if (set.duration != null) map['d'] = set.duration;
  //     return map;
  //   }).toList();
  // }

  // ДЕСЕРИАЛИЗАЦИЯ: Восстанавливаем упражнения из ID + данных
  // static List<ExercisePerformance> _deserializeExercises(
  //   String json,
  //   Map<int, Exercise>? exerciseMap,
  // ) {
  //   if (json.isEmpty) return [];

  //   final List<dynamic> jsonList = jsonDecode(json);

  //   return jsonList.map((item) {
  //     final exerciseId = item['exerciseId'] as int;
  //     final setsJson = item['sets'] as List<dynamic>;

  //     // Получаем Exercise из маппинга или создаем временный
  //     Exercise exercise;
  //     if (exerciseMap != null && exerciseMap.containsKey(exerciseId)) {
  //       exercise = exerciseMap[exerciseId]!;
  //     } else {
  //       // Заглушка для случаев, когда маппинг не предоставлен
  //       final category = _parseCategory(item['category'] as String?);
  //       final equipment = _parseEquipment(item['equipment'] as String?);

  //       exercise = Exercise(
  //         id: exerciseId,
  //         name: 'Exercise #$exerciseId',
  //         level: 1,
  //         category: category,
  //         equipment: equipment,
  //         description: '',
  //         muscle: '',
  //         secondaryMuscle: '',
  //       );
  //     }

  //     final sets = _deserializeSets(setsJson);

  //     return ExercisePerformance.create(exercise: exercise, sets: sets);
  //   }).toList();
  // }

  // static List<SetData> _deserializeSets(List<dynamic> setsJson) {
  //   return setsJson.map((setJson) {
  //     return SetData(
  //       weight: setJson['w'] as double?,
  //       reps: setJson['r'] as int?,
  //       duration: setJson['d'] as double?,
  //     );
  //   }).toList();
  // }

  // static ExerciseCategory _parseCategory(String? category) {
  //   if (category == null) return ExerciseCategory.strength;
  //   try {
  //     return ExerciseCategory.values.firstWhere((e) => e.name == category);
  //   } catch (_) {
  //     return ExerciseCategory.strength;
  //   }
  // }

  // static Equipment _parseEquipment(String? equipment) {
  //   if (equipment == null) return Equipment.other;
  //   return Equipment.fromString(equipment);
  // }

// class UserHistModel implements BaseDBModel {
//   @override
//   final int id;
//   final String muscleGroup;
//   final String exercisesJson;
//   final String date;
//   final bool isDone;
//   final String? notes;

//   UserHistModel({
//     required this.id,
//     required this.date,
//     required this.exercisesJson,
//     required this.muscleGroup,
//     this.isDone = false,
//     this.notes,
//   });

//   factory UserHistModel.fromMap(Map<String, dynamic> map) =>
//       _$UserHistModelFromMap(map);

//   @override
//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'workout_id': id,
//       'muscle_group': muscleGroup,
//       'exercises_json': exercisesJson,
//       'date': date,
//       'isDone': isDone ? 1 : 0,
//       'notes': notes,
//     };
//   }

//   static UserHistModel fromWorkout(Workout workout) {
//     final exercisesJson = _serializeExercises(workout.exercises);
//     return UserHistModel(
//       id: workout.id,
//       date: workout.date.toIso8601String().split('T')[0],
//       exercisesJson: exercisesJson,
//       muscleGroup: workout.primaryMuscleGroup,
//       isDone: workout.isCompleted,
//       notes: workout.notes,
//     );
//   }

//   Workout toWorkout() {
//     final exercises = _deserializeExercises(exercisesJson);
//     return Workout(
//       id: id,
//       date: DateTime.parse(date),
//       exercises: exercises,
//       isCompleted: isDone,
//       notes: notes,
//     );
//   }

//   static String _serializeExercises(List<ExercisePerformance> exercises) {
//     final List<Map<String, dynamic>> jsonList = exercises.map((e) {
//       var map = <String, dynamic>{'exerciseId': e.exerciseId, 'sets': e.sets};

//       if (e is WeightedExercisePerformance) {
//         map['type'] = 'weighted';
//         map['weights'] = e.weights;
//         map['reps'] = e.reps;
//       } else if (e is BodyweightExercisePerformance) {
//         map['type'] = 'bodyweight';
//         map['reps'] = e.reps;
//       } else if (e is DurationExercisePerformance) {
//         map['type'] = 'duration';
//         map['durations'] = e.durations;
//       }

//       return map;
//     }).toList();

//     return jsonEncode(jsonList);
//   }

//   static List<ExercisePerformance> _deserializeExercises(String json) {
//     if (json.isEmpty) return [];

//     final List<dynamic> jsonList = jsonDecode(json);

//     return jsonList.map((item) {
//       final exerciseId = item['exerciseId'] as int;
//       final sets = item['sets'] as int;
//       final type = item['type'] as String;

//       switch (type) {
//         case 'weighted':
//           return WeightedExercisePerformance(
//             exerciseId: exerciseId,
//             sets: sets,
//             weights: List<double>.from(
//               item['weights'].map((w) => (w as num).toDouble()),
//             ),
//             reps: List<int>.from(item['reps']),
//           );
//         case 'bodyweight':
//           return BodyweightExercisePerformance(
//             exerciseId: exerciseId,
//             sets: sets,
//             reps: List<int>.from(item['reps']),
//           );
//         case 'duration':
//           return DurationExercisePerformance(
//             exerciseId: exerciseId,
//             sets: sets,
//             durations: List<double>.from(
//               item['durations'].map((d) => (d as num).toDouble()),
//             ),
//           );
//         default:
//           throw Exception('Unknown exercise type: $type');
//       }
//     }).toList();
//   }

//   static UserHistModel _$UserHistModelFromMap(Map<String, dynamic> map) =>
//       UserHistModel(
//         id: map['workout_id'] as int,
//         muscleGroup: map['muscle_group'] as String,
//         exercisesJson: map['exercises_json'] as String,
//         date: map['date'] as String,
//         isDone: (map['isDone'] as int) == 1,
//         notes: map['notes'] as String?,
//       );
// }
