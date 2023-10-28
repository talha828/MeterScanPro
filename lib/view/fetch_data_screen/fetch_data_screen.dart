import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:meter_scan/backend/API/api.dart';
import 'package:meter_scan/backend/getx_model/loading_controller.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';

class FetchDataScreen extends StatefulWidget {
  const FetchDataScreen({super.key});

  @override
  State<FetchDataScreen> createState() => _FetchDataScreenState();
}

class _FetchDataScreenState extends State<FetchDataScreen> {
  bool flag = false;
  final LoadingController loadingController = Get.put(LoadingController());

  setLoading(bool value) {
    setState(() {
      flag = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          // alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: width * 0.04, horizontal: width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    Assets.assetsFetch,
                    width: width * 0.5,
                    height: width * 0.5,
                  ),
                  const Text(
                    "Fetch Data Of Your User",
                    style: headingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Begin by loading all your data. It's essential to establish a stable internet connection for this task, which will then allow you to access and make use of the complete array of features and services at your disposal",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  MeterScanButton(
                      onTap: () {
                        setLoading(true);
                        Api.collectMasterDetails().catchError((onError) {
                          setLoading(false);
                        });
                      },
                      width: width,
                      label: "Fetch All Data"),
                ],
              ),
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
    );
  }
}
