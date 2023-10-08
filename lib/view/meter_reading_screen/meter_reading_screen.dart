import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:meter_scan/backend/database/sqflite.dart';
import 'package:meter_scan/backend/model/CustomerAndLineModel.dart';
import 'package:meter_scan/constant/constant.dart';
import 'package:meter_scan/generated/assets.dart';
import 'package:meter_scan/view/customer_screen/customer_screen.dart';
import 'package:meter_scan/widget/MeterScanButton.dart';
import 'package:meter_scan/widget/MeterScanTextField.dart';

class MeterReadingScreen extends StatefulWidget {
  final CustomerModel customer;
  const MeterReadingScreen({required this.customer, super.key});

  @override
  State<MeterReadingScreen> createState() => _MeterReadingScreenState();
}

class _MeterReadingScreenState extends State<MeterReadingScreen> {
  TextEditingController reading = TextEditingController();
  final ImagePicker picker = ImagePicker();
  TextEditingController date = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  bool imageFlag = false;
  bool loading = false;
  String newReading = "11";
  var file;

  insertData()async{
    if(reading.text.isNotEmpty){
      if(date.text.isNotEmpty){
        if(file !=null){
          final record = {
            'customer_name': widget.customer.customerName,
            'customer_id': widget.customer.customerId,
            'meter_reading': int.parse(reading.text),
            'meter_image': file.path,
            'date_string': date.text,
            'line_id': int.parse(widget.customer.lineId),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          };

// Insert the record into the database
          await SqfliteDatabase.insertCustomerRecord(record);
        }else{
      Get.snackbar("Image not found", "Please Take a Image");
        }
      }else{
      Get.snackbar("Date not found", "Please insert a date");
      }
    }else{
      Get.snackbar("Reading not Found", "Please insert a reading");
    }
  }

  getImage() async {
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      imageFlag = true;
      file = File(photo!.path);
      setState(() {});
      newReading = await detectTextFromFile(photo!.path);
      if (newReading.isNotEmpty) {
        reading = TextEditingController(text: newReading);
      }
      setState(() {});
    }
  }

  Future<String> detectTextFromFile(String filePath) async {
    // Create an InputImage object from the file.
    final InputImage inputImage = InputImage.fromFilePath(filePath);

    // Create a TextRecognizer object.
    final TextRecognizer textRecognizer = TextRecognizer();

    // Process the image and extract the text.
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Return the list of recognized text elements.
    return extractFiveOrSixDigitNumber(recognizedText.text);
  }

  String extractFiveOrSixDigitNumber(String inputText) {
    RegExp regex = RegExp(r'\d{5,6}');
    Match? match = regex.firstMatch(inputText);

    if (match != null) {
      return match.group(0) ?? ''; // Return the matched string
    } else {
      return ''; // Return an empty string if no match is found
    }
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
            widget.customer.customerName!,
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
            height: height - 100,
            padding: EdgeInsets.symmetric(
                vertical: width * 0.04, horizontal: width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MeterScanTextField(
                  controller: reading,
                  label: "Meter Reading",
                  hintText: "123456",
                ),
                MeterScanTextField(
                  controller: date,
                  label: "Reading Date",
                  hintText: date.text,
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
                              child: Image.file(
                                file,
                              )),
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
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: MeterScanButton(
                        onTap: ()=>insertData(),
                        width: width,
                        label: "Save",
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
