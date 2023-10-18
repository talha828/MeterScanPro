import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meter_scan/backend/getx_model/master_controller.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/backend/model/CustomerCombineModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/view/line_meter_reading_screen/line_meter_reading_screen.dart';
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
    mergeCustomers();
  }

  void mergeCustomers() {
    List<CustomerCombined> mergedCustomers = [];
    var detailsList = masterData.masterData.value.customerDetail!;
    print(detailsList.length);
    var masterList = masterData.masterData.value.customerMaster!;
    print(masterList.length);
    for (var details in detailsList) {
      var matchingMaster = masterList.firstWhere(
          (master) => master.customerId == details.customerId,
          orElse: () => CustomerMaster());

      var combinedCustomer =
          CustomerCombined.fromDetailsAndMaster(details, matchingMaster);
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
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: themeColor1,
            onPressed: () =>
                Get.to(LineMeterReadingScreen(line: widget.lineMaster)),
            label: const Text(
              "Line Meter Reading",
              style: TextStyle(color: Colors.white),
            )),
        appBar: AppBar(
          backgroundColor: themeColor1,
          title: Text(
            widget.lineMaster.lineName!,
            style: const TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body:
            SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: width * 0.04,horizontal: width * 0.04),
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
                    filteredList.isNotEmpty ? ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: SizedBox(
                              width: width * 0.13,
                              child: Text(
                                filteredList[index]!.meterNo!.toString(),
                                style: TextStyle(fontSize: width * 0.05),
                              ),
                            ),
                            onTap: () => Get.to(MeterReadingScreen(
                                customer: filteredList[index]!)),
                            title: Text(filteredList[index]!.customerName!),
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
                            filteredList.isNotEmpty ? filteredList.length : 0): const Center(child: CircularProgressIndicator()),
                  ],
                ),
              )
      ),
    );
  }
}

class CustomerModel {
  final String customerId;
  final String customerName;
  final String meterNo;
  final String lineId;

  CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.meterNo,
    required this.lineId,
  });
}

class CustomerTempModel {
  final int? customerId;
  final int? meterNo;
  final int? lineId;

  CustomerTempModel({
    required this.customerId,
    required this.meterNo,
    required this.lineId,
  });
}
