import 'package:get/get.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';

class MasterController extends GetxController{
  Rx<CustomerAndLineModel> masterData = CustomerAndLineModel().obs;
}