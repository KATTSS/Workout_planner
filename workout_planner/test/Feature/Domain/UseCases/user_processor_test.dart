import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/Features/Domain/Entities/user.dart';
import 'package:workout_planner/Features/Data/Models/user_model.dart';
import 'package:workout_planner/Features/Domain/UseCases/user_processor.dart';

void main() {
  late UserProcessor processor;

  setUp(() {
    processor = UserProcessor();
  });

  group('UserProcessor', () {
    group('fromModel', () {
      test('should convert UserModel to User correctly', () {
        final model = UserModel(
          id: 1,
          name: 'John Doe',
          sex: 1,
          height: 1.75,
          weight: 75.5,
        );

        final user = processor.fromModel(model);

        expect(user.name, 'John Doe');
        expect(user.sex, 1);
        expect(user.height, 1.75);
        expect(user.weight, 75.5);
      });

      test('should preserve all data from UserModel', () {
        final model = UserModel(
          id: 1,
          name: 'Jane Smith',
          sex: -1,
          height: 1.65,
          weight: 60.0,
        );

        final user = processor.fromModel(model);

        expect(user.name, 'Jane Smith');
        expect(user.sex, -1);
        expect(user.height, 1.65);
        expect(user.weight, 60.0);
      });

      test('should handle unspecified sex (0)', () {
        final model = UserModel(
          id: 1,
          name: 'Unknown',
          sex: 0,
          height: 1.7,
          weight: 70.0,
        );

        final user = processor.fromModel(model);

        expect(user.sex, 0);
      });

      test('should handle decimal values correctly', () {
        final model = UserModel(
          id: 1,
          name: 'Precision Test',
          sex: 1,
          height: 1.73,
          weight: 73.45,
        );

        final user = processor.fromModel(model);

        expect(user.height, 1.73);
        expect(user.weight, 73.45);
      });
    });

    group('toModel', () {
      test('should convert User to UserModel correctly', () {
        final user = User(name: 'John Doe', sex: 1, height: 1.75, weight: 75.5);

        final model = processor.toModel(user);

        expect(model.id, 1);
        expect(model.name, 'John Doe');
        expect(model.sex, 1);
        expect(model.height, 1.75);
        expect(model.weight, 75.5);
      });

      test('should always set id to 1 for single user app', () {
        final user1 = User(name: 'User 1', weight: 70, height: 1.75);
        final user2 = User(name: 'User 2', weight: 80, height: 1.80);

        final model1 = processor.toModel(user1);
        final model2 = processor.toModel(user2);

        expect(model1.id, 1);
        expect(model2.id, 1);
      });

      test('should preserve all User properties', () {
        final user = User(
          name: 'Test User',
          sex: -1,
          height: 1.60,
          weight: 55.0,
        );

        final model = processor.toModel(user);

        expect(model.name, 'Test User');
        expect(model.sex, -1);
        expect(model.height, 1.60);
        expect(model.weight, 55.0);
      });

      test('should handle User with default values', () {
        final user = User();

        final model = processor.toModel(user);

        expect(model.name, 'Undefined');
        expect(model.sex, 0);
        expect(model.height, 0.0);
        expect(model.weight, 0.0);
      });
    });

    group('round-trip conversion', () {
      test('should preserve data in model -> user -> model conversion', () {
        final originalModel = UserModel(
          id: 1,
          name: 'Round Trip Test',
          sex: 1,
          height: 1.78,
          weight: 78.5,
        );

        final user = processor.fromModel(originalModel);
        final convertedModel = processor.toModel(user);

        expect(convertedModel.name, originalModel.name);
        expect(convertedModel.sex, originalModel.sex);
        expect(convertedModel.height, originalModel.height);
        expect(convertedModel.weight, originalModel.weight);
      });

      test('should preserve data in user -> model -> user conversion', () {
        final originalUser = User(
          name: 'Another Round Trip',
          sex: -1,
          height: 1.65,
          weight: 65.0,
        );

        final model = processor.toModel(originalUser);
        final user = processor.fromModel(model);

        expect(user.name, originalUser.name);
        expect(user.sex, originalUser.sex);
        expect(user.height, originalUser.height);
        expect(user.weight, originalUser.weight);
      });
    });

    group('edge cases', () {
      test('should handle empty name', () {
        final model = UserModel(
          id: 1,
          name: '',
          sex: 0,
          height: 1.7,
          weight: 70.0,
        );

        final user = processor.fromModel(model);

        expect(user.name, '');
      });

      test('should handle very small height', () {
        final model = UserModel(
          id: 1,
          name: 'Short',
          sex: 0,
          height: 0.5,
          weight: 50.0,
        );

        final user = processor.fromModel(model);

        expect(user.height, 0.5);
      });

      test('should handle very large weight', () {
        final model = UserModel(
          id: 1,
          name: 'Heavy',
          sex: 0,
          height: 1.8,
          weight: 200.0,
        );

        final user = processor.fromModel(model);

        expect(user.weight, 200.0);
      });

      test('should handle zero values', () {
        final model = UserModel(
          id: 1,
          name: 'Zero Values',
          sex: 0,
          height: 0.0,
          weight: 0.0,
        );

        final user = processor.fromModel(model);

        expect(user.height, 0.0);
        expect(user.weight, 0.0);
      });
    });
  });
}
