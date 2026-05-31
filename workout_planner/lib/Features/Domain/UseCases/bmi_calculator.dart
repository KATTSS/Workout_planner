class BMICalculator {
  double calculate(double weightKg, double heightMeters) {
    if (heightMeters <= 0) return 0.0;
    return weightKg / (heightMeters * heightMeters);
  }

  String category(double bmi) {
    if (bmi <= 0) return 'unknown';
    if (bmi < 18.5) return 'low';
    if (bmi < 25.0) return 'normal';
    return 'overweight';
  }
}
