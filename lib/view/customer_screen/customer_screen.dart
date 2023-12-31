import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/getx_model/master_controller.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/backend/model/CustomerCombineModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/view/line_meter_reading_screen/line_meter_reading_screen.dart';
import 'package:meter_scan/view/line_screen/line_screen.dart';
import 'package:meter_scan/view/main_screen/main_screen.dart';
import 'package:meter_scan/view/meter_reading_screen/meter_reading_screen.dart';

class CustomerScreen extends StatefulWidget {
  CustomerScreen({super.key, required this.lineMaster});
  LineMaster lineMaster;

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final masterData = Get.find<MasterController>();
  List<CustomerCombined> customerNamesForSpecificLine = [];
  TextEditingController search = TextEditingController();
  List<CustomerCombined> filteredList = [];
  void filterList(String query) {
    filteredList = customerNamesForSpecificLine
        .where((line) =>
            line.customerName!.toLowerCase().contains(query.toLowerCase()) ||
            line.customerId.toString().contains(query))
        .toList();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // ff();
    mergeCustomers();
  }

  void ff() async {
    await SqfliteDatabase.printCustomerLineData();
  }

  void mergeCustomers() async {
    List<CustomerCombined> mergedCustomers = [];
    var detailsList = masterData.masterData.value.customerDetail!;
    print(detailsList.length);
    var masterList = masterData.masterData.value.customerMaster!;
    print(masterList.length);
    for (var details in detailsList) {
      var matchingMaster = masterList.firstWhere(
          (master) => master.customerId == details.customerId,
          orElse: () => CustomerMaster());
      bool recordStatus = await SqfliteDatabase.doesRecordExistForToday(
          details.customerId!, details.meterNo!);
      var combinedCustomer = CustomerCombined.fromDetailsAndMaster(
          details, matchingMaster, recordStatus);
      mergedCustomers.add(combinedCustomer);
    }

    setState(() {
      customerNamesForSpecificLine =
          getCustomersByLineId(mergedCustomers, widget.lineMaster.lineId!);
      filteredList = customerNamesForSpecificLine;
      print(customerNamesForSpecificLine.length);
      print(widget.lineMaster.lineId);
    });
  }

  List<CustomerCombined> getCustomersByLineId(
      List<CustomerCombined> customers, int specificLineId) {
    final filteredList = customers
        .where((customer) => customer.lineId == specificLineId)
        .toList();
    filteredList.sort((a, b) => a.customerId!.compareTo(b.customerId!));
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Get.to(const MainScreen());
        return false;
      },
      child: SafeArea(
        child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: themeColor1,
              onPressed: () => Get.to(
                LineScreen(
                  lineMaster: widget.lineMaster,
                ),
              ),
              label: const Text(
                "Line Meter Reading",
                style: TextStyle(color: Colors.white),
              ),
            ),
            appBar: AppBar(
              backgroundColor: themeColor1,
              title: const Text(
                "Customers",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () => Get.to(const MainScreen()),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
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
                  filteredList.isNotEmpty
                      ? ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              tileColor: filteredList[index].recordStatus!
                                  ? themeColor1.withOpacity(0.2)
                                  : Colors.white,
                              leading: Column(
                                children: [
                                  Text("Customer Id"),
                                  SizedBox(
                                    height: width * 0.02,
                                  ),
                                  Text(
                                    filteredList[index]!.customerId!.toString(),
                                    style: TextStyle(fontSize: width * 0.05),
                                  ),
                                ],
                              ),
                              onTap: () => Get.to(MeterReadingScreen(
                                  customer: filteredList[index]!)),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Customer Name"),
                                  SizedBox(
                                    height: width * 0.02,
                                  ),
                                  Text(filteredList[index]!.customerName!),
                                ],
                              ),
                              subtitle: Text(
                                  "Meter No : ${filteredList[index]!.meterNo}"),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios_rounded),
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
            )),
      ),
    );
  }
}
