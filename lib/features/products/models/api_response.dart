class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final String? error;

  const ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.error,
  });

  // SUCCESS RESPONSE
  factory ApiResponse.success({required T data, String message = "Success"}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  // ERROR RESPONSE
  factory ApiResponse.failure({
    String message = "Something went wrong",
    String? error,
  }) {
    return ApiResponse(
      success: false,
      data: null,
      message: message,
      error: error,
    );
  }
}
