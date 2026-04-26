import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

class ExcerciseDb {
  static ExcerciseDb? _instance;
  static ExcerciseDb get instance {
    _instance ??= ExcerciseDb._(
      assetPath: 'assets/databases/excercise_data.db',
    );
    return _instance!;
  }

  static Database? _db;
  final String _assetPath;
  static bool _isInitializing = false;

  ExcerciseDb._({required String assetPath}) : _assetPath = assetPath;

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
      _db = await _initDatabase();
      return _db!;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Database> _initDatabase() async {
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

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>?> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    final result = await db.rawQuery(sql, arguments);
    return result.isNotEmpty ? result.first : null;
  }

  void dispose() {
    _db?.close();
    _db = null;
    _instance = null;
  }
}
//   ExcerciseDb._();
//   static final ExcerciseDb instance = ExcerciseDb._();
//   static late Database _db;
//   static bool _isInitialized = false;

//   Future<void> init() async {
//     if (!_isInitialized) {
//       final databasePath = await getDatabasesPath();
//       final path = join(databasePath, 'exercises.db');

//       final exists = await databaseExists(path);
//       if (!exists) {
//
//       final data = await rootBundle.load(_assetPath);
//       final bytes = data.buffer.asUint8List();
//       await File(path).writeAsBytes(bytes);
//     }
//       _db = await openDatabase(path, version: 1, onCreate: _createDB);
//       _isInitialized = true;
//     }
//   }

//   Future<void> _createDB(Database db, int version) async {
//     final dbInitScript = await rootBundle.loadString('assets/db_init.sql');

//     for (final element in dbInitScript.split(';')) {
//       final trimmed = element.trim();
//       if (trimmed.isEmpty) continue;
//       await db.execute(trimmed);
//     }
//   }

//   String _dbName(Type type) {
//     if (type == UserHistModel) {
//       return 'UserHistoryItem';
//     }
//     throw Exception('Unsupported DB model type: $type');
//   }

// }
