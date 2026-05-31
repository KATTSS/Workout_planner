import 'package:workout_planner/Features/Domain/Entities/user.dart';
import 'package:workout_planner/Features/Data/Models/user_model.dart';

class UserProcessor {
  User fromModel(UserModel model) {
    return User(
      weight: model.weight,
      height: model.height,
      name: model.name,
      sex: model.sex,
    );
  }

  UserModel toModel(User user) {
    return UserModel(
      id: 1,
      name: user.name,
      sex: user.sex,
      height: user.height,
      weight: user.weight,
    );
  }
}
