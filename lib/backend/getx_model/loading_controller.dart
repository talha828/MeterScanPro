import 'package:get/get.dart';

class LoadingController extends GetxController {
  var myFlag = false.obs; // Use an RxBool to make it reactive

  void toggleFlag(bool newValue) {
    myFlag.value = newValue;
  }
}