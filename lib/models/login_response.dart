class UserModel {
  final int id;
  final String name;
  final String username;

  UserModel({required this.id, required this.name, required this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'username': username};
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      // Mengecek apakah 'status' bernilai 'success'
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      token: json['token'],
      user: json['data'] != null ? UserModel.fromJson(json['data']) : null,
    );
  }
}