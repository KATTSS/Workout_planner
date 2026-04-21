// import 'equipment.dart' show Equipment;

class Excercise {
  int id;
  String name;
  int level;
  String category;
  String equipment;
  String description;
  String muscle;
  String secondaryMuscle;

  Excercise(
    this.id,
    this.name,
    this.level,
    this.category,
    this.equipment,
    this.description,
    this.muscle,
    this.secondaryMuscle,
  );

  @override
  String toString() {
    return "$id, $name, $level, $description, $muscle, $secondaryMuscle";
  }

  Excercise copyWith({
    int? id,
    String? name,
    int? level,
    String? category,
    String? equipment,
    String? description,
    String? primaryMuscle,
    String? secondaryMuscle,
  }) {
    return Excercise(
      id ?? this.id,
      name ?? this.name,
      level ?? this.level,
      category ?? this.category,
      equipment ?? this.equipment,
      description ?? this.description,
      primaryMuscle ?? this.muscle,
      secondaryMuscle ?? this.secondaryMuscle,
    );
  }
}

mixin Weight {
  late double mass;
}

class WieghtedExcercise extends Excercise with Weight {
  WieghtedExcercise(
    int id,
    String name,
    int level,
    String category,
    String equipment,
    String description,
    String muscle,
    String secondaryMuscle,
    double mass,
  ) : super(
        id,
        name,
        level,
        category,
        equipment,
        description,
        muscle,
        secondaryMuscle,
      ) {
    this.mass = mass;
  }
}

// class DurationableExcercise extends Excercise {
//   double duration = 0.0;
//   DurationableExcercise(int id, String name, int level, this.duration)
//     : super(id, name, level);
// }

// class RepeatableExcercise extends Excercise {
//   int reps = 0;
//   int rounds = 0;
//   RepeatableExcercise(int id, String name, int level, this.reps, this.rounds)
//     : super(id, name, level);
// }

// mixin Equipmentable {
//   late Equipment equipment;
// }

// class RepeatableEquipmentableExcercise extends RepeatableExcercise
//     with Equipmentable {
//   RepeatableEquipmentableExcercise(
//     int id,
//     String name,
//     int level,
//     int reps,
//     int rounds,
//     Equipment equipment,
//   ) : super(id, name, level, reps, rounds) {
//     this.equipment = equipment;
//   }
// }

// class DurationableEquipmentableExcercise extends DurationableExcercise
//     with Equipmentable {
//   DurationableEquipmentableExcercise(
//     int id,
//     String name,
//     int level,
//     double duration,
//     Equipment equipment,
//   ) : super(id, name, level, duration) {
//     this.equipment = equipment;
//   }
// }
