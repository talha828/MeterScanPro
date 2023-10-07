import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/view/main_screen/main_screen.dart';
import 'package:meter_scan/widget/CustomCheckboxWithForgetPassword.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';
import 'package:meter_scan/widget/MeterScanTextField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(
                vertical: width * 0.04, horizontal: width * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(Assets.assetsLogin,width: width * 0.5,height: width * 0.5,),
                const Text("Login", style: headingStyle),
                SizedBox(height: width * 0.04,),

                MeterScanTextField(
                  controller: name,
                  label: "Name",
                  hintText: "John Wick",
                ),
                MeterScanTextField(
                    controller: name,
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
                SizedBox(height: width * 0.05,),
                MeterScanButton(onTap: ()=>Get.to(const MainScreen()), width: width, label: "Login"),
                SizedBox(height: width * 0.05,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
