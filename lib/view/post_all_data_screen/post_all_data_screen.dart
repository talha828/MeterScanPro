import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meter_scan/backend/API/api.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/model/CustomerMeterRecordModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';

class PostAllDataScreen extends StatefulWidget {
  const PostAllDataScreen({super.key});

  @override
  State<PostAllDataScreen> createState() => _PostAllDataScreenState();
}

class _PostAllDataScreenState extends State<PostAllDataScreen> {
  List<CustomerMeterRecordModel>? list = [];

  getData() async {
    list = await SqfliteDatabase.getAllCustomerRecords();
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor1,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            "Post All Data",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  list!.length.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: themeColor1),
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  offset: const Offset(0, -2),
                  blurRadius: 7,
                  spreadRadius: 8),
            ],
          ),
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: width * 0.04),
          height: width * 0.2,
          child: MeterScanButton(
            onTap: ()async=>await Api.postMeterReadings(list!),
            label: "Post Data",
            width: width,
          ),
        ),
        body: list!.isEmpty
            ? const Center(
                child: Text("No Records Found"),
              )
            : Container(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: width * 0.04),
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text(
                          list![index]!.custID!.toString(),
                          style: TextStyle(fontSize: width * 0.05),
                        ),
                        title: Text(list![index].syncBy),
                        trailing: Text(
                          list![index].readingDate,
                          style: TextStyle(fontSize: width * 0.04),
                        ),
                        subtitle:
                            Text("Reading : ${list![index].currentReading}"),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemCount: list!.length),
              ),
      ),
    );
  }
}
