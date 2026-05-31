class UserModel {
  final int id;
  final String name;
  final int sex;
  final double height;
  final double weight;

  UserModel({
    required this.id,
    required this.name,
    required this.sex,
    required this.height,
    required this.weight,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] ?? 1) as int,
      name: (map['name'] ?? 'Undefined') as String,
      sex: (map['sex'] ?? 0) as int,
      height: ((map['height'] ?? 0) as num).toDouble(),
      weight: ((map['weight'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sex': sex,
      'height': height,
      'weight': weight,
    };
  }
}
