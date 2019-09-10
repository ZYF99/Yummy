
import 'package:flutter_sample/bean/Cost.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableCost = 'costtable';
  final String columnId = 'id';
  final String columnDateTime = 'dateTime';
  final String columnName = 'name';
  final String columnMoney = 'money';


  static Database _db;

  DatabaseHelper.internal();

  Future<Database> get db async {

    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();

    String path = join (databasesPath, 'costtable.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }



  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableCost($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnDateTime INTEGER, $columnName TEXT, $columnMoney DOUBLE)');
  }

  Future<int> saveCost(Cost cost) async {
    var dbClient = await initDb();
    var result = await dbClient.insert(tableCost, cost.toMap());

//    var result = await dbClient.rawInsert(
//    'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');


    return result;
  }

  Future<List> getAllCosts() async {
    var dbClient = await initDb();
    //var result = await dbClient.query(tableCost, columns: [columnId, pointid, image, contractId ,publicationId, pointLng, pointLat]);
    var result = await dbClient.rawQuery('SELECT * FROM $tableCost');
    await dbClient.close();
    return result.toList();
  }


  Future<List> getDayCosts(DateTime dateTime) async {
    var dbClient = await db;
    //var result = await dbClient.query(tableCost, columns: [columnId, pointid, image, contractId ,publicationId, pointLng, pointLat]);
    DateTime today = new DateTime(dateTime.year,dateTime.month,dateTime.day);
    DateTime tomorrow = today.add(new Duration(days: 1));
    int startTime = today.millisecondsSinceEpoch;
    int endTime = tomorrow.millisecondsSinceEpoch;
    var result = await dbClient.rawQuery('SELECT * FROM $tableCost WHERE $columnDateTime > $startTime AND $columnDateTime < $endTime ');
    return result.toList();
  }

  //获取每日消费的金额列表
  Future<List> getDayCostsForTotal(DateTime dateTime) async {
    var dbClient = await db;
    DateTime today = new DateTime(dateTime.year,dateTime.month,dateTime.day);
    DateTime tomorrow = today.add(new Duration(days: 1));
    int startTime = today.millisecondsSinceEpoch;
    int endTime = tomorrow.millisecondsSinceEpoch;
    var result = await dbClient.rawQuery('SELECT $columnMoney FROM $tableCost WHERE $columnDateTime > $startTime AND $columnDateTime < $endTime ');
    return result.toList();
  }

  //获取每月消费的金额列表
  Future<List> getMonthCostsForTotal(DateTime dateTime) async {
    var dbClient = await db;
    DateTime now = dateTime;
    DateTime monthBeginning = DateTime(now.year,now.month,1);
    int startTime = monthBeginning.millisecondsSinceEpoch;
    int endTime = now.millisecondsSinceEpoch;
    var result = await dbClient.rawQuery('SELECT $columnMoney FROM $tableCost WHERE $columnDateTime > $startTime AND $columnDateTime < $endTime ');
    return result.toList();
  }



  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $tableCost'));
  }

  Future<Cost> getCost(int id) async {
    var dbClient = await db;

    var result = await dbClient.rawQuery('SELECT * FROM $tableCost WHERE $columnId = $id');

    if (result.length > 0) {
      return Cost.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteCost(int id) async {
    var dbClient = await db;
    return await dbClient.rawDelete('DELETE FROM $tableCost WHERE $columnId = $id');
  }

/*  Future<int> updateCost(Cost cost) async {
    var dbClient = await db;
    return await dbClient.update(tableCost, cost.toMap(), where: "$columnId = ?", whereArgs: [cost.id]);

    //return await dbClient.rawUpdate(
     //   'UPDATE $tableNote SET $columnTitle = \'${note.title}\', $columnDescription = \'${note.description}\' WHERE $columnId = ${note.id}');
  }*/



  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
