// Login Request Model - Represents login request data
class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

