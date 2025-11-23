import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/users_response_model.dart';

// API Service - Handles all API calls dynamically
class ApiService {
  // Base URL for the API - can be easily changed
  static const String baseUrl = 'https://reqres.in/api';
  
  // API Key for authentication
  static const String apiKey = 'reqres-free-v1';
  
  // Common headers with API key
  static Map<String, String> get defaultHeaders => {
    'x-api-key': apiKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Generic method to make GET requests
  Future<Map<String, dynamic>> getRequest({
    required String endpoint,
    Map<String, String>? queryParameters,
  }) async {
    try {
      // Build URL with query parameters
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      // Make GET request with API key header
      final response = await http.get(
        uri,
        headers: defaultHeaders,
      );

      // Parse response
      if (response.statusCode == 200) {
        try {
          return json.decode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Failed to load data: Status ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network connection error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      // Re-throw if it's already an Exception with a message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  // Generic method to make POST requests
  Future<Map<String, dynamic>> postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      // Merge default headers with custom headers (custom headers take precedence)
      final requestHeaders = {
        ...defaultHeaders,
        ...?headers,
      };

      // Make POST request with API key header
      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: json.encode(body),
      );

      // Parse response
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final decodedResponse = json.decode(response.body) as Map<String, dynamic>;
          return decodedResponse;
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        // Handle error response - reqres.in returns error in 'error' field
        try {
          final errorBody = json.decode(response.body) as Map<String, dynamic>;
          // Extract error message from response
          final errorMessage = errorBody['error'] as String?;
          if (errorMessage != null && errorMessage.isNotEmpty) {
            throw Exception(errorMessage);
          }
          throw Exception('Request failed with status ${response.statusCode}');
        } on FormatException {
          // If JSON parsing fails, return the raw response
          throw Exception('Request failed with status ${response.statusCode}. Response: ${response.body}');
        } catch (e) {
          // If it's already our Exception with the error message, rethrow it
          if (e is Exception && e.toString().startsWith('Exception: ') && 
              !e.toString().contains('Failed to parse') &&
              !e.toString().contains('Request failed')) {
            rethrow;
          }
          // Otherwise, create a new error message
          throw Exception('Request failed with status ${response.statusCode}');
        }
      }
    } on http.ClientException catch (e) {
      throw Exception('Network connection error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      // Re-throw if it's already an Exception with a message
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  // Login API call
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final uri = Uri.parse('$baseUrl/login');
      
      // Debug: Print request details (remove in production)
      print('Making login request to: $uri');
      print('Request body: ${json.encode(request.toJson())}');
      
      // Make POST request directly to have better error control with API key header
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: json.encode(request.toJson()),
      );

      // Debug: Print response details
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Parse response body
      Map<String, dynamic> responseBody;
      try {
        responseBody = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        // If JSON parsing fails, return error with raw response
        return LoginResponseModel(
          error: 'Invalid response format. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }

      // Check status code
      if (response.statusCode == 200) {
        // Success - return token
        return LoginResponseModel.fromJson(responseBody);
      } else if (response.statusCode == 401) {
        // Handle 401 Unauthorized
        final errorMessage = responseBody['error'] as String?;
        
        // If it's the "Missing API key" error (unusual for reqres.in)
        if (errorMessage?.toLowerCase().contains('api key') == true) {
          // This might be a CORS preflight issue or API configuration problem
          // Provide helpful error message
          return LoginResponseModel(
            error: 'API Configuration Error: The test API is returning an unexpected error. '
                'This may be due to CORS restrictions or API changes. '
                'Please try running on mobile/desktop instead of web, or check your network settings.',
          );
        }
        
        // Regular 401 - invalid credentials
        return LoginResponseModel(
          error: errorMessage ?? 'Invalid email or password. Please try again.',
        );
      } else {
        // Other error responses
        final errorMessage = responseBody['error'] as String?;
        return LoginResponseModel(
          error: errorMessage ?? 'Login failed (Status: ${response.statusCode}). Please check your credentials.',
        );
      }
    } on http.ClientException catch (e) {
      // Network error
      print('ClientException: ${e.message}');
      return LoginResponseModel(
        error: 'Network error: ${e.message}. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      // JSON parsing error
      print('FormatException: $e');
      return LoginResponseModel(
        error: 'Invalid response format: $e',
      );
    } catch (e, stackTrace) {
      // Other errors - log full details
      print('Unexpected error: $e');
      print('Stack trace: $stackTrace');
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      // Remove "Missing API key" if it's nested in the error
      if (errorMessage.contains('Missing API key')) {
        errorMessage = 'Network or configuration error. Please check your internet connection and try again.';
      }
      return LoginResponseModel(error: errorMessage);
    }
  }

  // Get users list API call - supports dynamic page parameter
  Future<UsersResponseModel> getUsers({int page = 1}) async {
    try {
      final response = await getRequest(
        endpoint: '/users',
        queryParameters: {'page': page.toString()},
      );
      return UsersResponseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }
}

