import 'equipment.dart' show Equipment;

class Excercise {
  int id;
  String name;
  int level;
  String description;
  String muscle;
  String secondaryMuscle;

  Excercise(
    this.id,
    this.name,
    this.level, {
    this.description = "",
    this.muscle = "",
    this.secondaryMuscle = "",
  });

  Excercise.basic(this.id, this.name, this.level)
    : description = "",
      muscle = "",
      secondaryMuscle = "";

  Excercise.descripted(this.id, this.name, this.level, this.description)
    : muscle = "",
      secondaryMuscle = "";

  Excercise.full(
    this.id,
    this.name,
    this.level,
    this.description,
    this.muscle,
    this.secondaryMuscle,
  );

  @override
  String toString() {
    return "$id, $name, $level, $description, $muscle, $secondaryMuscle";
  }
}

class DurationableExcercise extends Excercise {
  double duration = 0.0;
  DurationableExcercise(int id, String name, int level, this.duration)
    : super(id, name, level);
}

class RepeatableExcercise extends Excercise {
  int reps = 0;
  int rounds = 0;
  RepeatableExcercise(int id, String name, int level, this.reps, this.rounds)
    : super(id, name, level);
}

mixin Equipmentable {
  late Equipment equipment;
}

class RepeatableEquipmentableExcercise extends RepeatableExcercise
    with Equipmentable {
  RepeatableEquipmentableExcercise(
    int id,
    String name,
    int level,
    int reps,
    int rounds,
    Equipment equipment,
  ) : super(id, name, level, reps, rounds) {
    this.equipment = equipment;
  }
}

class DurationableEquipmentableExcercise extends DurationableExcercise
    with Equipmentable {
  DurationableEquipmentableExcercise(
    int id,
    String name,
    int level,
    double duration,
    Equipment equipment,
  ) : super(id, name, level, duration) {
    this.equipment = equipment;
  }
}

// class EquipmentableExcercise {
//   final Excercise excercise;
//   final Equipment equipment;

//   EquipmentableExcercise(this.excercise, this.equipment);

//   int get id => excercise.id;
//   int get level => excercise.level;
//   String get description => excercise.description;
// }
