import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/view/login_screen/login_screen.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';

class FetchDataScreen extends StatefulWidget {
  const FetchDataScreen({super.key});

  @override
  State<FetchDataScreen> createState() => _FetchDataScreenState();
}

class _FetchDataScreenState extends State<FetchDataScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
          body: Container(
            padding: EdgeInsets.symmetric(vertical: width * 0.04,horizontal: width * 0.04),
            child: Column(
              crossAxisAlignment:CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(Assets.assetsFetch,width: width * 0.5, height: width * 0.5,),
                const Text("Fetch Data Of Your User",style: headingStyle,textAlign: TextAlign.center,),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text("This appears to be your first login attempt. To continue, it is necessary for you to establish a stable internet connection. This connection will enable you to access and utilize the full range of features and services available",textAlign: TextAlign.center,),
                ),
                MeterScanButton(onTap: ()=>Get.to(const LoginScreen()), width: width, label: "Fetch All Data"),
              ],
            ),
          ),
        )
    );
  }
}
