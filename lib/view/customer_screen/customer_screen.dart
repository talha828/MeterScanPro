import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meter_scan/backend/getx_model/master_controller.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
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
  List<CustomerMaster?> customerNamesForSpecificLine = [];
  @override
  void initState() {
    super.initState();
    getCustomer();
  }

  getCustomer() {
    setState(() {
      List<int?> customerIdsForSpecificLine = masterData
          .masterData.value.customerDetail!
          .where(
              (customerLine) => customerLine.lineId == widget.lineMaster.lineId)
          .map((customerLine) => customerLine.customerId)
          .toList();
      customerNamesForSpecificLine = masterData.masterData.value.customerMaster!
          .where((customer) =>
              customerIdsForSpecificLine.contains(customer.customerId))
          .map((customer) => customer)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended( backgroundColor: themeColor1,onPressed: ()=>Get.to(LineMeterReadingScreen(line: widget.lineMaster)), label:const Text("Line Meter Reading",style: TextStyle(color: Colors.white),)),
        appBar: AppBar(
          backgroundColor: themeColor1,
          title: Text(widget.lineMaster.lineName!,style:const TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: customerNamesForSpecificLine.isNotEmpty
            ? SingleChildScrollView(
              child: ListView.separated(
                  physics:const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(customerNamesForSpecificLine[index]!.customerId!.toString(),style: const TextStyle(fontSize: 24),),
                      onTap: ()=>Get.to(MeterReadingScreen(customer: customerNamesForSpecificLine[index]!)),
                      title: Text(
                          customerNamesForSpecificLine[index]!.customerName!),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 1,
                    );
                  },
                  itemCount: customerNamesForSpecificLine.isNotEmpty
                      ? customerNamesForSpecificLine.length
                      : 0),
            )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
