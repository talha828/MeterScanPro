import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:meter_scan/backend/getx_model/loading_controller.dart';
import 'dart:io';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/model/UserModel.dart';
import 'package:meter_scan/view/login_screen/login_screen.dart';

const basicUrl =
    "https://gdbdd1958df4205-atpnew.adb.me-abudhabi-1.oraclecloudapps.com/ords/ws/data/";
const masterDetails = "${basicUrl}meter_reading_data/";

class Api {
  Api._();
  static final Dio _dio = Dio();

  static Future<void> collectMasterDetails() async {
    final LoadingController loadingController = Get.find<LoadingController>();
    try {
      loadingController.toggleFlag(true);
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
       try {
         print("===== call Api =======");
        final response = await _dio.get(
         'https://gdbdd1958df4205-atpnew.adb.me-abudhabi-1.oraclecloudapps.com/ords/ws/data/meter_reading_data/',
        );
         print("====== response status ======");
         print(response.statusCode.toString());
        if (response.statusCode == 200) {
          print("====== Build Model ======");
         final Map<String, dynamic> jsonData = response.data;
         final customerAndLineModel = CustomerAndLineModel.fromJson(jsonData);
         print(customerAndLineModel.customerDetail![1].customerId);
         if(customerAndLineModel != null){
           print("===== data storing =======");
           for(var customerMaster in customerAndLineModel.customerMaster!){
           SqfliteDatabase.insertCustomerMaster(customerMaster);
           }
           for(var customerDetail in customerAndLineModel.customerDetail!){
             SqfliteDatabase.insertCustomerDetail(customerDetail);
           }
           for(var lineMaster in customerAndLineModel.lineMaster!){
             SqfliteDatabase.insertLineMaster(lineMaster);
           }
           for(var lineDetail in customerAndLineModel.lineDetail!){
             SqfliteDatabase.insertLineDetail(lineDetail);
           }
           print("===== data storing completed =======");
           print("===== Call user Data Api =======");
           try {
             final response = await _dio.get('http://erp.convexconsulting.com.pk:9999/ords/ws/data/login/');
             if (response.statusCode == 200) {
               print("===== SetUp Model =======");
               final List<dynamic> data = response.data['items'];
               List<UserModel> users = data.map((json) => UserModel.fromJson(json)).toList();
               SqfliteDatabase.insertAllUsers(users);
               Get.to(const LoginScreen());
               loadingController.toggleFlag(false);
             } else {
               throw Exception('Failed to load user data');
             }
           } catch (e) {
             throw Exception('Failed to load user data: $e');
           }

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
}

