

class CustomerMeterRecordModel {
  int lineID;
  String meterNumber;
  String readingDate;
  int currentReading;
  int custID;
  String imageName;
  String mimeType;
  int imageSize;
  String latitude;
  String longitude;
  String capturedBy;
  String capturedOn;
  String syncBy;
  String syncOn;
  String body;
  CustomerMeterRecordModel({
    required this.lineID,
    required this.meterNumber,
    required this.readingDate,
    required this.currentReading,
    required this.custID,
    required this.imageName,
    required this.mimeType,
    required this.imageSize,
    required this.latitude,
    required this.longitude,
    required this.capturedBy,
    required this.capturedOn,
    required this.syncBy,
    required this.syncOn,
    required this.body,
  });

  Map<String, dynamic> toMap() {
    return {
      'LineID': lineID,
      'MeterNumber': meterNumber,
      'ReadingDate': readingDate,
      'CurrentReading': currentReading,
      'CustID': custID,
      'ImageName': imageName,
      'MimeType': mimeType,
      'ImageSize': imageSize,
      'Latitude': latitude,
      'Longitude': longitude,
      'CapturedBy': capturedBy,
      'CapturedOn': capturedOn,
      'SyncBy': syncBy,
      'SyncOn': syncOn,
      'body': body,
    };
  }
}
