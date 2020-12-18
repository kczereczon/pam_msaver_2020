import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pam_2020_msaver/models/CategoryModel.dart';
import 'package:pam_2020_msaver/models/OutcomeModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:async';

class SqliteDatabase {
  static Database _database;

  SqliteDatabase._();
  static final SqliteDatabase db = SqliteDatabase._();

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "outcomes.db");
    print(path);
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE categories ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "color TEXT"
          ")");
      await db.execute("CREATE TABLE outcomes ("
          "id INTEGER PRIMARY KEY,"
          "name TEXT,"
          "value TEXT,"
          "category_id INTEGER,"
          "datetime DATETIME,"
          "FOREIGN KEY(category_id) REFERENCES categories(id)"
          ")");
    });
  }

  getCategory(int id) async {
    final db = await database;
    var res = await db.query("categories", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty
        ? CategoryModel(
            id: res.first['id'], name: res.first['name'], color: Colors.red)
        : Null;
  }

  insertCategory(CategoryModel newClient) async {
    final db = await database;
    var res = await db.insert("categories", newClient.toMap());
    return res;
  }

  getAllCategories() async {
    final db = await database;
    var res = await db.query("categories");
    List<CategoryModel> list = res.isNotEmpty
        ? res
            .map((c) =>
                CategoryModel(color: c['color'], id: c['id'], name: c['name']))
            .toList()
        : [];
    return list;
  }

  insertOutcome(OutcomeModel outcome) async {
    final db = await database;
    var res = await db.insert("outcomes", outcome.toMap());
    return res;
  }

  Future<List<OutcomeModel>> getAllOutcomes() async {
    final db = await database;
    var res = await db.query("outcomes");
    print(res);
    List<OutcomeModel> list = res.isNotEmpty
        ? res
            .map((c) => OutcomeModel(
                value: double.parse(c['value']),
                id: c['id'],
                name: c['name'],
                dateTime: DateTime.parse(c['datetime'])))
            .toList()
        : [];
    return list;
  }
}