import 'equipment.dart' show Equipment;

class Excercise {
  int id;
  int level;
  String description;
  String muscle;
  String secondaryMuscle;

  Excercise(
    this.id,
    this.level, {
    this.description = "",
    this.muscle = "",
    this.secondaryMuscle = "",
  });

  Excercise.basic(this.id, this.level)
    : description = "",
      muscle = "",
      secondaryMuscle = "";

  Excercise.descripted(this.id, this.level, this.description)
    : muscle = "",
      secondaryMuscle = "";

  Excercise.full(
    this.id,
    this.level,
    this.muscle,
    this.secondaryMuscle,
    this.description,
  );
}

class DurationableExcercise extends Excercise {
  double duration = 0.0;
  DurationableExcercise(int id, int level, this.duration) : super(id, level);
}

class RepeatableExcercise extends Excercise {
  int reps = 0;
  int rounds = 0;
  RepeatableExcercise(int id, int level, this.reps, this.rounds)
    : super(id, level);
}

mixin Equipmentable {
  late Equipment equipment;
}

class EquipmentableExcercise {
  final Excercise excercise;
  final Equipment equipment;

  EquipmentableExcercise(this.excercise, this.equipment);

  int get id => excercise.id;
  int get level => excercise.level;
  String get description => excercise.description;
}
