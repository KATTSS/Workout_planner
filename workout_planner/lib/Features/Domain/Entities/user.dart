class User {
  int _sex = 0;
  double _weight = 0.0;
  double _height = 0.0;
  String _name = "Undefined";

  int get sex => _sex;
  double get weight => _weight;
  double get height => _height;
  String get name => _name;

  User({
    double weight = 0,
    double height = 0,
    String name = "Undefined",
    int sex = 0,
  }) {
    _weight = weight > 0 ? weight : 0.0;
    _height = (height > 0) && (height < 2.5) ? height : 0.0;
    _sex = sex.abs() <= 1 ? sex : 0;
    _name = name;
  }

  void updateWeight(double newWeight) {
    _weight = newWeight > 0 ? newWeight : _weight;
  }

  void updateHeight(double newHeight) {
    _height = newHeight > 0 ? newHeight : _height;
  }

  void updateSex(int sex) {
    _sex = sex.abs() <= 1 ? sex : _sex;
  }

  void updateName(String? newName) {
    _name = newName ?? _name;
  }
}
