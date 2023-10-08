import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/getx_model/master_controller.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/view/customer_screen/customer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController search = TextEditingController();
  String currentTime = '';
  String currentDate = '';
  final masterData = Get.put(MasterController());

  loadData() async {
    masterData.masterData.value = await SqfliteDatabase.fetchAllData();
    filteredList = masterData.masterData.value.lineMaster!;
  }

  List<LineMaster> filteredList = [];

  void filterList(String query) {
    filteredList = masterData.masterData.value.lineMaster!
        .where((line) =>
            line.lineName!.toLowerCase().contains(query.toLowerCase()) ||
            line.lineId.toString().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadData();
    updateTimeAndDate();
    Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        updateTimeAndDate();
      },
    );
  }

  void updateTimeAndDate() {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    final formattedDate = DateFormat('dd-MM-yyyy').format(now);

    setState(() {
      currentTime = formattedTime;
      currentDate = formattedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor1,
          title: const Text(
            "Talha Iqbal", // TODO Change Name Accordingly
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        drawer: const Drawer(),
        body: Column(
          children: [
            Container(
              width: width,
              height: width * 0.6,
              color: themeColor1,
              padding: EdgeInsets.symmetric(
                  vertical: width * 0.04, horizontal: width * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentTime,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.12,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    currentDate,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: width * 0.8,
                    child: TextField(
                      controller: search,
                      onChanged: (query) => filterList(query),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        hintText: "Search Line Here",
                        hintStyle: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            fontSize: width * 0.04,
                          ),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredList.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () => Get.to(
                              CustomerScreen(lineMaster: filteredList[index])),
                          title: Text(filteredList[index].lineName!),
                          leading: Text(
                            filteredList[index].lineId!.toString(),
                            style: const TextStyle(fontSize: 24),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 1,
                        );
                      },
                      itemCount:
                          filteredList.isNotEmpty ? filteredList.length : 0)
                  : const Center(child: CircularProgressIndicator()),
            )
          ],
        ),
      ),
    );
  }
}