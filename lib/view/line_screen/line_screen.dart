import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/view/line_meter_reading_screen/line_meter_reading_screen.dart';

import '../../backend/getx_model/master_controller.dart';

class LineScreen extends StatefulWidget {
  LineScreen({super.key, required this.lineMaster});
  LineMaster lineMaster;
  @override
  State<LineScreen> createState() => _LineScreenState();
}

class _LineScreenState extends State<LineScreen> {
  final masterData = Get.find<MasterController>();
  List<LineDetail>? list = [];
  List<LineDetail>? temp = [];
  TextEditingController search = TextEditingController();
  List<LineDetail> filteredList = [];
  getData() async {
    temp = masterData.masterData.value.lineDetail!
        .where((element) => element.lineId == widget.lineMaster.lineId!)
        .toList();
    print(temp);
    for (var i in temp!) {
      list!.add(LineDetail(
        lineId: i.lineId,
        meterId: i.meterId,
        meterName: i.meterName,
        meterPower: i.meterPower,
        isRecord: await SqfliteDatabase.doesLineMeterRecordExistForToday(
            widget.lineMaster.lineId!, i.meterId!),
      ));
    }
    filteredList = list!;
    setState(() {});
  }

  void filterList(String query) {
    filteredList = list!
        .where((line) =>
            line.meterName!.toLowerCase().contains(query.toLowerCase()) ||
            line.lineId.toString().contains(query))
        .toList();
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
            title: const Text(
              "Lines",
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(filteredList.length.toString()),
                ),
              ),
            ],
          ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: width * 0.04),
              child: Text(
                widget.lineMaster.lineName!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: width * 0.05),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: width * 0.04, horizontal: width * 0.04),
              decoration: BoxDecoration(
                // color: Colors.grey,
                border: Border.all(color: themeColor1),
                borderRadius: BorderRadius.circular(50),
              ),
              width: width * 0.8,
              child: TextField(
                controller: search,
                onChanged: (query) => filterList(query),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  hintText: "Search Meter Here",
                  hintStyle: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      fontSize: width * 0.04,
                    ),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            filteredList!.isNotEmpty
                ? ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: filteredList[index].isRecord!
                            ? themeColor1.withOpacity(0.2)
                            : Colors.white,
                        leading: Column(
                          children: [
                            Text("Line Id"),
                            SizedBox(
                              height: width * 0.02,
                            ),
                            Text(
                              filteredList[index]!.lineId!.toString(),
                              style: TextStyle(fontSize: width * 0.05),
                            ),
                          ],
                        ),
                        onTap: () => Get.to(
                            LineMeterReadingScreen(line: filteredList[index]!)),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Line Name"),
                            SizedBox(
                              height: width * 0.02,
                            ),
                            Text(filteredList[index]!.meterName!),
                          ],
                        ),
                        subtitle:
                            Text("Meter Id : ${filteredList[index]!.meterId}"),
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
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ),
      ),
    ));
  }
}
