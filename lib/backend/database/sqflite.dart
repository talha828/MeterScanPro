import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    // Define the path to your database file.
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'master_details.db');

    // Open the database. You can specify the version and onCreate callback.
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create the necessary tables here.
        await db.execute('''
              CREATE TABLE customer_master (
                customer_id INTEGER PRIMARY KEY,
                customer_name TEXT
              )
              ''');

        await db.execute('''
              CREATE TABLE customer_detail (
                customer_id INTEGER,
                line_id INTEGER,
                line_name TEXT,
                meter_no TEXT,
                meter_type TEXT,
                meter_power INTEGER,
                meter_formula INTEGER,
                rate REAL,
                mvariance TEXT,
                variance_descp INTEGER,
                FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id)
              )
            ''');

        await db.execute('''
              CREATE TABLE line_master (
                line_id INTEGER PRIMARY KEY,
                line_name TEXT
              )
            ''');

        await db.execute('''
              CREATE TABLE line_detail (
                line_id INTEGER,
                meter_id INTEGER,
                meter_name TEXT,
                meter_power INTEGER,
                FOREIGN KEY (line_id) REFERENCES line_master(line_id)
              )
            ''');

        await db.execute('''
              CREATE TABLE save_customer_record (
                line_id INTEGER,
                meter_id INTEGER,
                meter_name TEXT,
                meter_power INTEGER,
                FOREIGN KEY (line_id) REFERENCES line_master(line_id)
              )
            ''');
      },
    );
  }
  static Future<void> insertCustomerMaster(CustomerMaster customerMaster) async {
    final db = await database;
    await db.insert(
      'customer_master',
      customerMaster.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<void> insertCustomerDetail(CustomerDetail customerDetail) async {
    final db = await database;
    await db.insert(
      'customer_detail',
      customerDetail.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<void> insertLineMaster(LineMaster lineMaster) async {
    final db = await database;
    await db.insert(
      'line_master',
      lineMaster.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<void> insertLineDetail(LineDetail lineDetail) async {
    final db = await database;
    await db.insert(
      'line_detail',
      lineDetail.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<CustomerAndLineModel> fetchAllData() async {
    final db = await database;

    final customerMasterList = await db.query('customer_master');
    final customerDetailList = await db.query('customer_detail');
    final lineMasterList = await db.query('line_master');
    final lineDetailList = await db.query('line_detail');

    return CustomerAndLineModel(
      customerMaster: customerMasterList.map((e) => CustomerMaster.fromJson(e)).toList(),
      customerDetail: customerDetailList.map((e) => CustomerDetail.fromJson(e)).toList(),
      lineMaster: lineMasterList.map((e) => LineMaster.fromJson(e)).toList(),
      lineDetail: lineDetailList.map((e) => LineDetail.fromJson(e)).toList(),
    );
  }
}
