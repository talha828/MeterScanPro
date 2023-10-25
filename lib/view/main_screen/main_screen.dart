import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/getx_model/master_controller.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/view/customer_screen/customer_screen.dart';
import 'package:meter_scan/view/login_screen/login_screen.dart';
import 'package:meter_scan/view/post_customer_data_screen/post_all_data_screen.dart';
import 'package:meter_scan/view/post_line_data_screen/post_line_data_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String name = "loading";
  List<LineMaster> filteredList = [];
  List<LineMaster> resetList = [];


  loadData() async {
    SharedPreferences prefer = await SharedPreferences.getInstance();
    String? username = prefer.getString("username");
    setState(() {
      name = convertToTitleCase(username!);
    });
    masterData.masterData.value = await SqfliteDatabase.fetchAllData();
    for(var i in masterData.masterData.value.lineMaster!){
      resetList.add(LineMaster(lineId:i.lineId ,lineName:i.lineName ,isRecord:await SqfliteDatabase.doesLineRecordExistForToday(i.lineId!) ,));
    }
    filteredList = resetList;
  }


  String convertToTitleCase(String input) {
    List<String> parts = input.split('.');
    for (int i = 0; i < parts.length; i++) {
      parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
    }
    return parts.join(' ');
  }

  void filterList(String query) {
    filteredList = resetList
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
          title: Text(
            name,
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  filteredList.length.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: themeColor1),
                ),
              ),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            // padding: const EdgeInsets.all(0),
            children: [
              DrawerHeader(
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: const BoxDecoration(
                  color: themeColor1,
                ), //BoxDecoration
                child: UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: themeColor1),
                  accountName: Text(
                    name,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  accountEmail: const Text(
                    "Employee of M-Scan Pro",
                    style: TextStyle(color: Colors.white),
                  ),
                  currentAccountPictureSize: const Size.square(50),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(Assets.assetsImage)),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Data'),
                onTap: ()async => SqfliteDatabase.deleteAllRecord(),
              ),
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text('Post Line Data'),
                onTap: ()=>Get.to(const PostLineDataScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text('Post Customer Data'),
                onTap: ()=>Get.to(const PostCustomerDataScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('LogOut'),
                onTap: () async {
                  SharedPreferences prefer =
                      await SharedPreferences.getInstance();
                  prefer.setString("username", "null");
                  prefer.setString("password", "null");
                  Get.to(const LoginScreen());
                },
              ),
            ],
          ),
        ),
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
                          tileColor: filteredList[index].isRecord!
                              ? themeColor1.withOpacity(0.2)
                              : Colors.white,
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
