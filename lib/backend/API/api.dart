import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:meter_scan/backend/getx_model/loading_controller.dart';
import 'dart:io';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/model/CustomerMeterRecordModel.dart';
import 'package:meter_scan/backend/model/LineMeterRecordModel.dart';
import 'package:meter_scan/backend/model/UserModel.dart';
import 'package:meter_scan/view/login_screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view/main_screen/main_screen.dart';

const baseUrl = "http://erp.convexconsulting.com.pk:9999/ords/ws/data";
const masterDetails = "$baseUrl/meter_reading_data/?P_USERNAME=";
const login = "$baseUrl/login/";

class Api {
  Api._();
  static final Dio _dio = Dio();

  static Future<void> collectUserDetails() async {
    final LoadingController loadingController = Get.find<LoadingController>();
    print("===== Call user Data Api =======");
    try {
      final response = await _dio.get(login);
      if (response.statusCode == 200) {
        print("===== SetUp Model =======");
        final List<dynamic> data = response.data['items'];
        List<UserModel> users =
            data.map((json) => UserModel.fromJson(json)).toList();
        SqfliteDatabase.insertAllUsers(users);

        loadingController.toggleFlag(false);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }

  static Future<void> collectMasterDetails() async {
    final LoadingController loadingController = Get.find<LoadingController>();
    try {
      loadingController.toggleFlag(true);
      SharedPreferences prefer = await SharedPreferences.getInstance();
      String? username = prefer.getString("username");
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        try {
          print("===== call Api =======");
          final response = await _dio.get("$masterDetails$username");
          print("====== response status ======");
          print(response.statusCode.toString());
          if (response.statusCode == 200) {
            print("====== Build Model ======");
            final Map<String, dynamic> jsonData = response.data;
            final customerAndLineModel =
                CustomerAndLineModel.fromJson(jsonData);
            print(customerAndLineModel.customerDetail![1].customerId);
            if (customerAndLineModel != null) {
              print("===== data storing =======");
              for (var customerMaster in customerAndLineModel.customerMaster!) {
                SqfliteDatabase.insertCustomerMaster(customerMaster);
              }
              for (var customerDetail in customerAndLineModel.customerDetail!) {
                SqfliteDatabase.insertCustomerDetail(customerDetail);
              }
              for (var lineMaster in customerAndLineModel.lineMaster!) {
                SqfliteDatabase.insertLineMaster(lineMaster);
              }
              for (var lineDetail in customerAndLineModel.lineDetail!) {
                SqfliteDatabase.insertLineDetail(lineDetail);
              }
              print("===== data storing completed =======");
              Get.to(const MainScreen());
            }
          } else {
            loadingController.toggleFlag(false);
            throw Exception('Failed to load data');
          }
        } catch (e) {
          loadingController.toggleFlag(false);
          Get.snackbar(
            "Something Went Wrong",
            "At the moment, the app is unable to retrieve data from the API. Please consider trying again later.",
            snackPosition: SnackPosition.TOP,
          );
          loadingController.toggleFlag(false);
          rethrow; // Rethrow the exception to propagate it up the call stack.
        }
      }
    } on SocketException catch (_) {
      loadingController.toggleFlag(false);
      Get.snackbar(
        "Internet is Not Available",
        "Currently, your app is not connected to the internet. Please establish an internet connection and then attempt the task again.",
        snackPosition: SnackPosition.TOP,
      );
      print('not connected');
    }
  }

  static Future<void> postLineMeterReadings(
      List<LineMeterRecordModel> records) async {
    for (var record in records) {
      bool success = await _postSingleLineRecord(record);

      if (!success) {
        // Stop posting if there is an API error
        print('API Error. Stopping further posts.');
        break;
      }
    }
  }

  static Future<void> postMeterReadings(
      List<CustomerMeterRecordModel> records) async {
    for (var record in records) {
      bool success = await _postSingleRecord(record);

      if (!success) {
        // Stop posting if there is an API error
        print('API Error. Stopping further posts.');
        break;
      }
    }
  }
  static Future<bool> _postSingleRecord(CustomerMeterRecordModel record) async {
    final data = dio.FormData();

    // Create options with custom headers
    final options = dio.Options(headers: {
      'LineID': record.lineID,
      'MeterNumber': record.meterNumber,
      'ReadingDate': record.readingDate,
      'CurrentReading': record.currentReading,
      'CustID': record.custID,
      'ImageName': record.imageName,
      'MimeType': record.mimeType,
      'ImageSize': getImageSizeInKB(record.body),
      'Latitude': record.latitude,
      'Longitude': record.longitude,
      'CapturedBy': record.capturedBy,
      'CapturedOn': record.readingDate,
      'SyncBy': record.syncBy,
    });
    data.files.add(
      MapEntry(
        'body',
        dio.MultipartFile.fromBytes(base64Decode(record.body),
            filename: '${record.imageName}.jpg'),
      ),
    );

    try {
      var results = await _dio.post('$baseUrl/set_meter_reading/',
          data: data, options: options);
      print(results.data);
      print('Record posted successfully: ${record.lineID}');

      // Remove the record from the database on success
      await SqfliteDatabase.deleteRecordFromDatabase(record.custID,record.meterNumber);

      return true; // Success
    } catch (e) {
      Get.snackbar("Server Error", e.toString());
      return false; // Failure
    }
  }
  static Future<bool> _postSingleLineRecord(LineMeterRecordModel record) async {
    final data = dio.FormData();

    // Create options with custom headers
    final options = dio.Options(headers: {
      'LineID': record.lineID,
      'MeterNumber': record.meterNumber,
      'ReadingDate': record.readingDate,
      'CurrentReading': record.currentReading,
      'ImageName': record.imageName,
      'MimeType': record.mimeType,
      'ImageSize': getImageSizeInKB(record.body),
      'Latitude': record.latitude,
      'Longitude': record.longitude,
      'CapturedBy': record.capturedBy,
      'CapturedOn': record.readingDate,
      'SyncBy': record.syncBy,
    });
    data.files.add(
      MapEntry(
        'body',
        dio.MultipartFile.fromBytes(base64Decode(record.body),
            filename: '${record.imageName}.jpg'),
      ),
    );

    try {
      var results = await _dio.post('$baseUrl/set_line_meter_reading/',
          data: data, options: options);
      print(results.data);
      print('Record posted successfully: ${record.lineID}');

      // Remove the record from the database on success
      await SqfliteDatabase.deleteLineRecordFromDatabase(record.lineID);

      return true; // Success
    } catch (e) {
      Get.snackbar("Server Error", e.toString());
      return false; // Failure
    }
  }
  static int getImageSizeInKB(String base64Image) {
    // Decode the base64 string into bytes
    List<int> bytes = base64Decode(base64Image);

    // Calculate the size of the byte array
    int imageSizeInBytes = bytes.length;

    // Convert bytes to kilobytes
    double imageSizeInKB = imageSizeInBytes / 1024.0;

    return imageSizeInKB.round();
  }
}
