import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:workout_planner/Features/Data/Models/user_hist_models.dart';
import 'package:workout_planner/Features/Data/Repository/user_hist_factory.dart';
import 'package:workout_planner/Features/Data/Models/base_db_model.dart';

class UserHistDb {
  UserHistDb._();
  static final UserHistDb instance = UserHistDb._();
  static late Database _db;
  static bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'db_v1.0.2.db');
      _db = await openDatabase(path, version: 1, onCreate: _createDB);
      _isInitialized = true;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    final dbInitScript = await rootBundle.loadString('assets/db_init.sql');

    for (final element in dbInitScript.split(';')) {
      final trimmed = element.trim();
      if (trimmed.isEmpty) continue;
      await db.execute(trimmed);
    }
  }

  String _dbName(Type type) {
    if (type == UserHistModel) {
      return 't_UserHistoryItem';
    }
    throw Exception('Unsupported DB model type: $type');
  }

  Future<int> insert<T extends BaseDBModel>(T model) async => await _db.insert(
    _dbName(T),
    model.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  Future<T?> get<T extends BaseDBModel>(
    dynamic id, {
    String idColumn = 'workout_id',
  }) async {
    final res = await _db.query(
      _dbName(T),
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    return res.isNotEmpty ? dbFactories[T]!(res.first) as T : null;
  }
  // Future<T?> get<T extends BaseDBModel>(dynamic id) async {
  //   final res = await _db.query(
  //     _dbName(T),
  //     where: 'workout_id = ?',
  //     whereArgs: [id],
  //   );
  //   return res.isNotEmpty ? dbFactories[T]!(res.first) as T : null;
  // }

  Future<int> update<T extends BaseDBModel>(T model) async => _db.update(
    _dbName(T),
    model.toMap(),
    where: 'workout_id = ?',
    whereArgs: [model.id],
  );

  Future<int> delete<T extends BaseDBModel>(dynamic id) async =>
      _db.delete(_dbName(T), where: 'workout_id = ?', whereArgs: [id]);
}
