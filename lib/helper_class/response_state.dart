class ResponseState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? response;

  const ResponseState({
    this.isLoading = false,
    this.error,
    this.response,
  });

  ResponseState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? response,
  }) {
    return ResponseState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      response: response ?? this.response,
    );
  }
}


class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success({dynamic data, int? statusCode}) {
    return ApiResponse(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({String? message, int? statusCode, dynamic data}) {
    return ApiResponse(
      isSuccess: false,
      message: message ?? 'An error occurred',
      statusCode: statusCode,
      data: data,
    );
  }
}