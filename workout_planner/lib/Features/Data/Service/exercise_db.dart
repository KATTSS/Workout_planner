import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:workout_planner/Features/Data/Service/query_builder.dart';

class ExerciseDb {
  static ExerciseDb? _instance;
  static ExerciseDb get instance {
    _instance ??= ExerciseDb._(assetPath: 'assets/databases/excercise_data.db');
    return _instance!;
  }

  Database? _db;
  final String _assetPath;
  bool _isInitializing = false;

  ExerciseDb._({required String assetPath}) : _assetPath = assetPath;

  Future<Database> get database async {
    if (_db != null) return _db!;

    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _db!;
    }

    _isInitializing = true;
    try {
      _db = await _init();
      return _db!;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'exercise_data.db');

    final exists = await databaseExists(path);
    if (!exists) {
      await _copyDatabaseFromAssets(path);
    }

    return await openDatabase(path, readOnly: true, singleInstance: true);
  }

  Future<void> _copyDatabaseFromAssets(String targetPath) async {
    try {
      final data = await rootBundle.load(_assetPath);
      final bytes = data.buffer.asUint8List();

      final dir = Directory(dirname(targetPath));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await File(targetPath).writeAsBytes(bytes);
    } catch (e) {
      throw Exception(
        'Failed to copy database from assets: $e\nPath: $_assetPath',
      );
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

  void dispose() {
    _db?.close();
    _db = null;
    _instance = null;
  }
}
