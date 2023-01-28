import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertest/model/ReportData.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static const _databaseName = "gps_data.sqlite";
  static const _databaseName2 = "gps_data_sqlite.db";
  static const _tableData = "data";

  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();
  static Database? _database;

/*  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  initDatabase() async {
    var databasePath = await getDatabasesPath();
    var path = join(databasePath, "itbook_db.db");
    Sqflite.setDebugModeOn(true);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {}*/

  Future<Database> _initDatabase() async {
    var databaseLocation = await getDatabasesPath();
    var path = join(databaseLocation, _databaseName);
    var exists = await databaseExists(path);

    if (exists) {
      print("Existing database is used");
      Sqflite.setDebugModeOn(true);
      await openDatabase(path);
    } else {
      print("create copy from assets");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      var data = await rootBundle.load(join("assets", _databaseName));
      List<int> bytes = data.buffer.asInt8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await File(path).writeAsBytes(bytes, flush: true);
      print("Copy Success!");
    }
    return await openDatabase(path);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<Map>> select(String table) async {
    var dbClient = await instance.database;
    final rep = await dbClient.query(table);
    return await dbClient.query(table);
  }

  List<ReportData> parseReport(List<Map<String, dynamic>> reportList) {
    final reports = <ReportData>[];
    for (var r in reportList) {
      final report = ReportData.fromJson(r);
      reports.add(report);
    }
    return reports;
  }

  Future<List<ReportData>> readReport() async {
    final db = await instance.database;
    final reportList =
        await db.rawQuery("SELECT * FROM data ORDER BY Date_Time ASC");
    final reports = parseReport(reportList);
    return reports;
  }

  void close() {
    _database?.close();
  }
}
