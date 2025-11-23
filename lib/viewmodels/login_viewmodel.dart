import 'package:flutter/foundation.dart';
import '../models/api_response_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../services/api_service.dart';

// Login ViewModel - Manages login screen state and business logic
class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  ApiResponse<LoginResponseModel> _loginResponse = ApiResponse<LoginResponseModel>();
  String _email = '';
  String _password = '';
  String? _emailError;
  String? _passwordError;

  // Getters
  ApiResponse<LoginResponseModel> get loginResponse => _loginResponse;
  String get email => _email;
  String get password => _password;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  bool get isLoading => _loginResponse.isLoading;
  bool get isLoggedIn => _loginResponse.isSuccess;

  // Update email
  void setEmail(String value) {
    _email = value;
    _emailError = null; // Clear error when user types
    notifyListeners();
  }

  // Update password
  void setPassword(String value) {
    _password = value;
    _passwordError = null; // Clear error when user types
    notifyListeners();
  }

  // Validate email format
  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _emailError = 'Email is required';
      return false;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _emailError = 'Please enter a valid email';
      return false;
    }
    return true;
  }

  // Validate password
  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _passwordError = 'Password is required';
      return false;
    }
    if (password.length < 3) {
      _passwordError = 'Password must be at least 3 characters';
      return false;
    }
    return true;
  }

  // Validate form
  bool validateForm() {
    final isEmailValid = _validateEmail(_email);
    final isPasswordValid = _validatePassword(_password);
    notifyListeners();
    return isEmailValid && isPasswordValid;
  }

  // Login method
  Future<void> login() async {
    // Validate form first
    if (!validateForm()) {
      return;
    }

    // Set loading state
    _loginResponse = ApiResponse.loading();
    notifyListeners();

    try {
      // Create login request
      final request = LoginRequestModel(
        email: _email,
        password: _password,
      );

      // Call API
      final response = await _apiService.login(request);

      // Check response
      if (response.isSuccess) {
        _loginResponse = ApiResponse.success(response);
      } else {
        _loginResponse = ApiResponse.error(
          response.error ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      _loginResponse = ApiResponse.error('An error occurred: $e');
    }

    notifyListeners();
  }

  // Reset login state
  void resetLoginState() {
    _loginResponse = ApiResponse<LoginResponseModel>();
    notifyListeners();
  }
}

