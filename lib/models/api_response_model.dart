// Generic API Response Model - Handles different response states
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  ApiResponse({
    this.data,
    this.error,
    this.isLoading = false,
  });

  // Factory constructor for loading state
  factory ApiResponse.loading() {
    return ApiResponse<T>(isLoading: true);
  }

  // Factory constructor for success state
  factory ApiResponse.success(T data) {
    return ApiResponse<T>(data: data, isLoading: false);
  }

  // Factory constructor for error state
  factory ApiResponse.error(String error) {
    return ApiResponse<T>(error: error, isLoading: false);
  }

  // Check if response is successful
  bool get isSuccess => data != null && error == null && !isLoading;

  // Check if response has error
  bool get hasError => error != null && !isLoading;
}

