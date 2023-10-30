import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/view/fetch_data_screen/fetch_data_screen.dart';
import 'package:meter_scan/widget/CustomCheckboxWithForgetPassword.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';
import 'package:meter_scan/widget/MeterScanTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../backend/API/api.dart';
import '../../backend/getx_model/loading_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isChecked = true;
  bool flag = false;
  final LoadingController loadingController = Get.put(LoadingController());

  autoLogin() async {
    setState(() => flag = true);
    SharedPreferences prefer = await SharedPreferences.getInstance();
    String? username = prefer.getString("username");
    String? password = prefer.getString("password");
    bool? firstTime = prefer.getBool("firstTime");
    bool? logout = prefer.getBool("logout");
    if (firstTime != null) {
      setState(() => flag = false);
      if (username != null && password != null) {
        SqfliteDatabase.getUser(
            username, password, firstTime, (value) => setState(() => flag = value));
      } else {}
    } else {
      Api.collectUserDetails();
      setState(() => flag = false);
    }
  }



  @override
  void initState() {
    autoLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: height,
          padding: EdgeInsets.symmetric(
              vertical: width * 0.04, horizontal: width * 0.04),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    Assets.assetsMeterSnapLogoSlogan,
                    width: width * 0.4,
                    height: width * 0.5,
                    scale: 3,
                  ),
                  MeterScanTextField(
                    controller: username,
                    label: "Username",
                    hintText: "Jonh.wick",
                  ),
                  MeterScanTextField(
                      controller: password,
                      label: "Password",
                      hintText: "*******",
                      obscureText: true,
                      suffixIcon: Icons.remove_red_eye_outlined),
                  CustomCheckboxWithForgetPassword(
                    isForgetPassword: false,
                    onCheckboxTap: () => setState(
                      () => _isChecked = !_isChecked,
                    ),
                    isChecked: _isChecked,
                    onForgetPasswordTap: () {},
                  ),
                  SizedBox(
                    height: width * 0.05,
                  ),
                  MeterScanButton(
                      onTap: () async{
                        SharedPreferences prefer = await SharedPreferences.getInstance();
                        bool? firstTime = prefer.getBool("firstTime");
                        await prefer.setBool("logout", false);
                        SqfliteDatabase.getUser(
                          username.text.toLowerCase(),
                          password.text,
                            firstTime == null?true:false,
                          (value) => setState(() => flag = value));},
                      width: width,
                      label: "Login"),
                  SizedBox(
                    height: width * 0.05,
                  ),
                ],
              ),
              flag
                  ? Container(
                      color: Colors.white.withOpacity(0.7),
                      child: const Center(
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballScale,
                          colors: [themeColor1],
                          strokeWidth: 1,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
