import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/Features/Domain/UseCases/bmi_calculator.dart';

void main() {
  late BMICalculator bmiCalculator;

  setUp(() {
    bmiCalculator = BMICalculator();
  });

  group('BMICalculator', () {
    group('calculate', () {
      test('should calculate correct BMI for normal weight person', () {
        // 70kg, 1.75m -> BMI = 70 / (1.75^2) = 70 / 3.0625 ≈ 22.86
        final bmi = bmiCalculator.calculate(70, 1.75);
        expect(bmi, closeTo(22.86, 0.1));
      });

      test('should calculate correct BMI for overweight person', () {
        // 100kg, 1.75m -> BMI = 100 / 3.0625 ≈ 32.65
        final bmi = bmiCalculator.calculate(100, 1.75);
        expect(bmi, closeTo(32.65, 0.1));
      });

      test('should calculate correct BMI for underweight person', () {
        // 50kg, 1.75m -> BMI = 50 / 3.0625 ≈ 16.33
        final bmi = bmiCalculator.calculate(50, 1.75);
        expect(bmi, closeTo(16.33, 0.1));
      });

      test('should return 0 for zero height', () {
        final bmi = bmiCalculator.calculate(70, 0);
        expect(bmi, 0.0);
      });

      test('should return 0 for negative height', () {
        final bmi = bmiCalculator.calculate(70, -1.75);
        expect(bmi, 0.0);
      });

      test('should calculate BMI for very tall person', () {
        // 80kg, 2.0m -> BMI = 80 / 4 = 20
        final bmi = bmiCalculator.calculate(80, 2.0);
        expect(bmi, 20.0);
      });

      test('should calculate BMI for very short person', () {
        // 40kg, 1.5m -> BMI = 40 / 2.25 ≈ 17.78
        final bmi = bmiCalculator.calculate(40, 1.5);
        expect(bmi, closeTo(17.78, 0.1));
      });

      test('should work with decimal weights and heights', () {
        // 65.5kg, 1.68m
        final bmi = bmiCalculator.calculate(65.5, 1.68);
        expect(bmi, greaterThan(0));
      });
    });

    group('category', () {
      test('should return "unknown" for zero or negative BMI', () {
        expect(bmiCalculator.category(0), 'unknown');
        expect(bmiCalculator.category(-5), 'unknown');
      });

      test('should return "low" for BMI < 18.5', () {
        expect(bmiCalculator.category(18.4), 'low');
        expect(bmiCalculator.category(16.0), 'low');
        expect(bmiCalculator.category(17.5), 'low');
      });

      test('should return "normal" for BMI between 18.5 and 25', () {
        expect(bmiCalculator.category(18.5), 'normal');
        expect(bmiCalculator.category(20.0), 'normal');
        expect(bmiCalculator.category(24.9), 'normal');
      });

      test('should return "overweight" for BMI >= 25', () {
        expect(bmiCalculator.category(25.0), 'overweight');
        expect(bmiCalculator.category(30.0), 'overweight');
        expect(bmiCalculator.category(40.0), 'overweight');
      });

      test('should handle boundary values correctly', () {
        expect(bmiCalculator.category(18.49), 'low');
        expect(bmiCalculator.category(18.51), 'normal');
        expect(bmiCalculator.category(24.99), 'normal');
        expect(bmiCalculator.category(25.01), 'overweight');
      });
    });

    group('category with calculate', () {
      test('should return correct category for calculated BMI', () {
        // Test underweight
        final bmiLow = bmiCalculator.calculate(50, 1.75);
        expect(bmiCalculator.category(bmiLow), 'low');

        // Test normal weight
        final bmiNormal = bmiCalculator.calculate(70, 1.75);
        expect(bmiCalculator.category(bmiNormal), 'normal');

        // Test overweight
        final bmiHigh = bmiCalculator.calculate(100, 1.75);
        expect(bmiCalculator.category(bmiHigh), 'overweight');
      });
    });
  });
}
