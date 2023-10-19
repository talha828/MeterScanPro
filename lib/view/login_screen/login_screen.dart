import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/view/fetch_data_screen/fetch_data_screen.dart';
import 'package:meter_scan/view/main_screen/main_screen.dart';
import 'package:meter_scan/widget/CustomCheckboxWithForgetPassword.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';
import 'package:meter_scan/widget/MeterScanTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isChecked = true;
  bool flag = false;

  autoLogin()async{
    setState(()=>flag=true);
    SharedPreferences prefer = await SharedPreferences.getInstance();
    String? username = prefer.getString("username");
    String? password = prefer.getString("password");
    bool? firstTime = prefer.getBool("firstTime");
     prefer.setBool("firstTime",false);
    if(firstTime != null){
      setState(()=>flag=false);
      if(username != null && password != null){
        SqfliteDatabase.getUser(username, password, true, (value)=>setState(()=>flag=value));
      }else{
        // Future.delayed(const Duration(seconds: 2),(){
        //   setState(()=>flag=false);
        //   Get.to(const FetchDataScreen());
        // });
      }
    }else{
      Future.delayed(const Duration(seconds: 2),(){
        setState(()=>flag=false);
        Get.to(const FetchDataScreen());
      });
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
        body: SingleChildScrollView(
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(
                vertical: width * 0.04, horizontal: width * 0.04),
            child: Stack(
              children: [
                Column(
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
                    SizedBox(height: width * 0.05,),
                    MeterScanButton(onTap: ()=>SqfliteDatabase.getUser(name.text, password.text, _isChecked,(value)=>setState(()=>flag=value)), width: width, label: "Login"),
                    SizedBox(height: width * 0.05,),
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
      ),
    );
  }
}
