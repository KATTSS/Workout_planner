import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Data/Service/local_user_data_source.dart';
import 'package:workout_planner/Features/Data/Service/ilocal_user_data_source.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';
import 'package:workout_planner/Features/Domain/UseCases/bmi_calculator.dart';
import 'package:workout_planner/Features/Domain/UseCases/user_processor.dart';
import 'package:workout_planner/Features/Domain/Entities/user.dart';

class UserViewModel extends ChangeNotifier {
  final Ref _ref;
  final BMICalculator _bmiCalc = BMICalculator();
  final UserProcessor _processor = UserProcessor();

  User? user;
  String bmiCategory = 'unknown';
  double bmiValue = 0.0;
  String? nameError;
  String? heightError;
  String? weightError;

  UserViewModel(this._ref);

  ILocalUserDataSource get _dataSource =>
      _ref.read(localUserDataSourceProvider);

  Future<void> loadUser() async {
    final model = await _dataSource.getUser();
    if (model != null) {
      user = _processor.fromModel(model);
      _recalcBmi();
      notifyListeners();
    } else {
      user = User();
      notifyListeners();
    }
  }

  void updateName(String v) {
    user?.updateName(v);
    nameError = null;
    notifyListeners();
  }

  void updateHeight(double v) {
    user?.updateHeight(v);
    _validateHeight(v);
    _recalcBmi();
    notifyListeners();
  }

  void updateWeight(double v) {
    user?.updateWeight(v);
    _validateWeight(v);
    _recalcBmi();
    notifyListeners();
  }

  void updateSex(int v) {
    user?.updateSex(v);
    notifyListeners();
  }

  bool _validateHeight(double v) {
    if (v <= 0 || v > 2.5) {
      heightError = 'Height must be >0 and <=2.5 m';
      return false;
    }
    heightError = null;
    return true;
  }

  bool _validateWeight(double v) {
    if (v <= 0) {
      weightError = 'Weight must be > 0';
      return false;
    }
    weightError = null;
    return true;
  }

  bool validateAll() {
    if (user == null) return false;
    final hOk = _validateHeight(user!.height);
    final wOk = _validateWeight(user!.weight);
    notifyListeners();
    return hOk && wOk;
  }

  Future<bool> save() async {
    if (user == null) return false;
    if (!validateAll()) return false;
    final model = _processor.toModel(user!);
    await _dataSource.upsertUser(model);
    await _dataSource.insertWeightHistory(
      DateTime.now().toIso8601String(),
      user!.weight,
    );
    return true;
  }

  void _recalcBmi() {
    if (user == null) return;
    bmiValue = _bmiCalc.calculate(user!.weight, user!.height);
    bmiCategory = _bmiCalc.category(bmiValue);
  }
}

final localUserDataSourceProvider = Provider<ILocalUserDataSource>((ref) {
  final db = ref.watch(userHistDbProvider);
  return LocalUserDataSource(db);
});

final userViewModelProvider = ChangeNotifierProvider<UserViewModel>((ref) {
  return UserViewModel(ref);
});
