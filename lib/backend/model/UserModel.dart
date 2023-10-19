class UserModel {
  final int cmuserAppId;
  final String fullName;
  final String userName;
  final String password;
  final String status;

  UserModel({
    required this.cmuserAppId,
    required this.fullName,
    required this.userName,
    required this.password,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      cmuserAppId: json['cmuser_app_id'],
      fullName: json['full_name'],
      userName: json['user_name'],
      password: json['password'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cmuser_app_id': cmuserAppId,
      'full_name': fullName,
      'user_name': userName,
      'password': password,
      'status': status,
    };
  }
}
