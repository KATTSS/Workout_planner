import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:workout_planner/Features/Data/Service/query_builder.dart';

class UserHistDb {
  UserHistDb._();
  static final UserHistDb instance = UserHistDb._();
  Database? _db;
  bool _isInitialized = false;

  Future<Database> get database async {
    if (!_isInitialized) {
      await init();
    }
    return _db!;
  }

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

  Future<List<Map<String, dynamic>>> executeQuery(QueryBuilder builder) async {
    final db = await database;
    return db.rawQuery(builder.build(), builder.args);
  }

  Future<Map<String, dynamic>?> executeQuerySingle(QueryBuilder builder) async {
    final results = await executeQuery(builder);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> executeCommand(QueryBuilder builder) async {
    final db = await database;

    switch (builder.type) {
      case QueryType.insert:
        return db.insert(
          builder.build().split(' ')[2], // Extract table name
          builder.values!,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      case QueryType.update:
        return db.update(
          builder.build().split(' ')[1], // Extract table name
          builder.values!,
          where: _extractWhereClause(builder.build()),
          whereArgs: builder.args,
        );
      case QueryType.delete:
        return db.delete(
          builder.build().split(' ')[2], // Extract table name
          where: _extractWhereClause(builder.build()),
          whereArgs: builder.args,
        );
      default:
        throw Exception('Unsupported operation');
    }
  }

  String? _extractWhereClause(String sql) {
    final whereMatch = RegExp(r'WHERE (.+?)(;|$)').firstMatch(sql);
    return whereMatch?.group(1);
  }

  void dispose() {
    _db?.close();
    _db = null;
    _isInitialized = false;
  }
}
