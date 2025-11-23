// Login Response Model - Represents login API response
class LoginResponseModel {
  final String? token;
  final String? error;

  LoginResponseModel({
    this.token,
    this.error,
  });

  // Factory constructor to create LoginResponseModel from JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String?,
      error: json['error'] as String?,
    );
  }

  // Check if login was successful
  bool get isSuccess => token != null && token!.isNotEmpty;
}

