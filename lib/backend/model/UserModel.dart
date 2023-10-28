class UserModel {
  final String isLock;
  final String fullName;
  final String userName;
  final String password;
  final String status;

  UserModel({
    required this.isLock,
    required this.fullName,
    required this.userName,
    required this.password,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      isLock: json['is_locked'],
      fullName: json['full_name'],
      userName: json['user_name'],
      password: json['password'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_locked': isLock,
      'full_name': fullName,
      'user_name': userName,
      'password': password,
      'status': status,
    };
  }
}
