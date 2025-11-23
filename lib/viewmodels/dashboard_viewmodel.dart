import 'package:flutter/foundation.dart';
import '../models/api_response_model.dart';
import '../models/users_response_model.dart';
import '../services/api_service.dart';

// Dashboard ViewModel - Manages dashboard screen state and business logic
class DashboardViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  ApiResponse<UsersResponseModel> _usersResponse = ApiResponse<UsersResponseModel>();
  int _currentPage = 1;

  // Getters
  ApiResponse<UsersResponseModel> get usersResponse => _usersResponse;
  int get currentPage => _currentPage;
  bool get isLoading => _usersResponse.isLoading;
  List<dynamic> get users => _usersResponse.data?.users ?? [];
  bool get hasError => _usersResponse.hasError;
  String? get errorMessage => _usersResponse.error;

  // Fetch users from API - supports dynamic page parameter
  Future<void> fetchUsers({int? page}) async {
    // Use provided page or current page
    final pageToFetch = page ?? _currentPage;

    // Set loading state
    _usersResponse = ApiResponse.loading();
    notifyListeners();

    try {
      // Call API with dynamic page parameter
      final response = await _apiService.getUsers(page: pageToFetch);
      _usersResponse = ApiResponse.success(response);
      _currentPage = pageToFetch;
    } catch (e) {
      _usersResponse = ApiResponse.error('Failed to load users: $e');
    }

    notifyListeners();
  }

  // Refresh users list (pull-to-refresh)
  Future<void> refreshUsers() async {
    await fetchUsers(page: 1); // Reset to page 1 on refresh
  }

  // Load next page
  Future<void> loadNextPage() async {
    if (!isLoading && _usersResponse.data != null) {
      final nextPage = _currentPage + 1;
      if (nextPage <= _usersResponse.data!.totalPages) {
        await fetchUsers(page: nextPage);
      }
    }
  }

  // Load previous page
  Future<void> loadPreviousPage() async {
    if (!isLoading && _currentPage > 1) {
      await fetchUsers(page: _currentPage - 1);
    }
  }
}

