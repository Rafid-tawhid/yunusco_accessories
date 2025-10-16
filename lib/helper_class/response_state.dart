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