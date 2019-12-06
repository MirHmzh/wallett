import 'package:sqflite/sqflite.dart';
import 'dart:async';
//mendukug pemrograman asinkron
import 'dart:io';
//bekerja pada file dan directory
import 'package:path_provider/path_provider.dart';
import 'dbmodel.dart';
//pubspec.yml

//kelass Dbhelper
class DbHelper {
  static DbHelper _dbHelper;
  static Database _database;

  DbHelper._createObject();

  factory DbHelper() {
    if (_dbHelper == null) {
      _dbHelper = DbHelper._createObject();
    }
    return _dbHelper;
  }

  Future<Database> initDb() async {

  //untuk menentukan nama database dan lokasi yg dibuat
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'wallett.db';

   //create, read databases
    var todoDatabase = openDatabase(path, version: 1, onCreate: _createDb);

    //mengembalikan nilai object sebagai hasil dari fungsinya
    return todoDatabase;
  }

    //buat tabel baru dengan nama contact
  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount TEXT,
        desc TEXT,
        income INTEGER,
        date DATE
      )
    ''');
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDb();
    }
    return _database;
  }

  Future<List<Map<String, dynamic>>> select() async {
    Database db = await this.database;
    // var mapList = await db.query('usage', orderBy: 'name');
    var mapList = await db.query('usage');
    return mapList;
  }

  Future<List<Map<String, dynamic>>> selectMonth(String date) async {
    Database db = await this.database;
    // var mapList = await db.query('usage', orderBy: 'name');
    var mapList = await db.rawQuery("SELECT * FROM usage WHERE strftime('%Y-%m', date) = '"+date+"'");
    return mapList;
  }

//create databases
  Future<int> insert(Money object) async {
    Database db = await this.database;
    int count = await db.insert('usage', object.toMap());
    return count;
  }
//update databases
  Future<int> update(Money object) async {
    Database db = await this.database;
    print(object.id);
    int count = await db.update('usage', object.toMap(),
                                where: 'id=?',
                                whereArgs: [object.id]);
    return count;
  }

//delete databases
  Future<int> delete(int id) async {
    Database db = await this.database;
    int count = await db.delete('usage',
                                where: 'id=?',
                                whereArgs: [id]);
    return count;
  }

  Future<List<Money>> getUsageList() async {
    var usageList = await select();
    int count = usageList.length;
    List<Money> usages = List<Money>();
    for (int i=0; i<count; i++) {
      usages.add(Money.fromMap(usageList[i]));
    }
    print(usages);
    return usages;
  }

  Future<List<Money>> getMonthList(String date) async {
    var contactMapList = await selectMonth(date);
    int count = contactMapList.length;
    List<Money> contactList = List<Money>();
    for (int i=0; i<count; i++) {
      contactList.add(Money.fromMap(contactMapList[i]));
    }
    return contactList;
  }

  Future<List<Money>> getMoneyList() async {
    var contactMapList = await select();
    int count = contactMapList.length;
    List<Money> contactList = List<Money>();
    for (int i=0; i<count; i++) {
      contactList.add(Money.fromMap(contactMapList[i]));
    }
    return contactList;
  }

}