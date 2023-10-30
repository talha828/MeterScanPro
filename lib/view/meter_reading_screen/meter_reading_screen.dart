import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/backend/model/CustomerCombineModel.dart';
import 'package:meter_scan/backend/model/CustomerMeterRecordModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/view/customer_screen/customer_screen.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';
import 'package:meter_scan/widget/MeterScanTextField.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeterReadingScreen extends StatefulWidget {
  final CustomerCombined customer;
  const MeterReadingScreen({required this.customer, super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  bool isEditable = false;
  TextEditingController _numberController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  TextEditingController date = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  bool imageFlag = false;
  bool loading = false;
  bool isSaved = false;
  String newReading = "11";
  File? file;
  Uint8List? bytesImage;
  getAutoData() async {
    CustomerMeterRecordModel? data = await SqfliteDatabase.loadRecordByMeterAndCustID(
            widget.customer.meterNo!, widget.customer.customerId!);
    if (data != null) {
      bytesImage = base64Decode(data.body);

      _numberController =
          TextEditingController(text: data.currentReading.toString());
      date = TextEditingController(text: data.readingDate);
      imageFlag = true;
      isSaved = true;
      isEditable = true;
      setState(() {});
    }
  }

  insertData() async {
    if (_numberController.text.isNotEmpty) {
      if (date.text.isNotEmpty) {
        if (isEditable?bytesImage != null:file != null) {
          print("=== get username ===");
          SharedPreferences prefer = await SharedPreferences.getInstance();
          String? name = prefer.getString("username");
          print("=== get location ===");
          var ff = await _geolocatorPlatform.requestPermission();
          bool df = await _geolocatorPlatform.isLocationServiceEnabled();
          if (df == false) {
            bool df = await _geolocatorPlatform.openLocationSettings();
          }
          Position? position = await _geolocatorPlatform.getLastKnownPosition();

          if (position == null) {
            Get.snackbar("Location Error",
                "Please Enable your location and restart your application");
          }
          print("=== get timestamp ===");
          final timestamp =
              DateTime.now().millisecondsSinceEpoch; // Generate a timestamp
          print("=== create record ===");
          List<int>? bytes;
          if(isEditable == false){
            bytes = await file!.readAsBytes();
          }
          String base64 = base64Encode(isEditable?(file!=null?file!.readAsBytesSync():bytesImage!):bytes!);
          CustomerMeterRecordModel record = CustomerMeterRecordModel(
              lineID: widget.customer.lineId!,
              meterNumber: widget.customer.meterNo!,
              readingDate: isEditable?date.text.toString():formatCustomDate(date.text.toString()),
              currentReading: int.parse(_numberController.text),
              custID: widget.customer.customerId!,
              imageName: "${widget.customer.customerId!} $timestamp",
              mimeType: 'image/jpeg',
              imageSize: isEditable?bytesImage!.length:await file!.length(),
              latitude:
                  position == null ? "123123" : position!.latitude.toString(),
              longitude:
                  position == null ? "123123" : position.longitude.toString(),
              capturedBy: name!,
              capturedOn: timestamp.toString(),
              syncBy: widget.customer.customerName!,
              syncOn: timestamp.toString(),
              body: base64);
          print("=== insert record ===");
          if(isEditable){
            await SqfliteDatabase.updateCustomerRecord(record);
          }else{
            await SqfliteDatabase.insertCustomerRecord(record);
          }
          Get.to(CustomerScreen(
              lineMaster: LineMaster(
            lineId: widget.customer.lineId,
            lineName: widget.customer.lineName,
          )));
        } else {
          Get.snackbar("Image not found", "Please Take a Image");
        }
      } else {
        Get.snackbar("Date not found", "Please insert a date");
      }
    } else {
      Get.snackbar("Reading not Found", "Please insert a reading");
    }
  }

  String formatCustomDate(String originalDate) {
    // Parse the original date into a DateTime object
    DateTime dateTime = DateFormat('dd-MM-yyyy').parse(originalDate);

    // Format the date in the desired format
    String formattedDate =
        DateFormat('dd-MMM-yyyy').format(dateTime).toUpperCase();

    return formattedDate;
  }

  getImage() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      XFile? dd = await FlutterImageCompress.compressAndGetFile(
        photo.path,
        "${(await getApplicationDocumentsDirectory()).path}/$timestamp.jpg",
        quality: 50,
      );
      imageFlag = true;
      file = File(dd!.path);
      setState(() {});
      newReading = await detectTextFromFile(dd.path);
      if (newReading.isNotEmpty) {
        _numberController = TextEditingController(text: newReading);
      }
      setState(() {});
    }
  }

  Future<String> detectTextFromFile(String filePath) async {
    final InputImage inputImage = InputImage.fromFilePath(filePath);
    final TextRecognizer textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    return extractFiveOrSixDigitNumber(recognizedText.text);
  }

  String extractFiveOrSixDigitNumber(String inputText) {
    RegExp regex = RegExp(r'\d{5,6}');
    Match? match = regex.firstMatch(inputText);

    if (match != null) {
      return match.group(0) ?? '';
    } else {
      return '';
    }
  }

  @override
  void initState() {
    getAutoData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor1,
          title: Text(
            "Customer Meter",
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
        body: SingleChildScrollView(
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(
                vertical: width * 0.04, horizontal: width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: width * 0.04),
                  child: Text(
                    widget.customer.customerName!,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: width * 0.05),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Meter Reading",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: width * 0.04,
                      ),
                    ),
                    SizedBox(height: width * 0.04),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: fillColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _numberController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "123456",
                                hintStyle: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                    fontSize: width * 0.04,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                IgnorePointer(
                  ignoring: true,
                  child: MeterScanTextField(
                    controller: date,
                    label: "Reading Date",
                    hintText: date.text,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: width * 0.04),
                  child: Text(
                    "Take Meter Image",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: width * 0.04,
                    ),
                  ),
                ),
                imageFlag
                    ? GestureDetector(
                        onLongPress: () {
                          setState(() {
                            imageFlag = false;
                          });
                        },
                        child: SizedBox(
                          width: width,
                          height: width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: file == null
                                ? Image.memory(
                                    bytesImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    file!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => getImage(),
                        child: Container(
                          height: width * 0.5,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(10),
                            color: fillColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset(
                                Assets.assetsSpeedometer,
                                width: width * 0.2,
                                height: width * 0.2,
                              ),
                              Text(
                                "Take Customer Meter Image",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: width * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                isSaved
                    ? Container()
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: MeterScanButton(
                                onTap: () => insertData(),
                                width: width,
                                label: "Save",
                              ),
                            ),
                          ],
                        ),
                      ),
                isEditable
                    ? Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: MeterScanButton(
                          onTap: () => insertData(),
                          width: width,
                          label: "Edit Record",
                        ),
                      ),
                    ],
                  ),
                ):Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
