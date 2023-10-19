class CustomerCombined{
  int? customerId;
  int? lineId;
  String? lineName;
  String? meterNo;
  String? meterType;
  int? meterPower;
  int? meterFormula;
  double? rate;
  String? mvariance;
  int? varianceDescp;
  String? customerName;
  CustomerCombined({
    this.customerId,
    this.lineId,
    this.lineName,
    this.meterNo,
    this.meterType,
    this.meterPower,
    this.meterFormula,
    this.rate,
    this.mvariance,
    this.varianceDescp,
    this.customerName,
  });

  factory CustomerCombined.fromDetailsAndMaster(details,  master) {
    return CustomerCombined(
      customerId: details.customerId,
      lineId: details.lineId,
      lineName: details.lineName,
      meterNo: details.meterNo,
      meterType: details.meterType,
      meterPower: details.meterPower,
      meterFormula: details.meterFormula,
      rate: details.rate,
      mvariance: details.mvariance,
      varianceDescp: details.varianceDescp,
      customerName: master.customerName,
    );
  }
}