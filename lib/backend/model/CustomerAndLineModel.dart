class CustomerAndLineModel {
  List<CustomerMaster>? customerMaster;
  List<CustomerDetail>? customerDetail;
  List<LineMaster>? lineMaster;
  List<LineDetail>? lineDetail;

  CustomerAndLineModel(
      {this.customerMaster,
        this.customerDetail,
        this.lineMaster,
        this.lineDetail});

  CustomerAndLineModel.fromJson(Map<String, dynamic> json) {
    if (json['customer_master'] != null) {
      customerMaster = <CustomerMaster>[];
      json['customer_master'].forEach((v) {
        customerMaster!.add(CustomerMaster.fromJson(v));
      });
    }
    if (json['customer_detail'] != null) {
      customerDetail = <CustomerDetail>[];
      json['customer_detail'].forEach((v) {
        customerDetail!.add(CustomerDetail.fromJson(v));
      });
    }
    if (json['line_master'] != null) {
      lineMaster = <LineMaster>[];
      json['line_master'].forEach((v) {
        lineMaster!.add(LineMaster.fromJson(v));
      });
    }
    if (json['line_detail'] != null) {
      lineDetail = <LineDetail>[];
      json['line_detail'].forEach((v) {
        lineDetail!.add(LineDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (customerMaster != null) {
      data['customer_master'] =
          customerMaster!.map((v) => v.toJson()).toList();
    }
    if (customerDetail != null) {
      data['customer_detail'] =
          customerDetail!.map((v) => v.toJson()).toList();
    }
    if (lineMaster != null) {
      data['line_master'] = lineMaster!.map((v) => v.toJson()).toList();
    }
    if (lineDetail != null) {
      data['line_detail'] = lineDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerMaster {
  int? customerId;
  String? customerName;

  CustomerMaster({this.customerId, this.customerName});

  CustomerMaster.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    customerName = json['customer_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['customer_id'] = customerId;
    data['customer_name'] = customerName;
    return data;
  }
}

class CustomerDetail {
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

  CustomerDetail(
      {this.customerId,
        this.lineId,
        this.lineName,
        this.meterNo,
        this.meterType,
        this.meterPower,
        this.meterFormula,
        this.rate,
        this.mvariance,
        this.varianceDescp});

  CustomerDetail.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    lineId = json['line_id'];
    lineName = json['line_name'];
    meterNo = json['meter_no'];
    meterType = json['meter_type'];
    meterPower = json['meter_power'];
    meterFormula = json['meter_formula'];
    rate = 0.0;
    mvariance = json['mvariance'];
    varianceDescp = json['variance_descp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['customer_id'] = customerId;
    data['line_id'] = lineId;
    data['line_name'] = lineName;
    data['meter_no'] = meterNo;
    data['meter_type'] = meterType;
    data['meter_power'] = meterPower;
    data['meter_formula'] = meterFormula;
    data['rate'] = rate;
    data['mvariance'] = mvariance;
    data['variance_descp'] = varianceDescp;
    return data;
  }
}

class LineMaster {
  int? lineId;
  String? lineName;

  LineMaster({this.lineId, this.lineName});

  LineMaster.fromJson(Map<String, dynamic> json) {
    lineId = json['line_id'];
    lineName = json['line_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['line_id'] = lineId;
    data['line_name'] = lineName;
    return data;
  }
}

class LineDetail {
  int? lineId;
  String? meterName;
  int? meterId;
  int? meterPower;

  LineDetail({this.lineId, this.meterName, this.meterId, this.meterPower});

  LineDetail.fromJson(Map<String, dynamic> json) {
    lineId = json['line_id'];
    meterName = json['meter_name'];
    meterId = json['meter_id'];
    meterPower = json['meter_power'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['line_id'] = lineId;
    data['meter_name'] = meterName;
    data['meter_id'] = meterId;
    data['meter_power'] = meterPower;
    return data;
  }
}
