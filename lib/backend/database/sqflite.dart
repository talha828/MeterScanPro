import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/backend/model/CustomerMeterRecordModel.dart';
import 'package:meter_scan/backend/model/UserModel.dart';
import 'package:meter_scan/view/main_screen/main_screen.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

        await db.execute('''
          CREATE TABLE customer_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_name TEXT,
            customer_id TEXT,
            meter_reading REAL,
            meter_image TEXT,
            date_string TEXT,
            line_id INTEGER,
            timestamp TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE line_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            line_name TEXT,
            meter_reading REAL,
            meter_image TEXT,
            date_string TEXT,
            line_id INTEGER,
            timestamp TEXT
          )
        ''');

        await db.execute('''
      CREATE TABLE users(
        cmuser_app_id INTEGER PRIMARY KEY,
        full_name TEXT,
        user_name TEXT,
        password TEXT,
        status TEXT
      )
    ''');
        await db.execute(
          '''
          CREATE TABLE customer_line_data(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            LineID INTEGER,
            MeterNumber TEXT,
            ReadingDate TEXT,
            CurrentReading INTEGER,
            CustID INTEGER,
            ImageName TEXT,
            MimeType TEXT,
            ImageSize INTEGER,
            Latitude TEXT,
            Longitude TEXT,
            CapturedBy TEXT,
            CapturedOn TEXT,
            SyncBy TEXT,
            SyncOn TEXT,
            body TEXT
          )
          ''',
        );
      },
    );
  }

  static Future<void> insertCustomerMaster(
      CustomerMaster customerMaster) async {
    final db = await database;
    await db.insert(
      'customer_master',
      customerMaster.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertCustomerDetail(
      CustomerDetail customerDetail) async {
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
      customerMaster:
          customerMasterList.map((e) => CustomerMaster.fromJson(e)).toList(),
      customerDetail:
          customerDetailList.map((e) => CustomerDetail.fromJson(e)).toList(),
      lineMaster: lineMasterList.map((e) => LineMaster.fromJson(e)).toList(),
      lineDetail: lineDetailList.map((e) => LineDetail.fromJson(e)).toList(),
    );
  }

  static Future<void> insertCustomerRecord(CustomerMeterRecordModel record) async {
    final db = await database;
    await db.insert(
      'customer_line_data',
      record.toMap(),
    );
  }

  static Future<int> insertLineRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert("line_records", record);
  }

  static Future<void> insertAllUsers(List<UserModel> users) async {
    final db = await database;
    final batch = db.batch();

    for (var user in users) {
      batch.insert('users', user.toJson());
    }

    await batch.commit();
  }

  static Future<void> getUser(
      String? userName, String? password, bool check, var indicator) async {
    if (userName!.isNotEmpty) {
      if (password!.isNotEmpty || password.length > 20 ) {
        indicator(true);
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query('users',
            where: 'user_name = ? AND password = ?',
            whereArgs: [userName, password]);

        if (maps.isNotEmpty) {
          if (check) {
            SharedPreferences prefer = await SharedPreferences.getInstance();
            prefer.setString("username", userName);
            prefer.setString("password", password);
            indicator(false);
            Get.to(const MainScreen());
          } else {
            indicator(false);
            Get.to(const MainScreen());
          }
        } else {
          indicator(false);
          Get.snackbar(
              "Authentication fail", "Please check your username or password");
        }
      } else {
        indicator(false);
        Get.snackbar("Incorrect Password", "Please enter your correct password");
      }
    } else {
      indicator(false);
      Get.snackbar("userName Not Found", "Please Enter your userName");
    }
  }
  static Future<bool> doesRecordExistForToday(int custId, String meterNo) async {
    final db = await database;

    // Get the current date in the same format as readingDate in the database
    final currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    // Query the database to check if a record with the given custId, meterNo, and today's date exists
    final result = await db.query(
      'customer_line_data',
      where: 'CustID = ? AND MeterNumber = ? AND ReadingDate = ?',
      whereArgs: [custId, meterNo, currentDate],
    );

    // If the result is not empty, a matching record exists
    return result.isNotEmpty;
  }
  static Future<void> printCustomerLineData() async {
    final db = await database;

    // Query the entire "customer_line_data" table
    final List<Map<String, dynamic>> records = await db.query('customer_line_data');

    // Print each record to the console
    for (var record in records) {
      print(record);
    }
  }
  static Future<CustomerMeterRecordModel?> loadRecordByMeterAndCustID(String meterNo, int custID) async {
    final db = await database;
    final currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // Query the database to check if a record with the given meterNo and custID exists
    final List<Map<String, dynamic>> result = await db.query(
      'customer_line_data',
      where: 'CustID = ? AND MeterNumber = ? AND ReadingDate = ?',
      whereArgs: [custID, meterNo, currentDate],
    );


    if (result.isNotEmpty) {
      // If a matching record is found, load it into a CustomerMeterRecordModel
      final recordData = result.first;
      final record = CustomerMeterRecordModel(
        lineID: recordData['LineID'],
        meterNumber: recordData['MeterNumber'],
        readingDate: recordData['ReadingDate'],
        currentReading: recordData['CurrentReading'],
        custID: recordData['CustID'],
        imageName: recordData['ImageName'],
        mimeType: recordData['MimeType'],
        imageSize: recordData['ImageSize'],
        latitude: recordData['Latitude'],
        longitude: recordData['Longitude'],
        capturedBy: recordData['CapturedBy'],
        capturedOn: recordData['CapturedOn'],
        syncBy: recordData['SyncBy'],
        syncOn: recordData['SyncOn'],
        body: recordData['body'], // You may need to convert this based on your data storage method
      );
      return record;
    } else {
      // If no matching record is found, return null
      return null;
    }
  }
}
