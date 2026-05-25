import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';

class SetData {
  final double? weight;
  final int? reps;
  final double? duration;

  const SetData({this.weight, this.reps, this.duration});

  bool isValidFor(PerformanceType type) {
    switch (type) {
      case PerformanceType.weighted:
        return weight != null && weight! >= 0 && reps != null && reps! > 0;
      case PerformanceType.bodyweight:
        return reps != null && reps! > 0;
      case PerformanceType.duration:
        return duration != null && duration! > 0;
    }
  }

  // Фабричные конструкторы для разных типов
  factory SetData.weighted({required double weight, required int reps}) {
    return SetData(weight: weight, reps: reps);
  }

  factory SetData.bodyweight({required int reps}) {
    return SetData(reps: reps);
  }

  factory SetData.duration({required double duration}) {
    return SetData(duration: duration);
  }
}
