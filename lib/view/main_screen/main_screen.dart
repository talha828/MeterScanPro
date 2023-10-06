import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/widget/MeterScanTextField.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController search = TextEditingController();
  String currentTime = '';
  String currentDate = '';

  @override
  void initState() {
    super.initState();

    // Initialize the current time and date
    updateTimeAndDate();

    // Update the time and date every second
    Timer.periodic(Duration(seconds: 1), (timer) {
      updateTimeAndDate();
    });
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
            "Talha Iqbal",
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
              child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return const ListTile(
                      title: Text("Maher Town Korangi Karachi"),
                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 1,
                    );
                  },
                  itemCount: 15),
            )
          ],
        ),
      ),
    );
  }
}
